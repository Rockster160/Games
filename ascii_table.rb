require "/Users/rocco/code/games/engine/colorize"

class AsciiTable
  attr_accessor :rows, :width, :sizes, :padding

  def initialize(opts={})
    @padding = opts[:padding] || 1
    @rows = []
    @width = opts[:width] || 0
    @sizes = []
  end

  def insert_hr
    @rows << :hr
  end

  def <<(new_cells)
    cells = new_cells.map { |cell| cell.is_a?(Cell) ? cell : Cell.new(cell) }
    @width = [cells.length, width].sort.last
    cells.each_with_index { |cell, idx|
      @sizes[idx] = [cell.length, @sizes[idx] || 0].sort.last
    }
    @rows << cells
  end

  def draw
    darkgrey = Colorize.color([100, 100, 100])
    @rows.each do |row|
      if row == :hr
        print "#{darkgrey}+"
        @sizes.each { |cw|
          print "-"*(cw+(@padding*2)) unless cw == 0
          print "+"
        }
        puts "#{uncolor}"
        next
      end

      print "#{darkgrey}|#{uncolor}"
      cells = row.map.with_index { |cell, idx|
        cell.width = @sizes[idx] + @padding*2 unless cell.nil?
        cell.to_s
      }
      print cells.join("#{darkgrey}|#{uncolor}")
      puts "#{darkgrey}|"
    end
  end

  class Cell
    attr_accessor :text, :options, :width

    def initialize(text, opts={})
      @text = text.nil? ? nil : text.to_s
      @opts = opts
    end

    def length
      @text&.length || 0
    end

    def to_s
      @text.then { |str|
        next "" if str.nil?
        case @opts[:align] || :center
        when :center then str = str.center(@width)
        when :left   then str = str.ljust(@width)
        when :right  then str = str.rjust(@width)
        end
        code = @opts.key?(:color) ? Colorize.color(@opts[:color]) : ""
        code = @opts.key?(:bg) ? Colorize.color(@opts[:bg], code, :bg) : code
        "#{code}#{Colorize.bold(str)}#{uncolor}"
      }
    end
  end
end
