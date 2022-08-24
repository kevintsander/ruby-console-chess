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
    Board::MAP.each_with_index do |location_row, row_id|
      location_row.each_with_index do |location, col_id|
        unit_at_location = board.unit_at(location)
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
    puts stitch_sections
  end
end
