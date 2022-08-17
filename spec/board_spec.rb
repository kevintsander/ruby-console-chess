# frozen_string_literal: true

require './lib/board'

describe Board do
  let(:player1) { double('player1', color: :white) }
  let(:player2) { double('player2', color: :black) }

  describe '#initialize' do
    it 'creates all chess game pieces' do
      board = described_class.new([player1, player2])
      [player1, player2].each do |player|
        player_units = board.units.select { |unit| unit.player == player }

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
  end

  describe '#unit' do
    subject(:board) { described_class.new([player1, player2]) }
    let(:unit) { double('unit', location: 'g3') }

    before do
      allow(board).to receive(:units).and_return([unit])
    end

    context 'a unit is at the location' do
      it 'return true' do
        result = board.unit('g3')
        expect(result).to be(unit)
      end
    end

    context 'a unit is not at the location' do
      it 'return true' do
        result = board.unit('c2')
        expect(result).to be_nil
      end
    end
  end

  describe '#unit_blocking_move?' do
    subject(:board_block) { described_class.new([player1, player2]) }

    context 'horizontal move with no other units between' do
      let(:move_unit) { double('unit', location: 'g2', player: player1) }
      let(:friendly_unit) { double('unit', location: 'c3', player: player1) }
      let(:unfriendly_unit) { double('unit', location: 'a1', player: player2) }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit, unfriendly_unit])
      end

      it 'returns false' do
        to_coordinates = board_block.location_coordinates('g5')
        expect(board_block).not_to be_unit_blocking_move(move_unit, to_coordinates)
      end
    end

    context 'horizontal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'g2', player: player1) }
      let(:friendly_unit) { double('unit', location: 'g4', player: player1) }
      let(:unfriendly_unit) { double('unit', location: 'g3', player: player2) }

      it 'returns true' do
        to_coordinates = board_block.location_coordinates('g5')
        # check unfriendly
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, to_coordinates)
        # check friendly
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, to_coordinates)
      end
    end
    context 'diagonal move with no units between' do
      let(:move_unit) { double('unit', location: 'b2', player: player1) }
      let(:friendly_unit) { double('unit', location: 'd5', player: player1) }
      let(:unfriendly_unit) { double('unit', location: 'e8', player: player2) }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit, unfriendly_unit])
      end

      it 'returns false' do
        to_coordinates = board_block.location_coordinates('h8')
        expect(board_block).not_to be_unit_blocking_move(move_unit, to_coordinates)
      end
    end

    context 'diagonal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'b2', player: player1) }
      let(:friendly_unit) { double('unit', location: 'd4', player: player1) }
      let(:unfriendly_unit) { double('unit', location: 'f6', player: player2) }

      it 'returns true' do
        to_coordinates = board_block.location_coordinates('h8')
        # check unfriendly
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, to_coordinates)
        # check friendly
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, to_coordinates)
      end
    end

    context 'friendly unit on move space' do
      let(:move_unit) { double('unit', location: 'b2', player: player1) }
      let(:friendly_unit) { double('unit', location: 'd4', player: player1) }

      it 'returns true' do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        to_coordinates = board_block.location_coordinates('d4')
        expect(board_block).to be_unit_blocking_move(move_unit, to_coordinates)
      end
    end

    context 'unfriendly unit on move space' do
      let(:move_unit) { double('unit', location: 'b2', player: player1) }
      let(:unfriendly_unit) { double('unit', location: 'd4', player: player2) }

      it 'returns false' do
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        to_coordinates = board_block.location_coordinates('d4')
        expect(board_block).not_to be_unit_blocking_move(move_unit, to_coordinates)
      end
    end
  end
end
