# frozen_string_literal: true

module BoardStatusChecker
  def check?(unit)
    return false unless unit.is_a?(King)

    enemy_units(unit) do |enemy|
      return true if allowed_locations(enemy).include?(unit.location)
    end
    false
  end

  def enemy_can_attack_move?(unit, move_location)
    check_location = unit.location
    until check_location == move_location
      check_location = step_location(check_location, move_location)

      enemy_units(unit) do |enemy|
        return true if allowed_locations(enemy).include?(check_location)
      end
    end
    false
  end
end
