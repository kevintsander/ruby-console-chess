# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class Queen < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_move_deltas = { standard: queen_deltas_all_move_types,
                             attack: queen_deltas_all_move_types }
  end

  private

  def queen_deltas_all_move_types
    straight = (1..7).reduce([]) { |all, dist| all + [[dist, 0], [-dist, 0], [0, dist], [0, -dist]] }
    diagonal = (1..7).reduce([]) { |all, dist| all + [[dist, dist], [dist, -dist], [-dist, dist], [-dist, -dist]] }
    straight + diagonal
  end
end
