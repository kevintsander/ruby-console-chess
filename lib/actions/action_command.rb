# frozen_string_literal: true

# Represents a chess move
class ActionCommand
  attr_reader :board, :unit, :location, :action, :captured_unit, :from_location

  def initialize(board, unit, location)
    @board = board
    @unit = unit
    @location = location
    @from_location = nil
    @captured_unit = nil
  end

  def ==(other)
    other.class == self.class && other.board == board && other.unit == unit && other.location == location
  end

  def location_notation
    location
  end

  def perform_action
    @from_location = unit.location
    perform_moves
  end
end
