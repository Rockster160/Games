$test = true
$draw = true
$part = 1
# $done || ($done ||= true) && binding.pry
# ruby /Users/rocco/code/games/aoc2022/gen.rb 15
require "pry-rails"
require "json"
# require "io/console"
# require "io/wait"
require "/Users/rocco/code/games/engine/infini_board"
require "/Users/rocco/code/games/engine/input"; include Input
require "/Users/rocco/code/games/engine/colorize"; include Colorize
require "/Users/rocco/code/games/engine/draw"; include Draw
# Draw.cell_width = 1
def debug(*args); puts(*args) if $test; end
def d(*args); p(*args) if $test; end
input = File.read("/Users/rocco/code/games/aoc2022/d14.txt")
input = "498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9" if $test

class Grid
  attr_accessor :grid, :offset

  def set(*args); @grid.set(*args); end
  def at(*args); @grid.at(*args); end
  def width(*args); @grid.width(*args); end
  def height(*args); @grid.height(*args); end

  def initialize(points)
    floor = points.map { |point| point[1] }.max + 2
    @grid = InfiniBoard.new(->(x, y) {
      y >= floor ? "#" : "."
    })

    points.each do |point|
      @grid.set(point, "#")
    end
    @grid.set([500, 0], "+")
  end

  def drawat(point, val)
    return unless $draw

    moveto(point[0]-@grid.minx, point[1])
    print val
    moveto(0, @grid.height+1)
  end

  def draw
    return unless $draw

    Draw.draw_board(@grid.to_a) do |pencil|
      pencil.fg = :grey
      pencil.sprite("#", "#", :white)
      pencil.sprite("x", "o", [210, 180, 140])
    end
  end
end

def to_range(a, b)
  a, b = [a, b].sort
  (a..b)
end

# Part 1
# def fall(falling_sand)
#   if falling_sand[1]+1 >= @grid.height
#     @abyss = true
#     falling_sand = nil
#   elsif @grid.at(falling_sand[0], falling_sand[1]+1) == "."
#     falling_sand = [falling_sand[0], falling_sand[1]+1]
#   elsif @grid.at(falling_sand[0]-1, falling_sand[1]+1) == "."
#     falling_sand = [falling_sand[0]-1, falling_sand[1]+1]
#   elsif @grid.at(falling_sand[0]+1, falling_sand[1]+1) == "."
#     falling_sand = [falling_sand[0]+1, falling_sand[1]+1]
#   else
#     @grid.set(falling_sand, "x")
#     @grid.drawat(falling_sand, Colorize.color([210, 180, 140], "o"))
#     @sand_count += 1
#     falling_sand = nil
#   end
#   @grid.drawat(falling_sand, Colorize.color([255, 255, 0], "o")) if falling_sand
#   falling_sand
# end

# Part 2
def fall(falling_sand)
  if @grid.at(falling_sand[0], falling_sand[1]+1) == "."
    falling_sand = [falling_sand[0], falling_sand[1]+1]
  elsif @grid.at(falling_sand[0]-1, falling_sand[1]+1) == "."
    falling_sand = [falling_sand[0]-1, falling_sand[1]+1]
  elsif @grid.at(falling_sand[0]+1, falling_sand[1]+1) == "."
    falling_sand = [falling_sand[0]+1, falling_sand[1]+1]
  else
    @stopped = falling_sand == [500, 0]
    @grid.set(falling_sand, "x")
    @grid.drawat(falling_sand, Colorize.color([210, 180, 140], "o"))
    @sand_count += 1
    falling_sand = nil
  end
  @grid.drawat(falling_sand, Colorize.color([255, 255, 0], "o")) if falling_sand
  falling_sand
end

system "clear"

# Generate grid
points = []
input.split("\n").each do |line|
  point, *carry = line.split(" -> ")
  point = point.split(",").map(&:to_i)
  carry.each do |carry_to|
    new_point = carry_to.split(",").map(&:to_i)
    to_range(point[0], new_point[0]).each do |x|
      to_range(point[1], new_point[1]).each do |y|
        points << [x, y]
      end
    end
    point = new_point
  end
end

begin
  Input.hide_cursor
  @grid = Grid.new(points)

  falling_sand = nil
  @sand_count = 0

  i = 0
  loop do
    i += 1
    moveto(0, 0) && @grid.draw

    falling_sand ||= [500, 0]
    falling_sand = fall(falling_sand)
    sleep 0.05 if falling_sand

    moveto(0, @grid.height+1) if $draw
    puts "Tick: #{i}#{newline}Sand: #{@sand_count}"
    break if @abyss || @stopped
  end
ensure
  Input.show_cursor
end
