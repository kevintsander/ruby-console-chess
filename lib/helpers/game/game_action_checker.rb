# frozen_string_literal: true

require './lib/actions/normal_move_command'
require './lib/actions/attack_move_command'
require './lib/actions/en_passant_command'
require './lib/actions/kingside_castle_command'
require './lib/actions/queenside_castle_command'

module GameActionChecker
  attr_writer :test_game

  @test_game = false

  def actions_map
    { normal_move: { class: NormalMoveCommand, validator: method(:valid_standard_move_location?) },
      jump_move: { class: NormalMoveCommand, validator: method(:valid_jump_move_location?) },
      normal_attack: { class: AttackMoveCommand, validator: method(:valid_move_attack_location?) },
      jump_attack: { class: AttackMoveCommand, validator: method(:valid_jump_attack_location?) },
      initial_double: { class: NormalMoveCommand, validator: method(:valid_initial_double_move_location?) },
      en_passant: { class: EnPassantCommand, validator: method(:valid_en_passant_location?) },
      queenside_castle: { class: QueensideCastleCommand, validator: method(:valid_castle_location?) },
      kingside_castle: { class: KingsideCastleCommand, validator: method(:valid_castle_location?) } }
  end

  def valid_standard_move_location?(move_action)
    unit = move_action.unit
    move_location = move_action.location
    !board.enemy_unit_at_location?(unit,
                                   move_location) && !board.unit_blocking_move?(unit,
                                                                                move_location)
  end

  def valid_move_attack_location?(attack_action)
    unit = attack_action.unit
    move_location = attack_action.location
    board.enemy_unit_at_location?(unit,
                                  move_location) && !board.unit_blocking_move?(unit,
                                                                               move_location)
  end

  def valid_jump_move_location?(jump_action)
    move_location = jump_action.location
    !board.unit_at(move_location)
  end

  def valid_jump_attack_location?(jump_attack_action)
    unit = jump_attack_action.unit
    move_location = jump_attack_action.location
    board.enemy_unit_at_location?(unit, move_location)
  end

  def valid_en_passant_location?(en_passant_action)
    unit = en_passant_action.unit

    return false unless unit.is_a?(Pawn)

    return false unless last_action

    move_location = en_passant_action.location
    last_unit_location = last_unit.location
    units_delta = board.location_delta(unit.location, last_unit_location)
    last_move_delta = board.location_delta(last_action.from_location, last_unit_location)
    # if last move was a pawn that moved two ranks, and it is in adjacent column, can jump behind other pawn (en passant)
    if last_unit.is_a?(Pawn) &&
       units_delta[1].abs == 1 &&
       units_delta[0].abs.zero? &&
       last_move_delta[0].abs == 2 &&
       board.file(move_location) == board.file(last_unit_location)
      true
    else
      false
    end
  end

  def valid_initial_double_move_location?(action)
    unit = action.unit
    move_location = action.location
    unit.is_a?(Pawn) &&
      !unit_actions(action.unit)&.any? &&
      !board.enemy_unit_at_location?(unit, move_location) &&
      !board.unit_blocking_move?(unit, move_location)
  end

  def valid_castle_location?(action)
    unit = action.unit
    unit_class = unit.class
    return false unless [Rook, King].include?(unit_class)

    castle_type = if action.is_a?(KingsideCastleCommand)
                    :kingside_castle
                  elsif action.is_a?(QueensideCastleCommand)
                    :queenside_castle
                  end

    other_unit_hash = board.other_castle_unit_move_hash(unit, castle_type)
    return false unless other_unit_hash&.any?

    move_location = action.location
    other_unit = other_unit_hash[:unit]
    other_unit_move_location = other_unit_hash[:move_location]

    # cannot be blocked or have an enemy on the move space
    return false if board.enemy_unit_at_location?(unit, move_location) ||
                    board.unit_blocking_move?(unit, move_location, other_unit)
    return false if board.enemy_unit_at_location?(other_unit, other_unit_move_location) ||
                    board.unit_blocking_move?(other_unit, other_unit_move_location, unit)

    # neither unit can have moved
    return false if [unit, other_unit].any? { |castle_unit| unit_actions(castle_unit)&.any? }

    # king cannot pass over space that could be attacked
    king = unit_class == King ? unit : other_unit
    king_move_location = unit_class == King ? move_location : other_unit_move_location
    return false if board.enemy_can_attack_move?(king, king_move_location)

    true
  end

  def allowed_actions(unit)
    allowed = []
    # sort kingside and queenside castle first so that their moves trump standard moves
    sorted_allowed_action_deltas = unit.allowed_actions_deltas.sort_by do |action|
      [KingsideCastleCommand, QueensideCastleCommand].include?(action) ? 0 : 1
    end

    sorted_allowed_action_deltas.each do |(action_type, deltas)|
      action_map = actions_map[action_type]
      deltas.each do |delta|
        move_location = board.delta_location(unit.location, delta)
        # action locations must be unique (cannot kingside/queenside castle and standard move to same location)
        next unless move_location && !allowed.detect { |action| action.location == move_location }

        action_class = action_map[:class]
        action = action_class.new(board, unit, move_location)

        next unless action_map[:validator].call(action)
        next if action_would_cause_check?(action)

        allowed << action
      end
    end
    allowed
  end

  def units_with_actions(player)
    board.units.select do |unit|
      allowed_actions = allowed_actions(unit)
      unit.player == player && allowed_actions && allowed_actions.any?
    end
  end

  def action_would_cause_check?(action)
    if @test_game
      return false
    end # for test game, do not perform this check because we need to test if moves would cause check

    # create a test game with the king off board (to )
    new_test_game = get_test_game_copy
    new_test_game_units = new_test_game.board.units
    test_unit = new_test_game_units.detect { |test_unit| test_unit.location == action.unit.location }
    test_friendly_king = new_test_game_units.detect do |test_unit|
      test_unit.is_a?(King) && test_unit.player == action.unit.player
    end

    # get a copy of the action to test
    test_action = action.class.new(new_test_game.board, test_unit, action.location)
    test_action.perform_action

    new_test_game.check?(test_friendly_king)
  end

  def can_promote_unit?(unit)
    return false unless unit.is_a?(Pawn)

    forward_delta = [0.send(unit.forward, 1), 0]
    test_forward_location = board.delta_location(unit.location, forward_delta)

    test_forward_location ? false : true
  end

  private

  # creates a test game
  def get_test_game_copy
    test = self.class.new(players)
    test.test_game = true
    test_board_units = board.units.map { |unit| unit.dup }
    test_game_log = game_log.map { |log_item| log_item[:action].dup }
    test.instance_variable_set(:@game_log, test_game_log)
    test.board.clear_units.add_unit(*test_board_units)
    test
  end
end
