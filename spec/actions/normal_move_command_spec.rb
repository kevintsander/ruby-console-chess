# frozen_string_literal: true

require './lib/actions/normal_move_command'

describe NormalMoveCommand do
  let(:board) { double('board') }
  let(:unit) { double('unit', location: 'g4') }
  subject(:normal_move) { described_class.new(board, unit, 'g8') }

  before do
    allow(unit).to receive(:move)
  end

  describe '#perform_action' do
    it 'moves the unit' do
      expect(unit).to receive(:move).with('g8').once
      normal_move.perform_action
    end

    context 'unit set for promotion' do
      let(:white_player) { double('player', color: :white) }
      let(:promote_pawn) { double('pawn', player: white_player) }
      subject(:promote_move) { described_class.new(board, promote_pawn, 'a8') }

      it 'replaces the pawn with a new unit' do
        allow(promote_pawn).to receive(:location).and_return('')
        allow(promote_pawn).to receive(:move)
        allow(board).to receive(:add_unit)
        promote_move.promoted_unit_class = Queen
        expect(promote_pawn).to receive(:promote)
        expect(Queen).to receive(:new).with('a8', white_player)
        expect(board).to receive(:add_unit).once
        promote_move.perform_action
      end
    end
  end
end
