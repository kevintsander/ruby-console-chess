# frozen_string_literal: true

# Contains methods for checking possible board moves
module BoardMoveChecker
  def can_move_standard?(unit, move_location)
    !unit.enemy?(unit_at(move_location)) && !unit_blocking_move?(unit, move_location)
  end

  def can_move_attack?(unit, move_location)
    unit.enemy?(unit_at(move_location)) && !unit_blocking_move?(unit, move_location)
  end

  def can_jump_standard?(move_location)
    !unit_at(move_location)
  end

  def can_jump_attack?(unit, move_location)
    unit.enemy?(unit_at(move_location))
  end

  def can_en_passant?(unit, move_location)
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

  def can_move_initial_double?(unit, move_location)
    unit.is_a?(Pawn) &&
      !@game_log.unit_actions(unit) &&
      !unit_blocking_move?(unit, move_location) &&
      !unit.enemy?(unit_at(move_location))
  end

  def king_can_kingside_castle?(unit, move_location)
    return false unless unit.is_a(King)
    return false if check?(unit)
    return false if @game_log.unit_actions(unit)

    rook = friendly_units(unit).select { |friendly| friendly.is_a(Rook) && friendly.kingside_start? }
    return false unless rook_can_kingside_castle?(rook)

    return false if unit_blocking_move?(unit, move_location, rook)
    return false if enemy_can_attack_move?(unit, move_location)
    return false if unit.enemy?(unit_at(move_location))

    true
  end

  def king_can_queenside_castle?(unit, move_location)
    return false unless unit.is_a(King)
    return false if check?(unit)
    return false if @game_log.unit_actions(unit)

    rook = friendly_units(unit).select { |friendly| friendly.is_a(Rook) && friendly.queenside_start? }
    return false unless rook_can_queenside_castle?(rook)

    return false if unit_blocking_move?(unit, move_location, rook)
    return false if enemy_can_attack_move?(unit, move_location)
    return false if unit.enemy?(unit_at(move_location))

    true
  end

  def rook_can_kingside_castle?(unit, move_location)
    return false unless unit.is_a(Rook) && unit.kingside_start?
    return false if @game_log.unit_actions(unit)

    rook = friendly_units(unit).select { |friendly| friendly.is_a(King) }
    return false unless king_can_kingside_castle?(king)

    return false if unit_blocking_move?(unit, move_location, rook)
    return false if unit.enemy?(unit_at(move_location))

    true
  end

  def rook_can_queenside_castle?(unit, move_location)
    return false unless unit.is_a(Rook) && unit.queenside_start?
    return false if @game_log.unit_actions(unit)

    rook = friendly_units(unit).select { |friendly| friendly.is_a(King) }
    return false unless king_can_queenside_castle?(king)

    return false if unit_blocking_move?(unit, move_location, rook)
    return false if unit.enemy?(unit_at(move_location))

    true
  end

  def can_kingside_castle?(unit, move_location)
    case unit.class
    when Rook
      rook_can_kingside_castle?(unit, move_location)
    when King
      king_can_kingside_castle?(unit, move_location)
    end
  end

  def can_queenside_castle?(unit, move_location)
    case unit.class
    when Rook
      rook_can_queenside_castle?(unit, move_location)
      king_can_kingside_castle?(unit, move_location)
    end
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

  def can_perform_action?(unit, move_location, action)
    case action
    when :move_standard
      can_move_standard?(unit, move_location)
    when :initial_double
      can_move_initial_double?(unit, move_location)
    when :move_attack
      can_move_attack?(unit, move_location)
    when :jump_standard
      can_jump_standard?(move_location)
    when :jump_attack
      can_jump_attack?(unit, move_location)
    when :en_passant
      can_en_passant?(unit, move_location)
    when :kingside_castle
      can_kingside_castle?(unit, move_location)
    when :queenside_castle
      can_queenside_castle?(unit, move_location)
    end
  end
end
