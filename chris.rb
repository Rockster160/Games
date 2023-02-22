# Width and Height of map
@grid_x = 5
@grid_y = 8

@user_x = 1
@user_y = 1

@wall_x = 3
@wall_y = 3
# Function to draw map and place user
def clear
  system("cls") || system("clear")
end
def drawing
  draw(@grid_x, @grid_y + 1)
end
# Displays user coordinates
def coordinates
  puts "User x: #{@user_x + 1}, User y: #{@user_y + 1}"
end

def draw(w, h)
  clear
  coordinates
  @level = h.times.map do

    @wall = "O"
    @player = "X"
    @space = ". "
    @level_array = Array.new(w, @space).join("")
  end
  # wall positioning
  @level[(@wall_y - 1)][(@wall_x - 1 ) * 2] = @wall
  # user positioning
  @level[@user_y][@user_x * 2] = @player
  @level.pop
  puts @level

  # Gets user's live key presses
  def get_live_key
    state = `stty -g`
    `stty raw -echo -icanon isig`

    STDIN.getc.chr
  ensure
    `stty #{state}`
  end

  user_input = get_live_key

  # Makes "user" move when a corresponding key is pressed
  if user_input == "w"
    @temp_y = (@user_y - 1) % @grid_y
    @user_y = @temp_y if @level[@user_x][@temp_y] == @space
    clear
    drawing
  end

  if user_input == "a"
    @temp_x = (@user_x - 1) % @grid_x
    @user_x = @temp_x if @level[@user_y][@temp_x] == @space
    clear
    drawing
  end

  if user_input == "s"
    @temp_y = (@user_y + 1) % @grid_y
    @user_y = @temp_y if @level[@user_x][@temp_y] == @space
    clear
    drawing
  end

  if user_input == "d"
    @temp_x = (@user_x + 1) % @grid_x
    @user_x = @temp_x = if @level[@user_y][@temp_x] == @space
      clear
      drawing
    end

    if user_input != w or a or s or d
      puts "Please use wasd keys to move player"
      drawing
    end
  end
  drawing
