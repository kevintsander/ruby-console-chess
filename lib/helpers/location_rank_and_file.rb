# frozen_string_literal: true

# module for getting rank and file from location
module LocationRankAndFile
  def rank(location)
    location[1]
  end

  def file(location)
    location[0]
  end
end
