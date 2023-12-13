# Started ~3:11am

$test = true
# $draw = true
$part = 2
$part ||= 1
# $pryonce || ($pryonce ||= true) && binding.pry

require "/Users/rocco/code/games/aoc2022/base"
# Draw.cell_width = 1

input = File.read("/Users/rocco/code/games/aoc2022/d17.txt")
input = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
" if $test

rock_types = "####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##"

class Jet
  def self.blow(idx)
    jet = $jets[idx % $jets.length]
    # jet = $jets.shift
    # $jets.push(jet)
  end
end

class Rock
  attr_accessor :shape, :x, :y

  def self.spawn(idx, x, y)
    rock_type = $rock_types[idx % $rock_types.length]
    # rock_type = $rock_types.shift
    # $rock_types.push(rock_type)
    new(rock_type, x, y)
  end

  def initialize(rock_type, x, y)
    @shape = rock_type.split("\n").map { |row| row.split("").map { |char| char == "#" ? "#" : nil } }
    @x = x
    @y = y + height
  end

  def move(x, y)
    @x += x
    @y += y
  end

  def height
    @shape.length
  end

  def width
    @shape.first.length
  end
end

class Chamber
  attr_accessor :width, :grid, :falling_rock, :tick, :rock_count, :top, :jet_idx, :rock_idx, :max_fall, :pattern_cache

  def initialize
    @tick = 0
    @rock_count = 0
    @width = 7
    @top = -1
    @grid = []
    @jet_idx = 0
    @rock_idx = 0
    @max_fall = 0
    @current_fall = 0
    @pattern_cache = {}
  end

  def height
    @grid.length
  end

  def spawn_rock
    @falling_rock = Rock.spawn(@rock_idx, 2, @top+3)
    @rock_idx += 1
    @current_fall = 0
    new_height = @falling_rock.y + 1

    if new_height > height
      @grid += Array.new(new_height - height) { Array.new(@width) { "." } }
    end
    @falling_rock
  end

  def settle_rock
    @top = @falling_rock.y if @falling_rock.y > @top
    rock_botleft_coords.each { |x, y|
      @grid[y][x] = "#"
    }

    @pattern_cache[[@jet_idx, @rock_idx]] = {
      top: @top,
      max_fall: @max_fall,
      current_fall: @current_fall,
      rock_count: @rock_count,
      grid: @grid,
    }

    @rock_count += 1
    @falling_rock = nil
  end

  def move_rock(x, y)
    valid = rock_botleft_coords.all? { |rx, ry|
      nx, ny = rx + x, ry + y
      next false if nx < 0 || nx >= @width
      next false if ny < 0

      # Grid uses botleft coords
      @grid[ny][nx] == "."
    }

    if valid
      @current_fall += 1 if y < 0
      @max_fall = @current_fall if @current_fall > @max_fall
      @falling_rock.move(x, y)
    elsif y < 0 # Falling
      settle_rock
    else
      @nosleep = true
    end
  end

  def rock_botleft_coords
    return [] if @falling_rock.nil?

    @falling_rock.shape.map.with_index { |row, y|
      row.map.with_index { |cell, x|
        next unless cell == "#"

        [@falling_rock.x + x, @falling_rock.y - y]
      }
    }.flatten(1).compact
  end

  def rock_topleft_coords
    return [] if @falling_rock.nil?

    rock_botleft_coords.map { |x, y|
      [x, height - y - 1]
    }
  end

  def spawn_jet
    Jet.blow(@jet_idx).tap { |j| @jet_idx += 1 }
  end

  def tick
    # Check repeating pattern here
    @tick += 1

    move_rock(spawn_jet == "<" ? -1 : 1, 0) # Blow side to side
    draw
    move_rock(0, -1) # Fall
    draw
  end

  def detect_pattern
    # stopped(rocks) = 120
    # height(top) = 184
    # max_fall = 12
    # stopped/cycle = 35
    # height/cycle = 53
    # cycles left = 28571428568
    gcd = $jets.length * $rock_types.length
    return false unless gcd == @tick

    $pryonce || ($pryonce ||= true) && binding.pry
    # pattern = @grid.last(10)
    # pattern_idx = @grid.rindex(pattern)
    # pattern_jet_idx = @jet_idx
    # pattern_rock_idx = @rock_idx
    #
    # old_pattern_idx = iloop { |idx|
    #   # pattern_jet_idx -= $jets.length
    #   # return false if pattern_jet_idx < 0
    #   # pattern_rock_idx -= $rock_types.length
    #   # return false if pattern_rock_idx < 0
    #
    #   break @grid.index(pattern) if @grid.index(pattern) < pattern_idx
    # }
    # if pattern
    # multiply values to set the `top` value
    # return true
  end

  def draw
    return unless $draw

    Draw.board(@grid.reverse) do |pencil|
      rock_topleft_coords.each { |coord|
        pencil.object("@", coord, :white)
      }
    end
    print "#{newline}"
    print "t:#{@tick}#{newline}"
    print "#{white}#{rock_botleft_coords}#{newline}"
    print "#{grey}#{rock_topleft_coords}#{newline}"
    print "Top: #{@top}#{newline}"
    print "Rock: #{@rock_count}#{newline}"
    sleep(0.2) unless @nosleep
    # sleep(@top >= 14 ? 1 : 0.05) unless @nosleep
    @nosleep = false
  end
end

$rock_types = rock_types.split("\n\n")
$jets = input.split("").select { |j| ["<", ">"].include?(j) }

$rock_count = $part == 1 ? 2022 : 1_000_000_000_000
def to_delim(num)
  num.to_s.reverse.scan(/.{0,3}/)[0...-1].join("_").reverse
end

@chamber = Chamber.new

system "clear" if $draw

Benchmark.time("Falling Rocks") do |bm|
  pc = $rock_count / 100.to_f
  $rock_count.times do |t|
    bm.counter(((t+1)/pc).floor, 100)
    print "#{to_delim(t)} / #{to_delim($rock_count)}"
    break if @chamber.detect_pattern
    @chamber.spawn_rock
    @chamber.draw

    loop {
      @chamber.tick
      break if @chamber.falling_rock.nil?
    }
  end
end

puts @chamber.top+1
# Find a repeating pattern, then do math to figure out the rest
