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

  def stalemate?(king)
    return false unless king.is_a?(King)
    return false if check?(king)
    return false if allowed_actions(king)&.any?

    board.friendly_units(king) do |friendly|
      # create test game
      allowed_actions(friendly).each do |action|
        action_type = action[0]
        action_locations = action[1]
        action_locations.each do |action_location|
          new_test_game = test_game
          new_test_game_units = new_test_game.board.units
          test_friendly_king = new_test_game_units.select do |test_unit|
            test_unit.location == king.location
          end.first
          test_friendly_unit = new_test_game_units.select do |test_unit|
            test_unit.location == friendly.location
          end.first
          new_test_game.perform_action(king.player, test_friendly_unit, action_type, action_location)
          return false unless new_test_game.check?(test_friendly_king)
        end
      end
    end
    true
  end

  private

  # creates a test game
  def test_game
    test = Game.new(players)
    test_board_units = board.units.map { |unit| unit.dup }
    test_game_log = GameLog.new
    test_game_log_log = game_log.log.dup
    test_game_log.instance_variable_set(:@log, test_game_log_log)
    test_game_log_log.each do |log_item|
      log_item[:unit] = test_board_units.select { |unit| unit.location == log_item[:unit].loation }
    end
    test.board.clear_units.add_unit(*test_board_units)
    test
  end
end
