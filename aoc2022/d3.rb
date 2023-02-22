# /Users/rocco/code/games/aoc2022/gen.rb 4
require "pry-rails"
input = File.read("/Users/rocco/code/games/aoc2022/d3.txt")
# input = "vJrwpWtwJgWrhcsFMMfFFhFp
# jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
# PmmdzqPrVvPwwTWBwg
# wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
# ttgJtRGJQctTZtZT
# CrZsJsPPZsGzwwsLwLmpwMDw"

pris = [nil] + ("a".."z").to_a + ("A".."Z").to_a

# First
# puts input.split("\n").map { |ruck|
#   pris.index(ruck.chars.each_slice((ruck.length/2)).to_a.inject(&:&).first)
# }.sum

# Second
puts input.split("\n").each_slice(3).map { |group|
  pris.index(group.map(&:chars).inject(&:&).first)
}.sum
