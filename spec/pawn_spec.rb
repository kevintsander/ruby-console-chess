# frozen_string_literal: true

require './lib/units/pawn'

describe Pawn do
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
