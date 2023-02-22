class LightsOut
  attr_accessor :size
​
  def initialize(size)
    self.size = size
  end
​
  def play
    while !game_finished?
      print_board
      process_next_round
    end
​
    print_board
    puts "Congratulations! You won!"
  end
​
  private
​
  def board # randomized is not guaranteed to be solvable
    @board ||= ::Array.new(size){ ::Array.new(size){ rand(2) == 1 ? "o" : "x" } }
  end
​
  def print_board
    numbers = [*1..size]
    dashes = ::Array.new(size * 2){ "-" }
    alphabet = [*"a".."z"]
​
    puts ""
    puts "    " + numbers.join(" ")
    puts "   " + dashes.join("")
    board.each_with_index do |row, index|
      puts( "#{alphabet[index]} | " + row.join(" "))
    end
    puts ""
  end
​
  def game_finished?
    board.each do |row|
      return false unless row.first == "x" && row.uniq.count == 1
    end
​
    true
  end
​
  def process_next_round
    puts "\nEnter Coordinates to toggle lights (row/column - example: 'a4'):"
    coordinates = gets.chomp
​
    # dev-cheat: if input is "solve", then it turns off all the lights
    if coordinates == "solve"
      board.each do |row|
        row.fill("x")
      end
    else
      row_index = [*"a".."z"].index(coordinates.chars.first.downcase)
      column_index = coordinates.chars.last.to_i - 1
​
      toggle_lights(row_index, column_index)
    end
  end
​
  def toggle_lights(row, column)
    # always toggle self
    toggle_light(row, column)
​
    # if row is top, dont toggle above
    toggle_light(row - 1, column) unless row == 0
​
    # if row is bottom, dont toggle below
    toggle_light(row + 1, column) unless row == (size - 1)
​
    # if column is left, dont toggle left
    toggle_light(row, column - 1) unless column == 0
​
    # if column is right, dont toggle right
    toggle_light(row, column + 1) unless column == (size - 1)
  end
​
  def toggle_light(row, column)
    light = board[row][column]
​
    if light == "o"
      board[row][column] = "x"
    else
      board[row][column] = "o"
    end
  end
end
​
##### Script Start #####
​
puts "Hello! Would you like to play a game of lights out? (y/n)"
​
play_game = gets.chomp
​
if play_game == "y"
  puts "Ok then, let's begin!"
  puts "How large would you like the board to be? (enter a number 1-9)"
  size = gets.chomp.to_i
  ::LightsOut.new(size).play
else
  puts "ok then, see you next time!"
end
