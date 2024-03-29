# frozen_string_literal: true

require 'colorize'

SQUARE_COLORS = %i[on_light_blue on_light_green].freeze

module ConsoleGameOutputs
  def display_introduction
    puts <<~INTRO
      +++++++++++++++++++++++++++++++++++++++++++++++++
      +                                               +
      +          /////////////                        +
      +         ///                                   +
      +        ///      //   //  /////  /////  /////  +
      +       ///      //   //  //     //     //      +
      +      ///      ///////  /////  ////// //////   +
      +     ///      //   //  //         //     //    +
      +    ///      //   //  /////  ////// //////     +
      +   ///                                         +
      +  ////////////                                 +
      +                                               +
      +++++++++++++++++++++++++++++++++++++++++++++++++

        Welcome to Chess, the strategy game played since the 15th century!

        For each player, the battlefield contains:
          eight pawns, two rooks, two knights, two bishops, a king and a queen.

        The first player to outsmart the enemy and checkmate the opposing king will win!

    INTRO
  end

  def game_over_section
    current_player_name = current_player.name
    other_player_name = other_player(current_player).name

    if game.status == :player_draw
      <<~DRAW

        DRAW!#{' '}
        Players agreed to lay down their arms.
      DRAW
    elsif game.status == :max_turn_draw
      <<~DRAW

        DRAW!
        Coult not determine a winner after fifty turns!
        It was a long and bloody battle...
      DRAW
    elsif game.status == :checkmate
      <<~CHECKMATE

        CHECKMATE!
        #{current_player_name} overwhelmed #{other_player_name}'s forces
        and captured the King!
      CHECKMATE
    elsif game.status == :stalemate
      <<~STALEMATE

        STALEMATE!
        #{current_player_name} almost cornerered #{other_player_name}'s king,
        but they managed to escape...
      STALEMATE
    end
  end

  def promote_unit_section
    'SELECT A UNIT TO PROMOTE'.underline + "\nQ = Queen\nB = Bishop\nR = Rook\nN = Knight"
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
        board_string += "\n" if col_id == ChessEngine::Board::MAP[row_id].size - 1
      end
      even_color, odd_color = odd_color, even_color
    end
    board_string
  end

  def display_grid_available_units
    clear_display
    puts add_dynamic_section_to_grid(available_units_section)
    puts '(D = Draw, S = Save, X = Exit)' if current_player.is_a?(ConsolePlayer)
  end

  def display_grid_allowed_actions(unit)
    clear_display
    puts add_dynamic_section_to_grid(allowed_actions_section(unit))
    puts '(S = Save, X = Exit)' if current_player.is_a?(ConsolePlayer)
  end

  def display_grid_promote_unit
    clear_display
    puts add_dynamic_section_to_grid(promote_unit_section)
    puts '(S = Save, X = Exit)' if current_player.is_a?(ConsolePlayer)
  end

  def display_grid_game_over
    clear_display
    puts add_dynamic_section_to_grid(game_over_section)
  end

  def add_dynamic_section_to_grid(section)
    stitched_grid = ''
    section_lines = section.split("\n")
    board_section_string.each_line.with_index do |line, index|
      stitched_grid += if index.zero?
                         "#{line.chomp} | #{game_turn_section}\n"
                       elsif index.between?(1, 7)
                         "#{line.chomp} | #{section_lines[index - 1]}\n"
                       elsif index == 8
                         "#{line.chomp} | #{game_status_section}\n"
                       else
                         line.to_s
                       end
    end
    stitched_grid.chomp
  end

  def game_turn_section
    forecolor = current_player.color == :white ? :black : :white
    "Turn: #{game.turn.to_s.ljust(2,
                                  ' ')}\tPlayer: #{current_player.name.colorize(color: forecolor,
                                                                                 background: current_player.color)}"
  end

  def game_status_section
    text = 'CHECK'.on_yellow if game.status == :check
    text = 'CHECKMATE'.on_red if game.status == :checkmate
    text = 'DRAW'.on_yellow if game.status == :player_draw || game.status == :max_turn_draw
    text = 'STALEMATE'.on_red if game.status == :stalemate
    text
  end

  def available_units_section
    available_units = game.units_with_actions(game.current_color)
    full_text = 'UNITS WITH AVAILABLE ACTIONS'.underline + "\n"
    grouped_units = available_units.group_by { |unit| unit.name }
    full_text = grouped_units.reduce(full_text) do |units_text, (unit_class, units)|
      unit_class_text = "#{unit_class}:".ljust(7, ' ')
      units_text += "  #{unit_class_text}"
      units_text = units.reduce(units_text) do |class_text, unit|
        class_text + " #{unit.location},"
      end
      "#{units_text.chop}\n"
    end
    full_text.chomp
  end

  def allowed_actions_section(unit)
    full_text = "AVAILABLE ACTIONS FOR #{unit.name.upcase} (#{unit.location}):".underline + "\n"
    action_locations_display_hash(unit).each do |action_display_name, locations|
      location_text = "  #{action_display_name.capitalize}:"
      action_header_length = location_text.size
      locations.sort.each do |location|
        location_text += "\n#{' ' * action_header_length}" if location_text.split("\n").last.size >= 40
        location_text += " #{location},"
      end
      full_text += "#{location_text.chop}\n"
    end
    full_text.chomp
  end

  def display_ask_player_name(color)
    puts "Who will control the #{color} pieces? (Enter player name)"
  end

  def display_ask_game_start_action
    puts '1 = New Game   2 = Load game   3 = Load PGN File'
  end

  def display_ask_which_save
    text = "Which save would you like to open? (enter number)\n"
    file_handler.all_saves.each_with_index do |save, save_index|
      text += "\t#{save_index + 1}) #{file_handler.file_name(save)}\n"
    end
    puts text
  end

  def display_ask_which_pgn
    text = "Load a recent PGN file or enter a file path:\n"
    file_handler.all_pgns.each_with_index do |pgn, pgn_index|
      text += "\t#{pgn_index + 1}) #{file_handler.file_name(pgn)}\n"
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
