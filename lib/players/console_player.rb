# frozen_string_literal: true

# Represents a console player
class ConsolePlayer
  attr_reader :name, :color
  
  def initialize(name, color)
    @name = name
    @color = color
  end

  def input_unit_location
    display_ask_unit_location
    gets.chomp.downcase
  end

  def input_move_location
    display_ask_move_location
    gets.chomp.downcase
  end

  def input_promoted_unit_class
    display_ask_promote_class
    gets.chomp.upcase
  end

  private

  def display_ask_unit_location
    puts "#{name}, what unit would you like to move?"
  end

  def display_ask_move_location
    puts 'What location would you like to move to?'
  end

  def display_ask_promote_class
    puts 'What unit would you like to promote your pawn to?\nQ = Queen   R = Rook   B = Bishop   N = Knight'
  end
end
