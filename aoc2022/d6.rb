# ruby /Users/rocco/code/games/aoc2022/gen.rb 7
require "pry-rails"
input = File.read("/Users/rocco/code/games/aoc2022/d6.txt")
# input = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"

# First
charcount = 4
puts input.chars.each_cons(charcount).each.with_index { |g, idx|
  break (idx + charcount) if g.uniq.length == charcount
}

# Second
# puts input.chars.each_cons(14).each.with_index { |g, idx|
#   break (idx + 14) if g.uniq.length == 14
# }
