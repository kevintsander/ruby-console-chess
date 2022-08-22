# frozen_string_literal: true

require './lib/game'

describe Game do
  let(:white_player) { double('player', color: :white) }
  let(:black_player) { double('player', color: :black) }
  let(:blank_log) { double('blank_log', log: [], last_move: nil) }
  let(:blank_board) { double('board', units: []) }
  subject(:blank_game) { described_class.new([white_player, black_player]) }

  before do
    blank_game.instance_variable_set(:@board, blank_board)
    blank_game.instance_variable_set(:@game_log, blank_log)
    allow(blank_log).to receive(:log_action)
    allow(blank_log).to receive(:unit_actions)
  end

  describe '#allowed_actions' do
    subject(:game_allowed) { blank_game }
    subject(:board_allowed) { Board.new(blank_log) }

    matcher :match_locations do |check_locations, action_command_type = nil|
      match do |actions|
        test_actions = action_command_type ? actions.select { |action| action.is_a?(action_command_type) } : actions
        test_actions_locations = test_actions.map(&:location)
        check_locations.each do |check_location|
          return false unless test_actions_locations.include?(check_location)
        end
        true
      end
    end

    before do
      blank_game.instance_variable_set(:@board, board_allowed)
    end

    context 'moves inside boundary' do
      it 'returns all moves' do
        pawn_unit = Pawn.new('c2', white_player)
        knight_unit = Knight.new('e5', black_player)
        king_unit = King.new('f6', white_player)
        board_allowed.add_unit(pawn_unit)
        pawn_result = game_allowed.allowed_actions(pawn_unit)
        board_allowed.clear_units.add_unit(knight_unit)
        knight_result = game_allowed.allowed_actions(knight_unit)
        board_allowed.clear_units.add_unit(king_unit)
        king_result = game_allowed.allowed_actions(king_unit)

        expect(pawn_result).to match_locations(%w[c3 c4], NormalMoveCommand)
        expect(knight_result).to match_locations(%w[g4 f3 g6 f7 d7 c6 c4 d3], NormalMoveCommand)
        expect(king_result).to match_locations(%w[g5 g6 g7 f5 f7 e5 e6 e7], NormalMoveCommand)
      end
    end

    context 'moves outside of boundary' do
      it 'limits moves' do
        pawn_unit = Pawn.new('c8', white_player)
        rook_unit = Rook.new('c3', black_player)
        knight_unit = Knight.new('h8', black_player)
        bishop_unit = Bishop.new('e2', white_player)
        queen_unit = Queen.new('b7', black_player)
        king_unit = King.new('h8', white_player)

        board_allowed.add_unit(pawn_unit)
        pawn_result = game_allowed.allowed_actions(pawn_unit)
        board_allowed.clear_units.add_unit(rook_unit)
        rook_result = game_allowed.allowed_actions(rook_unit)
        board_allowed.clear_units.add_unit(knight_unit)
        knight_result = game_allowed.allowed_actions(knight_unit)
        board_allowed.clear_units.add_unit(bishop_unit)
        bishop_result = game_allowed.allowed_actions(bishop_unit)
        board_allowed.clear_units.add_unit(queen_unit)
        queen_result = game_allowed.allowed_actions(queen_unit)
        board_allowed.clear_units.add_unit(king_unit)
        king_result = game_allowed.allowed_actions(king_unit)

        expect(pawn_result).to be_empty
        expect(rook_result).to match_locations(%w[c1 c2 c4 c5 c6 c7 c8 a3 b3 d3 e3 f3 g3 h3], NormalMoveCommand)
        expect(knight_result).to match_locations(%w[f7 g6], NormalMoveCommand)
        expect(bishop_result).to match_locations(%w[d1 f1 d3 c4 b5 a6 f3 g4 h5], NormalMoveCommand)
        expect(queen_result).to match_locations(%w[a8 a7 a6 b8 c8 c7 d7 e7 f7 g7 h7 c6 d5 e4 f3 g2 h1 b6 b5 b4
                                                   b3 b2 b1], NormalMoveCommand)
        expect(king_result).to match_locations(%w[h7 g7 g8], NormalMoveCommand)
      end
    end

    context 'units are blocking moves' do
      it 'returns all moves that are not blocked by units' do
        blocking_pawn = Pawn.new('e4', black_player)
        bishop_unit = Bishop.new('c6', white_player)
        rook_unit = Rook.new('e6', white_player)
        queen_unit = Queen.new('g4', white_player)

        allow(board_allowed).to receive(:units).and_return([blocking_pawn, bishop_unit, rook_unit, queen_unit])

        bishop_result = game_allowed.allowed_actions(bishop_unit)
        rook_result = game_allowed.allowed_actions(rook_unit)
        queen_result = game_allowed.allowed_actions(queen_unit)

        expect(bishop_result).to match_locations(%w[b7 a8 b5 a4 d5 d7 e8], NormalMoveCommand)
        expect(rook_result).to match_locations(%w[e7 e8 d6 e5 f6 g6 h6], NormalMoveCommand)
        expect(queen_result).to match_locations(%w[h4 h5 h3 g5 g6 g7 g8 g3 g2 g1 e2 d1 f3 f4 f5], NormalMoveCommand)
      end
    end

    context 'unblocked enemies in move range' do
      it 'allows attack' do
        queen = Queen.new('f6', black_player)
        enemy_queen = Queen.new('f1', white_player)
        enemy_knight = Knight.new('d5', white_player)
        enemy_pawn = Pawn.new('d4', white_player)
        enemy_bishop = Bishop.new('f8', white_player)

        allow(board_allowed).to receive(:units).and_return([queen, enemy_queen, enemy_knight, enemy_pawn, enemy_bishop])

        queen_result = game_allowed.allowed_actions(queen)
        enemy_knight_result = game_allowed.allowed_actions(enemy_knight)

        expect(queen_result).to match_locations(%w[f1 f8 d4], AttackMoveCommand)
        expect(enemy_knight_result).to match_locations(%w[f6], AttackMoveCommand)
      end
    end

    context 'blocked enemies in move range' do
      it 'do not allow attack' do
        white_rook = Rook.new('a1', white_player)
        white_pawn = Pawn.new('a2', white_player)
        black_rook = Rook.new('a6', black_player)
        black_bishop = Bishop.new('c1', black_player)

        allow(board_allowed).to receive(:units).and_return([white_rook, white_pawn, black_rook, black_bishop])

        white_rook_result = game_allowed.allowed_actions(white_rook)
        black_rook_result = game_allowed.allowed_actions(black_rook)

        expect(white_rook_result).to match_locations(%w[c1], AttackMoveCommand)
        expect(black_rook_result).to match_locations(%w[a2], AttackMoveCommand)
      end
    end

    context 'enemy pawn just moved two spaces' do
      let(:enemy_pawn_jumped_two) { Pawn.new('d4', white_player) }
      let(:log_en_passant) { double('log_en_passant', last_move: { unit: enemy_pawn_jumped_two, last_location: 'd2' }) }

      before do
        allow(blank_log).to receive(:last_move).and_return({ unit: enemy_pawn_jumped_two, last_location: 'd2' })
        allow(blank_log).to receive(:unit_actions)
      end

      it 'adjacent pawn can en passant' do
        adjacent_pawn = Pawn.new('e4', black_player)
        board_allowed.add_unit(enemy_pawn_jumped_two, adjacent_pawn)
        adjacent_pawn_result = game_allowed.allowed_actions(adjacent_pawn)
        expect(adjacent_pawn_result).to match_locations(['d3'], EnPassantCommand)
      end

      it 'non-adjacent pawn cannot en passant' do
        non_adjacent_pawn = Pawn.new('f4', black_player)
        board_allowed.add_unit(enemy_pawn_jumped_two, non_adjacent_pawn)
        non_adjacent_pawn_result = game_allowed.allowed_actions(non_adjacent_pawn)
        en_passant_move_result = non_adjacent_pawn_result.detect { |action| action.is_a?(EnPassantCommand) }
        expect(en_passant_move_result).to be(nil)
      end
    end

    context 'pawn has not moved' do
      let(:new_pawn) { Pawn.new('h7', black_player) }
      let(:log_double) { double('game_log', last_move: nil) }

      before do
        allow(blank_board).to receive(:units).and_return([new_pawn])
        allow(blank_log).to receive(:unit_actions).and_return(nil)
      end

      it 'allowed to double move' do
        board_allowed.add_unit(new_pawn)
        result = game_allowed.allowed_actions(new_pawn)
        expect(result).to match_locations(%w[h5 h6], NormalMoveCommand)
      end
    end

    context 'pawn has moved' do
      let(:moved_pawn) { Pawn.new('h6', black_player) }

      before do
        allow(blank_board).to receive(:units).and_return([moved_pawn])
        allow(blank_log).to receive(:unit_actions).with(moved_pawn).and_return({ action: :normal_move,
                                                                                 last_location: 'h7' })
      end

      it 'not allowed to double move' do
        board_allowed.add_unit(moved_pawn)
        result = game_allowed.allowed_actions(moved_pawn)
        expect(result).not_to match_locations(['h4'], NormalMoveCommand)
      end
    end

    context 'pawn has not moved, but is blocked by another unit' do
      let(:new_pawn) { Pawn.new('h7', black_player) }
      let(:blocking_friendly) { Knight.new('h6', black_player) }
      let(:enemy_on_space) { Rook.new('h5', white_player) }

      before do
        allow(blank_log).to receive(:unit_actions).and_return(nil)
      end

      it 'not allowed to double move' do
        allow(board_allowed).to receive(:units).and_return([new_pawn, blocking_friendly])
        blocking_friendly_result = game_allowed.allowed_actions(new_pawn)

        expect(blocking_friendly_result).not_to match_locations(['h5'], NormalMoveCommand)
      end
    end

    context 'king and rook have not moved and no units blocking path' do
      let(:white_queenside_rook) { Rook.new('a1', white_player) }
      let(:black_queenside_rook) { Rook.new('a8', black_player) }
      let(:white_kingside_rook) { Rook.new('h1', white_player) }
      let(:black_kingside_rook) { Rook.new('h8', black_player) }
      let(:white_king) { King.new('e1', white_player) }
      let(:black_king) { King.new('e8', black_player) }

      before do
        allow(blank_log).to receive(:unit_actions)
        board_allowed.add_unit(white_queenside_rook, black_queenside_rook,
                               white_kingside_rook, black_kingside_rook,
                               white_king, black_king)
      end

      it 'can castle' do
        white_king_result = game_allowed.allowed_actions(white_king)
        white_queenside_rook_result = game_allowed.allowed_actions(white_queenside_rook)
        white_kingside_rook_result = game_allowed.allowed_actions(white_kingside_rook)
        black_king_reuslt = game_allowed.allowed_actions(black_king)
        black_queenside_king_result = game_allowed.allowed_actions(black_queenside_rook)
        black_kingside_rook_result = game_allowed.allowed_actions(black_kingside_rook)

        expect(white_king_result).to match_locations(['c1'], QueensideCastleCommand)
      end
    end

    context 'king and rook have not moved but units blocking path' do
      let(:black_queenside_rook) { Rook.new('a8', black_player) }
      let(:black_kingside_rook) { Rook.new('h8', black_player) }
      let(:black_king) { King.new('e8', black_player) }
      let(:white_bishop) { Bishop.new('g8', white_player) }
      let(:black_queen) { Queen.new('d8', white_player) }

      before do
        board_allowed.add_unit(black_queenside_rook, black_kingside_rook, black_king,
                               white_bishop, black_queen)
      end

      it 'cannot castle' do
        black_queenside_rook_result = game_allowed.allowed_actions(black_queenside_rook)
        black_kingside_rook_result = game_allowed.allowed_actions(black_kingside_rook)
        black_king_result = game_allowed.allowed_actions(black_king)

        expect(black_queenside_rook_result).not_to match_locations(['d8'], QueensideCastleCommand)
        expect(black_kingside_rook_result).not_to match_locations(['f8'], KingsideCastleCommand)
        expect(black_king_result).not_to match_locations(['g8'], KingsideCastleCommand)
        expect(black_king_result).not_to match_locations(['c8'], QueensideCastleCommand)
      end
    end

    context 'king and rook have not moved but king move spaces are under attack' do
      let(:white_queenside_rook) { Rook.new('a1', white_player) }
      let(:white_kingside_rook) { Rook.new('h1', white_player) }
      let(:white_king) { King.new('e1', white_player) }
      let(:black_rook) { Rook.new('f8', black_player) }
      let(:black_knight) { Knight.new('e3', black_player) }

      before do
        board_allowed.add_unit(white_queenside_rook, white_kingside_rook, white_king,
                               black_rook, black_knight)
      end

      it 'cannot castle' do
        queenside_rook_result = game_allowed.allowed_actions(white_queenside_rook)
        kingside_rook_result = game_allowed.allowed_actions(white_kingside_rook)
        king_result = game_allowed.allowed_actions(white_king)

        expect(queenside_rook_result).not_to match_locations(['d1'], QueensideCastleCommand)
        expect(kingside_rook_result).not_to match_locations(['f1'], KingsideCastleCommand)
        expect(king_result).not_to match_locations(['g1'], KingsideCastleCommand)
        expect(king_result).not_to match_locations(['c1'], QueensideCastleCommand)
      end
    end

    context 'king or rook have moved' do
      let(:queenside_rook) { Rook.new('a1', white_player) }
      let(:kingside_rook) { Rook.new('h1', white_player) }
      let(:king) { King.new('e1', white_player) }

      before do
        board_allowed.add_unit(queenside_rook, kingside_rook, king)
        allow(blank_log).to receive(:unit_actions).and_return({ action: :normal_move })
      end

      it 'cannot castle' do
        queenside_rook_result = game_allowed.allowed_actions(queenside_rook)
        kingside_rook_result = game_allowed.allowed_actions(kingside_rook)
        king_result = game_allowed.allowed_actions(king)

        expect(queenside_rook_result).not_to match_locations(['d1'], QueensideCastleCommand)
        expect(kingside_rook_result).not_to match_locations(['f1'], KingsideCastleCommand)
        expect(king_result).not_to match_locations(['g1'], KingsideCastleCommand)
        expect(king_result).not_to match_locations(['c1'], QueensideCastleCommand)
      end
    end
  end

  describe '#promote' do
    xit 'removes the pawn and adds the promotee' do
    end
  end

  describe '#stalemate?' do
    subject(:game_stalemate) { blank_game }
    let(:board_stalemate) { Board.new(blank_log) }
    let(:black_king) { King.new('a8', black_player) }
    let(:black_queen) { Queen.new('g8', black_player) }
    let(:black_rook1) { Rook.new('h8', black_player) }
    let(:black_pawn) { Pawn.new('a5', black_player) }
    let(:black_rook2) { Rook.new('a2', black_player) }
    let(:white_pawn1) { Pawn.new('a4', white_player) }
    let(:white_pawn2) { Pawn.new('c5', white_player) }
    let(:white_bishop) { Bishop.new('h6', white_player) }
    let(:white_king) { King.new('h1', white_player) }

    before do
      allow(game_stalemate).to receive(:board).and_return(board_stalemate)
      board_stalemate.add_unit(black_king, black_queen,
                               black_rook1,
                               black_pawn, black_rook2,
                               white_pawn1, white_pawn2,
                               white_bishop, white_king)
    end

    context 'king is not in check and a piece can move without putting it in check' do
      it 'returns false' do
        expect(game_stalemate).not_to be_stalemate(white_king)
      end
    end

    context 'king is not in check, but any move will put it in check' do
      it 'returns true' do
        black_knight = Knight.new('c6', black_player)
        game_stalemate.board.add_unit(black_knight)
        expect(game_stalemate).to be_stalemate(white_king)
      end
    end
  end

  describe '#check?' do
    let(:king) { King.new('b2', white_player) }
    let(:board_check) { Board.new(blank_log) }
    subject(:game_check) { blank_game }

    before do
      allow(game_check).to receive(:board).and_return(board_check)
    end

    context 'king unit is in check' do
      it 'returns true' do
        enemy_bishop = Bishop.new('f6', black_player)
        allow(board_check).to receive(:units).and_return([king, enemy_bishop])
        expect(game_check).to be_check(king)
      end
    end

    context 'king unit is not in check' do
      it 'returns false' do
        enemy_bishop = Bishop.new('e6', black_player)
        allow(board_check).to receive(:units).and_return([king, enemy_bishop])
        expect(game_check).not_to be_check(king)
      end
    end
  end

  describe '#checkmate?' do
    let(:white_king) { King.new('h1', white_player) }
    let(:black_rook) { Rook.new('g5', black_player) }
    let(:black_knight) { Knight.new('f2', black_player) }
    let(:board_checkmate) { Board.new(blank_log) }
    subject(:game_checkmate) { blank_game }

    before do
      allow(game_checkmate).to receive(:board).and_return(board_checkmate)
      board_checkmate.add_unit(white_king, black_rook, black_knight)
    end

    context 'king is in check but still has possible moves' do
      it 'returns false' do
        black_bishop = Bishop.new('c8', black_player)
        board_checkmate.add_unit(black_bishop)
        expect(game_checkmate).not_to be_checkmate(white_king)
      end
    end

    context 'king is in check and has no possible moves' do
      it 'returns true' do
        black_bishop = Bishop.new('b8', black_player)
        board_checkmate.add_unit(black_bishop)
        expect(game_checkmate).to be_checkmate(white_king)
      end
    end
  end
end
