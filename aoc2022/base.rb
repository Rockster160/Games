require "pry-rails"
require "json"

require "/Users/rocco/code/games/engine/infini_board"
require "/Users/rocco/code/games/engine/input"; include Input
require "/Users/rocco/code/games/engine/colorize"; include Colorize
require "/Users/rocco/code/games/engine/draw"; include Draw

# $pryonce || ($pryonce ||= true) && binding.pry
def debug(*args); puts(*args) if $test; end
def d(*args); p(*args) if $test; end

def iloop(&block)
  loop.with_index do |_, idx|
    block.call(idx)
  end
end

$benchmark = true
class Benchmark
  attr_accessor :did_count

  def self.time(str, &block)
    bm = new
    puts str if $benchmark
    start = Time.now.to_f
    res = block.call(bm)

    if $benchmark
      puts Colorize.color(:yellow, "#{"\n" if bm.did_count}  #{(Time.now.to_f - start).round(2)}s", reset: true)
    end

    res
  end

  def counter(cur, max=nil)
    @did_count = true
    return unless $benchmark

    clr && print(Colorize.color(:cyan, "\r  #{[cur, max].compact.join("/")} ", reset: true))
  end
end

# Grid:
  # Able to convert draw coord <-> actual coord
  # Able to show numbers?
# Draw:
  # Detect length of strings (ignoring colors)
  # Easier to color?
# Fix interpolating bools
# Refactor file structure
  # aoc/2022/Day 16: Proboscidea Volcanium/(code.rb|input.txt)
# Get input automatically using API key- only check if after start and if input is empty
