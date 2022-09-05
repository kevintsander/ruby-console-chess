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
      next if enemy.off_board?

      enemy_location = enemy.location
      jump_actions = enemy.allowed_actions_deltas[:jump_attack]
      jump_actions && jump_actions.each do |jump_delta|
        jump_location = delta_location(enemy_location, jump_delta)
        return true if jump_location == location
      end
      move_actions = enemy.allowed_actions_deltas[:normal_attack]
      move_actions && move_actions.each do |move_delta|
        move_location = delta_location(enemy_location, move_delta)
        return true if move_location == location && !unit_blocking_move?(enemy, move_location)
      end
    end
    false
  end

  def enemy_unit_at_location?(unit, location)
    unit_at_location = unit_at(location)
    unit_at_location && unit_at_location.player != unit.player
  end

  def unit_blocking_move?(unit, to_location, ignore_unit = nil)
    check_location = unit.location
    until check_location == to_location
      check_location = step_location(check_location, to_location)
      unit_at_location = unit_at(check_location)
      unit_at_location = nil if unit_at_location == ignore_unit # allow a unit to be ignored (for castling)

      # blocking if a unit found in the path, unless it is an unfriendly unit on the final space
      return true if unit_at_location && (unit_at_location.player == unit.player || check_location != to_location)
    end
    false
  end
end
