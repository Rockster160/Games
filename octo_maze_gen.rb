require 'pry-rails'

class Cell
  attr_accessor :n, :e, :s, :w, :x, :y, :p, :id
  BASE = 16

  def initialize(id)
    @id = id
    # ratio=50
    @n = false # rand(100) <= ratio
    @e = false # rand(100) <= ratio
    @s = false # rand(100) <= ratio
    @w = false # rand(100) <= ratio
  end

  def place(x=0, y=0)
    @x = x
    @y = y
    self
  end

  def neighbors
    [@n, @e, @s, @w].count(true)
  end

  def to_binary
    [
      @n ? "1" : "0",
      @e ? "1" : "0",
      @s ? "1" : "0",
      @w ? "1" : "0",
    ].join("")
  end

  def to_hex
    @p = to_binary.to_i(2).to_s(BASE)
  end

  def to_s
    "#{@id.to_s.rjust(3, ' ')}  X:#{@x.to_s.rjust(2, ' ')} Y:#{@y.to_s.rjust(2, ' ')} | N:#{@n ? 1 : 0} E:#{@e ? 1 : 0} S:#{@s ? 1 : 0} W:#{@w ? 1 : 0}"
  end
end

module Algorithm
  module_function
  DIRS = {
    n: [0, -1],
    e: [1, 0],
    s: [0, 1],
    w: [-1, 0],
  }

  def inverse_dir(dir)
    case dir.to_s.to_sym
    when :n then :s
    when :e then :w
    when :s then :n
    when :w then :e
    end
  end

  def full_random(maze)
    cell = maze.cells&.sample || maze.new_cell
    dir = DIRS.keys.sample
    x, y = DIRS[dir]

    # return if rand(cell.neighbors + 1) > 0

    # There's already a path here, so no need to recalculate stuff
    return if cell.send(dir)

    new_cell = maze.new_cell(cell.x + x, cell.y + y)
    cell.send("#{dir}=", true)
    new_cell.send("#{inverse_dir(dir)}=", true)
    cell.to_hex
    new_cell.to_hex
  end
end

class Maze
  attr_accessor :cells, :min_x, :min_y, :max_x, :max_y

  def initialize(cell_count=5)
    @cell_count = cell_count
    @cells = []
  end

  def generate
    Algorithm.full_random(self) while @cells.length < @cell_count
    set_offsets
  end

  def new_cell(x=0, y=0)
    cell = cell_at(x, y)
    return cell if cell

    cell = Cell.new(cells.count).place(x, y)
    cells << cell
    cell
  end

  def cell_at(x, y)
    cells.find { |cell| cell.x == x && cell.y == y }
  end

  def find_cell(id)
    cells.find { |cell| cell.id == id }
  end

  def ordered_cells
    cells.sort_by { |cell| [cell.y, cell.x] }
  end

  def set_offsets
    @min_x = 0
    @min_y = 0
    @max_x = 0
    @max_y = 0

    cells.each do |cell|
      @min_x = cell.x if cell.x < @min_x
      @min_y = cell.y if cell.y < @min_y

      @max_x = cell.x if cell.x > @max_x
      @max_y = cell.y if cell.y > @max_y
    end

    cells.each do |cell|
      cell.x -= @min_x
      cell.y -= @min_y
    end

    @width = (@max_x - @min_x) + 1
    @height = (@max_y - @min_y) + 1
  end

  def export
    generate if cells.empty?

    map = Array.new(@height) { Array.new(@width) { " " } }

    cells.each do |cell|
      map[cell.y][cell.x] = cell.to_hex
    end

    map
  end
end

module Draw
  module_function

  def draw(count=5)
    maze ||= Maze.new(count)
    compact_map = maze.export

    # by_three(compact_map)
    by_five(compact_map)
  end

  def by_three(compact_map)
    height = compact_map.length
    width = compact_map.first.length

    map = Array.new(height*3) { Array.new(width*3) { " " } }
    compact_map.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cx = x*3 + 1
        cy = y*3 + 1
        n, e, s, w = cell.to_i(16).to_s(2).rjust(4, "0").split("").map { |char| char == "1" }
        map[cy][cx] = cell
        map[cy - 1][cx] = "#" if n
        map[cy][cx + 1] = "#" if e
        map[cy + 1][cx] = "#" if s
        map[cy][cx - 1] = "#" if w
      end
    end
    map.each { |l| puts l.join(" ") }
  end

  def by_five(compact_map)
    height = compact_map.length
    width = compact_map.first.length

    map = Array.new(height*5) { Array.new(width*5) { " " } }
    compact_map.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        next if cell == " "
        cx = x*5 + 2
        cy = y*5 + 2
        n, e, s, w = cell.to_i(16).to_s(2).rjust(4, "0").split("").map { |char| char == "1" }
        (-1..1).each { |dy|
          (-1..1).each { |dx|
            next if dy == 0 && dx == 0
            map[cy + dy][cx + dx] = "#"
          }
        }
        map[cy - 2][cx] = "#" if n
        map[cy][cx + 2] = "#" if e
        map[cy + 2][cx] = "#" if s
        map[cy][cx - 2] = "#" if w
      end
    end
    map.each { |l| puts l.join(" ") }
  end
end
