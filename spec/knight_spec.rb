# frozen_string_literal: true

require './lib/units/knight'

describe Knight do
  describe '#initialize' do
    context 'player color is black' do
      let(:black_player) { double('player', name: 'player1', color: :black) }
      subject(:black_knight) { described_class.new('g8', black_player) }

      it 'sets symbol to black knight' do
        expect(black_knight.symbol).to eq('♞')
      end
    end

    context 'player color is white' do
      let(:white_player) { double('player', name: 'player1', color: :white) }
      subject(:white_knight) { described_class.new('g1', white_player) }

      it 'sets symbol to white knight' do
        expect(white_knight.symbol).to eq('♘')
      end
    end
  end
end
