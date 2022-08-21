# frozen_string_literal: true

# Represents a chess move
class ActionCommand
  attr_reader :board, :unit, :location, :action, :captured_unit

  def initialize(board, unit, location)
    @board = board
    @unit = unit
    @location = location
    @last_location = unit.location
    @captured_unit = nil
  end
end

class NormalMoveCommand < ActionCommand
  def perform_action
    unit.move(location)
    # game_log.log_action(turn, :move, unit, location, last_location)
  end
end

class AttackMoveCommand < ActionCommand
  def perform_action
    captured_unit = board.unit_at(location)
    unit.move(location)
    captured_unit.capture
    @captured_unit = captured_unit
    # game_log.log_action(turn, :attack, unit, location, last_location, captured_unit)
  end
end

class EnPassantCommand < ActionCommand
  def perform_action
    captured_unit_from_location = board.delta_location(location, [-1 * 0.send(unit.forward), 0])
    captured_unit = board.unit_at(captured_unit_from_location)
    unit.move(location)
    captured_unit.capture
    @captured_unit = captured_unit
    # game_log.log_action(turn, :en_passant, unit, location, last_location, captured_unit)
  end
end

class KingsideCastleCommand < ActionCommand
  def perform_action
    other_unit_action = other_castle_unit_action(unit, :kingside_castle)

    unit.move(location)
    other_unit_action.perform_action
  end
end

class QueensideCastleCommand < ActionCommand
  def perform_action
    other_unit_action = other_castle_unit_action(unit, :queenside_castle)

    unit.move(location)
    other_unit_action.perform_action
  end
end
