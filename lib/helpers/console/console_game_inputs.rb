# frozen_string_literal: true

module ConsoleGameInputs
  def get_player_name(color)
    display_ask_player_name(color)
    name = gets.chomp
    check_initialize_menu_special_input(name)
    name
  end

  def get_unit_location
    display_grid_available_units
    location = game.current_player.input_unit_location
    check_turn_menu_inputs(location)

    location
  end

  def get_action_location(unit)
    display_grid_allowed_actions(unit)
    location = game.current_player.input_move_location
    check_turn_menu_inputs(location)
    location
  end

  def get_promoted_unit_abbreviation
    class_abbrev = game.current_player.input_promoted_unit_class
    check_turn_menu_inputs(class_abbrev)
    class_abbrev
  end

  def get_save_id
    display_ask_which_save
    input = gets.chomp
    check_initialize_menu_special_input(input)
    int_input = input.to_i
    return int_input if int_input.between?(1, Game.all_saves.size)
  end

  def get_pgn
    display_ask_which_pgn
    input = gets.chomp
    check_initialize_menu_special_input(input)
    int_input = input.to_i
    if int_input.between?(1, Game.all_pgns.size)
      Game.load_pgn_by_id(int_input)
    else
      Game.load_pgn(input)
    end
  rescue StandardError => e
    display_file_load_error(message)
  end

  def get_save_name
    display_ask_save_name
    input = gets.chomp
    check_exit_input(input)
    input
  end

  def get_game_start_action
    display_ask_game_start_action
    action = gets.chomp
    check_exit_input(action)
    %w[1 2 3].include?(action) ? action : nil
  end

  def get_pgn_game
    pgn_data = get_pgn
    new_game = Game.new
    new_game.add_players(create_pgn_players(pgn_data, new_game))
    new_game
  rescue StandardError
    display_pgn_interpreter_error
  end

  private

  def check_player_draw(input)
    game.submit_draw if input == '='
    game.player_draw
  end

  def check_turn_menu_inputs(input)
    if input.upcase == 'S'
      # save
      game.save_game(get_save_name)
    end
    check_exit_input(input)
  end

  def check_initialize_menu_special_input(input)
    if input.upcase == 'B'
      # back to menu
      game.initialize_game
    end
    check_exit_input(input)
  end

  def check_exit_input(input)
    if input.upcase == 'X'
      # quit
      exit
    end
  end
end
