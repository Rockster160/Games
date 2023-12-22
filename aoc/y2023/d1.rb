# Started 1702744984 Dec 16, 9:43AM

$part = 1
# $pryonce || ($pryonce ||= true) && binding.pry

require "/Users/rocco/code/games/aoc/base"
# Draw.cell_width = 1

input = (
   if ARGV[0] != "test"
    File.read("/Users/rocco/code/games/aoc/y2023/d1.txt")
  else
    ""
  end
)
input = File.read("/Users/rocco/code/games/aoc/y2023/d1.txt") unless ARGV[0] == "test"
input = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen" if ARGV[0] == "test"

# Part 1

# puts input.split("\n").sum { |row, idx|
#   row.match(/\D*(\d)[\d\D]*(\d)\D*/).then { |m|
#     m.nil? ? "#{row[/\d/]*2}".to_i : "#{m[1]}#{m[2]}".to_i
#   }
# }

# Part 2

@nums = ["\\d", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
digit =  /(?:#{@nums.join("|")})/

def i(num)
  return if num.nil?
  num.to_s == num.to_i.to_s ? num.to_i : @nums.index(num)
end


# puts input.split("\n").sum { |row, idx|
#   row.scan(digit).then { |m|
#     "#{i(m.first)}#{i(m.last)}".to_i.tap { puts "#{row} [#{m.first}][#{m.last}] = #{_1}" }
#   }
# }
# 55362 too high
# 55321 not right
# input = "jkrbkfsevencnvzp89vhmsdcfcthreetwonedrl" # -- "twone" breaks everything...

puts input.split("\n").sum { |row, idx|
  row.length.times.map { |t|
    row[t..-1].index(digit)&.then { t + _1 }
  }.compact.sort.then { |arr|
    min, max = arr.first, arr.last
    [min, max].map { |t| i(row[t..-1][digit]) }.tap { |m1, m2|
      puts "#{row} [#{m1}][#{m2}] = #{[m1, m2].join("")}"
    }.join("").to_i
  }
}
# 55358

# Finished 1702748941 Dec 16, 10:49AM
