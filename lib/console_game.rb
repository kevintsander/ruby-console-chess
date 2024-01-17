# frozen_string_literal: true

require 'chess-engine'
require_relative './players/console_player'
require_relative './players/pgn_player'
require_relative './helpers/console_game_outputs'
require_relative './helpers/console_game_inputs'

# Represents a Chess game to be played in the console
class ConsoleGame
  include ConsoleGameOutputs
  include ConsoleGameInputs

  attr_reader :game, :file_handler

  def initialize
    @file_handler = ChessEngine::GameFileHandler.new('./saves/')
  end

  def display_game
    display_introduction
    initialize_game
    play_turn until game.game_over?
    display_grid_game_over
  end

  def play_turn
    unit = nil
    until unit
      location_input = get_unit_location
      return if game.status == :player_draw

      unit = game.select_actionable_unit(location_input)
    end
    action = game.select_allowed_action(unit, get_action_location(unit)) until action
    game.perform_action(action)
    return unless game.status == :promoting

    display_grid_promote_unit
    promoted_class = select_promoted_unit_class(get_promoted_unit_abbreviation) until promoted_class

    promote_action = game.select_promote_action(promoted_class)
    game.perform_action(promote_action)
  end

  def select_promoted_unit_class(unit_abbreviation)
    { 'Q' => ChessEngine::Units::Queen, 'R' => ChessEngine::Units::Rook, 'B' => ChessEngine::Units::Bishop,
      'N' => ChessEngine::Units::Knight }[unit_abbreviation.upcase]
  end

  def allowed_actions(unit)
    game.unit_allowed_actions(unit)
  end

  def initialize_game
    start_action = get_game_start_action until start_action
    new_game = nil
    case start_action
    when '1'
      create console_players
      new_game = ChessEngine::Game.new()
      new_game.start
    when '2'
      save_id = get_save_id until save_id
      new_game = file_handler.load_save_by_id(save_id)
    when '3'
      new_game = get_pgn_game until new_game
      new_game.start
    end
    @game = new_game
  end

  def create_console_players
    @white_player = create_console_player(:white)
    @black_player = create_console_player(:black)
    [@white_player, @black_player]
  end

  def create_console_player(color)
    name = get_player_name(color)
    ConsolePlayer.new(name, color)
  end

  def create_pgn_players(pgn_data)
    p pgn_data
    interpreter = ChessEngine::PgnInterpreter.new(pgn_data)
    white_player_name = interpreter.white_player_name
    black_player_name = interpreter.black_player_name
    turns = interpreter.turns
    white_player_moves = turns.map { |turn| turn[:white] }
    black_player_moves = turns.map { |turn| turn[:black] }
    @white_player = PgnPlayer.new(white_player_name, :white, self, white_player_moves)
    @black_player = PgnPlayer.new(black_player_name, :black, self, black_player_moves)
    [@white_player, @black_player]
  end

  def current_player
    { white: @white_player, black: @black_player }[game.current_color]
  end

  def other_player(player)
    player == @black_player ? @white_player : @black_player
  end
end
