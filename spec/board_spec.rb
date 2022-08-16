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

  describe '#defender_blocking_move?' do
    subject(:board_block) { described_class.new([player1, player2]) }

    context 'horizontal move with no defenders between' do
      let(:move_unit) { double('unit', location: 'g2') }
      let(:other_unit) { double('unit', location: 'c3') }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, other_unit])
      end

      it 'returns false' do
        to_location = 'g5'
        from_coordinates = board_block.location_coordinates(move_unit.location)
        to_coordinates = board_block.location_coordinates(to_location)
        expect(board_block).not_to be_defender_blocking_move(from_coordinates, to_coordinates)
      end
    end

    context 'horizontal move with defenders between' do
      let(:move_unit) { double('unit', location: 'g2') }
      let(:blocking_unit) { double('unit', location: 'g4') }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, blocking_unit])
      end

      it 'returns true' do
        to_location = 'g5'
        from_coordinates = board_block.location_coordinates(move_unit.location)
        to_coordinates = board_block.location_coordinates(to_location)

        expect(board_block).to be_defender_blocking_move(from_coordinates, to_coordinates)
      end
    end
    context 'diagonal move with no defenders between' do
      let(:move_unit) { double('unit', location: 'b2') }
      let(:other_unit) { double('unit', location: 'd5') }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, other_unit])
      end

      it 'returns false' do
        to_location = 'h8'
        from_coordinates = board_block.location_coordinates(move_unit.location)
        to_coordinates = board_block.location_coordinates(to_location)

        expect(board_block).not_to be_defender_blocking_move(from_coordinates, to_coordinates)
      end
    end
    context 'diagonal move with defenders between' do
      let(:move_unit) { double('unit', location: 'b2') }
      let(:blocking_unit) { double('unit', location: 'd4') }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, blocking_unit])
      end

      it 'returns true' do
        to_location = 'h8'
        from_coordinates = board_block.location_coordinates(move_unit.location)
        to_coordinates = board_block.location_coordinates(to_location)

        expect(board_block).to be_defender_blocking_move(from_coordinates, to_coordinates)
      end
    end
  end
end