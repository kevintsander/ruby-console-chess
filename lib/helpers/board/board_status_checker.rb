# frozen_string_literal: true

module BoardStatusChecker
  def check?(unit)
    return false unless unit.is_a?(King)
  end
end
