# /Users/rocco/code/games/aoc2022/gen.rb 5
require "pry-rails"
input = File.read("/Users/rocco/code/games/aoc2022/d4.txt")
# input = "2-4,6-8
# 2-3,4-5
# 5-7,7-9
# 2-8,3-7
# 6-6,4-6
# 2-6,4-8"

# First
puts input.split("\n").count { |g|
  e1, e2 = g.split(",").map { |r| r.split("-").map(&:to_i).then {|l,h|(l..h)}}.then {|r1,r2|r1.cover?(r2) || r2.cover?(r1)}
}

# Second
puts input.split("\n").count { |g|
  e1, e2 = g.split(",").map { |r| r.split("-").map(&:to_i).then {|l,h|(l..h).to_a}}.then {|r1,r2|(r1 & r2).length > 0}
}
