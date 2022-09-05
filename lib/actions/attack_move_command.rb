# frozen_string_literal: true

require './lib/action_command'

# represents an attack move that will capture another unit
class AttackMoveCommand < ActionCommand
  DISPLAY_NAME = 'Attack move'

  def perform_moves
    captured_unit = board.unit_at(location)
    unit.move(location)
    captured_unit.capture
    @captured_unit = captured_unit
  end
end
