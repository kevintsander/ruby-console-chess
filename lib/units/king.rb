# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class King < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_move_deltas = { move_standard: king_deltas,
                             move_attack: king_deltas }
  end

  private

  def king_deltas
    straight = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    diagonal = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    straight + diagonal
  end
end
