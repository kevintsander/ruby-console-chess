# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class Pawn < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_actions_deltas = { move_standard: pawn_move_delta,
                                move_attack: pawn_attack_deltas,
                                en_passant: pawn_attack_deltas }
  end

  private

  def forward_rank_dir
    0.send(forward, 1)
  end

  def pawn_move_delta
    [[forward_rank_dir, 0]]
  end

  def pawn_attack_deltas
    [[forward_rank_dir, -1], [forward_rank_dir, 1]]
  end
end
