require 'colorize'
​
class LightsOut
  LIGHT_ON =  '✅'.center(3)
  LIGHT_OFF = '❌'.center(3)
  CHARS = ('A'..'Z').to_a
  COMPLIMENTS = [
    'Youre one in a million kid!',
    'When I grow up I want to be like you!',
    'Youre more fun than bubble wrap!',
    'In a world full of bagels youre a doughnut!',
    'In high school I bet you were voted most likely to keep being awesome.',
    'You were cool way before hipsters were cool.',
  ].freeze
  INSULTS = [
    'Brains arent everything. In your case theyre nothing.',
    'I can explain it to you but I cant understand it for you.',
    'I have neither the time nor the crayons to explain this to you.',
    'I would agree with you but then we would both be wrong.',
  ].freeze
​
  def initialize(size)
    @size = size.to_i
    @board = Array.new(@size) { |_row| Array.new(@size) { |_col| rand(0..1).zero? } }
    @moves = []
    ARGV.clear
    @start_time = ::Time.now
    play
  end
​
  def play
    begin
      print_board
      input_move
      flip_lights!
    end until solved?
    win!
  rescue ::Interrupt
    puts "\nThanks for playing! Better luck next time!\n".magenta
    `say "#{INSULTS.sample}"`
    exit 0
  end
​
  def print_board
    puts [
      [' '],
      (1..@size).map { |col| CHARS[col-1].center(4) }.join.prepend(' '),
      (1..@size).map { |row|
        row.to_s + (1..@size).map { |col| (@board[row-1][col-1] ? LIGHT_ON : LIGHT_OFF) }.join
      },
      [' '],
    ].flatten
  end
​
  private
​
  def duration
    (@end_time - @start_time).floor
  end
​
  def win!
    @end_time = ::Time.now
    print_board
    @size.times { puts '🎉' * @size }
    `say Congratulations!`
    `say you solved a size #{@size} board in #{@moves.size} moves!`
    `say it took you #{duration} seconds to solve this puzzle!`
    `say #{COMPLIMENTS.sample}`
  end
​
  def solved?
    @board.flatten.uniq.size == 1
  end
​
  def flip_lights!
    neighbors_coordinates(*@moves.last).each do |row, col|
      @board[row][col] = !@board[row][col]
    end
  end
​
  def input_move
    print 'Enter move > '
    input = gets.chomp
    @moves << [row(input), col(input)]
    @moves.last
  rescue StandardError
    puts 'Invalid input! Try again.'.light_red
    puts "Move must contain exactly 1 row and exactly 1 column.\n".blue
    retry
  end
​
  def row(input)
    row_inputs = input.scan(/[1-#{@size}]/)
    raise if row_inputs.size > 1
​
    row_inputs[0].to_i - 1
  end
​
  def col(input)
    col_inputs = input.scan(/[A-Za-z]/)
    raise if col_inputs.size > 1
​
    CHARS.index(col_inputs[0].upcase)
  end
​
  def neighbors_coordinates(row, col)
    ([row-1, row, row+1].product([col-1, col, col+1]) - [row, col]).select { |coords|
      coords.all? { |i| i >= 0 && i < @size } && (
        coords[0] == row ||
        coords[1] == col
      )
    }
  end
end
​
g = LightsOut.new(ARGV[0])
