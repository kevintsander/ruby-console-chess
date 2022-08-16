module UnitSymbolMapper
  SYMBOLS = { king: { white: '♔', black: '♚' },
              queen: { white: '♕', black: '♛' },
              bishop: { white: '♗', black: '♝' },
              knight: { white: '♘', black: '♞' },
              rook: { white: '♖', black: '♜' },
              pawn: { white: '♙', black: '♟' } }.freeze

  def get_color_symbol(color)
    unit_type = self.class.name.downcase.to_sym
    return unless SYMBOLS.key?(unit_type)

    SYMBOLS[unit_type][color]
  end
end
