# frozen_string_literal: true

require './lib/unit_symbol_mapper'
require './lib/location_rank_and_file'

# Represents an abstract chess unit
class Unit
  include UnitSymbolMapper
  include LocationRankAndFile

  attr_reader :location, :player, :id, :symbol, :allowed_actions_deltas, :initial_rank

  def initialize(location, player, id = location)
    @location = location
    @player = player
    @id = id
    @symbol = get_color_symbol(player.color)
    @initial_rank = rank(location)
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

  def enemy?(other_unit)
    player != other_unit.player
  end

  # Gets forward location based on initial location, to be used by constructor
  def forward
    case player.color
    when :white
      :+
    when :black
      :-
    end
  end
end
