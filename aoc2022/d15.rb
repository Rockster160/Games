# $test = true
# $draw = true
$part = 2
$part ||= 1
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

class Sensor
  attr_accessor :num, :x, :y, :bx, :by, :dist, :minx, :maxx, :miny, :maxy

  def initialize(sx, sy, bx, by)
    @num = $sensors.count+1
    @x = sx
    @y = sy
    @bx = bx
    @by = by
    @dist = distance_to(bx, by)
    @minx = @x - @dist
    @maxx = @x + @dist
    @miny = @y - @dist
    @maxy = @y + @dist
  end

  def coord
    [@x, @y]
  end

  def to_s
    "##{@num}#{coord.inspect}r:#{@dist}"
  end

  def distance_to(x, y)
    manhattan_dist([@x, @y], [x, y])
  end

  def xs_at_y(y)
    return [] unless (@miny..@maxy).cover?(y)

    (@minx..@maxx).select { |x| distance_to(x, y) <= @dist }
  end

  def debug(coords)
    system "clear"
    g = InfiniBoard.new(".")
    g.set(coord, "#{cyan}S #{Colorize.reset_code}")
    coords.each { |c| g.set(c, "#") }
    Draw.board(g.to_a)
    Draw.borders(g.to_a, [coords.map { |c| c[0] }.min, coords.map { |c| c[1] }.min])
  end

  def surround
    # debug(surroundings)
    [].tap { |surroundings|
      top = @y-@dist-1
      right = @x+@dist+1
      bot = @y+@dist+1
      left = @x-@dist-1
      loop.with_index { |_, i|
        break if i > dist
        surroundings << [@x+i, top+i] # top->right
        surroundings << [right-i, @y+i] #right->bot
        surroundings << [@x-i, bot-i] # bot-> left
        surroundings << [left+i, @y-i] # left-> top
      }
    }.tap { |s|
      # next unless $draw
      # next unless s.include?([14, 11])
      #
      # debug(s)
    }
  end
end

def manhattan_dist(c1, c2)
  (c1[0] - c2[0]).abs + (c1[1] - c2[1]).abs
end

$sensors = []
$minx = nil
$maxx = nil
$miny = nil
$maxy = nil

Benchmark.time("Collect Sensors") do |bm|
  input.split("\n").map.with_index { |row, idx|
    bm.counter(idx+1)
    _, sx, sy, bx, by = row.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/).to_a.map(&:to_i)
    oxmin, oxmax = [bx, bx].sort
    oymin, oymax = [by, by].sort

    $minx = oxmin if $minx.nil? || oxmin < $minx
    $maxx = oxmax if $maxx.nil? || oxmax > $maxx
    $miny = oymin if $miny.nil? || oymin < $miny
    $maxy = oymax if $maxy.nil? || oymax > $maxy

    $sensors << Sensor.new(sx, sy, bx, by)
  }
end

if $part == 1
  y = $test ? 10 : 2_000_000
  obj_xs_at_y = Benchmark.time("Find Beacons and sensors") do |bm|
    $sensors.each_with_object([]) { |sensor, xs|
      xs << sensor.x if sensor.y == y
      xs << sensor.bx if sensor.by == y
    }.uniq
  end

  relevant_sensors = []
  sensor_xs = Benchmark.time("Find Xs") do |bm|
    $sensors.map.with_index { |sensor, idx|
      bm.counter(idx+1, $sensors.count)
      sensor.xs_at_y(y).tap { |sxs| relevant_sensors << sensor if sxs.length > 0 }
    }.flatten.uniq
  end

  valid_xs = Benchmark.time("Filter down") do |bm|
    sensor_xs - obj_xs_at_y
  end

  puts "Count: #{valid_xs.count}"
end

