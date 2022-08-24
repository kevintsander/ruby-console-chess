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
    @promoted_unit_class = nil
    @promoted_unit = nil
  end

  def ==(other)
    other.class == self.class && other.board == board && other.unit == unit && other.location == location
  end

  def perform_action
    perform_moves
    do_promotion
  end

  def do_promotion
    @promoted_unit = @promoted_unit_class.new(unit.location, unit.player) if @promoted_unit_class
  end
end
