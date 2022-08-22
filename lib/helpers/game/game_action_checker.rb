# frozen_string_literal: true

require './lib/actions/normal_move_command'
require './lib/actions/attack_move_command'
require './lib/actions/en_passant_command'
require './lib/actions/kingside_castle_command'
require './lib/actions/queenside_castle_command'

module GameActionChecker
  attr_writer :test_game

  @test_game = false

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
    move_location = en_passant_action.location

    return false unless unit.is_a?(Pawn)

    last_move = @game_log.last_move
    return false unless last_move

    last_unit = last_move[:unit]
    last_unit_location = last_unit.location
    units_delta = board.location_delta(unit.location, last_unit_location)
    last_move_delta = board.location_delta(last_move[:last_location], last_unit_location)
    # if last move was a pawn that moved two ranks, and it is in adjacent column, can jump behind other pawn (en passant)
    if last_unit.is_a?(Pawn) &&
       units_delta[1].abs == 1 &&
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
      !@game_log.unit_actions(action.unit) &&
      !board.enemy_unit_at_location?(unit, move_location) &&
      !board.unit_blocking_move?(unit, move_location)
  end

  def valid_castle_location?(action)
    unit = action.unit
    unit_class = unit.class
    return false unless [Rook, King].include?(unit_class)

    castle_action_class = action.class
    other_unit = other_castle_unit(unit, castle_action_class)
    return false unless other_unit

    move_location = action.location
    other_unit_move_location = castle_unit_move_location(other_unit, castle_action_class)

    # cannot be blocked or have an enemy on the move space
    return false if board.enemy_unit_at_location?(unit,
                                                  move_location) || board.unit_blocking_move?(unit, move_location,
                                                                                              other_unit)
    return false if board.enemy_unit_at_location?(other_unit,
                                                  other_unit_move_location) || board.unit_blocking_move?(other_unit,
                                                                                                         other_unit_move_location, unit)

    # neither unit can have moved
    return false if [unit, other_unit].any? { |castle_unit| @game_log.unit_actions(castle_unit) }

    # king cannot pass over space that could be attacked
    king = unit_class == King ? unit : other_unit
    king_move_location = unit_class == King ? move_location : other_unit_move_location
    return false if board.enemy_can_attack_move?(king, king_move_location)

    true
  end

  def actions
    { move_standard: { class: NormalMoveCommand, validator: method(:valid_standard_move_location?) },
      jump_standard: { class: NormalMoveCommand, validator: method(:valid_jump_move_location?) },
      move_attack: { class: AttackMoveCommand, validator: method(:valid_move_attack_location?) },
      jump_attack: { class: AttackMoveCommand, validator: method(:valid_jump_attack_location?) },
      initial_double: { class: NormalMoveCommand,
                        validator: method(:valid_initial_double_move_location?) },
      en_passant: { class: EnPassantCommand, validator: method(:valid_en_passant_location?) },
      queenside_castle: { class: QueensideCastleCommand, validator: method(:valid_castle_location?) },
      kingside_castle: { class: KingsideCastleCommand, validator: method(:valid_castle_location?) } }
  end

  def allowed_actions(unit)
    allowed = []
    unit.allowed_actions_deltas.each do |(action_type, deltas)|
      action_map = actions[action_type]
      deltas.each do |delta|
        move_location = board.delta_location(unit.location, delta)
        next unless move_location

        action_class = action_map[:class]
        action = action_class.new(board, unit, move_location)

        next unless action_map[:validator].call(action)
        next if action_would_cause_check?(action)

        allowed << action
      end
    end
    allowed
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

  def other_castle_unit(unit, castle_action_class)
    if unit.is_a?(Rook)
      friendly_king(unit)
    elsif unit.is_a?(King)
      castle_rook(unit, castle_action_class)
    end
  end

  def other_castle_unit_action(unit, castle_action_class)
    other_unit = other_castle_unit(unit, castle_action_class)
    other_unit.allowed_actions.detect { |action| action.is_a?(castle_action_class) }
  end

  private

  def friendly_king(unit)
    board.friendly_units(unit).detect do |friendly|
      friendly.is_a?(King)
    end
  end

  def castle_rook(king, castle_action_class)
    board.friendly_units(king).detect do |friendly|
      friendly.is_a?(Rook) &&
        if castle_action_class == KingsideCastleCommand
          friendly.kingside_start?
        elsif castle_action_class == QueensideCastleCommand
          friendly.queenside_start?
        end
    end
  end

  def castle_unit_move_location(unit, castle_action_class)
    delta = if castle_action_class == KingsideCastleCommand
              unit.allowed_actions_deltas[:kingside_castle].first
            elsif castle_action_class == QueensideCastleCommand
              unit.allowed_actions_deltas[:queenside_castle].first
            end
    board.delta_location(unit.location, delta)
  end

  # creates a test game
  def get_test_game_copy
    test = self.class.new(players)
    test.test_game = true
    test_board_units = board.units.map { |unit| unit.dup }
    test_game_log = GameLog.new
    test_game_log_log = game_log.log.dup
    test_game_log.instance_variable_set(:@log, test_game_log_log)
    test_game_log_log.each do |log_item|
      log_item[:unit] = test_board_units.select { |unit| unit.location == log_item[:unit].loation }
    end
    test.board.clear_units.add_unit(*test_board_units)
    test
  end
end
