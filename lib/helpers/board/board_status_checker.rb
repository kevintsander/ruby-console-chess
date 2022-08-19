# frozen_string_literal: true

module BoardStatusChecker
  def check?(unit)
    return false unless unit.is_a?(King)
    return true if enemy_can_attack_location?(unit, unit.location)

    false
  end
end
