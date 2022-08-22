# frozen_string_literal: true

require './lib/units/queen'

describe Queen do
  describe '#initialize' do
    context 'player color is black' do
      let(:black_player) { double('player', name: 'player1', color: :black) }
      subject(:black_queen) { described_class.new('d8', black_player) }

      it 'sets symbol to black queen' do
        expect(black_queen.symbol).to eq('♛')
      end
    end

    context 'player color is white' do
      let(:white_player) { double('player', name: 'player1', color: :white) }
      subject(:white_queen) { described_class.new('d1', white_player) }

      it 'sets symbol to white queen' do
        expect(white_queen.symbol).to eq('♕')
      end
    end
  end
end
