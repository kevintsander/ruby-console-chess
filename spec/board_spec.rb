# frozen_string_literal: true

require './lib/board'

describe Board do
  let(:white_player) { double('white_player', color: :white) }
  let(:black_player) { double('black_player', color: :black) }

  describe '#initialize' do
    it 'creates all chess game pieces' do
      board = described_class.new([white_player, black_player])
      [white_player, black_player].each do |player|
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
    subject(:board) { described_class.new([white_player, black_player]) }
    let(:unit) { double('unit', location: 'g3') }

    before do
      allow(board).to receive(:units).and_return([unit])
    end

    context 'a unit is at the location' do
      it 'return true' do
        result = board.unit_at('g3')
        expect(result).to be(unit)
      end
    end

    context 'a unit is not at the location' do
      it 'return true' do
        result = board.unit_at('c2')
        expect(result).to be_nil
      end
    end
  end

  describe '#unit_blocking_move?' do
    subject(:board_block) { described_class.new([white_player, black_player]) }

    context 'horizontal move with no other units between' do
      let(:move_unit) { double('unit', location: 'g2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'c3', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'a1', player: black_player) }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit, unfriendly_unit])
      end

      it 'returns false' do
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'g5')
      end
    end

    context 'horizontal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'g2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'g4', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'g3', player: black_player) }

      it 'returns true' do
        # check unfriendly
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
        # check friendly
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
      end
    end
    context 'diagonal move with no units between' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd5', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'e8', player: black_player) }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit, unfriendly_unit])
      end

      it 'returns false' do
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'h8')
      end
    end

    context 'diagonal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd4', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'f6', player: black_player) }

      it 'returns true' do
        # check unfriendly
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
        # check friendly
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
      end
    end

    context 'friendly unit on move space' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd4', player: white_player) }

      it 'returns true' do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'd4')
      end
    end

    context 'unfriendly unit on move space' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'd4', player: black_player) }

      it 'returns false' do
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'd4')
      end
    end
  end

  describe '#allowed_actions' do
    subject(:board_allowed) { described_class.new([white_player, black_player]) }

    context 'moves inside boundary' do
      it 'returns all moves' do
        pawn_unit = Pawn.new('c3', white_player)
        allow(board_allowed).to receive(:units).and_return([pawn_unit])
        result = board_allowed.allowed_actions(pawn_unit)
        expect(result).to eq({ move_standard: ['c4'] })
      end
    end

    context 'friendly units are blocking moves' do
      xit 'returns all moves that are not out of bounds or blocked by friendly units' do
      end
    end
  end
end
