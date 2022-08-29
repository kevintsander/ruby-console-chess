# frozen_string_literal: true

# Represents a chess move
class ActionCommand
  attr_reader :board, :unit, :location, :action, :captured_unit, :from_location
  attr_accessor :promoted_unit_class

  def initialize(board, unit, location)
    @board = board
    @unit = unit
    @location = location
    @from_location = nil
    @captured_unit = nil
    @promoted_unit_class = nil
    @promoted_unit = nil
  end

  def ==(other)
    other.class == self.class && other.board == board && other.unit == unit && other.location == location
  end

  def perform_action
    @from_location = unit.location
    perform_moves
    do_promotion if @promoted_unit_class
  end

  def do_promotion
    unit.promote
    @promoted_unit = @promoted_unit_class.new(@location, unit.player)
    board.add_unit(@promoted_unit)
  end

  def display_name
    DISPLAY_NAME
  end
end
