# frozen_string_literal: true

module BoardStatusChecker
  def check?(unit)
    return false unless unit.is_a?(King)

    enemy_units(unit) do |enemy|
      return true if allowed_locations(enemy).include?(unit.location)
    end
    false
  end
end
