# frozen_string_literal: true

require './lib/game'
require './lib/players/console_player'
require './lib/helpers/game/console_game_displayer'

# Represents a Chess game to be played in the console
class ConsoleGame
  include ConsoleGameDisplayer

  attr_reader :game

  def display_game
    display_introduction
    @game = Game.new(create_players)
    game.start
    play_turn until game.game_over?
    display_game_over
  end

  def play_turn
    display_grid
    current_player = game.current_player
    unit = select_unit(current_player.input_unit_location) until unit
    action = select_allowed_action(unit, current_player.input_move_location) until action
    game.perform_action(action)
  end

  def select_unit(location)
    unit = game.board.unit_at(location)
    unit&.player == game.current_player ? unit : nil
  end

  def select_allowed_action(unit, move_location)
    game.allowed_actions(unit).detect { |action| action.location == move_location }
  end

  def allowed_actions(unit)
    game.allowed_actions(unit)
  end

  def get_player_name(color)
    display_ask_player_name(color)
    gets.chomp.capitalize
  end

  def create_players
    white_player = create_player(:white)
    black_player = create_player(:black)
    [white_player, black_player]
  end

  def create_player(color)
    name = get_player_name(color)
    ConsolePlayer.new(name, color)
  end
end
