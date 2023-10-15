require "pry-rails"
# TODO: In order to solve issues with chosen cells, maintain "possibles" even after a tile is chosen
# Later on, if there is a conflict with the current one, swap to one of the other possibles instead
# https://bolddunkley.itch.io/wfc-mixed
# https://atiladhun.itch.io/wavefunction-collapse

# Every cell has "sockets" - sockets are which cells are allowed to be next to it in each direction.
# To generate, randomly choose a cell. Out of the options that are available to the cell,
#   randomly choose one. After choosing, must update the cells around it based on their availability.
# Smart choosing: Keep track of the stack. When a cell is selected and the surrounding cells are chosen, if there comes a cell that becomes impossible, exit to the top of the stack and remove the current cell as a possibility
# Rotations should be allowed for every cell, and allowed sockets should rotate accordingly
# Potentially also have rules for what tiles are allowed at edges?
#   Maybe this can be done with an exterior mask of "blanks"

class Failed < StandardError; end

# class Socket
#   attr_accessor :name, :rules
# end

module Calc
  module_function

  def weighted_choice(keyvals)
    sum = keyvals.values.sum
    selected_idx = rand(0..sum.to_f)

    keyvals.each do |key, weight|
      return key if selected_idx <= weight
      selected_idx -= weight
    end; nil
  end
end

module Cardinal
  module_function
  def dirs
    @dirs ||= [:n, :e, :s, :w, :ne, :nw, :se, :sw]
  end

  def directions
    [
      [ 0,  1],
      [ 0, -1],
      [ 1,  0],
      [-1,  0],
    ]
  end

  def inverse(dir)
    case dir
    when :n then :s
    when :e then :w
    when :s then :n
    when :w then :e
    when :ne then :sw
    when :nw then :se
    when :se then :nw
    when :sw then :ne
    end
  end

  def coord(dir)
    case dir
    when :n  then [ 0, -1]
    when :e  then [ 1,  0]
    when :s  then [ 0,  1]
    when :w  then [-1,  0]
    when :ne then [ 1, -1]
    when :nw then [-1, -1]
    when :se then [ 1,  1]
    when :sw then [-1,  1]
    end
  end

  def rotate_dir(dir)
    case dir
    when :n then :e
    when :e then :s
    when :s then :w
    when :w then :n
    when :ne then :se
    when :nw then :ne
    when :se then :sw
    when :sw then :nw
    end
  end

  def rotate(rules, count=1)
    return rules if count <= 0

    rotate(
      rules.each_with_object({}) { |(k, v), rotated| rotated[rotate_dir(k)] = v },
      count-1,
    )
  end
end

class Tile
  @@tiles = {}

  def self.all = @@tiles
  def self.ids = @@tiles.values.map(&:id)
  def self.[](id) = @@tiles[id]
  def self.mode=(new_mode)
    @@mode = new_mode
  end

  attr_accessor :name, :weight, :rotation, :rules, :rotatable

  def initialize(name, **args)
    @name = name
    @alias = *args[:alias] || []
    @weight = args[:weight] || 1
    @rotation = args[:rotation]|| 0
    @rotatable = args[:rotatable] || false
    @rules = Hash.new([]).merge(
      args[:rules] || args.slice(*Cardinal.dirs).transform_values { |v| v.is_a?(Array) ? v : [v] }
    )
    @@tiles[id] = self

    if args[:rotatable] && @rotation == 0
      3.times { |t|
        Tile.new(name,
          **args.except(*Cardinal.dirs).merge(
            rotation: t+1,
            rules: Cardinal.rotate(@rules, t+1)
          )
        )
      }
    end
  end

  def aliases
    [@name] + @alias
  end

  def id
    @rotatable ? "#{@name}.#{@rotation}" : @name
  end

  def compatible?(dir, tile)
    return false if tile.nil?
    inverse = Cardinal.inverse(dir)
    other_match = tile.rules[inverse].empty? || !(tile.rules[inverse] & aliases).empty?
    local_match = @rules[dir].empty? || !(@rules[dir] & tile.aliases).empty?

    other_match && local_match
  end

  def self.validate
    # Go through and make sure each tile rule matches with the opposite tile rule
    # (straight.n includes angle, so angle.s should include straight)
    # All items in all rules should represent ids from other Tiles

    # Or MAYBE rules only need a single socket, and the other cell is assumed
  end
