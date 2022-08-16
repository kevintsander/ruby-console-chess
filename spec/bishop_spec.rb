# frozen_string_literal: true

require './lib/units/bishop'

describe Bishop do
  describe '#initialize' do
    context 'player color is black' do
      let(:black_player) { double('player', name: 'player1', color: :black) }
      subject(:black_king) { described_class.new('c8', black_player) }

      it 'sets symbol to black bishop' do
        expect(black_king.symbol).to eq('♝')
      end
    end

    context 'player color is white' do
      let(:white_player) { double('player', name: 'player1', color: :white) }
      subject(:white_king) { described_class.new('c1', white_player) }

      it 'sets symbol to white bishop' do
        expect(white_king.symbol).to eq('♗')
      end
    end
  end
end
