# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class King < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_actions_deltas = { move_standard: king_deltas,
                                move_attack: king_deltas,
                                kingside_castle: kingside_castle_delta,
                                queenside_castle: queenside_castle_delta }
  end

  private

  def king_deltas
    straight = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    diagonal = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    straight + diagonal
  end

  def kingside_castle_delta
    [[0, 2]]
  end

  def queenside_castle_delta
    [[0, -2]]
  end
end
