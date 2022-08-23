# frozen_string_literal: true

module ConsoleGameDisplayer
  def board_section_string; end

  def white_off_board_section; end

  def black_off_board_section; end

  def history_section; end

  def actions_section; end

  def stitch_sections; end

  def display_sections
    puts stitch_sections
  end
end
