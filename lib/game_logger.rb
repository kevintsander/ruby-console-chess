# frozen_string_literal: true

module GameLogger
  @log = []
  attr_reader :log

  def log_action(turn, player, action, move)
    log_item = { turn: turn, player: player, action: action, move: move }
    @log << log_item
  end

  def last_move
    @log.last[:move]
  end
end
