# $test = true
$part = 1
# $pryonce || ($pryonce ||= true) && binding.pry

require "/Users/rocco/code/games/aoc2022/base"
# Draw.cell_width = 1

input = File.read("/Users/rocco/code/games/aoc2022/d16.txt")
input = "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II" if $test

class Area
  attr_accessor :name, :rate, :connections, :paths

  def initialize(name, rate, connections)
    @name = name
    @rate = rate.to_i
    @connections = connections.split(", ")
    @paths = []
    $areas[name] = self
  end

  def tunnels
    @connections.map { |path| $areas[path] }
  end
end

# worth = $areas.select { |_name, area| area.rate > 0 }

def explore(area, path=[])
  path = path + [area.name]
  start = ($paths[path.first] ||= {})
  old_dist = start[path.last]&.length

  if path.length > 1 && (old_dist.nil? || old_dist > path.length)
    start[path.last] = path[1..]
  end

  area.tunnels.each { |down|
    explore(down, path) unless path.include?(down.name)
  }
end


$paths = {}
$areas = {}
$pressurized_valves = []
$countdown = 30

input.split("\n").each_with_index { |row, idx|
  _, name, rate, tunnels = row.match(/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ((?:\w+(, )?)*)/).to_a
  area = Area.new(name, rate, tunnels)
  $pressurized_valves.push(area) if area.rate > 0
}

Benchmark.time("Find all Paths") do |bm|
  $areas.each_with_index do |(_name, area), idx|
    explore(area)
  end
end

class Adventure
  attr_accessor :current, :steps, :pressure, :pressurized_valves, :open_valves

  def initialize
    @current = $areas["AA"]
    @steps = []
    @pressure = 0
    @open_valves = []
    @pressurized_valves = $pressurized_valves.dup
  end

  def alternate_reality
    # Need to deep clone
    self.dup.tap { |alternate|
      alternate.current = @current.dup
      alternate.steps = @steps.dup
      alternate.pressure = @pressure.dup
      alternate.pressurized_valves = @pressurized_valves.dup
      alternate.open_valves = @open_valves.dup
    }
  end

  def debug
    cpressure = 0
    valves_open = {}
    @steps.each_with_index do |step, idx|
      puts "== Minute #{idx+1} =="
      if valves_open.length == 0
        puts "No valves are open."
      elsif valves_open.length == 1
        puts "Valve #{valves_open.keys.first} is open, releasing #{valves_open.values.first} pressure."
      else
        names = valves_open.keys.sort.tap { |a| a[-1] = "and #{a[-1]}" }
        names = names.length == 2 ? names.join(" ") : names.join(", ")
        puts "Valves #{names} are open, releasing #{valves_open.values.sum} pressure."
      end
      cpressure += valves_open.values.sum
      name = step[/\w+$/]
      if step.match?(/^move/i)
        puts "You move to valve #{name}."
      else
        puts "You open valve #{name}."
        $pryonce || ($pryonce ||= true) && binding.pry if $areas[name].nil?
        valves_open[name] = $areas[name].rate
      end
      puts ""
    end
  end

  def open_valve(area)
    path = $paths[@current.name][area.name]
    @steps += path.map { |step| "Move to #{step}" }
    @steps += ["Open valve #{area.name}"]
    @pressure += ($countdown - @steps.length) * area.rate
    @current = area
    @open_valves.push(area)
    @pressurized_valves.reject! { |valve| valve.name == area.name }
  end
end

def continue_journey(adventure=Adventure.new)
  if adventure.steps.length >= $countdown || adventure.pressurized_valves.length == 0
    $completed << adventure

    # if adventure.steps == ["Move to DD", "Open valve DD"]
    #   $pryonce || ($pryonce ||= true) && binding.pry
    # end
    return
  end

  available = adventure.pressurized_valves
  smart = available.select { |valve|
    path = $paths[adventure.current.name][valve.name]
    # You would never walk past an on_valve that's higher than the one you're going to
    next false if path.length + 1 > $countdown - adventure.steps.length
    true
  }

  smart.each do |goal_valve|
    alternate = adventure.alternate_reality
    alternate.open_valve(goal_valve)
    continue_journey(alternate)
  end
end

puts "Direct paths: #{$paths.sum { |starts, ends| ends.keys.length }}"

$completed = []
Benchmark.time("Journey") do |bm|
  continue_journey
end

puts "Possible Adventures: #{$completed.count}"

best = nil
Benchmark.time("Get best") do |bm|
  best = $completed.max { |a1, a2| a1.pressure <=> a2.pressure }
end

puts best.inspect
puts "Pressure Released: #{best.pressure}"

puts best.debug
# $pryonce || ($pryonce ||= true) && binding.pry

# TOO LOW -- 1824
