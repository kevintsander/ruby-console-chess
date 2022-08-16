# frozen_string_literal: true

require './lib/unit'

# Represents a King chess piece
class King < Unit
  def initialize(location, player, id = location)
    super(location, player, id)
    @symbol = get_color_symbol(player.color)
  end
end
