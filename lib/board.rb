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

  def unit_blocking_move?(unit, to_location)
    check_location = unit.location
    until check_location == to_location
      check_location = step_location(check_location, to_location)
      unit_at_location = unit(check_location)

      # blocking if a unit found in the path, unless it is an unfriendly unit on the final space
      return true if unit_at_location && (unit_at_location.player == unit.player || check_location != to_location)
    end
    false
  end

  def allowed_moves(unit)
    allowed_locations(unit)
  end

  private

  # converts a unit allowed deltas to allowed locations
  def allowed_locations(unit)
    unit.allowed_move_deltas.each_with_object({}) do |(action, deltas), new_hash|
      locations = []
      deltas.each do |delta|
        unit_coordinates = location_coordinates(unit.location)
        location = coordinates_location(move_coordinates(unit_coordinates, delta))
        unit_at_location = unit(location)
        break unless location

        case action
        when :move_standard
          break if unit_blocking_move?(unit, location)
        when :move_attack
          break unless unit_at_location && unit_at_location.player != unit.player && unit_blocking_move?(unit, location)
        when :jump_standard
          break if unit_at_location
        when :jump_attack
          break unless unit_at_location && unit_at_location.player != unit.player
        when :en_passant
          break
        when :kingside_castle
          break
        when :queenside_castle
          break
        end

        locations << location
      end
      new_hash[action] = locations if locations.any?
      new_hash
    end
  end

  def filter_moves; end

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
