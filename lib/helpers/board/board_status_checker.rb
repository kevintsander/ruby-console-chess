# frozen_string_literal: true

module BoardStatusChecker
  def enemy_can_attack_move?(unit, move_location)
    check_location = unit.location
    until check_location == move_location
      check_location = step_location(check_location, move_location)
      return true if enemy_can_attack_location?(unit, check_location)
    end
    false
  end

  def enemy_can_attack_location?(unit, location)
    enemy_units(unit) do |enemy|
      return if enemy.captured?

      enemy_location = enemy.location
      jump_actions = enemy.allowed_actions_deltas[:jump_move]
      jump_actions && jump_actions.each do |jump_delta|
        jump_location = delta_location(enemy_location, jump_delta)
        return true if jump_location == location
      end
      move_actions = enemy.allowed_actions_deltas[:normal_move]
      move_actions && move_actions.each do |move_delta|
        move_location = delta_location(enemy_location, move_delta)
        return true if move_location == location && !unit_blocking_move?(enemy, move_location)
      end
    end
    false
  end
end
