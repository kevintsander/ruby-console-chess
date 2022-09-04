# frozen_string_literal: true

require 'colorize'

SQUARE_COLORS = %i[on_light_blue on_light_black].freeze

module ConsoleGameOutputs
  def display_introduction
    puts <<~INTRO
      CHESS

        Welcome to Chess, the strategy game played since the 15th century!

        For each player, the battlefield contains:
          eight pawns, two rooks, two knights, two bishops, a king and a queen.

      #{'    '}
      The first player to outsmart the enemy and checkmate the opposing king will win!

    INTRO
  end

  def display_game_over
    current_player = game.current_player
    current_player_name = current_player.name.capitalize
    other_player_name = game.other_player(current_player).name.capitalize
    if game.fifty_turn_draw?
      puts 'DRAW! Could not determine a winner after fifty turns! It was a long and bloody battle.'
    elsif game.any_checkmate?
      puts "CHECKMATE! #{current_player_name} overwhelmed #{other_player_name}'s forces and captured the king!"
    elsif game.any_stalemate?
      puts "STALEMATE! #{current_player_name} almost cornered #{other_player_name}'s king, but they away..."
    end
  end

  def board_section_string
    even_color = SQUARE_COLORS[0]
    odd_color = SQUARE_COLORS[1]
    board_string = "    a  b  c  d  e  f  g  h \n"
    # board_string = ''
    game.board.class::MAP.each_with_index do |location_row, row_id|
      location_row.each_with_index do |location, col_id|
        unit_at_location = game.board.unit_at(location)
        square_string = unit_at_location ? " #{unit_at_location.symbol.colorize(:black)} " : '   '

        board_string += " #{row_id + 1} " if col_id == 0
        board_string += square_string.send(col_id.even? ? even_color : odd_color)
        board_string += "\n" if col_id == Board::MAP[row_id].size - 1
      end
      even_color, odd_color = odd_color, even_color
    end
    board_string
  end

  def display_grid
    # puts stitch_sections
    puts board_section_string
    puts '    (S = Save, X = Exit)'
  end

  def display_available_units(player)
    available_units = game.units_with_actions(player)
    full_text = 'Units with available actions:'
    full_text = available_units.reduce(full_text) do |text, unit|
      text += " #{unit.class.name}@#{unit.location},"
      text
    end
    puts full_text.chop
  end

  def display_allowed_actions(unit)
    full_text = ''
    action_locations_display_hash(unit).each do |action_display_name, locations|
      location_text = "#{action_display_name.capitalize}:"
      locations.sort.each do |location|
        location_text += " #{location},"
      end
      full_text += "#{location_text.chop}\n"
    end
    puts full_text.chomp
  end

  def display_ask_player_name(color)
    puts "Who will control the #{color} pieces? (Enter player name)"
  end

  def display_ask_game_start_action
    puts '1 = New Game   2 = Load game   3 = Load PGN File'
  end

  def display_ask_which_save
    text = "Which save would you like to open? (enter number)\n"
    Game.all_saves.each_with_index do |save, save_index|
      text += "\t#{save_index + 1}) #{Game.file_name(save)}\n"
    end
    puts text
  end

  def display_ask_which_pgn
    text = "Load a recent PGN file or enter a file path:\n"
    Game.all_pgns.each_with_index do |pgn, pgn_index|
      text += "\t#{pgn_index + 1}) #{Game.file_name(pgn)}\n"
    end
    puts text
  end

  def display_file_load_error(message)
    puts "Could not load file: #{message}"
  end

  def display_pgn_interpreter_error
    puts 'Could not interpret PGN file.'
  end

  def display_ask_save_name
    puts 'Enter a name for the save:'
  end

  def clear_display
    system('clear') || system('cls')
  end

  private

  def action_locations_display_hash(unit)
    allowed_actions = allowed_actions(unit)
    allowed_actions.each_with_object({}) do |action, action_locations|
      action_display_name = action.class::DISPLAY_NAME
      action_locations[action_display_name] ||= []
      action_locations[action_display_name] << action.location_notation
    end
  end
end