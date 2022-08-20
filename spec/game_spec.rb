# frozen_string_literal: true

require './lib/game'

describe Game do
  let(:white_player) { double('player', color: :white) }
  let(:black_player) { double('player', color: :black) }

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
      let(:unit) { double('unit', player: white_player, location: 'g2') }
      let(:move_board) { double('board', units: [unit]) }
      subject(:move_game) { described_class.new([white_player, black_player]) }

      before do
        allow(move_game).to receive(:board).and_return(move_board)
        allow(move_board).to receive(:allowed_actions).with(unit)
                                                      .and_return({ move_standard: ['g3'],
                                                                    initial_double: ['g4'] })
        allow(unit).to receive(:move).with('g3')
      end

      it 'sends move command to the unit' do
        expect(unit).to receive(:move).with('g3').once
        move_game.move_unit(white_player, unit, 'g3')
        # expect(unit).to receive(:move).with('g4').once
        # move_game.move_unit(white_player, unit, 'g4')
      end

      xit 'sends move to log' do
        expect(pawn.game_log)
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
end
