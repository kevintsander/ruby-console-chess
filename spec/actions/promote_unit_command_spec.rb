# frozen_string_literal: true

require './lib/actions/promote_unit_command'

describe PromoteUnitCommand do
  describe '#perform_action' do
    let(:board) { double('board') }
    let(:player) { double('player', color: :black) }
    let(:pawn) { Pawn.new('d1', player) }
    subject(:promote) { described_class.new(board, pawn, 'd1', Queen) }

    it 'sends message to promote (remove) pawn and create new unit' do
      allow(pawn).to receive(:promote)
      allow(board).to receive(:add_unit)
      expect(pawn).to receive(:promote).once
      expect(Queen).to receive(:new).with('d1', player).once
      expect(board).to receive(:add_unit).once
      promote.perform_action
    end
  end
end
