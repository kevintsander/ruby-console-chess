# frozen_string_literal: true

require './lib/game'
require './lib/players/console_player'
require './lib/players/pgn_player'
require './lib/helpers/game/console_game_displayer'
require './lib/helpers/game/pgn_interpreter'

# Represents a Chess game to be played in the console
class ConsoleGame
  include ConsoleGameDisplayer

  attr_reader :game

  def display_game
    display_introduction
    initialize_game
    play_turn until game.game_over?
    display_game_over
  end

  def play_turn
    clear_display
    display_grid
    current_player = game.current_player
    display_available_units(current_player)
    unit = select_unit(current_player.input_unit_location) until unit
    display_allowed_actions(unit)
    action = select_allowed_action(unit, current_player.input_move_location) until action
    game.perform_action(action)
    return unless game.can_promote_unit?(unit)

    clear_display
    display_grid
    promoted_class = select_promoted_unit_class(current_player.input_promoted_unit_class) until promoted_class
    game.perform_promote(unit, promoted_class)
  end

  def select_unit(location)
    check_special_input(location)
    current_player = game.current_player
    unit_at_location = game.board.unit_at(location)
    if unit_at_location&.player == current_player && game.units_with_actions(current_player).include?(unit_at_location)
      unit = unit_at_location
    end
    unit
  end

  def select_allowed_action(unit, move_location)
    check_special_input(move_location)
    game.allowed_actions(unit).detect { |action| action.location_notation == move_location }
  end

  def select_promoted_unit_class(unit_abbreviation)
    check_special_input(unit_abbreviation)
    case unit_abbreviation.upcase
    when 'Q'
      Queen
    when 'R'
      Rook
    when 'B'
      Bishop
    when 'K'
      Knight
    end
  end

  def allowed_actions(unit)
    game.allowed_actions(unit)
  end

  def get_player_name(color)
    display_ask_player_name(color)
    gets.chomp.capitalize
  end

  def get_yes_no
    loop do
      answer = gets.chomp
      unless %w[Y N].include?(answer.upcase)
        display_must_be_yes_no
        next
      end
      return answer.upcase
    end
  end

  def get_save_id
    display_ask_which_save
    input = begin
      Integer(gets.chomp)
    rescue StandardError
      nil
    end
    return input if Game.all_saves.size >= input
  end

  def get_pgn_file_path
    display_ask_file_path
    gets.chomp
  end

  def get_save_name
    display_ask_save_name
    gets.chomp
  end

  def get_game_start_action
    display_ask_game_start_action
    action = gets.chomp
    %w[1 2 3].include?(action) ? action : nil
  end

  def initialize_game
    start_action = get_game_start_action until start_action
    case start_action
    when '1'
      @game = game.new(create_players)
      @game.start
    when '2'
      save_id = get_save_id until save_id
      @game = Game.load_by_id(save_id)
    when '3'
      pgn_path = get_pgn_file_path
      @game = Game.new
      @game.add_players(create_pgn_players(pgn_path, @game))
      @game.start
    end
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

  def create_pgn_players(pgn_path, game)
    interpreter = PgnInterpreter.new(pgn_path)
    white_player_name = interpreter.white_player_name
    black_player_name = interpreter.black_player_name
    turns = interpreter.turns
    white_player_moves = turns.map { |turn| turn[:white] }
    black_player_moves = turns.map { |turn| turn[:black] }
    white_player = PgnPlayer.new(white_player_name, :white, game, white_player_moves)
    black_player = PgnPlayer.new(black_player_name, :black, game, black_player_moves)
    [white_player, black_player]
  end

  private

  def check_special_input(input)
    if input.upcase == 'S'
      # save
      game.save_game(get_save_name)
    elsif input.upcase == 'X'
      # quit
      exit
    end
    nil
  end
end
