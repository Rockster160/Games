# def draw(x, y)
#   y.times { puts ". " * x }
# end
#
# draw(3, 3)

#######################################################################

# def level(x, y)
#   Array.new(y) { Array.new(x) { ". " } }
# end
#
# @player = { x: 0, y: 0 }
# @level = level(3, 3)
#
# def draw
#   @level.each_with_index { |line, y|
#     line.each_with_index { |cell, x|
#       if @player[:x] == x && @player[:y] == y
#         print "# "
#       else
#         print cell
#       end
#     }
#     puts ""
#   }
# end
#
# loop do
#   draw
#
#   case gets.chomp.downcase
#   when "w" then @player[:y] -= 1
#   when "a" then @player[:x] -= 1
#   when "s" then @player[:y] += 1
#   when "d" then @player[:x] += 1
#   end
# end

#######################################################################

# def level(x, y)
#   Array.new(y) { Array.new(x) { ". " } }
# end
#
# @player = { x: 0, y: 0 }
# @level = level(8, 8)
#
# def draw
#   @level.each_with_index { |line, y|
#     line.each_with_index { |cell, x|
#       if @player[:x] == x && @player[:y] == y
#         print "# "
#       else
#         print cell
#       end
#     }
#     puts ""
#   }
# end
#
# loop do
#   system("cls") || system("clear")
#   draw
#
#   case gets.chomp.downcase
#   when "w" then @player[:y] -= 1
#   when "a" then @player[:x] -= 1
#   when "s" then @player[:y] += 1
#   when "d" then @player[:x] += 1
#   end
# end

#######################################################################

# def level(x, y)
#   Array.new(y) { Array.new(x) { ". " } }
# end
#
# @player = { x: 0, y: 0 }
# @level = level(8, 8)
#
# def draw
#   @level.each_with_index { |line, y|
#     line.each_with_index { |cell, x|
#       if @player[:x] == x && @player[:y] == y
#         print "# "
#       else
#         print cell
#       end
#     }
#     puts ""
#   }
# end
#
# def get_live_key
#   state = `stty -g`
#   `stty raw -echo -icanon isig`
#
#   STDIN.getc.chr
# ensure
#   `stty #{state}`
# end
#
# loop do
#   system("cls") || system("clear")
#   draw
#
#   case get_live_key
#   when "w" then @player[:y] -= 1
#   when "a" then @player[:x] -= 1
#   when "s" then @player[:y] += 1
#   when "d" then @player[:x] += 1
#   end
# end

#######################################################################

def level(x, y)
  Array.new(y) { Array.new(x) { ". " } }
end

@player = { x: 0, y: 0 }
@level = level(8, 8)

def draw
  @level.each_with_index { |line, y|
    line.each_with_index { |cell, x|
      if @player[:x] == x && @player[:y] == y
        print "# "
      else
        print cell
      end
    }
    puts ""
  }
end

def get_live_key
  state = `stty -g`
  `stty raw -echo -icanon isig`

  STDIN.getc.chr
ensure
  `stty #{state}`
end

loop do
  system("cls") || system("clear")
  draw

  case get_live_key
  when "w" then @player[:y] -= 1
  when "a" then @player[:x] -= 1
  when "s" then @player[:y] += 1
  when "d" then @player[:x] += 1
  end

  @player[:x] = @player[:x] % @level.first.length
  @player[:y] = @player[:y] % @level.length
end
