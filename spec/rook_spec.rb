# frozen_string_literal: true

require './lib/units/rook'

describe Rook do
  describe '#initialize' do
    context 'player color is black' do
      let(:black_player) { double('player', name: 'player1', color: :black) }
      subject(:black_rook) { described_class.new('a8', black_player) }

      it 'sets symbol to black rook' do
        expect(black_rook.symbol).to eq('♜')
      end
    end

    context 'player color is white' do
      let(:white_player) { double('player', name: 'player1', color: :white) }
      subject(:white_rook) { described_class.new('a1', white_player) }

      it 'sets symbol to white rook' do
        expect(white_rook.symbol).to eq('♖')
      end
    end
  end
end
