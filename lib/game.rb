# frozen_string_literal: true

require './lib/board'
require './lib/game_log'

# Represents a Chess game
class Game
  attr_reader :board, :game_log, :players

  def initialize(players)
    @players = players
    @game_log = GameLog.new
    @board = Board.new(new_game_units, game_log)
    @turn = 0
  end

  def move_unit(player, unit, location)
    return unless unit.player == player

    allowed_actions = board.allowed_actions(unit)
    allowed_move_locations = []
    allowed_move_locations += allowed_actions[:move_standard] if allowed_actions[:move_standard]
    allowed_move_locations += allowed_actions[:jump_standard] if allowed_actions[:jump_standard]
    allowed_move_locations += allowed_actions[:initial_double] if allowed_actions[:initial_double]

    return unless allowed_move_locations.include?(location)

    last_location = unit.location
    unit.move(location)
    game_log.log_action(0, player, :move, unit, location, last_location)
  end

  def new_game_units
    units = []
    players.each do |player|
      non_pawn_rank = player.color == :white ? '1' : '8'
      pawn_rank = player.color == :white ? '2' : '7'
      units << King.new("e#{non_pawn_rank}", player)
      units << Queen.new("d#{non_pawn_rank}", player)
      units += %w[c f].map { |file| Bishop.new("#{file}#{non_pawn_rank}", player) }
      units += %w[b g].map { |file| Knight.new("#{file}#{non_pawn_rank}", player) }
      units += %w[a h].map { |file| Rook.new("#{file}#{non_pawn_rank}", player) }
      units += %w[a b c d e f g h].map { |file| Pawn.new("#{file}#{pawn_rank}", player) }
    end
    units
  end
end
