require 'pry'
class Cell
  attr_accessor :neighbor_count, :live
  def initialize(alive=nil)
    @live = alive
    return unless alive.nil?
    @live = rand(2) == 0 ? true : false
  end
  def tick
    @live = @live ? (neighbor_count == 2 || neighbor_count == 3) : (neighbor_count == 3)
  end
  def to_s
    @live ? 'o' : '.'
  end
end

class Board
  attr_accessor :rows
  def initialize
    @rows = Array.new(17) { Array.new(17) { Cell.new(false) } }
  end
  def tick
    @rows.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cell.neighbor_count =  (-1..1).map do |rel_y|
          (-1..1).map do |rel_x|
            next if rel_x == 0 && rel_y == 0
            @rows[y + rel_y][x + rel_x].live unless @rows[y + rel_y].nil? || @rows[y + rel_y][x + rel_x].nil?
          end
        end.flatten.compact.count(true)
      end
    end
    @rows.each { |row| row.each(&:tick) }
  end
  def show
    @rows.map { |row| row.join(' ') }
  end
  def to_comparable
    @rows.map do |row|
      row.map { |cell| cell.live }
    end.flatten
  end
end

class Game
  attr_accessor :board
  def initialize
    @board = Board.new
  end
  def tick
    @board.tick
  end
  def draw
    # system 'clear' or system 'cls'
    puts @board.show
  end
end

class TestGame
  def initialize(binary_iteration, modifiable_area, goals)
    @old_board = nil
    @binary_iteration = binary_iteration
    @modifiable_area = modifiable_area
    @goals = goals
    @game = Game.new
    run_test
  end

  def boards_match?
    return false if @old_board.nil?
    @game.board.to_comparable == @old_board
  end

  def run_test
    @binary_iteration.split("").each_with_index do |cell_choice, idx|
      next if cell_choice == "0"
      cell_x, cell_y = @modifiable_area[idx]
      write_cell(cell_x, cell_y, true)
    end

    puts "Start: #{@binary_iteration}"
    @game.draw

    running = true
    1000.times do |t|
      break unless running
      @game.tick

      if check_solution
        puts "Solution: #{@binary_iteration} | Iteration: #{t}"
        running = false
        @game.draw
      elsif boards_match?
        puts "Stable: #{@binary_iteration} | Iteration: #{t}"
        running = false
      else
        @old_board = @game.board.to_comparable
      end
    end

    if running
      puts "Looping?: #{@binary_iteration} | Iteration: 1000+"
      @game.draw
    end
  end

  def check_solution
    passing = true

    @goals.each do |goal|
      next unless passing

      goal.each do |(goal_x, goal_y)|
        next unless passing
        next if goal_x.nil? || goal_y.nil?

        passing = false unless read_cell(goal_x, goal_y)
      end
    end

    passing
  end

  def get_cell(x, y)
    @game.board.rows[y][x]
  end

  def write_cell(x, y, life)
    cell = get_cell(x, y)
    cell.live = true
  end

  def read_cell(x, y)
    cell = get_cell(x, y)
    cell.live
  end
end

modifiable_area = [
  [7, 14], [8, 14], [9, 14],
  [7, 15], [8, 15], [9, 15],
  [7, 16], [8, 16], [9, 16],
]
goal1 = [
  [    ], [4, 6],
  [3, 7], [4, 7],
  [3, 8], [4, 8],
]
goal2 = [
  [12, 6], [     ],
  [12, 7], [13, 7],
  [12, 8], [13, 8],
]

(0..("1"*modifiable_area.length).to_i(2)).each do |b10_iteration|
  binary_iteration = b10_iteration.to_s(2).rjust(modifiable_area.length, "0")
  TestGame.new(binary_iteration, modifiable_area, [goal1, goal2])
  puts "="*60
end
# TestGame.new("11110100", modifiable_area, [goal1, goal2])
