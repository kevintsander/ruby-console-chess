# frozen_string_literal: true

class ConsoleGame
  def initialize(game)
    @game = game
  end

  def create_player
    get_player_name
    get_player_color
  end

  def play_game
    start_game
  end

  def play_turn
    ask_player
  end
end
