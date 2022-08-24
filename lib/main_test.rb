require './lib/player'
require './lib/game'
require './lib/helpers/game/console_game_displayer'

require './lib/actions/normal_move_command'

player1 = Player.new('kevin', :white)
player2 = Player.new('ivy', :black)

game = Game.new([player1, player2])
game.extend(ConsoleGameDisplayer)
game.start
puts game.board_section_string

white_pawn = game.board.unit_at('a2')
action = game.allowed_actions(white_pawn)[0]

game.perform_action(action)

puts game.board_section_string
