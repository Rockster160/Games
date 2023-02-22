require "./kata_test"
require "./colorize"

def draw(maze, player, change, cardinal)
  system "clear" or system "cls"
  chars = {
    player: { char: "> ", col: [:cyan] },
    wall:   { char: "██", col: [:light_black] },
    start:  { char: "s ", col: [nil, :light_blue] },
    finish: { char: "√ ", col: [:black, :green] },
    safe:   { char: "• ", col: [:white] },
  }
  mapping = [
    :safe,   # 0
    :wall,   # 1
    :start,  # 2
    :finish, # 3
  ]
  old_pos = player.map.with_index { |coord, idx| coord - change[idx] }
  puts "================================"
  puts "Traveling #{cardinal}. From #{old_pos} to #{player}"
  puts "  " + maze.map.with_index { |_row, idx| "#{idx} " }.join("")
  maze.each.with_index do |row, y|
    print "#{y} "
    row.each.with_index do |cell, x|
      char_type = [x,y] == player ? :player : mapping[cell]
      color = chars.dig(char_type, :col).dup

      if mapping[cell] == :wall
        color[1] = :red
      elsif mapping[cell] == :finish
        color = [:black, :green]
      elsif [x,y] == old_pos
        color[1] = :yellow
      end

      print chars.dig(char_type, :char).colorize(*color)
    end
    print "\n"
  end
  puts "================================"
end

def maze_runner(m, d)
  (d.map(&:to_sym).each.with_object([].tap{|a|a[0]=m.index{|r|a[1]=r.index(2)}}).find{|o,g|
    break:Finish if m.dig(*(g.map!.with_index{|c,i|c+{N:[-1,0],E:[0,1],S:[1,0],W:[0,-1]}[o][i]}))==3
    break :Dead if m.dig(*g) == 1 || g[1] < 0 || g[1] >= m.size || g[0] < 0 || g[0] >= m[0].size
  } || :Lost).to_s
end

def maze_runner(maze, directions)
  y = maze.index { |i| i.include? 2 }
  x = maze[y].index(2)
  n = maze.length

  directions.each do |direction|
    player = [x, y]
    y += (direction == 'S' ? 1 : -1) if ['N', 'S'].include?(direction)
    x += (direction == 'E' ? 1 : -1) if ['E', 'W'].include?(direction)
    draw(maze, player, [x, y], direction); sleep 1

    return "Dead" if x < 0 || y < 0 || x >= n || y >= n || maze[y][x] == 1

    break if maze[y][x] == 3
  end

  maze[y][x] == 3 ? "Finish" : "Lost"
end

# # 0 = Safe place to walk
# # 1 = Wall
# # 2 = Start Point
# # 3 = Finish Point

maze = [[1,1,1,1,1,1,1],
        [1,0,0,0,0,0,3],
        [1,0,1,0,1,0,1],
        [0,0,1,0,0,0,1],
        [1,0,1,0,1,0,1],
        [1,0,0,0,0,0,1],
        [1,2,1,0,1,0,1]]

directions = ["N","N","N","W","W"]

# maze_runner(maze, directions)
# => "Dead"

# Test.it("Should return Finish") do
  Test.assert_equals(maze_runner(maze,["N","N","N","N","N","E","E","E","E","E"]), "Finish")
#   # Test.assert_equals(maze_runner(maze,["N","N","N","N","N","E","E","S","S","E","E","N","N","E"]), "Finish")
#   # Test.assert_equals(maze_runner(maze,["N","N","N","N","N","E","E","E","E","E","W","W"]), "Finish")
# end
#
# Test.it("Should return Dead") do
#   # Test.assert_equals(maze_runner(maze,["N","N","N","W","W"]), "Dead")
#   # Test.assert_equals(maze_runner(maze,["N","N","N","N","N","E","E","S","S","S","S","S","S"]), "Dead")
# end
#
# Test.it("Should return Lost") do
#   # Test.assert_equals(maze_runner(maze,["N","E","E","E","E"]), "Lost")
# end
