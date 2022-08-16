# frozen_string_literal: true

require './lib/unit'

describe Unit do
  let(:player) { double('player') }
  describe '#captured?' do
    context 'unit has no location' do
      subject(:unit_captured) { described_class.new(nil, player) }

      it 'returns true' do
        expect(unit_captured).to be_captured
      end
    end
    context 'unit has a location' do
      subject(:unit_alive) { described_class.new('g5', player) }
      it 'returns false' do
        expect(unit_alive).not_to be_captured
      end
    end
  end

  describe '#capture' do
    subject(:unit_capture) { described_class.new('g5', player) }
    it 'sets location to nil' do
      expect { unit_capture.capture }.to change { unit_capture.location }.from('g5').to(nil)
    end
  end

  describe '#move' do
    subject(:unit_move) { described_class.new('g5', player) }

    it 'moves the location' do
      expect { unit_move.move('f7') }.to change { unit_move.location }.from('g5').to('f7')
    end
  end
end
