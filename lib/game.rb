# frozen_string_literal: true

require './lib/board'
require './lib/helpers/game/game_logger'
require './lib/helpers/game/game_action_checker'
require './lib/helpers/game/game_status_checker'
require './lib/helpers/game/game_file_handler'
require './lib/errors/game_errors'
require './lib/actions/promote_command'

# Represents a Chess game
class Game
  include GameErrors
  include GameLogger
  include GameActionChecker
  include GameStatusChecker
  include GameFileHandler

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

  def both_players_played?
    turn_logs = game_log.select { |log_item| log_item[:turn] == turn }
    player1_played = turn_logs&.select { |log_item| log_item[:action].player == players[0] }&.any?
    player2_played = turn_logs&.select { |log_item| log_item[:action].player == players[1] }&.any?
    player1_played && player2_played
  end

  def turn_over?
    both_players_played? && !can_promote_unit?
  end

  def perform_action(action)
    raise GameNotStartedError if turn.zero?
    raise GameAlreadyOverError if game_over?

    unit = action.unit
    raise ArgumentError, 'Only current player can perform action' if unit.player != current_player
    raise MustPromoteError if can_promote_unit?(last_unit) && !action.is_a?(PromoteCommand)

    unless allowed_actions(unit).include?(action)
      raise ArgumentError,
            "unit #{unit.symbol} cannot perform #{action.class.name} at #{action.location}"
    end

    action.perform_action
    log_action(action)
    return if game_over?

    switch_current_player unless can_promote_unit?(unit)
    @turn += 1 if turn_over?
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
