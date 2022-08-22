# frozen_string_literal: true

require './lib/actions/action_command'

# represents a normal move
class NormalMoveCommand < ActionCommand
  def perform_action
    unit.move(location)
    # game_log.log_action(turn, :move, unit, location, last_location)
  end
end
