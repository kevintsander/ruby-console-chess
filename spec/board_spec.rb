# frozen_string_literal: true

require './lib/board'

describe Board do
  let(:white_player) { double('white_player', color: :white) }
  let(:black_player) { double('black_player', color: :black) }
  let(:game_log) { double('game_log', last_move: nil) }

  describe '#unit_at' do
    subject(:board) { described_class.new(game_log) }
    let(:unit) { double('unit', location: 'g3') }

    before do
      board.add_unit(unit)
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
    subject(:board_block) { described_class.new(game_log) }

    context 'horizontal move with no other units between' do
      let(:move_unit) { double('unit', location: 'g2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'c3', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'a1', player: black_player) }

      before do
        board_block.add_unit(move_unit, friendly_unit, unfriendly_unit)
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
        board_block.add_unit(move_unit, unfriendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
        # check friendly
        board_block.clear_units.add_unit(move_unit, friendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
      end
    end
    context 'diagonal move with no units between' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd5', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'e8', player: black_player) }

      it 'returns false' do
        board_block.add_unit(move_unit, friendly_unit, unfriendly_unit)
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'h8')
      end
    end

    context 'diagonal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd4', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'f6', player: black_player) }

      it 'returns true' do
        # check unfriendly
        board_block.add_unit(move_unit, unfriendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
        # check friendly
        board_block.clear_units.add_unit(move_unit, friendly_unit)
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
      end
    end
  end
end
