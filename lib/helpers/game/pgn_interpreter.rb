# frozen_string_literal: true

require './lib/units/pawn'
require './lib/units/king'
require './lib/units/queen'
require './lib/units/rook'
require './lib/units/bishop'
require './lib/units/knight'

# This class interprets chess PGN files
class PgnInterpreter
  TURN_REGEX = /(?<turn>\d*)[.]                                                                   # turn number
                [\n\r\s]+                                                                         # space
                (?<white>(?<move>
                  (?:[KQBRN]?[abcdefgh]?[12345678]?x?(?:[abcdefgh][12345678])|O-O|O-O-O)(?:=[QBRN])?[+#]? # white move
                  (?:[\r\n\s]*\{[^}]*\})?))
                [\r\n\s]+                                                                         # space
                (?<black>\g<move>)?                                                               # black move
                /x.freeze

  MOVE_REGEX = /(?:(?<unit>[KQBRN])?(?<unit_file>[abcdefgh])?(?<unit_rank>[12345678])?            # unit
                (?<capture>x)?                                                                    # capture
                (?<move>(?:[abcdefgh][12345678])|O-O|O-O-O))                                      # move
                (?:=(?<promoted_unit>[QRBN]))?                                                    # promoted unit
                (?<status>[+#])?(?:[\r\n\s]*\{(?<comment>[^}]*)\})?                               # status (checkmate)
                /x.freeze

  TAG_PAIR_REGEX = /\[(?<key>\S+)[\r\n\s]+"(?<value>[^"]*)"\]/.freeze

  CLASS_ABBREV_MAP = [{ abbrev: nil, class: Pawn },
                      { abbrev: 'K', class: King },
                      { abbrev: 'Q', class: Queen },
                      { abbrev: 'B', class: Bishop },
                      { abbrev: 'R', class: Rook },
                      { abbrev: 'N', class: Knight }].freeze

  def initialize(pgn_filepath)
    @pgn_data = File.read(pgn_filepath)
  end

  def tags
    @pgn_data.scan(TAG_PAIR_REGEX)
  end

  def white_player_name
    tags.select { |tag| tag[0].capitalize == 'White' }.first[0]
  end

  def black_player_name
    tags.select { |tag| tag[0].capitalize == 'Black' }.first[0]
  end

  def turns
    @pgn_data.to_enum(:scan, TURN_REGEX).map do
      processed_turn_moves(Regexp.last_match.named_captures)
    end.sort_by { |turn| turn[:turn].to_i }
  end

  private

  def processed_turn_moves(turn_regex_captures)
    turn = turn_regex_captures
    moves = {}
    moves[:turn] = turn['turn']
    moves[:white] = self.class.process_move_captures(MOVE_REGEX.match(turn['white']).named_captures)
    moves[:black] = self.class.process_move_captures(MOVE_REGEX.match(turn['black']).named_captures)
    moves
  end

  class << self
    def unit_abbrev_to_class(abbrev)
      CLASS_ABBREV_MAP.detect { |map| map[:abbrev] == abbrev }[:class]
    end

    def process_move_captures(move_captures)
      move_captures.map do |key, value|
        value = 'K' if key == 'unit' && ['O-O', 'O-O-O'].include?(move_captures['move'])
        # convert unit abbreviations to classes
        if %w[unit promoted_unit].include?(key)
          key = "#{key}_class"
          value = unit_abbrev_to_class(value)
        end
        key = 'unit_class' if key == 'unit'
        [key.to_sym, value]
      end.to_h
    end
  end
end