if $part == 2
  max = $test ? 20 : 4_000_000
  min = 0

  # possibles = []
  # Benchmark.time("Collecting surroundings") do |bm|
  #   $sensors.each.with_index { |sensor, idx|
  #     bm.counter(idx+1, $sensors.count)
  #     possibles += sensor.surround
  #   }
  # end
  # Benchmark.time("Uniq!") do |bm|
  #   possibles.uniq!
  # end
  # count = possibles.count
  # Benchmark.time("Filtering dups") do |bm|
  #   possibles.reject!.with_index { |possible, idx|
  #     bm.counter(idx+1, count)
  #     # true means reject
  #     next true if !(min..max).cover?(possible[0]) || !(min..max).cover?(possible[1])
  #     $sensors.any? { |sensor| sensor.distance_to(*possible) <= sensor.dist }
  #   }
  # end
  # if possibles.length != 1
  #   puts "\e[31m[ERROR] | Wrong possibilities!\e[0m"
  #   $pryonce || ($pryonce ||= true) && binding.pry
  # end

  # maybes = []
  # surrounds = []
  # found = $sensors.each_with_index.find { |sensor, idx|
  #   # bm.counter(idx+1, $sensors.count)
  #   nearby_sensors = Benchmark.time("Find nearby to Sensor #{sensor}") do |bm|
  #     $sensors.select.with_index do |other, oidx|
  #       next if [other.x, other.y] == [sensor.x, sensor.y]
  #       (sensor.distance_to(*[other.x, other.y]) == (sensor.dist + other.dist) + 1)
  #       .tap {|bool|
  #         color = bool ? lime : grey
  #         puts "#{color} #{other} dist = #{sensor.distance_to(*[other.x, other.y])} "
  #       }
  #     end
  #   end
  #   print Colorize.reset_code
  #   next if nearby_sensors.length == 0
  #
  #   surround = Benchmark.time("Find surroundings of #{sensor}") do |bm|
  #     sensor.surround.tap { |s| puts s.inspect }
  #   end
  #   Benchmark.time("Filter surroundings from other sensors") do |bm|
  #     puts "========================= Surroundings"
  #     p surround
  #     surround.reject! { |point|
  #       puts "#{grey}Looking for point #{point.inspect} (dist:#{sensor.distance_to(*point)})"
  #       nearby_sensors.find do |nearby|
  #         (nearby.distance_to(*point) <= nearby.dist)
  #         .tap { |bool|
  #           color = bool ? orange : grey
  #           puts "#{color}  #{nearby} dist = #{nearby.distance_to(*point)}"
  #           $pryonce || ($pryonce ||= true) && binding.pry if bool && point == [14, 11]
  #         }
  #       end.tap { |found|
  #
  #         # $pryonce || ($pryonce ||= true) && binding.pry if point == [14, 11]
  #       }
  #     }
  #     puts "========================= Surroundings AFTER"
  #     p surround
  #     $pryonce || ($pryonce ||= true) && binding.pry
  #   end
  #   print Colorize.reset_code
  #
  #   $pryonce || ($pryonce ||= true) && binding.pry if surround.length == 1
  #   break surround.first if surround.length == 1
  # } || []

  maybes = []
  # bads = []
  Benchmark.time("Gather Surroundings") do |bm|
    $sensors.each_with_index do |sensor, idx|
      bm.counter(idx+1, $sensors.count)
      maybes += sensor.surround
    end
  end
  puts "Maybe: #{maybes.count}"
  Benchmark.time("Uniq / clamp Maybes") do |bm|
    maybes.uniq!.reject! { |point| !(min..max).cover?(point[0]) || !(min..max).cover?(point[1]) }
  end
  Benchmark.time("Filter Maybes") do |bm|
    $sensors.each_with_index do |sensor, idx|
      bm.counter(idx+1, $sensors.count)
      maybes.reject! { |point| sensor.distance_to(*point) <= sensor.dist }
    end
  end
  p maybes
  bx, by = maybes.first
  tuning_frequency = (bx*4_000_000)+by
  puts "TF: #{tuning_frequency}"
end
