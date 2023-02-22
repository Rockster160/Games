# $test = true
$part = 1
# ruby /Users/rocco/code/games/aoc2022/gen.rb 14
require "pry-rails"
require "json"
# require "io/console"
# require "io/wait"
# require "/Users/rocco/code/games/engine/colorize"; include Colorize
# require "/Users/rocco/code/games/engine/draw"; include Draw
# Draw.cell_width = 1
def debug(*args); puts(*args) if $test; end
def d(*args); p(*args) if $test; end
input = File.read("/Users/rocco/code/games/aoc2022/d13.txt")
input = "[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]" if $test

def compare(l, r)
  return false if l.nil? || r.nil?
  return if l == r

  if [l, r].all? { |b| b.is_a?(Integer) }
    l < r
  elsif [l, r].all? { |b| b.is_a?(Array) }
    val = [*l, nil].each_with_index { |i, x|
      break false if r[x].nil? # Right is shorter, Wrong order
      break true if i.nil? # Ran out, right is longer: Correct order
      check = compare(i, r[x])
      break check unless check.nil?
    }

    return val unless val.nil?
    l.length < r.length
  else
    compare([l].flatten(1), [r].flatten(1))
  end
end


# Part 1
# indices = input.split("\n\n").map.with_index { |pair, idx|
#   compare(*pair.split("\n").map { |t| JSON.parse(t) }) ? (idx+1) : nil
# }.compact
#
# puts indices.join(", ")
# puts indices.sum

# Part 2
div1, div2 = [[2]], [[6]]
lines = input.split("\n").reject! { |l| l.nil? || l.empty? }
arrays = lines.map { |t| JSON.parse(t) }
packets = (arrays + [div1, div2]).sort { |paira, pairb|
  check = compare(paira, pairb)
  next 0 if check.nil?
  check ? -1 : 1
}

puts (packets.index(div1)+1) * (packets.index(div2)+1)
