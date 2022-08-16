# frozen_string_literal: true

class Unit
  attr_reader :location, :player, :id

  def initialize(location, player, id = location)
    @location = location
    @player = player
    @id = id
  end

  def captured?
    !location
  end

  def capture
    @location = nil
  end

  def move(location)
    @location = location
  end
end
