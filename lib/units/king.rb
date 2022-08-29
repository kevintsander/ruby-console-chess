# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class King < Unit
  def allowed_actions_deltas
    @allowed_actions_deltas ||= { normal_move: king_deltas,
                                  normal_attack: king_deltas,
                                  kingside_castle: kingside_castle_delta,
                                  queenside_castle: queenside_castle_delta }
    @allowed_actions_deltas
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
