# frozen_string_literal: true

require './lib/helpers/location_rank_and_file'
require './lib/helpers/board/board_location_mapper'
require './lib/helpers/board/board_status_checker'
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
  include BoardStatusChecker

  attr_reader :units

  def initialize(game_log)
    clear_units
    @game_log = game_log
  end

  def clear_units
    @units = []
    self
  end

  def add_unit(*args)
    args.each do |unit|
      @units << unit
    end
    self
  end

  def unit_at(location, delta = nil)
    at_location = delta ? delta_location(location, delta) : location
    units.select { |unit| unit.location == at_location }&.first
  end

  def enemy_unit_at_location?(player, location)
    unit_at_location = unit_at(location)
    unit_at_location && unit_at_location.player != player
  end

  def unit_blocking_move?(unit, to_location, ignore_unit = nil)
    check_location = unit.location
    until check_location == to_location
      check_location = step_location(check_location, to_location)
      unit_at_location = unit_at(check_location)
      unit_at_location = nil if unit_at_location == ignore_unit # allow a unit to be ignored (for castling)

      # blocking if a unit found in the path, unless it is an unfriendly unit on the final space
      return true if unit_at_location && (unit_at_location.player == unit.player || check_location != to_location)
    end
    false
  end

  def friendly_units(unit)
    if block_given?
      units.each do |other|
        yield(other) if unit.friendly?(other)
      end
    else
      units.select { |other| unit.friendly?(other) }
    end
  end

  def enemy_units(unit)
    if block_given?
      units.each do |other|
        yield(other) if unit.enemy?(other)
      end
    else
      units.select { |other| unit.enemy?(other) }
    end
  end

  def other_castle_unit_move_hash(unit, castle_type)
    friendly_units(unit) do |friendly|
      next if castle_type == :kingside_castle && !friendly.kingside_start?
      next if castle_type == :queenside_castle && !friendly.is_a?(King) && !friendly.queenside_start?

      delta = friendly.allowed_actions_deltas[castle_type]&.first
      next unless delta

      return { unit: friendly, move_location: delta_location(friendly.location, delta) }
    end
    nil
  end
end
