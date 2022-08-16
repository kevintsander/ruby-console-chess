# frozen_string_literal: true

require './lib/unit_symbol_mapper'

# Represents an abstract chess unit
class Unit
  include UnitSymbolMapper

  attr_reader :location, :player, :id, :symbol

  def initialize(location, player, id = location)
    @location = location
    @player = player
    @id = id
    @symbol = get_color_symbol(player.color)
  end

  def captured?
    !location
  end

  def capture
    @location = nil
  end

  def move(location)
    @location = location
  end
end
