# frozen_string_literal: true

require './lib/unit_symbol_mapper'
require './lib/location_rank_and_file'

# Represents an abstract chess unit
class Unit
  include UnitSymbolMapper
  include LocationRankAndFile

  attr_reader :location, :player, :id, :symbol, :forward, :allowed_move_deltas

  def initialize(location, player, id = location)
    @location = location
    @player = player
    @id = id
    @symbol = get_color_symbol(player.color)
    @forward = initial_forward
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

  private

  # Gets forward location based on initial location, to be used by constructor
  def initial_forward
    case rank(@location)
    when '2'
      :+
    when '7'
      :-
    end
  end
end
