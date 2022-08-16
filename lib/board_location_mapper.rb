# frozen_string_literal: true

module BoardLocationMapper
  MAP = [
    %w[a1 b1 c1 d1 e1 f1 g1 h1],
    %w[a2 b2 c2 d2 e2 f2 g2 h2],
    %w[a3 b3 c3 d3 e3 f3 g3 h3],
    %w[a4 b4 c4 d4 e4 f4 g4 h4],
    %w[a5 b5 c5 d5 e5 f5 g5 h5],
    %w[a6 b6 c6 d6 e6 f6 g6 h6],
    %w[a7 b7 c7 d7 e7 f7 g7 h7],
    %w[a8 b8 c8 d8 e8 f8 g8 h8]
  ].freeze

  def location_coordinates(location)
    MAP.each_with_index do |row, row_id|
      row.each_with_index do |search_location, col_id|
        return [row_id, col_id] if search_location == location
      end
    end
    nil
  end

  def location_delta(from_location, to_location)
    from_coordinates = location_coordinates(from_location)
    to_coordinates = location_coordinates(to_location)
    [to_coordinates[0] - from_coordinates[0], to_coordinates[1] - from_coordinates[1]]
  end

  def direction(delta)
    greatest_common = delta[0].gcd(delta[1])
    [delta[0] / greatest_common, delta[1] / greatest_common]
  end
end
