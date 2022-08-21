# frozen_string_literal: true

require './lib/actions/move'

module GameActionChecker
  def valid_standard_move_location?(unit, move_location, _action)
    !board.enemy_unit_at_location?(unit, move_location) && !board.unit_blocking_move?(unit, move_location)
  end

  def valid_move_attack_location?(unit, move_location, _action)
    board.enemy_unit_at_location?(unit, move_location) && !board.unit_blocking_move?(unit, move_location)
  end

  def valid_jump_move_location?(_unit, move_location, _action)
    !board.unit_at(move_location)
  end

  def valid_jump_attack_location?(unit, move_location, _action)
    board.enemy_unit_at_location?(unit, move_location)
  end

  def valid_en_passant_location?(unit, move_location, _action)
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

  def valid_initial_double_move_location?(unit, move_location, _action)
    unit.is_a?(Pawn) &&
      !@game_log.unit_actions(unit) &&
      !board.enemy_unit_at_location?(unit, move_location) &&
      !board.unit_blocking_move?(unit, move_location)
  end

  def valid_castle_location?(unit, move_location, castle_action)
    unit_class = unit.class
    return false unless [Rook, King].include?(unit_class)

    other_unit_action = board.other_castle_unit_action(unit, castle_action)
    return false unless other_unit_action

    other_unit = other_unit_action[:unit]
    other_unit_move_location = other_unit_action[:location]

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
    unit.allowed_actions_deltas.reduce([]) do |all_allowed_actions, (action, deltas)|
      action_map = actions[action]
      deltas.each_with_object(all_allowed_actions) do |delta, action_allowed_actions|
        move_location = board.delta_location(unit.location, delta)
        if action_map[:validator].call(unit, move_location, action)
          action_allowed_actions << action_map[:class].new(board, unit, move_location)
        end
      end
    end
  end
end
