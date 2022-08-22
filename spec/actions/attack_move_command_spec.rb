# frozen_string_literal: true

require './lib/actions/attack_move_command'

describe AttackMoveCommand do
  let(:board) { double('board') }
  let(:attacker) { double('unit', location: 'g4') }
  let(:attackee) { double('unit', location: 'h3') }
  subject(:attack_move) { described_class.new(board, attacker, 'h3') }

  describe '#perform_action' do
    it 'moves the unit and captures one on the same space' do
      allow(board).to receive(:unit_at).and_return(attackee)
      allow(attacker).to receive(:move)
      allow(attackee).to receive(:capture)
      expect(attacker).to receive(:move).with('h3').once
      expect(attackee).to receive(:capture).once
      attack_move.perform_action
    end
  end
end
