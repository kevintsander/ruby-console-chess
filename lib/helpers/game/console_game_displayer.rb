# frozen_string_literal: true

require 'colorize'

SQUARE_COLORS = %i[on_light_blue on_light_black].freeze

module ConsoleGameDisplayer
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
    if game.fifty_turn_draw?
      puts 'DRAW! Could not determine a winner after fifty turns! It was a long and bloody battle.'
    elsif game.checkmate?
      puts "CHECKMATE! #{game.current_player.capitalize} overwhelmed the enemy forces and captured the king!"
    elsif game.stalemate?
      puts 'STALEMATE! The king was almost cornered, but got away...'
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

  def white_off_board_section; end

  def black_off_board_section; end

  def history_section; end

  def actions_section; end

  def stitch_sections
    # overall fixed size (need to determine)
    # top left square
    # top half black off board
    # bottom half white off board
    # history to right
    # allowed moves on bottom - allowed to grow vertically
  end

  def display_grid
    # puts stitch_sections
    puts board_section_string
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
    action_locations_hash(unit).each do |action_display_name, locations|
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

  def display_ask_load_game
    puts 'Would you like to load an existing save? (Y/N)'
  end

  def display_ask_which_save
    text = "Which save would you like to open? (enter number)\n"
    Game.all_saves.each_with_index do |save, save_index|
      text += "\t#{save_index + 1}) #{Game.save_name(save)}\n"
    end
    puts text
  end

  def display_ask_save_name
    puts 'Enter a name for the save:'
  end

  def display_must_be_yes_no
    puts 'Please enter Y or N.'
  end

  def clear_display
    system('clear') || system('cls')
  end

  private

  def action_locations_hash(unit)
    allowed_actions = allowed_actions(unit)
    allowed_actions.each_with_object({}) do |action, action_locations|
      action_display_name = action.class::DISPLAY_NAME
      action_locations[action_display_name] ||= []
      action_locations[action_display_name] << action.location
    end
  end
end
