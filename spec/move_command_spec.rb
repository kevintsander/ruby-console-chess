# frozen_string_literal: true

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
