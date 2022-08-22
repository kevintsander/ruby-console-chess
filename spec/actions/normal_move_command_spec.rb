# frozen_string_literal: true

require './lib/actions/normal_move_command'

describe NormalMoveCommand do
  let(:board) { double('board') }
  let(:unit) { double('unit', location: 'g4') }
  subject(:normal_move) { described_class.new(board, unit, 'g8') }

  describe '#perform_action' do
    it 'moves the unit' do
      allow(unit).to receive(:move)
      expect(unit).to receive(:move).with('g8').once
      normal_move.perform_action
    end
  end
end
