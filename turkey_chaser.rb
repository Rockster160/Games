require "io/console"
require "io/wait"
require "pry-rails"

map = "bbbbbbbbbbbb.bbbbbbb
b..................b
b....b........b....b
b....b........b....b
b....b.bb..bb.b....b
b....b........b....b
b....b........b....b
b....b........b....b
b....b........b....b
.....b........b.....
b....b........b....b
b....b........b....b
b....b........b....b
b....b........b....b
b....b.bb..bb.b....b
b....b........b....b
b....b........b....b
b..................b
bbbbbbbbbbbb.bbbbbbb"


class Coord
  attr_accessor :x, :y

  def initialize(x, y, board)
    @board = board
    @maxy = board.length
    @maxx = board.first.length
    @x = x
    @y = y
  end

  def coord
    [@x, @y]
  end

  def torand
    nil until move(rand(@maxx), rand(@maxy))
    self
  end

  def move(rx, ry)
    nx = (@x + rx) % @maxx
    ny = (@y + ry) % @maxy
    return false if @board.dig(ny, nx) == "b"
    @x, @y = nx, ny
    true
  end
end

class TurkeyChaser
  def initialize(map)
    @board = map.split("\n").map { |row| row.split("") }
    @board_height = @board.length
    @board_width = @board.first.length
    @player = Coord.new(1, 1, @board)
    @turkey = Coord.new(5, 5, @board).torand
    @quit = false
  end

  def play
    system "clear" or system "cls"
    print "\e[?25l" # Hide cursor
    @prestate = `stty -g`
    `stty raw -echo -icanon isig`

    prompt = Thread.new do
      loop do
        char = STDIN.getc.chr
        if char == "\e"
          char << STDIN.read_nonblock(3) rescue nil
          char << STDIN.read_nonblock(2) rescue nil
        end
        input(char)
        STDIN.getc while STDIN.ready?
        sleep 0.15
      end
    end

    loop do
      break if @quit
      sleep 0.15
      tick
      break if @turkey.coord == @player.coord
    end
    prompt = 0
    if @turkey.coord == @player.coord
      fixtext
      puts "\n\n\r#{color(2)}🎉🎉🎉 You caught the turkey! 🎉🎉🎉#{color_reset}"
    end
  ensure
    prompt = 0 # Closes the thread
  end

  def fixtext
    print "\e[?25h" # Show cursor
    `stty #{@prestate}`
  end

  def input(key)
    @last_input = key
    case key.to_sym
    when :a then @player.move(-1, 0)
    when :w then @player.move(0, -1)
    when :d then @player.move(+1, 0)
    when :s then @player.move(0, +1)
    when :x then @quit = true
    end
  end

  def tick
    @turkey.move((-1..1).to_a.sample, (-1..1).to_a.sample) if rand(3) == 0
    draw
  end

  def color_reset
    "\e[33;5;0m"
  end

  def color(n, ground=:fg)
    "\e[#{ground == :bg ? 48 : 38};5;#{n}m"
  end

  def move_cursor(x, y)
    print "\033[#{y};#{x}f"
  end

  def delete_after
    "\033[K"
  end

  def draw
    move_cursor(0, 0) # Move to 0,0 to redraw map back on top
    grass = color(22, :bg) # Green ish
    print grass
    print show.map { |row| row.join("#{grass}") }.join("#{color_reset}#{delete_after}\r\n#{grass}")
    print color_reset
  end

  def show
    @board.map.with_index { |row, y|
      row.map.with_index { |cell, x|
        if [x, y] == @player.coord
          cyan = color(51)
          "#{cyan}@ "
        elsif [x, y] == @turkey.coord
          "🦃"
        elsif cell == "b"
          wallbrown = color(130)
          "#{wallbrown}██"
        else
          "  "
        end
      }
    }
  end
end

TurkeyChaser.new(map).play
