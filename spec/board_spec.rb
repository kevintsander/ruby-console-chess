# frozen_string_literal: true

require './lib/board'

describe Board do
  let(:white_player) { double('white_player', color: :white) }
  let(:black_player) { double('black_player', color: :black) }
  let(:game_log) { double('game_log') }

  describe '#initialize' do
    it 'creates all chess game pieces' do
      board = described_class.new([white_player, black_player], game_log)
      [white_player, black_player].each do |player|
        player_units = board.units.select { |unit| unit.player == player }

        king_unit_count = player_units.count { |unit| unit.is_a?(King) }
        queen_unit_count = player_units.count { |unit| unit.is_a?(Queen) }
        bishop_unit_count = player_units.count { |unit| unit.is_a?(Bishop) }
        knight_unit_count = player_units.count { |unit| unit.is_a?(Knight) }
        rook_unit_count = player_units.count { |unit| unit.is_a?(Rook) }
        pawn_unit_count = player_units.count { |unit| unit.is_a?(Pawn) }
        expect(king_unit_count).to eq(1)
        expect(queen_unit_count).to eq(1)
        expect(bishop_unit_count).to eq(2)
        expect(knight_unit_count).to eq(2)
        expect(rook_unit_count).to eq(2)
        expect(pawn_unit_count).to eq(8)
      end
    end
  end

  describe '#unit' do
    subject(:board) { described_class.new([white_player, black_player], game_log) }
    let(:unit) { double('unit', location: 'g3') }

    before do
      allow(board).to receive(:units).and_return([unit])
    end

    context 'a unit is at the location' do
      it 'return true' do
        result = board.unit_at('g3')
        expect(result).to be(unit)
      end
    end

    context 'a unit is not at the location' do
      it 'return true' do
        result = board.unit_at('c2')
        expect(result).to be_nil
      end
    end
  end

  describe '#unit_blocking_move?' do
    subject(:board_block) { described_class.new([white_player, black_player], game_log) }

    context 'horizontal move with no other units between' do
      let(:move_unit) { double('unit', location: 'g2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'c3', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'a1', player: black_player) }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit, unfriendly_unit])
      end

      it 'returns false' do
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'g5')
      end
    end

    context 'horizontal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'g2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'g4', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'g3', player: black_player) }

      it 'returns true' do
        # check unfriendly
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
        # check friendly
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'g5')
      end
    end
    context 'diagonal move with no units between' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd5', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'e8', player: black_player) }

      before do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit, unfriendly_unit])
      end

      it 'returns false' do
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'h8')
      end
    end

    context 'diagonal move with defenders or friendly units between' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd4', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'f6', player: black_player) }

      it 'returns true' do
        # check unfriendly
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
        # check friendly
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'h8')
      end
    end

    context 'friendly unit on move space' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:friendly_unit) { double('unit', location: 'd4', player: white_player) }

      it 'returns true' do
        allow(board_block).to receive(:units).and_return([move_unit, friendly_unit])
        expect(board_block).to be_unit_blocking_move(move_unit, 'd4')
      end
    end

    context 'unfriendly unit on move space' do
      let(:move_unit) { double('unit', location: 'b2', player: white_player) }
      let(:unfriendly_unit) { double('unit', location: 'd4', player: black_player) }

      it 'returnwhs false' do
        allow(board_block).to receive(:units).and_return([move_unit, unfriendly_unit])
        expect(board_block).not_to be_unit_blocking_move(move_unit, 'd4')
      end
    end
  end

  describe '#allowed_actions' do
    subject(:board_allowed) { described_class.new([white_player, black_player], game_log) }

    context 'moves inside boundary' do
      it 'returns all moves' do
        pawn_unit = Pawn.new('c3', white_player)
        knight_unit = Knight.new('e5', black_player)
        king_unit = King.new('f6', white_player)
        allow(board_allowed).to receive(:units).and_return([pawn_unit], [knight_unit], [king_unit])
        pawn_result = board_allowed.allowed_actions(pawn_unit)
        knight_result = board_allowed.allowed_actions(knight_unit)
        king_result = board_allowed.allowed_actions(king_unit)

        expect(pawn_result[:move_standard].sort).to eq(%w[c4].sort)
        expect(knight_result[:jump_standard].sort).to eq(%w[g4 f3 g6 f7 d7 c6 c4 d3].sort)
        expect(king_result[:move_standard].sort).to eq(%w[g5 g6 g7 f5 f7 e5 e6 e7].sort)
      end
    end

    context 'moves outside of boundary' do
      it 'limits moves' do
        pawn_unit = Pawn.new('c8', white_player)
        rook_unit = Rook.new('c3', black_player)
        knight_unit = Knight.new('h8', black_player)
        bishop_unit = Bishop.new('e2', white_player)
        queen_unit = Queen.new('b7', black_player)
        king_unit = King.new('h8', white_player)

        allow(board_allowed).to receive(:units).and_return([pawn_unit], [rook_unit], [bishop_unit], [queen_unit],
                                                           [king_unit])
        pawn_result = board_allowed.allowed_actions(pawn_unit)
        rook_result = board_allowed.allowed_actions(rook_unit)
        knight_result = board_allowed.allowed_actions(knight_unit)
        bishop_result = board_allowed.allowed_actions(bishop_unit)
        queen_result = board_allowed.allowed_actions(queen_unit)
        king_result = board_allowed.allowed_actions(king_unit)

        expect(pawn_result).to be_empty
        expect(rook_result[:move_standard].sort).to eq(%w[c1 c2 c4 c5 c6 c7 c8 a3 b3 d3 e3 f3 g3 h3].sort)
        expect(knight_result[:jump_standard].sort).to eq(%w[f7 g6].sort)
        expect(bishop_result[:move_standard].sort).to eq(%w[d1 f1 d3 c4 b5 a6 f3 g4 h5].sort)
        expect(queen_result[:move_standard].sort).to eq(%w[a8 a7 a6 b8 c8 c7 d7 e7 f7 g7 h7 c6 d5 e4 f3 g2 h1 b6 b5 b4
                                                           b3 b2 b1].sort)
        expect(king_result[:move_standard].sort).to eq(%w[h7 g7 g8].sort)
      end
    end

    context 'units are blocking moves' do
      it 'returns all moves that are not blocked by units' do
        blocking_pawn = Pawn.new('e4', black_player)
        bishop_unit = Bishop.new('c6', white_player)
        rook_unit = Rook.new('e6', white_player)
        queen_unit = Queen.new('g4', white_player)

        allow(board_allowed).to receive(:units).and_return([blocking_pawn, bishop_unit, rook_unit, queen_unit])

        bishop_result = board_allowed.allowed_actions(bishop_unit)
        rook_result = board_allowed.allowed_actions(rook_unit)
        queen_result = board_allowed.allowed_actions(queen_unit)

        expect(bishop_result[:move_standard].sort).to eq(%w[b7 a8 b5 a4 d5 d7 e8].sort)
        expect(rook_result[:move_standard].sort).to eq(%w[e7 e8 d6 e5 f6 g6 h6].sort)
        expect(queen_result[:move_standard].sort).to eq(%w[h4 h5 h3 g5 g6 g7 g8 g3 g2 g1 e2 d1 f3 f4 f5].sort)
      end
    end

    context 'unblocked enemies in move range' do
      it 'allows attack' do
        queen = Queen.new('f6', black_player)
        enemy_queen = Queen.new('f1', white_player)
        enemy_knight = Knight.new('d5', white_player)
        enemy_pawn = Pawn.new('d4', white_player)
        enemy_bishop = Bishop.new('f8', white_player)

        allow(board_allowed).to receive(:units).and_return([queen, enemy_queen, enemy_knight, enemy_pawn, enemy_bishop])

        queen_result = board_allowed.allowed_actions(queen)
        enemy_knight_result = board_allowed.allowed_actions(enemy_knight)

        expect(queen_result[:move_attack].sort).to eq(%w[f1 f8 d4].sort)
        expect(enemy_knight_result[:jump_attack]).to eq(%w[f6])
      end
    end

    context 'blocked enemies in move range' do
      it 'do not allow attack' do
        white_rook = Rook.new('a1', white_player)
        white_pawn = Pawn.new('a2', white_player)
        black_rook = Rook.new('a6', black_player)
        black_bishop = Bishop.new('c1', black_player)

        allow(board_allowed).to receive(:units).and_return([white_rook, white_pawn, black_rook, black_bishop])

        white_rook_result = board_allowed.allowed_actions(white_rook)
        black_rook_result = board_allowed.allowed_actions(black_rook)

        expect(white_rook_result[:move_attack]).to eq(%w[c1])
        expect(black_rook_result[:move_attack]).to eq(%w[a2])
      end
    end

    context 'enemy pawn just moved two spaces' do
      let(:adjacent_pawn) { double('pawn', player: black_player, location: 'e4') }
      let(:enemy_pawn_jumped_two) { double('pawn', player: white_player, location: 'd4') }
      let(:log) { double('move_log', last_move: { unit: enemy_pawn_jumped_two, last_location: 'd2' }) }
      xit 'adjacent pawn can en passant' do
        adjacent_pawn_result = board_allowed.allowed_actions(adjacent_pawn)
        expect(adjacent_pawn_result[:en_passant]).to be(['d3'])
      end

      xit 'non-adjacent pawn cannot en passant' do
      end
    end
  end
end
