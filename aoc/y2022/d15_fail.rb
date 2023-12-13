$test = true
$draw = true
$part = 1
# $pryonce || ($pryonce ||= true) && binding.pry

require "/Users/rocco/code/games/aoc2022/base"
# Draw.cell_width = 1

input = File.read("/Users/rocco/code/games/aoc2022/d15.txt")
input = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3" if $test

system "clear"
# puts "Board setup"
@grid = InfiniBoard.new(-> (x, y) { $draw ? Colorize.color(:grey, "# ") : "# " })

def manhattan_dist(c1, c2)
  (c1[0] - c2[0]).abs + (c1[1] - c2[1]).abs
end

objects = []
minx = nil
maxx = nil
miny = nil
maxy = nil

# puts "Iterate through sensors"
input.split("\n").each_with_index { |row, idx|
  _, sx, sy, bx, by = row.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/).to_a.map(&:to_i)
  oxmin, oxmax = [sx, bx].sort
  oymin, oymax = [sy, by].sort

  minx = oxmin if minx.nil? || oxmin < minx
  maxx = oxmax if maxx.nil? || oxmax > maxx
  miny = oymin if miny.nil? || oymin < miny
  maxy = oymax if maxy.nil? || oymax > maxy

  objects << [[sx, sy], [bx, by]]
}

colors = (color_list.keys - [:black, :grey, :white, :silver]).reverse
objects = objects.sort_by { |sensor, beacon| manhattan_dist(sensor, beacon) } if $draw
# puts "Find visible"
objects.each_with_index do |(sensor, beacon), idx|
  # print "\nSensor: #{sensor.inspect}, Beacon: #{beacon.inspect}"
  sx, sy = sensor
  bx, by = beacon
  color = colors[idx % colors.length]

  d = manhattan_dist(sensor, beacon)
  # print ", Distance: #{d}\n"
  (-d..d).each do |dy|
    (-d..d).each do |dx|
      nx, ny = [sx+dx, sy+dy]
      next if nx < minx || nx > maxx || ny < miny || ny > maxy
      next unless manhattan_dist([sx, sy], [nx, ny]) <= d

      if $draw
        @grid.set([nx, ny], Colorize.color(color, ". ")) if @grid.at(nx, ny).end_with?("# ")
      else
        @grid.set([nx, ny], ". ") if @grid.at(nx, ny).end_with?("# ")
      end
    end
  end

  if $draw
    @grid.set(sensor, Colorize.color(color, "S "))
    @grid.set(beacon, Colorize.color(color, "B "))
  else
    @grid.set(sensor, "S ")
    @grid.set(beacon, "B ")
  end
end
puts

if $draw
  # puts "Drawing"
  Draw.draw_board(@grid.to_a)

  (@grid.minx..@grid.maxx).each do |x|
    (@grid.miny..@grid.maxy).each do |y|
      drawat([x-@grid.minx, @grid.height], x)
      drawat([@grid.width, y-@grid.miny], y)
    end
  end

  moveto(0, @grid.height+1)
end
# puts "Done"
puts
puts "Not visible: #{@grid.grid[10].values.map {|c|c[/..$/][0]}.count(".")}"
