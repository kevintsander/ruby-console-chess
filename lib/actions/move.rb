# frozen_string_literal: true

# Represents a chess move
class MoveLogCommand
  attr_reader :board, :unit, :location, :action, :captured_unit

  def initialize(unit, location)
    @unit = unit
    @location = location
    @last_location = unit.location
    @captured_unit = nil
  end
end

class NormalMoveCommand
  def perform_action(_turn, _board, _game_log)
    unit.move(location)
    # game_log.log_action(turn, :move, unit, location, last_location)
  end
end

class AttackMoveCommand
  def perform_action(_turn, board, _game_log)
    captured unit = board.unit_at(location)
    unit.move(location)
    captured_unit.capture
    @captured_unit = captured_unit
    # game_log.log_action(turn, :attack, unit, location, last_location, captured_unit)
  end
end

class EnPassantCommand
  def perform_action(_turn, board, _game_log)
    captured_unit_from_location = board.delta_location(location, [-1 * 0.send(unit.forward), 0])
    captured_unit = board.unit_at(captured_unit_from_location)
    unit.move(location)
    captured_unit.capture
    @captured_unit = captured_unit
    # game_log.log_action(turn, :en_passant, unit, location, last_location, captured_unit)
  end
end

class KingsideCastleCommand
  def perform_action(turn, board, game_log)
    other_unit_action = other_castle_unit_action(unit, :kingside_castle)

    unit.move(location)
    other_unit_action.perform_action(turn, board, game_log)
  end
end

class QueensideCastleCommand
  def perform_action(turn, board, game_log)
    other_unit_action = other_castle_unit_action(unit, :queenside_castle)

    unit.move(location)
    other_unit_action.perform_action(turn, board, game_log)
  end
end
