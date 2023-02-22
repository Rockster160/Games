require "/Users/rocco/code/games/engine/engine"

map = "bbbbbbbbbbbb.bbbbbbb
b..................b
b..................b
b..................b
b..................b
b..................b
b..................b
b..................b
b..................b
....................
b..................b
b..................b
b..................b
b..................b
b..................b
b..................b
b..................b
b..................b
bbbbbbbbbbbb.bbbbbbb"

class Board
  attr_accessor :board

  def initialize(board)
    @board = board
  end

  def width
    @width ||= board.first.length
  end

  def height
    @height ||= board.length
  end

  def try_move(coord, nx, ny)
    new_cell = @board[coord[1] + ny][coord[0] + nx]
    return if new_cell == "b"

    coord[0] = (nx + coord[0]) % (width)
    coord[1] = (ny + coord[1]) % (height)
    coord
  end
end

class TurkeyChaser
  attr_accessor :board

  def initialize(map)
    @board = Board.new(map.split("\n").map { |row| row.split("") })
    @player = [5, 5]
    @turkey = [15, 15]
  end

  def input(key)
    case key
    when :a, :left   then @board.try_move(@player, -1, 0)
    when :w, :up     then @board.try_move(@player, 0, -1)
    when :d, :right  then @board.try_move(@player, +1, 0)
    when :s, :down   then @board.try_move(@player, 0, +1)
    # when :x, :escape, :control_c then Engine.fullquit
    when :p then $stop = true
    end
  end

  def tick
    @board.try_move(@turkey, (-1..1).to_a.sample, (-1..1).to_a.sample) if rand(10) == 0
  end

  def show
    Draw.draw_board(@board.board) { |pencil|
      pencil.background(:green)
      pencil.sprite("b", " ", [150, 75, 0], :bg)
      pencil.object("🦃", @turkey)
      pencil.object("@", @player, :blue)
    }
  end
end

game = TurkeyChaser.new(map)
Engine.game(
  input: ->(key) { game.input(key) },
  tick: ->() { game.tick },
  draw: ->() { game.show },
)
