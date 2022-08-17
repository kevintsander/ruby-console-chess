# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class Rook < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_actions_deltas = { move_standard: rook_deltas,
                                move_attack: rook_deltas }
  end

  private

  def rook_deltas
    (1..7).reduce([]) { |all, dist| all + [[0, dist], [0, -dist], [dist, 0], [-dist, 0]] }
  end
end
