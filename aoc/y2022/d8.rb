$test = true
# ruby /Users/rocco/code/games/aoc2022/gen.rb 9
require "pry-rails"
require "json"

input = File.read("/Users/rocco/code/games/aoc2022/d8.txt")
input = "30373
25512
65332
28549
35390" if $test

@matrix = input.split("\n").map { |row| row.chars.map(&:to_i) }

def visible?(x, y)
  return true if x == 0 || y == 0
  return true if x >= @matrix.first.length || y >= @matrix.length

  tree = @matrix[y][x]
  return true if @matrix[..(y-1)].none? { |r| r[x] >= tree }
  return true if @matrix[(y+1)..].none? { |r| r[x] >= tree }
  return true if @matrix[y][..(x-1)].none? { |c| c >= tree }
  return true if @matrix[y][(x+1)..].none? { |c| c >= tree }
  false
end

# First
count = 0
p @matrix.map.with_index { |row, y|
  row.map.with_index { |cell, x|
    count += 1 if visible?(x, y).tap { |v| print "\e[3#{v ? 2 : 1}m#{cell} " if $test }
  }
  puts "\e[0m" if $test
}.flatten.count

# Second
def direction_score(tree, directive_trees)
  tallest = -1
  directive_trees.count { |current|
    next if tallest == 10 # No tree is 10 or taller
    next tallest = 10 if current >= tree # The tree blocks the rest of the view

    # Stupid description made this confusing.
    # (current >= tallest).tap { tallest = current if current > tallest }
    true
  }
end

def scenic_score(x, y)
  return 0 if x == 0 || y == 0 || x == @matrix.first.length - 1 || y == @matrix.length - 1

  tree = @matrix[y][x]
  dirs = {
    up:    direction_score(tree, @matrix[..(y-1)].reverse.map { |row| row[x] }),
    left:  direction_score(tree, @matrix[y][..(x-1)].reverse),
    down:  direction_score(tree, @matrix[(y+1)..].map { |row| row[x] }),
    right: direction_score(tree, @matrix[y][(x+1)..]),
  }
  # print "[#{x}, #{y}](#{tree})==[#{dirs.values.inject(:*)}]: " if $test
  # cpj dirs if $test

  dirs.values.inject(:*)
end

p @matrix.map.with_index { |row, y|
  row.map.with_index { |cell, x|
    scenic_score(x, y).tap { |s| print " #{s.to_s.rjust(2, " ")} " if $test }
  }.tap { puts if $test }
}.flatten.max
