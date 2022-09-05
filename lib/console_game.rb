# frozen_string_literal: true

require './lib/game'
require './lib/players/console_player'
require './lib/players/pgn_player'
require './lib/helpers/console/console_game_outputs'
require './lib/helpers/console/console_game_inputs'
require './lib/helpers/game/pgn_interpreter'

# Represents a Chess game to be played in the console
class ConsoleGame
  include ConsoleGameOutputs
  include ConsoleGameInputs

  attr_reader :game

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
      return if check_player_draw(location_input)

      unit = select_unit(location_input)
    end
    action = select_allowed_action(unit, get_action_location(unit)) until action
    game.perform_action(action)
    return unless game.can_promote_unit?(unit)

    display_grid_promote_unit
    promoted_class = select_promoted_unit_class(get_promoted_unit_abbreviation) until promoted_class
    game.perform_promote(unit, promoted_class)
  end

  def select_unit(location)
    current_player = game.current_player
    unit_at_location = game.board.unit_at(location)
    if unit_at_location&.player == current_player && game.units_with_actions(current_player).include?(unit_at_location)
      unit = unit_at_location
    end
    unit
  end

  def select_allowed_action(unit, move_location)
    game.allowed_actions(unit).detect { |action| action.location_notation == move_location }
  end

  def select_promoted_unit_class(unit_abbreviation)
    { 'Q' => Queen, 'R' => Rook, 'B' => Bishop, 'N' => Knight }[unit_abbreviation.upcase]
  end

  def allowed_actions(unit)
    game.allowed_actions(unit)
  end

  def initialize_game
    start_action = get_game_start_action until start_action
    new_game = nil
    case start_action
    when '1'
      new_game = Game.new(create_console_players)
      new_game.start
    when '2'
      save_id = get_save_id until save_id
      new_game = Game.load_save_by_id(save_id)
    when '3'
      new_game = get_pgn_game until new_game
      new_game.start
    end
    @game = new_game
  end

  def create_console_players
    white_player = create_console_player(:white)
    black_player = create_console_player(:black)
    [white_player, black_player]
  end

  def create_console_player(color)
    name = get_player_name(color)
    ConsolePlayer.new(name, color)
  end

  def create_pgn_players(pgn_data, game)
    interpreter = PgnInterpreter.new(pgn_data)
    white_player_name = interpreter.white_player_name
    black_player_name = interpreter.black_player_name
    turns = interpreter.turns
    white_player_moves = turns.map { |turn| turn[:white] }
    black_player_moves = turns.map { |turn| turn[:black] }
    white_player = PgnPlayer.new(white_player_name, :white, game, white_player_moves)
    black_player = PgnPlayer.new(black_player_name, :black, game, black_player_moves)
    [white_player, black_player]
  end
end
