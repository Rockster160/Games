$test = true
# ruby /Users/rocco/code/games/aoc2022/gen.rb 10
require "pry-rails"
require "json"

require "io/console"
require "io/wait"
require "/Users/rocco/code/games/engine/colorize"; include Colorize
require "/Users/rocco/code/games/engine/draw"; include Draw

input = File.read("/Users/rocco/code/games/aoc2022/d9.txt")
# input = "R 4
# U 4
# L 3
# D 1
# R 4
# D 1
# L 5
# R 2" if $test
input = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20" if $test

def range(visited)
  range_data = [{min: 0, max: 0, cur: 0}, {min: 0, max: 0, cur: 0}]
  visited.each_with_object(range_data) { |(x, y), (rx, ry)|
    rx[:min], _, rx[:max] = [rx[:min], x, rx[:max]].sort
    ry[:min], _, ry[:max] = [ry[:min], y, ry[:max]].sort
  }
end

def draw(rope, visited, size=nil, origin=nil)
  visited = visited.uniq
  range_data = range(rope + visited)
  size ||= range_data.map { |ro| ro[:max] - ro[:min] }
  grid = Array.new(size[1]+3) { Array.new(size[0]+3) { "  " } }
  origin ||= range_data.map { |ro| ro[:min].abs+1 }
  moveto(0, 0)
  bg = color(:grey, nil, :bg, reset: false)
  print bg
  print grid.map { |r| r.join("") }.join("#{reset_code(:bg)}#{newline}#{bg}")

  print color(:black, nil, :fg)
  visited.uniq.each do |cell|
    drawat(add(cell, origin), color(:orange, "  ", :bg))
  end

  drawat(origin, color(:magenta, "s ", :bg))
  rope.each_with_index { |cell, idx|
    next if idx == 0

    icon = color(:cyan, "#{idx} ", :bg)
    icon = color(:green, "T ", :bg) if idx == rope.length - 1

    drawat(add(cell, origin), icon)
  }
  drawat(add(rope.first, origin), color(:rocco, "H ", :bg))

  moveto(0, size[1]+4)
  print reset_code(:fg)
  print reset_code(:bg)
  sleep 0.1 if $test
end

def touching?(c1, c2)
  (-1..1).any? { |x|
    (-1..1).any? { |y|
      [c1[0]+x, c1[1]+y] == c2
    }
  }
end

def add(c1, c2)
  [c1[0]+c2[0], c1[1]+c2[1]]
end

def follow(head, tail)
  return tail if touching?(head, tail)
  dir = head[0] == tail[0] || head[1] == tail[1] ? :inline : :diagonal

  (-1..1).each { |x|
    (-1..1).each { |y|
      next if dir == :inline && ![x, y].include?(0) # Skip diagonals
      next if dir == :diagonal && [x, y].include?(0) # Skip inlines

      new_tail = add(tail, [x, y])
      return new_tail if touching?(new_tail, head)
    }
  }
end

begin
  map_size = $test ? [25, 20] : nil
  map_origin = $test ? [12, 16] : nil
  rope_length = $test ? 10 : 10

  system "clear" or system "cls"
  print "\e[?25l" # Hide cursor

  visited = []
  rope = Array.new(rope_length) { [0, 0] }
  input.split("\n").each do |cmd|
    dir, count = cmd.split(" ")
    count.to_i.times do |m|
      head = rope[0]
      case dir
      when "U" then head[1] -= 1
      when "D" then head[1] += 1
      when "L" then head[0] -= 1
      when "R" then head[0] += 1
      end

      (1..rope.length-1).each { |t| rope[t] = follow(rope[t-1], rope[t]) }
      visited << rope.last

      draw(rope, visited, map_size, map_origin) if $test
      puts "#{cmd} - #{m} #{clear_rest_line}#{newline}" if $test
      print "#{clear_rest_line}#{newline}"
    end
  end

  puts "Visited: #{visited.uniq.count}"
  range_data = range(rope + visited)
  print "Origin: "
  p range_data.map { |ro| ro[:min].abs+1 }
  print "Size: "
  p range_data.map { |ro| ro[:max] - ro[:min] }
ensure
  print "\e[?25h" # Show cursor
end
