module GameErrors
  # Error to be raised when game is already over
  class GameAlreadyOverError < RuntimeError
    def initialize(msg = 'game already over')
      super
    end
  end

  class MustPromoteError < RuntimeError
    def initialize(msg = 'must promote unit to perform this action')
      super
    end
  end
end
