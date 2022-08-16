# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class King < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_move_deltas = { standard: king_deltas_all_move_types,
                             attack: king_deltas_all_move_types }
  end

  private

  def king_deltas_all_move_types
    straight = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    diagonal = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    straight + diagonal
  end
end
