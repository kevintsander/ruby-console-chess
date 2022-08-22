# frozen_string_literal: true

require './lib/actions/kingside_castle_command'

describe KingsideCastleCommand do
  let(:board) { double('board') }
  let(:kingside_rook) { double('kingside_rook', location: 'h8') }
  let(:king) { double('king', location: 'e8') }
  subject(:kingside_castle) { described_class.new(board, king, 'g8') }

  describe '#perform_action' do
    it 'moves the unit and captures one on the same space' do
      allow(board).to receive(:other_castle_unit_move_hash).and_return({ unit: kingside_rook, move_location: 'f8' })
      allow(king).to receive(:move).with('g8')
      allow(kingside_rook).to receive(:move).with('f8')
      expect(king).to receive(:move).with('g8').once
      expect(kingside_rook).to receive(:move).with('f8').once
      kingside_castle.perform_action
    end
  end
end
