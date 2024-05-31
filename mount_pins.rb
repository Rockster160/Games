# https://www.codewars.com/kata/585cf93f6ad5e0d9bf000010/train/ruby
# I I I I  # each Pin has a Number:    7 8 9 10
#  I I I                                4 5 6
#   I I                                  2 3
#    I                                    1
# You will get an array of integers between 1 and 10, e.g. [3, 5, 9], and have to remove them from the field like this:
#
# I I   I
#  I   I
#   I
#    I

# def bowling_pins(drop)
#   (0..9).to_a.then { |a|
#     (1..4).map { |n|
#       a.slice!(...n)
#     }
#   }.reverse.map { |row|
#     row.join(" ").center(7)
#   }.join("\n").gsub(/#{drop.map { |d| d-1 }.join("|")}/, " ").gsub(/\d/, "I")
# end

def bowling_pins(drop)
  (0..9).to_a.then { |a|
    (1..4).map { |n|
      a.slice!(...n)
    }
  }.reverse.map { |row|
    row.join(" ").center(7)
  }.join("\n").gsub(/#{drop.map { |d| d-1 }.join("|")}/, " ").gsub(/\d/, "I")
end

puts bowling_pins([3, 5, 9]) == "I I   I\n I   I \n  I    \n   I   "


# (0..9).to_a.then { |a|
#   (1..4).map { |n|
#     a.slice!(-n..)
#   }
# }
