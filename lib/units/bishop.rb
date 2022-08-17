# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class Bishop < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_actions_deltas = { move_standard: bishop_deltas,
                                move_attack: bishop_deltas }
  end

  private

  def bishop_deltas
    (1..7).reduce([]) { |all, dist| all + [[dist, dist], [dist, -dist], [-dist, dist], [-dist, -dist]] }
  end
end
