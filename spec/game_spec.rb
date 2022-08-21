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

    before do
      blank_game.instance_variable_set(:@board, board_allowed)
    end

    context 'moves inside boundary' do
      it 'returns all moves' do
        pawn_unit = Pawn.new('c3', white_player)
        knight_unit = Knight.new('e5', black_player)
        king_unit = King.new('f6', white_player)
        board_allowed.add_unit(pawn_unit)
        pawn_result = game_allowed.allowed_actions(pawn_unit)
        board_allowed.clear_units.add_unit(knight_unit)
        knight_result = game_allowed.allowed_actions(knight_unit)
        board_allowed.clear_units.add_unit(king_unit)
        king_result = game_allowed.allowed_actions(king_unit)

        expect(pawn_result[:move_standard].sort).to eq(%w[c4].sort)
        expect(knight_result[:jump_standard].sort).to eq(%w[g4 f3 g6 f7 d7 c6 c4 d3].sort)
        expect(king_result[:move_standard].sort).to eq(%w[g5 g6 g7 f5 f7 e5 e6 e7].sort)
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

        allow(board_allowed).to receive(:units).and_return([pawn_unit], [rook_unit], [bishop_unit], [queen_unit],
                                                           [king_unit])
        pawn_result = game_allowed.allowed_actions(pawn_unit)
        rook_result = game_allowed.allowed_actions(rook_unit)
        knight_result = game_allowed.allowed_actions(knight_unit)
        bishop_result = game_allowed.allowed_actions(bishop_unit)
        queen_result = game_allowed.allowed_actions(queen_unit)
        king_result = game_allowed.allowed_actions(king_unit)

        expect(pawn_result).to be_empty
        expect(rook_result[:move_standard].sort).to eq(%w[c1 c2 c4 c5 c6 c7 c8 a3 b3 d3 e3 f3 g3 h3].sort)
        expect(knight_result[:jump_standard].sort).to eq(%w[f7 g6].sort)
        expect(bishop_result[:move_standard].sort).to eq(%w[d1 f1 d3 c4 b5 a6 f3 g4 h5].sort)
        expect(queen_result[:move_standard].sort).to eq(%w[a8 a7 a6 b8 c8 c7 d7 e7 f7 g7 h7 c6 d5 e4 f3 g2 h1 b6 b5 b4
                                                           b3 b2 b1].sort)
        expect(king_result[:move_standard].sort).to eq(%w[h7 g7 g8].sort)
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

        expect(bishop_result[:move_standard].sort).to eq(%w[b7 a8 b5 a4 d5 d7 e8].sort)
        expect(rook_result[:move_standard].sort).to eq(%w[e7 e8 d6 e5 f6 g6 h6].sort)
        expect(queen_result[:move_standard].sort).to eq(%w[h4 h5 h3 g5 g6 g7 g8 g3 g2 g1 e2 d1 f3 f4 f5].sort)
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

        expect(queen_result[:move_attack].sort).to eq(%w[f1 f8 d4].sort)
        expect(enemy_knight_result[:jump_attack]).to eq(%w[f6])
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

        expect(white_rook_result[:move_attack]).to eq(%w[c1])
        expect(black_rook_result[:move_attack]).to eq(%w[a2])
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
        adjacent_pawn_result = game_allowed.allowed_actions(adjacent_pawn)
        expect(adjacent_pawn_result[:en_passant]).to eq(['d3'])
      end

      it 'non-adjacent pawn cannot en passant' do
        non_adjacent_pawn = Pawn.new('f4', black_player)
        non_adjacent_pawn_result = game_allowed.allowed_actions(non_adjacent_pawn)
        expect(non_adjacent_pawn_result[:en_passant]).to eq(nil)
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
        result = game_allowed.allowed_actions(new_pawn)
        expect(result[:initial_double]).to eq(['h5'])
      end
    end

    context 'pawn has moved' do
      let(:moved_pawn) { Pawn.new('h6', black_player) }

      before do
        allow(blank_board).to receive(:units).and_return([moved_pawn])
        allow(blank_log).to receive(:unit_actions).with(moved_pawn).and_return({ action: :move_standard,
                                                                                 last_location: 'h7' })
      end

      it 'not allowed to double move' do
        result = game_allowed.allowed_actions(moved_pawn)
        expect(result[:initial_double]).to eq(nil)
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
        allow(board_allowed).to receive(:units).and_return([new_pawn, enemy_on_space])
        enemy_on_space_result = game_allowed.allowed_actions(new_pawn)

        expect(blocking_friendly_result[:initial_double]).to eq(nil)
        expect(enemy_on_space_result[:initial_double]).to eq(nil)
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

        expect(white_king_result[:queenside_castle]).to eq(['c1'])
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

        expect(black_queenside_rook_result[:queenside_castle]).to eq(nil)
        expect(black_kingside_rook_result[:kingside_castle]).to eq(nil)
        expect(black_king_result[:kingside_castle]).to eq(nil)
        expect(black_king_result[:queenside_castle]).to eq(nil)
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

        expect(queenside_rook_result[:queenside_castle]).to eq(nil)
        expect(kingside_rook_result[:kingside_castle]).to eq(nil)
        expect(king_result[:kingside_castle]).to eq(nil)
        expect(king_result[:queenside_castle]).to eq(nil)
      end
    end

    context 'king or rook have moved' do
      let(:queenside_rook) { Rook.new('a1', white_player) }
      let(:kingside_rook) { Rook.new('h1', white_player) }
      let(:king) { King.new('e1', white_player) }

      before do
        board_allowed.add_unit(queenside_rook, kingside_rook, king)
        allow(blank_log).to receive(:unit_actions).and_return({ action: :move_standard })
      end

      it 'cannot castle' do
        queenside_rook_result = game_allowed.allowed_actions(queenside_rook)
        kingside_rook_result = game_allowed.allowed_actions(kingside_rook)
        king_result = game_allowed.allowed_actions(king)
        expect(queenside_rook_result[:queenside_castle]).to eq(nil)
        expect(kingside_rook_result[:kingside_castle]).to eq(nil)
        expect(king_result[:queenside_castle]).to eq(nil)
        expect(king_result[:kingside_castle]).to eq(nil)
      end
    end
  end

  describe '#new_game_units' do
    subject(:new_game) { described_class.new([white_player, black_player]) }

    it 'returns correct starting chess game pieces' do
      result = new_game.new_game_units
      [white_player, black_player].each do |player|
        player_units = result.select { |unit| unit.player == player }

        king_unit_count = player_units.count { |unit| unit.is_a?(King) }
        queen_unit_count = player_units.count { |unit| unit.is_a?(Queen) }
        bishop_unit_count = player_units.count { |unit| unit.is_a?(Bishop) }
        knight_unit_count = player_units.count { |unit| unit.is_a?(Knight) }
        rook_unit_count = player_units.count { |unit| unit.is_a?(Rook) }
        pawn_unit_count = player_units.count { |unit| unit.is_a?(Pawn) }
        expect(king_unit_count).to eq(1)
        expect(queen_unit_count).to eq(1)
        expect(bishop_unit_count).to eq(2)
        expect(knight_unit_count).to eq(2)
        expect(rook_unit_count).to eq(2)
        expect(pawn_unit_count).to eq(8)
      end
    end

    describe 'unit moves' do
      subject(:move_game) { blank_game }
      let(:move_board) { double('board', units: []) }

      before do
        allow(move_game).to receive(:board).and_return(move_board)
      end

      describe '#move_unit' do
        let(:unit) { double('unit', player: white_player, location: 'g2') }

        before do
          allow(move_game).to receive(:allowed_actions).with(unit)
                                                       .and_return({ move_standard: ['g3'],
                                                                     initial_double: ['g4'] })
          allow(unit).to receive(:move)
        end

        it 'sends move command to the unit' do
          expect(unit).to receive(:move).with('g3').once
          move_game.move_unit(white_player, unit, 'g3')
          expect(unit).to receive(:move).with('g4').once
          move_game.move_unit(white_player, unit, 'g4')
        end

        it 'sends move to log' do
          expect(blank_log).to receive(:log_action).once
          move_game.move_unit(white_player, unit, 'g4')
        end
      end

      describe '#attack_unit' do
        let(:pawn) { double('pawn', player: white_player, location: 'g4') }
        let(:king) { double('king', player: black_player, location: 'f5') }

        before do
          allow(move_game).to receive(:allowed_actions).with(king)
                                                       .and_return({ move_attack: ['g4'],
                                                                     move_standard: [%w[e6 f6 g6 e5 g5 f4 h4]] })
          allow(king).to receive(:move)
          allow(pawn).to receive(:capture)
          allow(move_board).to receive(:unit_at).with('g4').and_return(pawn)
        end

        it 'moves the unit and captures the unit on the same space' do
          expect(king).to receive(:move).with('g4').once
          expect(pawn).to receive(:capture).once
          move_game.attack_unit(white_player, king, 'g4')
        end

        it 'sends moved unit and captured unit to log' do
          expect(blank_log).to receive(:log_action).with(move_game.turn, white_player, :attack, king, 'g4', 'f5')
          expect(blank_log).to receive(:log_action).with(move_game.turn, white_player, :captured, pawn, nil, 'g4')
          move_game.attack_unit(white_player, king, 'g4')
        end
      end

      describe '#en_passant_unit' do
        let(:white_pawn) { double('pawn', player: white_player, location: 'c4', forward: :+) }
        let(:black_pawn) { double('pawn', player: black_player, location: 'd4', forward: :-) }

        before do
          allow(move_game).to receive(:allowed_actions).with(black_pawn)
                                                       .and_return({ en_passant: ['c3'] })
          allow(move_board).to receive(:delta_location).with('c3', [1, 0]).and_return('c4')
          allow(black_pawn).to receive(:move)
          allow(white_pawn).to receive(:capture)
          allow(move_board).to receive(:unit_at).with('c4').and_return(white_pawn)
        end

        it 'moves a unit to the locaiton and captures the unit on space behind' do
          expect(black_pawn).to receive(:move).with('c3')
          expect(white_pawn).to receive(:capture)
          move_game.en_passant_unit(black_player, black_pawn, 'c3')
        end

        it 'sends move unit and captured unit to log' do
          expect(blank_log).to receive(:log_action).with(move_game.turn, black_player, :en_passant, black_pawn, 'c3',
                                                         'd4')
          expect(blank_log).to receive(:log_action).with(move_game.turn,
                                                         black_player, :captured, white_pawn, nil, 'c4')
          move_game.en_passant_unit(black_player, black_pawn, 'c3')
        end
      end

      describe '#castle_unit' do
        let(:castle_board) { Board.new(blank_log) }
        let(:kingside_rook) { Rook.new('h1', white_player) }
        let(:queenside_rook) { Rook.new('a1', white_player) }
        let(:king) { King.new('e1', white_player) }

        before do
          castle_board.add_unit(kingside_rook, queenside_rook, king)
          allow(move_game).to receive(:board).and_return(castle_board)
          allow(kingside_rook).to receive(:move)
          allow(king).to receive(:capture)
        end

        context 'kingside castling from the king' do
          it 'castles the kingside rook and king' do
            expect(kingside_rook).to receive(:move).with('f1')
            expect(king).to receive(:move).with('g1')
            move_game.castle_unit(white_player, :kingside_castle, king, 'g1')
          end
        end

        context 'kingside castling from the rook' do
          it 'castles the kingside rook and king' do
            expect(king).to receive(:move).with('g1')
            expect(kingside_rook).to receive(:move).with('f1')
            move_game.castle_unit(white_player, :kingside_castle, kingside_rook, 'f1')
          end
        end

        it 'sends both moved units to log' do
          expect(blank_log).to receive(:log_action).with(move_game.turn, white_player, :kingside_castle, kingside_rook, 'f1',
                                                         'h1')
          expect(blank_log).to receive(:log_action).with(move_game.turn, white_player, :kingside_castle, king, 'g1',
                                                         'e1')
          move_game.castle_unit(white_player, :kingside_castle, king, 'g1')
        end
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
      it 'king is not in check but any move will put it in check' do
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