end

class Board
  attr_accessor :cells, :width, :height

  def self.draw=(showproc)
    @@showproc = showproc
  end

  def initialize(width, height)
    @width = width
    @height = height
    @cells = Array.new(height) { |y| Array.new(width) { |x| Cell.new(x, y, self) } }
  end

  def set(x, y, name, rotation=nil)
    @cells[y][x].choose([name, rotation].compact.join(".")) || raise(Failed, "No tile found with name: #{name}")
  end

  def at(cell, dir)
    relx, rely = Cardinal.coord(dir)
    x = cell.x + relx
    y = cell.y + rely
    return if x < 0 || x >= @width
    return if y < 0 || y >= @height

    @cells[y][x]
  end

  def solve!
    flat_cells = @cells.flatten.shuffle.sort_by { |c| c.tile.nil? ? 0 : 1 }
    loop do
      break if flat_cells.empty?
      cell = flat_cells.shift
      flat_cells.unshift(*cell.neighbors.shuffle) unless cell.solved?
      cell.solve!
    end
  end

  def show(cell)
    if @@showproc
      @@showproc.call(cell)
    else
      print cell.tile
    end
  end

  def draw
    system "clear"
    @cells.each do |row|
      row.each { |cell| show(cell) }
      puts
    end
  end
end

class Cell
  attr_accessor :x, :y, :tile, :possibles, :board, :err

  def initialize(x, y, board)
    @x = x
    @y = y
    @possibles = Tile.ids
    @board = board
  end

  def err? = @err

  def solved?
    @solved ||= neighbors.all?(&:tile)
  end

  def choose(tile_id)
    return @tile unless @tile.nil?

    @tile = Tile[tile_id]
    @possibles = [tile_id]
    neighbors.each(&:filter_possibles!)
  end

  def solve!
    return true if solved?

    select_possible!
    @solved = true
  end

  def select_possible!
    return @tile unless @tile.nil?

    choose(
      Calc.weighted_choice(
        @possibles.each_with_object({}) { |tile_id, obj|
          tile = Tile[tile_id] || raise("\e[31m No tile found: #{tile_id}\e[0m")
          obj[tile] = tile.weight&.to_f || 1
        }
      )&.id
    )
  end

  def neighbors
    Cardinal.directions.map { |rx, ry|
      x, y = @x+rx, @y+ry
      next if x < 0 || x >= @board.width
      next if y < 0 || y >= @board.height

      @board.cells[y][x]
    }.compact
  end

  def possible_tiles
    @possibles.map { |tile_id| Tile[tile_id] }
  end

  def draw
    char_width = 1
    print("\033[#{@y+1};#{(@x*char_width)+1}f")
    board.show(self)
  end

  def filter_possibles!
    changed = false
    @possibles = possible_tiles.select { |check_tile|
      Cardinal.dirs.all? do |dir|
        neighbor = @board.at(self, dir)
        next true if neighbor.nil?

        neighbor.possible_tiles.any? do |possible_neighbor_tile|
          check_tile.compatible?(dir, possible_neighbor_tile)
        end
      end.tap { |b| changed = true if !b }
    }.map(&:id)

    if @possibles.length == 1
      choose(@possibles.first)
      # sleep 0.05
      # @board.draw
    elsif @possibles.length == 0
      @err = true
      # @board.draw
      # binding.pry
      choose(Tile.ids.sample)
      # raise "Invalid map!"
    elsif changed
      neighbors.each(&:filter_possibles!)
    else
      return # Don't draw
    end

    sleep 0.05
    draw
  end
end

case ARGV[0]&.to_sym
when :grid then require "/Users/rocco/code/games/wfc/grid.rb"
when :game then require "/Users/rocco/code/games/wfc/game.rb"
else require "/Users/rocco/code/games/wfc/cave.rb"
end

begin
  print "\e[?25l" # hide_cursor
  board = Board.new(20, 20)
  # board.set(rand(20), rand(20), :water, rand(4))
  # board.set(0, 0, :mr)
  # board.set(0, 0, :mr)
  # select custom cells here
  board.draw
  board.solve!
rescue StandardError => e
  board.draw
  puts "\e[31m#{e}\e[0m"
  raise
ensure
  print "\e[?25h" # show_cursor
end
