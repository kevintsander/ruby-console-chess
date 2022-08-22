# frozen_string_literal: true

require './lib/actions/en_passant_command'

describe EnPassantCommand do
  let(:board) { double('board') }
  let(:en_passanter) { double('en_passanter', location: 'd4', forward: :-) }
  let(:en_passantee) { double('en_passantee', location: 'c4', forward: :+) }
  subject(:en_passant) { described_class.new(board, en_passanter, 'd3') }

  describe '#perform_action' do
    it 'moves the unit and captures one on the same space' do
      allow(board).to receive(:unit_at).and_return(en_passantee)
      allow(en_passanter).to receive(:move)
      allow(en_passantee).to receive(:capture)
      expect(en_passanter).to receive(:move).with('d3').once
      expect(en_passantee).to receive(:capture).once
      en_passant.perform_action
    end
  end
end
