# frozen_string_literal: true

require './lib/player'

class PgnPlayer < Player
  attr_reader :game

  def initialize(name, color, game, moves)
    super(name, color)
    @game = game
    @moves = moves
    @current_move = nil
    @fast_forward = false
  end

  def input_unit_location
    check_auto_move_type unless check_fast_forward
    # check board status to find unit that can move to the location
    @current_move = @moves.shift
    file = @current_move[:unit_file]
    rank = @current_move[:unit_rank]
    unit_class = @current_move[:unit_class]
    move_location = @current_move[:move]
    possible_units = possible_location_units(file, rank, unit_class)
    possible_units.each do |unit|
      allowed_action = find_allowed_action(unit, move_location)
      return unit.location if allowed_action
    end
    Raise ArgumentError 'Invalid PGN file move'
  end

  def input_move_location
    check_fast_forward
    @current_move[:move]
  end

  def input_promoted_unit_class
    check_fast_forward
    @current_move[:promoted_unit_class]
  end

  private

  def possible_location_units(file, rank, unit_class)
    if file && rank
      unit_at_location = game.board.unit_at("#{unit_file}#{unit_rank}")
      valid_move_unit?(unit_at_location, unit_class) ? [unit_at_location] : []
    elsif file
      game.board.units_at_file(file, @color, unit_class)
    elsif rank
      game.board.units_at_rank(rank, @color, unit_class)
    else
      game.board.units.select { |unit| unit.player == self && unit.instance_of?(unit_class) }
    end
  end

  def display_ask_auto_move_type
    puts "#{name} is up.\nN = Next   FF = Fast Forward"
  end

  def check_fast_forward
    return unless @fast_forward

    sleep(0.5)
    true
  end

  def check_auto_move_type
    type = ''
    until %w[N FF].include?(type)
      display_ask_auto_move_type
      type = gets.chomp.upcase
    end
    @fast_forward = true if type == 'FF'
    type
  end

  def find_allowed_action(unit, move_location)
    game.allowed_actions(unit).detect { |action| action.location_notation == move_location }
  end

  class << self
    def valid_move_unit?(unit, unit_class)
      unit.player == self && unit.instance_of?(unit_class)
    end
  end
end
