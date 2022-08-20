# frozen_string_literal: true

require './lib/board'
require './lib/game_log'

# Represents a Chess game
class Game
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

  def perform_action(player, unit, action, location)
    return unless unit.player == player

    case action
    when :move_standard, :jump_standard, :initial_double
      move_unit(player, unit, location)
    when :move_attack, :jump_attack
      attack_unit(player, unit, location)
    when :en_passant
      en_passant_unit(player, unit, location)
    when :kingside_castle
      castle_unit(player, action, unit, location)
    when :queenside_castle
      castle_unit(player, action, unit, location)
    end
  end

  def move_unit(player, unit, location)
    allowed_actions = board.allowed_actions(unit)
    allowed_move_locations = []
    allowed_move_locations += allowed_actions[:move_standard] if allowed_actions[:move_standard]
    allowed_move_locations += allowed_actions[:jump_standard] if allowed_actions[:jump_standard]
    allowed_move_locations += allowed_actions[:initial_double] if allowed_actions[:initial_double]

    return unless allowed_move_locations&.include?(location)

    last_location = unit.location
    unit.move(location)
    game_log.log_action(0, player, :move, unit, location, last_location)
  end

  def attack_unit(player, unit, location)
    allowed_attack_locations = []
    allowed_actions = board.allowed_actions(unit)
    allowed_attack_locations += allowed_actions[:move_attack] if allowed_actions[:move_attack]
    allowed_attack_locations += allowed_actions[:jump_attack] if allowed_actions[:jump_attack]

    return unless allowed_attack_locations&.include?(location)

    last_location = unit.location
    captured_unit = board.unit_at(location)
    unit.move(location)
    captured_unit.capture

    game_log.log_action(turn, player, :attack, unit, location, last_location)
    game_log.log_action(turn, player, :captured, captured_unit, nil, location)
  end

  def en_passant_unit(player, unit, location)
    allowed_actions = board.allowed_actions(unit)
    allowed_en_passant_locations = allowed_actions[:en_passant] if allowed_actions[:en_passant]

    return unless allowed_en_passant_locations&.include?(location)

    last_location = unit.location
    captured_unit_location = board.delta_location(location, [-1 * 0.send(unit.forward, 1), 0])
    captured_unit = board.unit_at(captured_unit_location)
    unit.move(location)
    captured_unit.capture

    game_log.log_action(turn, player, :en_passant, unit, location, last_location)
    game_log.log_action(turn, player, :captured, captured_unit, nil, captured_unit_location)
  end

  def castle_unit(player, castle_action, unit, location)
    allowed_actions = board.allowed_actions(unit)
    allowed_castle_locations = allowed_actions[:kingside_castle]

    return unless allowed_castle_locations&.include?(location)

    unit_class = unit.class
    if unit_class == Rook
      rook = unit
      rook_move_location = location
    elsif unit_class == King
      king = unit
      king_move_location = location
    end
    rook ||= board.get_castle_rook(king, castle_action)
    king ||= board.get_friendly_king(rook)

    rook_last_location = rook.location
    king_last_location = king.location
    rook_move_location ||= board.get_unit_castle_action_location(rook, castle_action)
    king_move_location ||= board.get_unit_castle_action_location(king, castle_action)

    rook.move(rook_move_location)
    king.move(king_move_location)

    game_log.log_action(turn, player, castle_action, rook, rook_move_location, rook_last_location)
    game_log.log_action(turn, player, castle_action, king, king_move_location, king_last_location)
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
    return false if board.check?(king)
    return false if board.allowed_actions(king)&.any?

    board.friendly_units(king) do |friendly|
      # create test game
      board.allowed_actions(friendly).each do |action|
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
          return false unless new_test_game.board.check?(test_friendly_king)
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
    test_game_log = game_log.dup
    test_game_log.instance_variable_set(:@log, test_game_log.log.dup)
    test_game_log.log.each do |log_item|
      log_item[:unit] = test_board_units.select { |unit| unit.location == log_item[:unit].loation }
    end
    test.board.clear_units.add_unit(*test_board_units)
    test
  end
end
