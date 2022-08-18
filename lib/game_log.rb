# frozen_string_literal: true

# Represents a game log
class GameLog
  attr_reader :log

  def initialize
    @log = []
  end

  def log_action(turn, player, action, move)
    log_item = { turn: turn, player: player, action: action, move: move }
    @log << log_item
  end

  def last_move
    @log.last[:move]
  end
end
