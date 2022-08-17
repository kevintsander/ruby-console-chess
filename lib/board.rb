# frozen_string_literal: true

require './lib/location_rank_and_file'
require './lib/board_location_mapper'
require './lib/units/king'
require './lib/units/queen'
require './lib/units/bishop'
require './lib/units/knight'
require './lib/units/rook'
require './lib/units/pawn'

# Represents a chess board
class Board
  include LocationRankAndFile
  include BoardLocationMapper

  attr_reader :players, :units

  def initialize(players)
    @players = players
    create_units
  end

  def unit(location)
    units.select { |unit| unit.location == location }&.first
  end

  def unit_blocking_move?(unit, to_coordinates)
    from_coordinates = location_coordinates(unit.location)
    delta = coordinates_delta(from_coordinates, to_coordinates)
    direction = direction(delta)
    check_coordinates = from_coordinates
    until check_coordinates == to_coordinates
      check_coordinates = move_coordinates(check_coordinates, direction)
      unit_at_location = unit(coordinates_location(check_coordinates))

      return true if unit_at_location && (unit_at_location.player == unit.player || check_coordinates != to_coordinates)
    end
    false
  end

  private

  def create_units
    @units ||= []
    players.each do |player|
      non_pawn_rank = player.color == :white ? '1' : '8'
      pawn_rank = player.color == :white ? '2' : '7'
      @units << King.new("e#{non_pawn_rank}", player)
      @units << Queen.new("d#{non_pawn_rank}", player)
      @units += %w[c f].map { |file| Bishop.new("#{file}#{non_pawn_rank}", player) }
      @units += %w[b g].map { |file| Knight.new("#{file}#{non_pawn_rank}", player) }
      @units += %w[a h].map { |file| Rook.new("#{file}#{non_pawn_rank}", player) }
      @units += %w[a b c d e f g h].map { |file| Pawn.new("#{file}#{pawn_rank}", player) }
    end
  end
end
