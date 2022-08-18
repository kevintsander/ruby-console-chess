# frozen_string_literal: true

require './lib/unit_symbol_mapper'
require './lib/location_rank_and_file'

# Represents an abstract chess unit
class Unit
  include UnitSymbolMapper
  include LocationRankAndFile

  attr_reader :location, :player, :id, :symbol, :allowed_actions_deltas

  def initialize(location, player, id = location)
    @location = location
    @player = player
    @id = id
    @symbol = get_color_symbol(player.color)
    @initial_location = location
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
    other_unit && player != other_unit.player
  end

  def kingside_start?
    %w[a b c d].include?(@initial_location[0])
  end

  def queenside_start?
    %w[e f g h].include?(@initial_location[0])
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
