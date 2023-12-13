# ruby /Users/rocco/code/games/aoc2022/gen.rb 6
require "pry-rails"
input = File.read("/Users/rocco/code/games/aoc2022/d5.txt")
# input =
# "    [D]
# [N] [C]
# [Z] [M] [P]
#  1   2   3
#
# move 1 from 2 to 1
# move 3 from 1 to 3
# move 2 from 2 to 1
# move 1 from 1 to 2"


stack, instructions = input.split("\n\n")
cols = []

stack.split("\n").each { |row|
  row.chars.each_slice(4).each_with_index { |(_, char, _, _), idx|
    next if char.to_s.match?(/\d/)
    cols[idx] ||= []
    cols[idx].push(char) unless char == " "
  }
}

# First
# instructions.split("\n").each do |inst|
#   _, count, from, to = inst.match(/move (\d+) from (\d+) to (\d+)/).to_a
#   count.to_i.times {
#     cols[to.to_i - 1].unshift(cols[from.to_i - 1].shift)
#   }
# end

# Second
instructions.split("\n").each do |inst|
  _, count, from, to = inst.match(/move (\d+) from (\d+) to (\d+)/).to_a
  cols[to.to_i - 1].unshift(*cols[from.to_i - 1].shift(count.to_i))
end

puts cols.map { |col| col.first }.join("")
