module Moves
  @forward_multiplier = 0.send(forward, 1)

  def diagonal_move_options(spaces, forward_only: false)
    forward_diagonals = [[spaces * @forward_multiplier, -spaces], [spaces * @forward_multiplier, spaces]]
    return forward_diagonals if forward_only

    backward_diagonals = [[spaces * -@forward_multiplier, -spaces], [spaces * -@forward_multiplier, spaces]]
    forward_diagonals + backward_diagonals
  end

  def multi_straight_move_deltas
    # max straight moves is 7
    [1..7].map { |index| straight_move_options(index) }
  end

  def straight_move_options(spaces, forward_only: false)
    forward_move = [[0, spaces * @forward_multiplier]]
    return forward_move if forward_only

    side_moves = [[spaces, 0], [-spaces, 0]]
    back_move = [[0, spaces * -@forward_multiplier]]
    forward_move + side_moves + back_move
  end

  def jump_move_options
    [[-1, -2], [-1, 2], [-2, -1], [-2, 1], [-2, 2], [1, -2], [1, 2], [2, -1], [2, -2], [2, 1]]
  end
end
