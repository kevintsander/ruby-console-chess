# frozen_string_literal: true

require './lib/actions/action_command'

class PromoteUnitCommand < ActionCommand
  def initialize(board, unit, location, new_unit_class_type)
    super(board, unit, location)
    @new_unit_class_type = new_unit_class_type
  end

  def perform_action
    unit.promote
    promoted_unit = @new_unit_class_type.new(location, unit.player)
    board.add_unit(promoted_unit)
  end
end
