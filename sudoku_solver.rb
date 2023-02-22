# Doesn't work, but would be cool
# class Array
#   def self.[](x, y=nil)
#     y.nil? ? super[x] : super[y][x]
#   end
# end

BOX_CHARS = {
  tr: "┐",
  bl: "└",
  br: "┘",
  tl: "┌",
  tm: "┬",
  bm: "┴",
  lm: "├",
  rm: "┤",
  hz: "─",
  vt: "│",
  md: "┼",
}

require "/Users/rocco/code/games/kata_test_framework.rb"
require "/Users/rocco/code/games/engine/engine"
require "pry-rails"

class SudokuSolver
  def initialize(board)
    @board = board
    @set = []
    @attempt = []
  end

  def possibles(x, y)
    row = @board[y]
    col = @board.map { |row| row[x] }
    chunk_x = x / 3
    chunk_y = y / 3
    chunk_yr = (chunk_y*3)..(chunk_y*3)+2
    chunk_xr = (chunk_x*3)..(chunk_x*3)+2
    chunk = @board[chunk_yr].flat_map { |row| row[chunk_xr] }

    (1..9).to_a - (row + col + chunk)
  end

  def undo(changes)
    changes.each { |coord|
      @attempt.reject! { |ac| ac == coord }
      @board[coord[1]][coord[0]] = 0
    }.then { false } # Always return false from `undo` for boolean logic
  end

  def backtracking_solve(x=0, y=0)
    easy_changes = []
    loop do
       changes = easy_solve # First solve all "easy" cells (One possible solution)
       return true if solved?
       break if changes.none?
       easy_changes += changes
    end

    new_x, new_y = x+1, y
    new_x, new_y = 0, new_y+1 if x >= 9
    return solved? || undo(easy_changes) if new_y >= 9

    # Already solved current cell, skip it
    unless @board[y][x] == 0
      backtracking_solve(new_x, new_y)
      return solved? || undo(easy_changes)
    end

    ps = possibles(x, y)
    return undo(easy_changes) if ps.none?
    ps.each { |possible|
      ps.one? && @attempt.none? ? @set << [x, y] : @attempt << [x, y]

      @board[y][x] = possible
      draw
      return true if backtracking_solve(new_x, new_y)
      @board[y][x] = 0

      @attempt.reject! { |coord| coord == [x, y] }
    }
    solved? || undo(easy_changes)
  end

  def easy_solve(x=0, y=0, changes=[])
    @board[y][x] == 0 && possibles(x, y).tap { |ps|
      next unless ps.one?

      changes << [x, y] unless @attempt.none?
      @attempt.none? ? @set << [x, y] : @attempt << [x, y]
      @board[y][x] = ps.first
      draw
    }

    new_x, new_y = x+1, y
    new_x, new_y = 0, new_y+1 if x >= 9
    return changes if new_y >= 9

    easy_solve(new_x, new_y, changes)
  end

  def solved?
    @solved ||= @board.flatten.none?(0)
  end

  def solve
    draw
    backtracking_solve
    @board
  end

  def print_rows(range)
    @board[range].each_with_index { |row, yidx|
      print BOX_CHARS[:vt]
      y = range.to_a[yidx]
      row.each_with_index { |cell, x|
        if cell == 0
          print(Colorize.red(" #{cell}"))
        elsif @attempt.include?([x,y])
          print(Colorize.gold(" #{cell}"))
        elsif @set.include?([x,y])
          print(Colorize.lime(" #{cell}"))
        else
          print(Colorize.grey(" #{cell}"))
        end
        print BOX_CHARS[:vt] if x % 3 == 2
      }
      print Draw.newline
    }
  end

  def draw
    x = BOX_CHARS
    w = 6
    Draw.moveto(0, 0)
    hr = x[:lm] + x[:hz]*w + x[:md] + x[:hz]*w + x[:md] + x[:hz]*w + x[:rm] + Draw.newline
    print x[:tl] + x[:hz]*w + x[:tm] + x[:hz]*w + x[:tm] + x[:hz]*w + x[:tr] + Draw.newline
    print_rows(0..2)
    print hr
    print_rows(3..5)
    print hr
    print_rows(6..8)
    print x[:bl] + x[:hz]*w + x[:bm] + x[:hz]*w + x[:bm] + x[:hz]*w + x[:br] + Draw.newline
  end
end

def sudoku(puzzle)
  SudokuSolver.new(puzzle).solve
end

puzzle = [
  [5,3,0,0,7,0,0,0,0],
  [6,0,0,1,9,5,0,0,0],
  [0,9,8,0,0,0,0,6,0],
  [8,0,0,0,6,0,0,0,3],
  [4,0,0,8,0,3,0,0,1],
  [7,0,0,0,2,0,0,0,6],
  [0,6,0,0,0,0,2,8,0],
  [0,0,0,4,1,9,0,0,5],
  [0,0,0,0,8,0,0,7,9],
]

 solution = [
  [5,3,4,6,7,8,9,1,2],
  [6,7,2,1,9,5,3,4,8],
  [1,9,8,3,4,2,5,6,7],
  [8,5,9,7,6,1,4,2,3],
  [4,2,6,8,5,3,7,9,1],
  [7,1,3,9,2,4,8,5,6],
  [9,6,1,5,3,7,2,8,4],
  [2,8,7,4,1,9,6,3,5],
  [3,4,5,2,8,6,1,7,9],
]

hard_puzzle = [
  [0,0,6,1,0,0,0,0,8],
  [0,8,0,0,9,0,0,3,0],
  [2,0,0,0,0,5,4,0,0],
  [4,0,0,0,0,1,8,0,0],
  [0,3,0,0,7,0,0,4,0],
  [0,0,7,9,0,0,0,0,3],
  [0,0,8,4,0,0,0,0,6],
  [0,2,0,0,5,0,0,8,0],
  [1,0,0,0,0,2,5,0,0],
]

hard_solution = [
  [3,4,6,1,2,7,9,5,8],
  [7,8,5,6,9,4,1,3,2],
  [2,1,9,3,8,5,4,6,7],
  [4,6,2,5,3,1,8,7,9],
  [9,3,1,2,7,8,6,4,5],
  [8,5,7,9,4,6,2,1,3],
  [5,9,8,4,1,3,7,2,6],
  [6,2,4,7,5,9,3,8,1],
  [1,7,3,8,6,2,5,9,4],
]

Draw.cls
describe "Solution" do
  it "should test for something" do
    Test.assert_equals(sudoku(puzzle), solution)
    Test.assert_equals(sudoku(hard_puzzle), hard_solution)
  end
end
