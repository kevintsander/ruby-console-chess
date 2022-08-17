# frozen_string_literal: true

require './lib/location_rank_and_file'
require './lib/board_location_mapper'
require './lib/board_move_checker'
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
  include BoardMoveChecker

  attr_reader :players, :units

  def initialize(players)
    @players = players
    create_units
  end

  def unit_at(location)
    units.select { |unit| unit.location == location }&.first
  end

  def unit_blocking_move?(unit, to_location)
    check_location = unit.location
    until check_location == to_location
      check_location = step_location(check_location, to_location)
      unit_at_location = unit_at(check_location)

      # blocking if a unit found in the path, unless it is an unfriendly unit on the final space
      return true if unit_at_location && (unit_at_location.player == unit.player || check_location != to_location)
    end
    false
  end

  def allowed_actions(unit)
    unit.allowed_actions_deltas.each_with_object({}) do |(action, deltas), new_hash|
      locations = allowed_action_locations(unit, action, deltas)
      new_hash[action] = locations if locations&.any?
      new_hash
    end
  end

  private

  def allowed_action_locations(unit, action, deltas)
    deltas.reduce([]) do |locations, delta|
      location = delta_location(unit.location, delta)
      break unless location # out of bounds?
      break unless can_perform_action?(unit, location, action)

      locations << location
    end
  end

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
