# frozen_string_literal: true

require './lib/player'

# Represents a console player
class ConsolePlayer < Player
  def input_unit_location
    display_ask_unit_location
    gets.chomp.downcase
  end

  def input_move_location
    display_ask_move_location
    gets.chomp.downcase
  end

  private

  def display_ask_unit_location
    puts "#{name.capitalize}, what unit would you like to move?"
  end

  def display_ask_move_location
    puts "#{name.capitalize}, what location would you like to move to?"
  end
end
