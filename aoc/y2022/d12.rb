# $test = true
# ruby /Users/rocco/code/games/aoc2022/gen.rb 13
require "pry-rails"
require "json"
# require "io/console"
# require "io/wait"
# require "/Users/rocco/code/games/engine/colorize"; include Colorize
require "/Users/rocco/code/games/engine/draw"; include Draw
Draw.cell_width = 3
def debug(*args); puts(*args) if $test; end
def d(*args); p(*args) if $test; end
input = File.read("/Users/rocco/code/games/aoc2022/d12.txt")
input = "Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi" if $test

@elevations = ("a".."z").to_a

def get_ele(x, y)
  return if x < 0 || y < 0
  return if x >= @grid.first.length || y >= @grid.length

  @grid[y][x].then { |c|
    next @elevations.index("a") if c == "S"
    next @elevations.index("z") if c == "E"
    c
  }
end

def nofollow(path)
  visited += path
  visited.uniq!
end

def show_path(path)
  print "--"
  path.each { |x,y| print "->#{char(@grid[y][x])}[#{x},#{y}]" }
  print ""
  puts
end

def char(elevation)
  elevation.is_a?(String) ? elevation : @elevations[elevation]
end

def find_shortest(input)
  start = []
  goal = []
  visited = []

  @grid = input.split("\n").map.with_index { |row, y|
    row.chars.map.with_index { |cell, x|
      goal = [x, y] if cell == "S"
      start = [x, y] if cell == "E"
      @elevations.index(cell) || cell
    }
  }

  paths = [
    [start]
  ]

  i = 0
  found_path = nil
  loop do
    i += 1
    new_paths = []

    paths.each do |path|
      next if found_path
      current = path.last
      curr_ele = get_ele(*current).to_i

      (-1..1).each do |dy|
        (-1..1).each do |dx|
          next if found_path
          next unless dx == 0 || dy == 0 # Only move straight - no diagonal
          nx, ny = current[0] + dx, current[1] + dy
          next if visited.include?([nx, ny])

          new_ele = get_ele(nx, ny)
          next if new_ele.nil?

          ele_diff = new_ele - curr_ele
          next if ele_diff < -1 # Moving backwards for more efficient

          # found_path = path + [[nx, ny]] if [nx, ny] == goal # Part 1
          found_path = path + [[nx, ny]] if char(@grid[ny][nx]) == "a" || char(@grid[ny][nx]) == "z" # Part 2
          visited << [nx, ny]
          new_paths << (path + [[nx, ny]])
        end
      end
    end
    break found_path if found_path

    Draw.draw_board(@grid) do |pencil|
      pencil.foreground(:grey)
    end
    paths.each do |path|
      path.each do |coord|
        Draw.drawat(coord, Colorize.color(:green, @grid[coord[1]][coord[0]]))
      end
    end
    Draw.moveto(0, @grid.length + 2)

    # puts "i#{i} -- c#{new_paths.count} -- l#{new_paths.last&.length}"

    break [] if new_paths.length == 0
    paths = new_paths
  end
end

puts find_shortest(input).length - 1 # Don't count the starting spot
