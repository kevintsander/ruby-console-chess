# frozen_string_literal: true

require './lib/units/pawn'

describe Pawn do
  context 'black pawn' do
    let(:black_player) { double('black_player', name: 'player2', color: :black) }
    subject(:pawn_seven) { described_class.new('g7', black_player) }
    it 'can only attack or move to lower rank' do
      move_ranks = pawn_seven.allowed_actions_deltas[:move_standard].map { |item| item[0] }
      attack_ranks = pawn_seven.allowed_actions_deltas[:move_attack].map { |item| item[0] }
      en_passant_ranks = pawn_seven.allowed_actions_deltas[:en_passant].map { |item| item[0] }
      expect(move_ranks).to include(-1)
      expect(move_ranks).not_to include(1)
      expect(attack_ranks).to include(-1)
      expect(attack_ranks).not_to include(1)
      expect(en_passant_ranks).to include(-1)
      expect(en_passant_ranks).not_to include(1)
    end
  end

  context 'white pawn' do
    let(:white_player) { double('white_player', name: 'player1', color: :white) }
    subject(:pawn_two) { described_class.new('g2', white_player) }
    it 'can only attack or move to higher rank' do
      move_ranks = pawn_two.allowed_actions_deltas[:move_standard].map { |item| item[0] }
      attack_ranks = pawn_two.allowed_actions_deltas[:move_attack].map { |item| item[0] }
      en_passant_ranks = pawn_two.allowed_actions_deltas[:en_passant].map { |item| item[0] }
      expect(move_ranks).to include(1)
      expect(move_ranks).not_to include(-1)
      expect(attack_ranks).to include(1)
      expect(attack_ranks).not_to include(-1)
      expect(en_passant_ranks).to include(1)
      expect(en_passant_ranks).not_to include(-1)
    end
  end

  describe '#initialize' do
    context 'player color is black' do
      let(:black_player) { double('player', name: 'player1', color: :black) }
      subject(:black_pawn) { described_class.new('a2', black_player) }

      it 'sets symbol to black pawn' do
        expect(black_pawn.symbol).to eq('♟')
      end
    end

    context 'player color is white' do
      let(:white_player) { double('player', name: 'player1', color: :white) }
      subject(:white_pawn) { described_class.new('a2', white_player) }

      it 'sets symbol to white pawn' do
        expect(white_pawn.symbol).to eq('♙')
      end
    end
  end
end
