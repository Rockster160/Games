require "pry-rails"
require "/Users/rocco/code/games/engine/engine"

# https://medium.com/swlh/programming-puzzle-lights-toggle-f4d27bf3683e
# https://www.xarg.org/2018/07/lightsout-solution-using-linear-algebra/
# https://stackoverflow.com/questions/19795973/lights-out-game-algorithm
# https://math.stackexchange.com/questions/2237467/solving-a-sparse-n-times-n-binary-matrix-efficiently/3992870#3992870
# http://web.archive.org/web/20100524223840/http://www.math.ksu.edu/~dmaldona/math551/lights_out.pdf

class Solver
  attr_accessor :game, :speed, :moves

  def initialize(game, speed:)
    @game = game
    @height = game.board.cells.length
    @width = game.board.cells.first.length
    @speed = speed
    @guesses = []
    @moves = []
  end

  def show
    Draw.cls # Clear screen of everything
    # Reset the board to the initial state, since it's currently solved
    @moves.each { |coord| @game.toggle(*coord) }
    @game.moves = 0
    # Iterate through the moves to show the completion
    @game.draw
    print "\r#{Draw.clr}"; show_moves
    @moves.each_with_index do |coord, idx|
      sleep @speed
      @game.toggle(*coord)
      @game.draw
      print "\r#{Draw.clr}"; show_moves(idx)
    end
    @game.win # Display the win message and move counter
    puts; show_moves
    puts @game.quit
  end

  def show_moves(idx=nil)
    @moves.each_with_index do |move, midx|
      move = move.then { |x, y| [[nil, *("A".."Z")][x], y] }.join("")
      if midx == idx
        print Colorize.lime("[#{move}]")
      else
        print "[#{move}]"
      end
    end
    print "#{Draw.newline}"
  end

  def toggle(x, y)
    ox, oy = Board::ORIGIN
    coord = [x + ox, y + oy]
    @game.toggle(*coord)
    @cache_game = @game.board.cells.map { |row| row.join("") }
    # If a move is done twice, it's the same as not doing it at all, so remove it from the list.
    @moves.include?(coord) ? @moves.reject! { |i| i == coord } : @moves << coord
  end

  def check(x, y)
    @cache_game[y][x] == "O"
  end

  def backtrack_solve(x=0, y=0, depth=0)
    @game.draw
    return :complete if @game.solved?

    next_x, next_y = x+1, y
    next_x, next_y = 0, next_y+1 if next_x >= @width
    return :fail if next_y >= @height

    # Do some "smart logic" - if we've passed the point where the moves we make will no longer
    #   affect cells that have been passed, if those cells are still "on", we know that we have an
    #   invalid state so we know that this solution is wrong.
    # Left cells: When checking [0,y], then [-1,y-2] must be "off"
    return :continue if x == 0 && y > 1 && check(@width-1, y-2)
    # Middle cells: When checking a cell away from an edge [x,y], then cell [x-1,y-1] must be "off"
    return :continue if x > 0 && y > 0 && check(x-1, y-1)

    # Check with toggle
    toggle(x, y)
    return :complete if backtrack_solve(next_x, next_y, depth+1) == :complete
    toggle(x, y) # Untoggle
    # Check without toggle
    return :complete if backtrack_solve(next_x, next_y, depth+1) == :complete
    :continue
  end

  def solve
    backtrack_solve
    show
  end
end

class Cell
  attr_accessor :state

  def initialize
    @state = false
  end

  def toggle!
    @state = !@state
  end

  def to_s
    @state ? "O" : "."
  end
end

class Board
  attr_accessor :cells, :size
  ORIGIN = [1, 1]

  def initialize(size)
    @size = size.to_i
    @cells = Array.new(@size) { Array.new(@size) { Cell.new } }
  end

  def toggle(toggle_x, toggle_y)
    tx, ty = [toggle_x - ORIGIN[0], toggle_y - ORIGIN[1]]
    return if tx < 0 || ty < 0 || tx >= @size || ty >= @size

    (-1..1).each { |dx|
      (-1..1).each { |dy|
        next unless dx == 0 || dy == 0 # Skip corners
        nx, ny = ty + dy, tx + dx
        next if nx < 0 || ny < 0 || nx >= @size || ny >= @size

        @cells.dig(nx, ny)&.toggle!
      }
    }
    true
  end
end

class Game
  attr_accessor :board, :moves, :chars, :engine
  ORIGIN = Board::ORIGIN

  def initialize(size, start_board=nil)
    @size = size
    @board = Board.new(size)
    @moves = 0
    @chars = ""

    start_board ? load(start_board) : randomize
  end

  def load(start_board)
    split = start_board.match?(/\w{2,}/) ? start_board.split("") : start_board.split(/[,.\n ]\s*/)
    split.each_slice(@size).with_index { |row, y|
      row.each_with_index { |state, x|
        @board.cells[y][x].state = state.to_i == 1
      }
    }
  end

  def randomize
    (@size**2).times { @board.toggle(rand(@size), rand(@size)) }
  end

  def toggle(x, y)
    (@moves += 1 if x && y && @board.toggle(x, y)).tap { win if solved? }
  end

  def win
    draw
    print Colorize.lime("\r#{Draw.clr}You win! Moves: #{@moves}#{Draw.newline}#{Draw.clr}")
  end

  def quit
    @engine&.fullquit || exit
  end

  def input(key)
    case key
    when :backspace then @chars.chop!
    when :space then @chars << " "
    when /^[a-z\d]$/i then @chars << key.to_s
    when :enter
      y, x = @chars[/[a-z\d]{2}/i].split("").sort.then { |n, l| [n.to_i, [nil, *("a".."z")].index(l.downcase)] }
      @chars = ""
      if !toggle(x, y)
        draw
        print Colorize.red("Invalid input. Please use a letter and a number with no space for the coord. Entered: [#{x}, #{y}]")
        return
      end
    when /mousedown\(/
      _, x, y = key.to_s.match(/mousedown\((-?\d+),(-?\d+)\)/).to_a.map(&:to_i)
      toggle(x + ORIGIN[0], y + ORIGIN[1])
    when /mouse/ # do nothing, but don't beep
    else print "\a"
    end

    quit if solved?
    draw
  end

  def solved?
    @board.cells.flatten.none?(&:state)
  end

  def draw
    Input.hide_cursor
    Draw.board(@board.cells, origin: ORIGIN) do |pencil|
      pencil.sprite("O", "O", :yellow)
    end
    Draw.draw_borders(@board.cells, sides: :all, padding: [0, 0])
    puts "\r#{Draw.clr}Seed: #{$seed}"
    puts "\r#{Draw.clr}Moves: #{@moves}"
    print "\r#{Draw.clr}coord: #{@chars}#{Draw.clr}"
    Input.show_cursor
  end
end

Draw.cls

opts = {}
args = ARGV
loop do
  break if args.none?
  arg = args.shift
  case arg
  when "--solve", "-v" then opts[:solve] = true
  when "--seed", "-s" then opts[:seed] = args.shift.to_i
  when "--size", "-z" then opts[:size] = args.shift.to_i
  when "--load", "-l" then opts[:load] = args.shift
  when /^\d+$/ then opts[:size] = arg.to_i
  end
end
$seed = opts[:seed] || rand(99999)
srand($seed)

game = Game.new(opts[:size] || 5, opts[:load])
if opts[:solve]
  Solver.new(game, speed: 0.5).solve
else
  Engine.start(
    game: game,
    start: -> { game.draw },
    input: ->(key) { game.input(key) },
    tick_time: 0,
    input_opts: {
      cursor: true
    },
  )
end

# -l 0101010011001010000111101
