# frozen_string_literal: true

# Contains methods for checking possible board moves
module BoardMoveChecker
  def can_move_standard?(unit, move_location)
    !unit.enemy?(unit_at(move_location)) && !unit_blocking_move?(unit, move_location)
  end

  def can_move_attack?(unit, move_location)
    unit.enemy?(unit_at(move_location)) && !unit_blocking_move?(unit, move_location)
  end

  def can_jump_standard?(move_location)
    !unit_at(move_location)
  end

  def can_jump_attack?(unit, move_location)
    unit.enemy?(unit_at(move_location))
  end

  def can_en_passant?(unit, move_location)
    return false unless unit.is_a?(Pawn)

    last_move = @game_log.last_move
    return false unless last_move

    last_unit = last_move[:unit]
    last_unit_location = last_unit.location
    units_delta = location_delta(unit.location, last_unit_location)
    last_move_delta = location_delta(last_move[:last_location], last_unit_location)
    # if last move was a pawn that moved two ranks, and it is in adjacent column, can jump behind other pawn (en passant)
    if last_unit.is_a?(Pawn) &&
       units_delta[1].abs == 1 &&
       last_move_delta[0].abs == 2 &&
       file(move_location) == file(last_unit_location)
      true
    else
      false
    end
  end

  def can_move_double?(unit, move_location)
    unit.is_a?(Pawn) && !@game_log.unit_actions(unit) && !unit_blocking_move?(unit, move_location)
  end

  def can_perform_action?(unit, move_location, action)
    case action
    when :move_standard
      can_move_standard?(unit, move_location)
    when :move_double
      can_move_double?(unit, move_location)
    when :move_attack
      can_move_attack?(unit, move_location)
    when :jump_standard
      can_jump_standard?(move_location)
    when :jump_attack
      can_jump_attack?(unit, move_location)
    when :en_passant
      can_en_passant?(unit, move_location)
    when :kingside_castle
      false
    when :queenside_castle
      false
    end
  end
end
