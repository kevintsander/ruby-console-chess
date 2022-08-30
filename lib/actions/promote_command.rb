# frozen_string_literal: true

class PromoteCommand < ActionCommand
  def initialize(board, unit, location, promoted_unit_class)
    super(board, unit, location)
    @promoted_unit_class = promoted_unit_class
  end

  def perform_moves
    unit.promote
    promoted_unit = @promoted_unit_class.new(location, unit.player)
    board.add_unit(promoted_unit)
  end
end
