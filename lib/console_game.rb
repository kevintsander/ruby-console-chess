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
    introduction
    create_player # 1
    create_playe # 2
    start_game
    play_turn until game.game_over?
    display_game_over_message
  end

  def play_turn
    get_unit
    show_actions_display # if ConsolePlayer only
    get_action
    add_promote_unit
    perform_action on game
  end
end
