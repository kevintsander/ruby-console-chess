# frozen_string_literal: true

require './lib/unit'

describe Unit do
  let(:player) { double('player', color: :black) }

  describe '#initialize' do
    context 'starts on rank 2' do
      subject(:unit_new) { described_class.new('g2', player) }
      it 'sets forward to positive' do
        expect(unit_new.forward).to eq(:+)
      end
    end
    context 'starts on rank 7'
  end

  describe '#captured?' do
    context 'unit has no location' do
      subject(:unit_captured) { described_class.new('g5', player) }

      it 'returns true' do
        unit_captured.instance_variable_set(:@location, nil)
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
