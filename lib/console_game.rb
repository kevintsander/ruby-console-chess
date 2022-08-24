# frozen_string_literal: true

require './lib/game'
require './lib/player'

class ConsoleGame

  def display_game
    display_introduction
    create_players
    game.start
    play_turn until game.game_over?
    display_game_over
  end

  def play_turn
    get_unit
    show_actions_display # if ConsolePlayer only
    get_action
    add_promote_unit
    perform_action on game
  end

  def get_player_name(:color)
    puts "Who will control the #{:color.to_s} pieces? (Enter player name)"
    gets.chomp
  end

  def create_players
    @white_player = create_player(:white)
    @black_player = create_player(:black)
  end

  def create_player(color)
    name = get_player_name
    Player.new(name, color)
  end
end
