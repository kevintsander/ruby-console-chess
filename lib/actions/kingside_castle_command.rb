# frozen_string_literal: true

require './lib/action_command'

# represents a kingside castle command
class KingsideCastleCommand < ActionCommand
  DISPLAY_NAME = 'Kingside castle'

  def location_notation
    'O-O'
  end

  def perform_moves
    other_castle_unit_move_hash = board.other_castle_unit_move_hash(unit, :kingside_castle)
    other_unit = other_castle_unit_move_hash[:unit]
    other_unit_move_location = other_castle_unit_move_hash[:move_location]

    unit.move(location)
    other_unit.move(other_unit_move_location)
  end
end
