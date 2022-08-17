# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class Queen < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_actions_deltas = { move_standard: queen_deltas,
                                move_attack: queen_deltas }
  end

  private

  def queen_deltas
    straight = (1..7).reduce([]) { |all, dist| all + [[dist, 0], [-dist, 0], [0, dist], [0, -dist]] }
    diagonal = (1..7).reduce([]) { |all, dist| all + [[dist, dist], [dist, -dist], [-dist, dist], [-dist, -dist]] }
    straight + diagonal
  end
end
