# frozen_string_literal: true

module GameLogger
  def log_action(action)
    @game_log << { turn: turn, action: action }
  end

  def last_action
    @game_log.last[:action] if @game_log&.any?
  end

  def last_unit
    last_action&.unit
  end

  def unit_actions(unit)
    @game_log.each_with_object([]) do |log_item, unit_actions|
      action = log_item[:action]
      unit_actions << action if action.unit == unit
    end
  end
end
