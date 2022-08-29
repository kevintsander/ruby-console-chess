# frozen_string_literal: true

require './lib/actions/action_command'

# represents a queenside castle move
class QueensideCastleCommand < ActionCommand
  DISPLAY_NAME = 'Queenside castle'

  def perform_moves
    other_castle_unit_move_hash = board.other_castle_unit_move_hash(unit, :queenside_castle)
    other_unit = other_castle_unit_move_hash[:unit]
    other_unit_move_location = other_castle_unit_move_hash[:move_location]

    unit.move(location)
    other_unit.move(other_unit_move_location)
  end
end
