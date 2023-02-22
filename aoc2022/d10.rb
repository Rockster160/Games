# $test = true
# ruby /Users/rocco/code/games/aoc2022/gen.rb 11
require "pry-rails"
require "json"
require "io/console"
require "io/wait"
require "/Users/rocco/code/games/engine/colorize"; include Colorize
require "/Users/rocco/code/games/engine/draw"; include Draw
Draw.cell_width = 1
def debug(*args); puts(*args); end
def d(*args); p(*args) if $test; end
input = File.read("/Users/rocco/code/games/aoc2022/d10.txt")
input = "addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop" if $test

# input = "noop
# addx 3
# addx -5"

def run
  x, y = (@cycle-1) % 40, (@cycle-1) / 40
  debug "[#{@cycle}](#{x},#{y}) X#{@reg} #{@ins}#{clr}"
  cmd, amount = @ins&.split(" ")
  amount = amount&.to_i

  pixel = (@reg-1..@reg+1).cover?((@cycle-1) % 40) ? "#" : "."
  @screen[y][x] = pixel

  @chg[@cycle + 1] = amount if cmd == "addx"
  debug "addx #{amount} after #{@cycle + 1}#{clr}" if cmd == "addx"

  @cycle_strength << (@cycle * @reg) if (@cycle - 20) % 40 == 0
  # debug "Store: #{@reg}*#{@cycle} (#{@cycle * @reg})" if (@cycle - 20) % 40 == 0

  @ins = nil if cmd == "noop"
  @ins = "running..." if cmd == "addx"
  debug "[/#{@cycle}]#{clr}"
  debug clr
  debug clr
  # print Colorize.color(:lime, pixel)
  moveto(x, y)
  print Colorize.color(:lime, pixel, reset: true)
  return unless @chg.key?(@cycle)

  # debug "set X to #{@reg + @chg[@cycle]} (#{@reg} + #{@chg[@cycle]})"
  @reg += @chg.delete(@cycle)
  @ins = nil
end

def draw
  moveto(0, 0)
  print @screen.map { |r| r.join("") }.join(newline)
  puts
end

@reg = 1
@cycle_strength = []
@chg = {}
@cycle = 0
@ins = nil
@screen = Array.new(6) { Array.new(40) { "-" }}
instructions = input.split("\n")

system "clear"
loop do
  draw
  @cycle += 1
  break if instructions.length == 0 && @chg.empty?
  @ins ||= instructions.shift
  run
  sleep 0.02
end
puts "\n"*6

# debug "\n"
# debug "IDX: #{@cycle}"
# debug "REG: #{@reg}"
# debug "Cycles: #{@cycle_strength.inspect}"
# puts @cycle_strength.sum
