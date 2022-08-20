# frozen_string_literal: true

require './lib/game'

describe Game do
  let(:white_player) { double('player', color: :white) }
  let(:black_player) { double('player', color: :black) }
  subject(:blank_log) { double('blank_log', log: []) }
  subject(:blank_board) { double('board', units: []) }
  subject(:blank_game) { described_class.new([white_player, black_player]) }

  before do
    blank_game.instance_variable_set(:@board, blank_board)
    blank_game.instance_variable_set(:@game_log, blank_log)
    allow(blank_log).to receive(:log_action)
    allow(blank_log).to receive(:unit_actions)
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
          allow(move_board).to receive(:allowed_actions).with(unit)
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
          allow(move_board).to receive(:allowed_actions).with(king)
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
          allow(move_board).to receive(:allowed_actions).with(black_pawn)
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
    let(:black_king) { King.new('a8', black_player) }
    let(:black_queen) { Queen.new('g8', black_player) }
    let(:black_rook1) { Rook.new('h8', black_player) }
    let(:black_pawn) { Pawn.new('a5', black_player) }
    let(:black_rook2) { Rook.new('a2', black_player) }
    let(:white_pawn1) { Pawn.new('a4', white_player) }
    let(:white_pawn2) { Pawn.new('c5', white_player) }
    let(:white_bishop) { Bishop.new('h6', white_player) }
    let(:white_king) { King.new('h1', white_player) }
    let(:game_stalemate) { described_class.new([black_player, white_player]) }

    before do
      game_stalemate.board.add_unit(black_king, black_queen,
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
end
