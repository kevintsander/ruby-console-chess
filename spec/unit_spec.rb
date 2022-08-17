# frozen_string_literal: true

require './lib/unit'

describe Unit do
  let(:white_player) { double('white_player', color: :white) }
  let(:black_player) { double('black_player', color: :black) }

  describe '#initialize' do
    context 'white player' do
      subject(:unit_new) { described_class.new('g2', white_player) }

      it 'sets forward to positive' do
        expect(unit_new.forward).to eq(:+)
      end
    end

    context 'black player' do
      subject(:unit_new) { described_class.new('g7', black_player) }

      it 'sets forward to negative' do
        expect(unit_new.forward).to eq(:-)
      end
    end
  end

  describe '#captured?' do
    context 'unit has no location' do
      subject(:unit_captured) { described_class.new('g5', white_player) }

      it 'returns true' do
        unit_captured.instance_variable_set(:@location, nil)
        expect(unit_captured).to be_captured
      end
    end

    context 'unit has a location' do
      subject(:unit_alive) { described_class.new('g5', white_player) }
      it 'returns false' do
        expect(unit_alive).not_to be_captured
      end
    end
  end

  describe '#capture' do
    subject(:unit_capture) { described_class.new('g5', white_player) }
    it 'sets location to nil' do
      expect { unit_capture.capture }.to change { unit_capture.location }.from('g5').to(nil)
    end
  end

  describe '#move' do
    subject(:unit_move) { described_class.new('g5', white_player) }

    it 'moves the location' do
      expect { unit_move.move('f7') }.to change { unit_move.location }.from('g5').to('f7')
    end
  end

  describe '#enemy?' do
    subject(:friendly_unit) { described_class.new('g5', white_player) }

    context 'unit is not owned by same player' do
      subject(:enemy_unit) { described_class.new('g1', black_player) }
      it 'returns true' do
        expect(friendly_unit).to be_enemy(enemy_unit)
      end
    end

    context 'unit is owned by same player' do
      subject(:friendly_unit_two) { described_class.new('g1', white_player) }
      it 'returns false' do
        expect(friendly_unit).not_to be_enemy(friendly_unit_two)
      end
    end
  end
end
