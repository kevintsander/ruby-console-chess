# frozen_string_literal: true

require './lib/board'
require './lib/game_log'
require './lib/helpers/game/game_action_checker'
require './lib/helpers/game/game_status_checker'

# Represents a Chess game
class Game
  include GameActionChecker
  include GameStatusChecker

  attr_reader :board, :game_log, :players, :turn

  def initialize(players)
    @players = players
    @game_log = GameLog.new
    @board = Board.new(game_log)
    @turn = 0
  end

  def setup_new_board
    @board.clear_units.add_unit(new_game_units)
  end

  def perform_action(action)
    action.perform_action
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
