# frozen_string_literal: true

module GameActionChecker
  def allowed_actions(unit)
    unit.allowed_actions_deltas.each_with_object({}) do |(action, deltas), new_hash|
      locations = allowed_action_delta_locations(unit, action, deltas)
      new_hash[action] = locations if locations&.any?
      new_hash
    end
  end

  def valid_standard_move_location?(unit, move_location)
    !board.enemy_unit_at_location?(unit, move_location) && !board.unit_blocking_move?(unit, move_location)
  end

  def valid_move_attack_location?(unit, move_location)
    board.enemy_unit_at_location?(unit, move_location) && !board.unit_blocking_move?(unit, move_location)
  end

  def valid_jump_move_location?(move_location)
    !board.unit_at(move_location)
  end

  def valid_jump_attack_location?(unit, move_location)
    board.enemy_unit_at_location?(unit, move_location)
  end

  def valid_en_passant_location?(unit, move_location)
    return false unless unit.is_a?(Pawn)

    last_move = @game_log.last_move
    return false unless last_move

    last_unit = last_move[:unit]
    last_unit_location = last_unit.location
    units_delta = board.location_delta(unit.location, last_unit_location)
    last_move_delta = board.location_delta(last_move[:last_location], last_unit_location)
    # if last move was a pawn that moved two ranks, and it is in adjacent column, can jump behind other pawn (en passant)
    if last_unit.is_a?(Pawn) &&
       units_delta[1].abs == 1 &&
       last_move_delta[0].abs == 2 &&
       board.file(move_location) == board.file(last_unit_location)
      true
    else
      false
    end
  end

  def valid_initial_double_move_location?(unit, move_location)
    unit.is_a?(Pawn) &&
      !@game_log.unit_actions(unit) &&
      !board.enemy_unit_at_location?(unit, move_location) &&
      !board.unit_blocking_move?(unit, move_location)
  end

  def valid_castle_location?(unit, move_location, castle_action)
    unit_class = unit.class
    return false unless [Rook, King].include?(unit_class)

    other_unit_action = other_castle_unit_action(unit, castle_action)
    return false unless other_unit_action

    other_unit = other_unit_action[:unit]
    other_unit_move_location = other_unit_action[:location]

    # cannot be blocked or have an enemy on the move space
    return false if board.enemy_unit_at_location?(unit,
                                                  move_location) || board.unit_blocking_move?(unit, move_location,
                                                                                              other_unit)
    return false if board.enemy_unit_at_location?(other_unit,
                                                  other_unit_move_location) || board.unit_blocking_move?(other_unit,
                                                                                                         other_unit_move_location, unit)

    # neither unit can have moved
    return false if [unit, other_unit].any? { |castle_unit| @game_log.unit_actions(castle_unit) }

    # king cannot pass over space that could be attacked
    king = unit_class == King ? unit : other_unit
    king_move_location = unit_class == King ? move_location : other_unit_move_location
    return false if board.enemy_can_attack_move?(king, king_move_location)

    true
  end

  def valid_action_location?(unit, move_location, action)
    # King cannot place self in check
    return false if unit.is_a?(King) && board.enemy_can_attack_location?(unit, move_location)

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

  def other_castle_unit_action(unit, castle_action)
    unit_class = unit.class
    return false unless [Rook, King].include?(unit_class)

    if unit_class == Rook
      other_unit = friendly_king(unit)
    elsif unit_class == King
      other_unit = castle_rook(unit, castle_action)
    end
    return unless other_unit

    other_location = unit_castle_action_location(other_unit, castle_action)
    { unit: other_unit, location: other_location }
  end

  def unit_castle_action_location(unit, castle_action)
    allowed_deltas = unit.allowed_actions_deltas[castle_action].first
    board.delta_location(unit.location, allowed_deltas)
  end

  def friendly_king(unit)
    board.friendly_units(unit).select do |friendly|
      friendly.is_a?(King)
    end.first
  end

  def castle_rook(king, castle_action)
    board.friendly_units(king).select do |friendly|
      friendly.is_a?(Rook) &&
        case castle_action
        when :kingside_castle
          friendly.kingside_start?
        when :queenside_castle
          friendly.queenside_start?
        end
    end.first
  end

  def allowed_action_delta_locations(unit, action, deltas)
    deltas.reduce([]) do |locations, delta|
      location = board.delta_location(unit.location, delta)
      next locations unless location # out of bounds?
      next locations unless valid_action_location?(unit, location, action)

      locations << location
    end
  end
end
