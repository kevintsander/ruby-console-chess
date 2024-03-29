# frozen_string_literal: true

class PgnPlayer
  attr_reader :name, :color, :fast_forward

  CLASS_ABBREV_MAP = [{ abbrev: nil, class: ChessEngine::Units::Pawn },
                      { abbrev: 'K', class: ChessEngine::Units::King },
                      { abbrev: 'Q', class: ChessEngine::Units::Queen },
                      { abbrev: 'B', class: ChessEngine::Units::Bishop },
                      { abbrev: 'R', class: ChessEngine::Units::Rook },
                      { abbrev: 'N', class: ChessEngine::Units::Knight }].freeze

  def initialize(name, color, console_game, moves)
    @name = name
    @color = color
    @console_game = console_game
    @moves = moves
    @current_move = nil
    @fast_forward = false
  end

  def input_unit_location
    # submit draw if no more moves (but game isnt over)
    return 'D' if @moves.none?

    check_auto_move_type unless check_fast_forward
    # check board status to find unit that can move to the location
    @current_move = @moves.shift
    file = @current_move[:unit_file]
    rank = @current_move[:unit_rank]
    unit_class = self.class.unit_abbrev_to_class(@current_move[:unit])
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
    @current_move[:promoted_unit]
  end

  private

  def possible_location_units(file, rank, unit_class)
    game = @console_game.game
    if file && rank
      unit_at_location = game.board.unit_at("#{unit_file}#{unit_rank}")
      valid_move_unit?(unit_at_location, unit_class) ? [unit_at_location] : []
    elsif file
      game.board.units_at_file(file, @color, unit_class)
    elsif rank
      game.board.units_at_rank(rank, @color, unit_class)
    else
      game.board.units.select { |unit| unit.color == self.color && unit.instance_of?(unit_class) }
    end
  end

  def display_ask_auto_move_type
    puts "#{name} is up.\nN = Next   FF = Fast Forward"
  end

  def check_fast_forward
    if @fast_forward
      sleep(0.7)
    else
      @fast_forward = @console_game.other_player(self).fast_forward
    end
    @fast_forward
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
    @console_game.game.unit_allowed_actions(unit).detect { |action| action.location_notation == move_location }
  end

  class << self
    def unit_abbrev_to_class(abbrev)
      CLASS_ABBREV_MAP.detect { |map| map[:abbrev] == abbrev }[:class]
    end

    def valid_move_unit?(unit, unit_class)
      unit.player == self && unit.instance_of?(unit_class)
    end
  end
end
