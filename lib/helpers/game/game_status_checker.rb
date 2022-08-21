# frozen_string_literal: true

module GameStatusChecker
  def check?(king)
    king.is_a?(King) && board.enemy_can_attack_location?(king, king.location)
  end

  def checkmate?(king)
    king.is_a?(King) & check?(king) & !allowed_actions(king)&.any?
  end
end
