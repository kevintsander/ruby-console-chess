# frozen_string_literal: true

require './lib/board'
# require './lib/game_log'
require './lib/helpers/game/game_logger'
require './lib/helpers/game/game_action_checker'
require './lib/helpers/game/game_status_checker'
require './lib/errors/game_errors'

# Represents a Chess game
class Game
  include GameErrors
  include GameLogger
  include GameActionChecker
  include GameStatusChecker

  attr_reader :board, :game_log, :players, :turn, :current_player

  @current_player = nil
  @turn = 0

  def initialize(players)
    @players = players
    @game_log = []
    @board = Board.new(game_log)
  end

  def start
    setup_new_board
    @turn = 1
    @current_player = @players.detect { |player| player.color == :white }
  end

  def game_over?
    fifty_turn_draw? || any_stalemate? || any_checkmate?
  end

  def perform_action(action)
    raise GameNotStartedError if turn.zero?
    raise GameAlreadyOverError if game_over?
    raise ArgumentError, 'Only current player can perform action' if action.unit.player != current_player
    raise MustPromoteError if can_promote_unit?(last_unit) && !action.promoted_unit_class

    unless allowed_actions(action.unit).include?(action)
      raise ArgumentError,
            "unit #{action.unit.symbol} cannot perform #{action.class.name} at #{action.location}"
    end

    action.perform_action
    log_action(action)
    switch_current_player unless game_over?
    @turn += 1
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

  def setup_new_board
    @board.clear_units.add_unit(*new_game_units)
  end

  private

  def other_player(player)
    (players - [player]).first
  end

  def switch_current_player
    @current_player = other_player(current_player)
  end
end
