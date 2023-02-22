# CHALLENGE:
# Given a list of directions (L -> Left, R -> Right, U -> Up, D -> Down)
# "LDLUUR"
# Determine if the end result is the same location as the beginning.

class Mover
  attr_accessor :coord

  def initialize
    @coord = [0, 0]
  end

  def move_from_str(str)
    str.split("").each do |dir|
      case dir
      when "L" then @coord[0] -= 1
      when "R" then @coord[0] += 1
      when "U" then @coord[1] += 1
      when "D" then @coord[1] -= 1
      end
    end
  end

  def is_at_start?(str)
    @coord == [0, 0]
  end
end



# str = "LDLUUR"
str = "LDLUURDR"

mover = Mover.new
mover.move_from_str(str)

puts "Coord is #{mover.coord}"
puts mover.is_at_start?(str)
