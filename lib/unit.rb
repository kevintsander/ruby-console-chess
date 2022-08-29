# frozen_string_literal: true

require './lib/helpers/unit/unit_symbol_mapper'
require './lib/helpers/location_rank_and_file'

# Represents an abstract chess unit
class Unit
  include UnitSymbolMapper
  include LocationRankAndFile

  attr_reader :location, :player, :id, :symbol, :captured, :promoted, :allowed_actions_deltas

  def initialize(location, player, id = location)
    @location = location
    @player = player
    @id = id
    @symbol = get_color_symbol(player.color)
    @initial_location = location
    @captured = false
    @promoted = false
    @allowed_actions_deltas = nil
  end

  def off_board?
    !location
  end

  def capture
    @location = nil
    @captured = true
  end

  def promote
    @location = nil
    @promoted = true
  end

  def move(location)
    @location = location
  end

  def enemy?(other_unit)
    other_unit && player != other_unit.player
  end

  def friendly?(other_unit)
    other_unit && self != other_unit && player == other_unit.player
  end

  def queenside_start?
    %w[a b c d].include?(@initial_location[0])
  end

  def kingside_start?
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

  def encode_with(coder)
    coder['location'] = location
    coder['player'] = player
    coder['id'] = id
    coder['symbol'] = symbol
    coder['initial_location'] = @initial_location
    coder['captured'] = captured
    coder['promoted'] = promoted
  end
end
