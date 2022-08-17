# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class Knight < Unit
  @jump_move = true

  def initialize(location, player, id = location)
    super(location, player, id)
    @allowed_actions_deltas = { jump_standard: knight_deltas,
                                jump_attack: knight_deltas }
  end

  private

  def knight_deltas
    [[2, 3], [2, -3], [-2, 3], [-2, -3], [3, 2], [3, -2], [-3, 2], [-3, -2]]
  end
end
