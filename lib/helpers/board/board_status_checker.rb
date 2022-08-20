# frozen_string_literal: true

module BoardStatusChecker
  def check?(king)
    king.is_a?(King) && enemy_can_attack_location?(king, king.location)
  end

  def checkmate?(king)
    king.is_a?(King) & check?(king) & !allowed_actions(king)&.any?
  end

  def stalemate?(king)
    king.is_a?(King) & !check?(king) & !allowed_actions(king)&.any?
  end
end
