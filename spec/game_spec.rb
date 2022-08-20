# frozen_string_literal: true

require './lib/game'

describe Game do
  let(:white_player) { double('player', color: :white) }
  let(:black_player) { double('player', color: :black) }
  subject(:blank_game) { described_class.new([white_player, black_player]) }

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

    describe '#move_unit' do
      subject(:move_game) { blank_game }
      let(:unit) { double('unit', player: white_player, location: 'g2') }
      let(:move_board) { double('board', units: [unit]) }
      let(:move_log) { double('game_log', log: []) }

      before do
        allow(move_game).to receive(:board).and_return(move_board)
        allow(move_game).to receive(:game_log).and_return(move_log)
        allow(move_board).to receive(:allowed_actions).with(unit)
                                                      .and_return({ move_standard: ['g3'],
                                                                    initial_double: ['g4'] })
        allow(move_log).to receive(:log_action)
        allow(unit).to receive(:move)
      end

      it 'sends move command to the unit' do
        expect(unit).to receive(:move).with('g3').once
        move_game.move_unit(white_player, unit, 'g3')
        expect(unit).to receive(:move).with('g4').once
        move_game.move_unit(white_player, unit, 'g4')
      end

      it 'sends move to log' do
        expect(move_log).to receive(:log_action).once
        move_game.move_unit(white_player, unit, 'g4')
      end
    end

    describe '#attack' do
      xit 'moves a unit to the location and captures the unit on the space' do
      end

      xit 'sends moved unit and captured unit to log' do
      end
    end

    describe '#en_passant' do
      xit 'moves a unit to the locaiton and captures the unit on space behind' do
      end

      xit 'sends move unit and captured unit to log' do
      end
    end

    describe '#kingside_castle' do
      xit 'castles the kingside rook and king' do
      end

      xit 'sends both moved units to log' do
      end
    end

    describe '#queenside_castle' do
      xit 'castles the queenside rook and king' do
      end

      xit 'sends both moved units to log'
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
      xit 'king is not in check but any move will put it in check' do
        black_knight = Knight.new('c6', black_player)
        game_stalemate.board.add_unit(black_knight)
        expect(game_stalemate).to be_stalemate(white_king)
      end
    end
  end
end
