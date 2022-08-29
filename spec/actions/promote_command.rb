# frozen_string_literal: true

require './lib/actions/promote_command'

describe PromoteCommand do
  let(:board) { double('board') }
  let(:player) { double('player') }
  let(:unit) { double('unit', location: 'g8', player: player) }
  subject(:promote) { described_class.new(board, unit, 'g8', Queen) }

  before do
    allow(unit).to receive(:promote)
    allow(board).to receive(:add_unit)
  end

  describe '#perform_action' do
    it 'promotes the unit and adds a new unit' do
      expect(unit).to receive(:promote).once
      expect(board).to receive(:add_unit).once
      promote.perform_action
    end
  end
end
