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

  def can_perform_action?(unit, move_location, action)
    case action
    when :move_standard
      can_move_standard?(unit, move_location)
    when :move_attack
      can_move_attack?(unit, move_location)
    when :jump_standard
      can_jump_standard?(move_location)
    when :jump_attack
      can_jump_attack?(unit, move_location)
    when :en_passant
      false
    when :kingside_castle
      false
    when :queenside_castle
      false
    end
  end
end
