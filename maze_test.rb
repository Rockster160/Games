require 'pry-rails'

class Maze
  attr_accessor :width, :height, :cells

  def initialize(width, height)
    @width, @height = width, height
    @cells = Array.new(height) {Array.new(width) {Cell.new}}
    @cells.each_with_index do |cell_row, y|
      cell_row.each_with_index do |cell, x|
        cell.coords = {x: x, y: y}
        # (-1..1).each do |rel_x|
        #   (-1..1).each do |rel_y|
        [[1, 0], [-1, 0], [0, -1], [0, 1]].each do |rel_x, rel_y|
          new_x, new_y = rel_x + x, rel_y + y
          # next if rel_x == 0 && rel_y == 0
          next if new_y >= height || new_y < 0
          next if new_x >= height || new_x < 0
          next unless cells[new_y] && cells[new_y][new_x]
          cell.neighbor_coords << {x: new_x, y: new_y}
        end
      end
    end
  end

  def all_cells
    cells.flatten
  end

  def cell_neighbors(cell)
    cell.neighbor_coords.map do |coord|
      cells[coord[:y]][coord[:x]]
    end
  end

  def count_all_live_cell_neighbors!
    all_cells.each do |cell|
      count_live_cell_neighbors!(cell)
    end
  end

  def count_live_cell_neighbors!(cell)
    cell.live_neighbor_count = cell_neighbors(cell).inject(0) { |sum, neighbor| sum + neighbor.to_i }
  end

  def generate!
    $starting_cell = cells.sample.sample
    $starting_cell.live = true
    count_all_live_cell_neighbors!
    until no_frontier_cells ||= nil
      frontier_cells = all_cells.select { |cell| cell.live_neighbor_count == 1 }
      frontier_cell = frontier_cells.sample
      all_neighbors = cell_neighbors(frontier_cell)
      dead_neighbors = all_neighbors.select { |cell| !(cell.live) }
      frontier_cell.live = true
      all_neighbors.each { |cell| count_live_cell_neighbors!(cell) }
      draw
      sleep 0.01
      no_frontier_cells = frontier_cells.count == 0
    end
    binding.pry
    self
  end

  def draw
    system 'clear'
    cells.each {|row| puts row.join('')}
    # cells.each {|row| puts row.map(&:coords).join('')}
  end

end

class Cell
  attr_accessor :neighbor_coords, :live, :live_neighbor_count, :coords

  def initialize
    @live = false
    @neighbor_coords = []
  end

  def to_s
    return "\e[31mx \e[0m" if coords == {x: 5, y: 10}
    @live ? '  ' : '# '
  end

  def to_i
    @live ? 1 : 0
  end

end

Maze.new(20, 30).generate!.draw
