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
