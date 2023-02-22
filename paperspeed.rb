require "terminal-table"


class Speed
  attr_accessor :new_speed, :old_speed, :new_first, :new_faster, :diff

  class << self
    def all
      @@speeds
    end

    def clear
      @@speeds = []
    end

    def new_faster
      @@speeds.select { |s| s.new_faster }
    end

    def new_slower
      @@speeds.select { |s| !s.new_faster }
    end
  end

  def initialize(line)
    @@speeds ||= []
    full, q1, t1, q2, t2 = line.match(/((?:new|old)_query): (\d+\.\d+) \|\| ((?:new|old)_query): (\d+\.\d+)/).to_a

    if q1 == "new_query"
      @new_first = true
      @new_speed = t1.to_f
      @old_speed = t2.to_f
    else
      @new_first = false
      @new_speed = t2.to_f
      @old_speed = t1.to_f
    end

    @new_faster = @new_speed < @old_speed
    @diff = (@old_speed - @new_speed).abs

    @@speeds << self
  end
end

raw = STDIN.read
lines = raw.split("\n")
lines.each { |line| Speed.new(line) }

puts Terminal::Table.new do |t|
  t.add_row ["", "New", "Old"]
  t.add_separator
  t.add_row ["Min Diff", Speed.new_faster.min {|s|s.diff}, Speed.new_slower.min {|s|s.diff}]
end

# speeds.select { |s| !s.new_faster }
#
# speeds.select { |s| s.new_faster }.max { |s| s.diff }
# speeds.select { |s| !s.new_faster }.max { |s| s.diff }
