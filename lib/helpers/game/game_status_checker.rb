# frozen_string_literal: true

module GameStatusChecker
  def check?(king)
    king.is_a?(King) && board.enemy_can_attack_location?(king, king.location)
  end

  def checkmate?(king)
    king.is_a?(King) && check?(king) && !friendly_units_have_moves(king) && allowed_actions(king).none?
  end

  def friendly_units_have_moves(unit)
    board.friendly_units(unit).any? do |friendly|
      allowed_actions = allowed_actions(friendly)
      allowed_actions&.any?
    end
  end

  def any_check?
    board.units.any? { |unit| unit.is_a?(King) && check?(unit) }
  end

  def any_checkmate?
    board.units.any? { |unit| unit.is_a?(King) && checkmate?(unit) }
  end

  def stalemate?(king)
    king.is_a?(King) && !check?(king) && !friendly_units_have_moves(king) && allowed_actions(king).none?
  end

  def any_stalemate?
    board.units.any? { |unit| unit.is_a?(King) && stalemate?(unit) }
  end

  def fifty_turn_draw?
    turn > 50
  end
end
