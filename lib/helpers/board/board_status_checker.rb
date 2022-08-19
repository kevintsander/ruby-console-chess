# frozen_string_literal: true

module BoardStatusChecker
  def check?(unit)
    return false unless unit.is_a?(King)
    return false unless enemy_can_attack_location?(unit, unit.location)

    true
  end

  def checkmate?(king)
    return false unless king.is_a?(King)
    return false if allowed_actions(king)&.any?

    true
  end
end
