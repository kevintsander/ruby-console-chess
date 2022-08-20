# frozen_string_literal: true

module BoardStatusChecker
  def check?(king)
    king.is_a?(King) && enemy_can_attack_location?(king, king.location)
  end

  def checkmate?(king)
    king.is_a?(King) & check?(king) & !allowed_actions(king)&.any?
  end

  def stalemate?(king)
    # king is not already in check
    # no piece can move without putting the king in check
    # get all friendly units
    # test if king would be in check if any of the allowed pieces moved
    #  should i clone the board and run the test there? or temporarily move the pieces on the current board?

    return false unless king.is_a?(King) & !check?(king) & !allowed_actions(king)&.any?

    # friendly_units(king) do |friendly|
    #   friendly.allowed_actions do
  end

  def test_move_board(unit, move_location); end
end
