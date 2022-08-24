# frozen_string_literal: true

# Represents a game log
class GameLog
  attr_reader :log

  def initialize
    @log = []
  end

  def log_action(turn, action, unit, location, last_location)
    log_item = { turn: turn, action: action, unit: unit, location: location,
                 last_location: last_location }
    @log << log_item
  end

  def last_move
    @log&.last
  end

  def last_unit
    last_move[:unit] if last_move
  end

  def unit_actions(unit)
    @log.select do |log_item|
      log_item[:unit] = unit
    end
        .map do |log_item|
      { action: log_item[:action], location: log_item[:location], last_location: log_item[:last_location] }
    end
  end
end
