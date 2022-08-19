# frozen_string_literal: true

# Contains methods for checking possible board moves
module BoardMoveChecker
  def enemy_unit_at_location?(_player, location)
    unit_at(location)&.player != playergits
  end

  def valid_standard_move_location?(unit, move_location)
    !unit.enemy?(unit_at(move_location)) && !unit_blocking_move?(unit, move_location)
  end

  def valid_move_attack_location?(unit, move_location)
    unit.enemy?(unit_at(move_location)) && !unit_blocking_move?(unit, move_location)
  end

  def valid_jump_move_location?(move_location)
    !unit_at(move_location)
  end

  def valid_jump_attack_location?(unit, move_location)
    unit.enemy?(unit_at(move_location))
  end

  def valid_en_passant_location?(unit, move_location)
    return false unless unit.is_a?(Pawn)

    last_move = @game_log.last_move
    return false unless last_move

    last_unit = last_move[:unit]
    last_unit_location = last_unit.location
    units_delta = location_delta(unit.location, last_unit_location)
    last_move_delta = location_delta(last_move[:last_location], last_unit_location)
    # if last move was a pawn that moved two ranks, and it is in adjacent column, can jump behind other pawn (en passant)
    if last_unit.is_a?(Pawn) &&
       units_delta[1].abs == 1 &&
       last_move_delta[0].abs == 2 &&
       file(move_location) == file(last_unit_location)
      true
    else
      false
    end
  end

  def valid_initial_double_move_location?(unit, move_location)
    unit.is_a?(Pawn) &&
      !@game_log.unit_actions(unit) &&
      !unit_blocking_move?(unit, move_location) &&
      !unit.enemy?(unit_at(move_location))
  end

  def valid_castle_location?(unit, move_location, castle_action)
    unit_class = unit.class
    return false unless [Rook, King].include?(unit_class)

    if unit_class == Rook
      rook = unit
      rook_move_location = move_location
    elsif unit_class == King
      king = unit
      king_move_location = move_location
    end

    rook ||= get_castle_rook(king, castle_action)
    king ||= get_friendly_king(rook)
    return unless king && rook

    rook_move_location ||= get_unit_castle_action_location(rook, castle_action)
    king_move_location ||= get_unit_castle_action_location(king, castle_action)
    # cannot be blocked or have an enemy on the move space
    return false if rook.enemy?(unit_at(rook_move_location)) || unit_blocking_move?(rook, rook_move_location, king)
    return false if king.enemy?(unit_at(king_move_location)) || unit_blocking_move?(king, king_move_location, rook)

    # neither king nor rook can have moved
    return false if [rook, king].any? { |castle_unit| @game_log.unit_actions(castle_unit) }
    # king cannot pass over space that could be attacked
    return false if enemy_can_attack_move?(king, king_move_location)

    true
  end

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
      enemy_location = enemy.location
      jump_actions = enemy.allowed_actions_deltas[:jump_standard]
      jump_actions && jump_actions.each do |jump_delta|
        jump_location = delta_location(enemy_location, jump_delta)
        return true if jump_location == location
      end
      move_actions = enemy.allowed_actions_deltas[:move_standard]
      move_actions && move_actions.each do |move_delta|
        move_location = delta_location(enemy_location, move_delta)
        return true if move_location == location && !unit_blocking_move?(enemy, move_location)
      end
    end
    false
  end

  def valid_action_location?(unit, move_location, action)
    # King cannot place self in check
    return false if unit.is_a?(King) && enemy_can_attack_location?(unit, move_location)

    case action
    when :move_standard
      valid_standard_move_location?(unit, move_location)
    when :initial_double
      valid_initial_double_move_location?(unit, move_location)
    when :move_attack
      valid_move_attack_location?(unit, move_location)
    when :jump_standard
      valid_jump_move_location?(move_location)
    when :jump_attack
      valid_jump_attack_location?(unit, move_location)
    when :en_passant
      valid_en_passant_location?(unit, move_location)
    when :kingside_castle, :queenside_castle
      valid_castle_location?(unit, move_location, action)
    end
  end

  private

  def get_castle_rook(king, castle_action)
    friendly_units(king).select do |friendly|
      friendly.is_a?(Rook) &&
        case castle_action
        when :kingside_castle
          friendly.kingside_start?
        when :queenside_castle
          friendly.queenside_start?
        end
    end.first
  end

  def get_unit_castle_action_location(unit, castle_action)
    allowed_deltas = unit.allowed_actions_deltas[castle_action].first
    delta_location(unit.location, allowed_deltas)
  end

  def get_friendly_king(unit)
    friendly_units(unit).select do |friendly|
      friendly.is_a?(King)
    end.first
  end
end
