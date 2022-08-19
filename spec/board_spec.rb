# frozen_string_literal: true

require './lib/board'

describe Board do
  let(:white_player) { double('white_player', color: :white) }
  let(:black_player) { double('black_player', color: :black) }
  let(:game_log) { double('game_log', last_move: nil) }

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
  end

  describe '#allowed_actions' do
    subject(:board_allowed) { described_class.new([white_player, black_player], game_log) }

    before do
      allow(game_log).to receive(:unit_actions)
    end

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
      let(:enemy_pawn_jumped_two) { Pawn.new('d4', white_player) }
      let(:log_en_passant) { double('log_en_passant', last_move: { unit: enemy_pawn_jumped_two, last_location: 'd2' }) }
      subject(:board_en_passant) { described_class.new([white_player, black_player], log_en_passant) }

      before do
        allow(log_en_passant).to receive(:unit_actions)
      end

      it 'adjacent pawn can en passant' do
        adjacent_pawn = Pawn.new('e4', black_player)
        adjacent_pawn_result = board_en_passant.allowed_actions(adjacent_pawn)
        expect(adjacent_pawn_result[:en_passant]).to eq(['d3'])
      end

      it 'non-adjacent pawn cannot en passant' do
        non_adjacent_pawn = Pawn.new('f4', black_player)
        non_adjacent_pawn_result = board_en_passant.allowed_actions(non_adjacent_pawn)
        expect(non_adjacent_pawn_result[:en_passant]).to eq(nil)
      end
    end

    context 'pawn has not moved' do
      let(:new_pawn) { Pawn.new('h7', black_player) }
      let(:log_double) { double('game_log', last_move: nil) }
      subject(:board_double) { described_class.new([white_player, black_player], log_double) }

      before do
        allow(board_double).to receive(:units).and_return([new_pawn])
        allow(log_double).to receive(:unit_actions).and_return(nil)
      end

      it 'allowed to double move' do
        result = board_double.allowed_actions(new_pawn)
        expect(result[:initial_double]).to eq(['h5'])
      end
    end

    context 'pawn has moved' do
      let(:moved_pawn) { Pawn.new('h6', black_player) }
      let(:log_double) { double('game_log', last_move: nil) }
      subject(:board_double) { described_class.new([white_player, black_player], log_double) }

      before do
        allow(board_double).to receive(:units).and_return([moved_pawn])
        allow(log_double).to receive(:unit_actions).with(moved_pawn).and_return({ action: :move_standard,
                                                                                  last_location: 'h7' })
      end

      it 'not allowed to double move' do
        result = board_double.allowed_actions(moved_pawn)
        expect(result[:initial_double]).to eq(nil)
      end
    end

    context 'pawn has not moved, but is blocked by another unit' do
      let(:new_pawn) { Pawn.new('h7', black_player) }
      let(:blocking_friendly) { Knight.new('h6', black_player) }
      let(:enemy_on_space) { Rook.new('h5', white_player) }
      let(:log_double) { double('game_log', last_move: nil) }
      subject(:board_double) { described_class.new([white_player, black_player], log_double) }

      before do
        allow(log_double).to receive(:unit_actions).and_return(nil)
      end

      it 'not allowed to double move' do
        allow(board_double).to receive(:units).and_return([new_pawn, blocking_friendly],
                                                          [new_pawn, enemy_on_space])
        blocking_friendly_result = board_double.allowed_actions(new_pawn)
        enemy_on_space_result = board_double.allowed_actions(new_pawn)

        expect(blocking_friendly_result[:initial_double]).to eq(nil)
        expect(enemy_on_space_result[:initial_double]).to eq(nil)
      end
    end

    context 'king and rook have not moved and no units blocking path' do
      subject(:board_castle) { described_class.new([white_player, black_player], game_log) }
      let(:white_queenside_rook) { Rook.new('a1', white_player) }
      let(:black_queenside_rook) { Rook.new('a8', black_player) }
      let(:white_kingside_rook) { Rook.new('h1', white_player) }
      let(:black_kingside_rook) { Rook.new('h8', black_player) }
      let(:white_king) { King.new('e1', white_player) }
      let(:black_king) { King.new('e8', black_player) }

      before do
        allow(game_log).to receive(:unit_actions)
        allow(board_castle).to receive(:units).and_return([white_queenside_rook, white_kingside_rook, white_king,
                                                           black_queenside_rook, black_kingside_rook, black_king])
      end

      it 'can castle' do
        white_king_result = board_castle.allowed_actions(white_king)
        white_queenside_rook_result = board_castle.allowed_actions(white_queenside_rook)
        white_kingside_rook_result = board_castle.allowed_actions(white_kingside_rook)
        black_king_reuslt = board_castle.allowed_actions(black_king)
        black_queenside_king_result = board_castle.allowed_actions(black_queenside_rook)
        black_kingside_rook_result = board_castle.allowed_actions(black_kingside_rook)

        expect(white_king_result[:queenside_castle]).to eq(['c1'])
      end
    end

    context 'king and rook have not moved but units blocking path' do
      xit 'cannot castle' do
      end
    end

    context 'king and rook have not moved but king move spaces are under attack' do
      subject(:board_castle) { described_class.new([white_player, black_player], game_log) }
      let(:white_queenside_rook) { Rook.new('a1', white_player) }
      let(:white_kingside_rook) { Rook.new('h1', white_player) }
      let(:white_king) { King.new('e1', white_player) }
      let(:black_rook) { Rook.new('f8', black_player) }
      let(:black_knight) { Knight.new('e3', black_player) }

      before do
        allow(game_log).to receive(:unit_actions)
        allow(board_castle).to receive(:units).and_return([white_queenside_rook, white_kingside_rook, white_king,
                                                           black_rook, black_knight])
      end

      it 'cannot castle' do
        queenside_rook_result = board_castle.allowed_actions(white_queenside_rook)
        kingside_rook_result = board_castle.allowed_actions(white_kingside_rook)
        king_result = board_castle.allowed_actions(white_king)

        expect(queenside_rook_result[:queenside_castle]).to eq(nil)
        expect(kingside_rook_result[:kingside_castle]).to eq(nil)
        expect(king_result[:kingside_castle]).to eq(nil)
        expect(king_result[:queenside_castle]).to eq(nil)
      end
    end

    context 'king or rook have moved' do
      subject(:board_castle) { described_class.new([white_player, black_player], game_log) }
      let(:queenside_rook) { Rook.new('a1', white_player) }
      let(:kingside_rook) { Rook.new('h1', white_player) }
      let(:king) { King.new('e1', white_player) }

      before do
        allow(board_castle).to receive(:units).and_return([queenside_rook, kingside_rook, king])
        allow(game_log).to receive(:unit_actions).and_return({ action: :move_standard })
      end

      it 'cannot castle' do
        queenside_rook_result = board_castle.allowed_actions(queenside_rook)
        kingside_rook_result = board_castle.allowed_actions(kingside_rook)
        king_result = board_castle.allowed_actions(king)
        expect(queenside_rook_result[:queenside_castle]).to eq(nil)
        expect(kingside_rook_result[:kingside_castle]).to eq(nil)
        expect(king_result[:queenside_castle]).to eq(nil)
        expect(king_result[:kingside_castle]).to eq(nil)
      end
    end
  end

  describe '#check?' do
    let(:king) { King.new('b2', white_player) }
    subject(:board_check) { described_class.new([white_player, black_player], game_log) }

    context 'king unit is in check' do
      it 'returns true' do
        enemy_bishop = Bishop.new('f6', black_player)
        allow(board_check).to receive(:units).and_return([king, enemy_bishop])
        expect(board_check).to be_check(king)
      end
    end

    context 'king unit is not in check' do
      it 'returns false' do
        enemy_bishop = Bishop.new('e6', black_player)
        allow(board_check).to receive(:units).and_return([king, enemy_bishop])
        expect(board_check).not_to be_check(king)
      end
    end
  end
end
