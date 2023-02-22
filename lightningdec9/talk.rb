# === Terminal Tips! ===

# Getting the size of the window
# ANSI Escape Codes
# Colors!
# Cursor / Printing over
# Using Ruby to get live keys


# ================= # Getting the size of the window
ENV["LINES"] # echo $LINES
ENV["COLUMNS"] # echo $COLUMNS


# ================= # ANSI Escape Codes
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797


# ================= # Colors!


# ================= # Cursor / Printing over
def clear_rest_line
  "\033[K"
end

def moveto(x, y)
  print "\033[#{y};#{x}f"
end

def newline
  print "\n\r"
end


# ================= # Using Ruby to get live keys
# https://man7.org/linux/man-pages/man1/stty.1.html
# `man stty`
require "io/console" # Built in helpers for char getting
require "io/wait"
@fps = 1/60.to_f # This is NOT actual FPS
@player = [0,0]
@turkey = [0,0]

def gameloop
  system "clear" # Clear the screen
  prestate = `stty -g` # Get initial state
  # Allow special characters, don't show input from keyboard, still allow interrupt (ctrl+c)
  `stty raw -echo -icanon isig`
  print "\e[?25l" # Hide cursor

  prompt = inputthread
  loop { tick }
ensure
  prompt = 0
  print "\e[?25h" # Show cursor
  `stty #{prestate}` # Reset initial state
end

def tick
  sleep @fps # Sleep so spam isn't crazy
  moveto(0, 0) # Reset cursor to redraw board

  green = "\e[32m"
  print "#{green}#{"."*5}#{clear_rest_line}\r\n"*5 # Draw board
  move if @last_key

  move_turkey if rand(10) == 0
  turkey_color = "\e[38;2;155;27;90m" # rgb(155, 27, 90)
  moveto(*@turkey)
  print "#{turkey_color}>#{green}"

  player_color = "\e[38;2;1;80;255m" # rgb(1, 80, 255)
  moveto(*@player)
  print "#{player_color}@#{green}"

  moveto(0, 6) # Move cursor to end for outputting any debug info
end

def move
  case @last_key
  when :w, :up then @player[1] -= 1
  when :a, :left then @player[0] -= 1
  when :s, :down then @player[1] += 1
  when :d, :right then @player[0] += 1
  end

  moveto(0, 6) # Move cursor to end so we don't print on top of board
  print "Pressed: #{@last_key}#{clear_rest_line}"

  @last_key = nil
end

def move_turkey
  @turkey[0] =  (@turkey[0] + (-1..1).to_a.sample) % 5
  @turkey[1] =  (@turkey[1] + (-1..1).to_a.sample) % 5
end

def inputthread
  Thread.new do
    loop do
      char = STDIN.getc.chr
      if char == "\e"
        char << STDIN.read_nonblock(3) rescue nil
        char << STDIN.read_nonblock(2) rescue nil
      end
      key = input(char) if char
      @last_key = key if key
      STDIN.getc while STDIN.ready?
    end
  end
end

def input(read)
  case read
  when " " then :space
  when "\t" then :tab
  when "\r" then :return
  when "\n" then :linefeed
  when "\e" then :escape
  when "\e[A" then :up
  when "\e[B" then :down
  when "\e[C" then :right
  when "\e[D" then :left
  when "\e[1;2A" then :shift_up
  when "\e[1;2B" then :shift_down
  when "\e[1;2C" then :shift_right
  when "\e[1;2D" then :shift_left
  when "\177", "\004", "\e[3~" then :backspace
  when "\u0003" then :control_c
  when /^.$/ then read.to_sym
  else
    # puts "SOMETHING ELSE: [#{input.inspect}]"
  end
end

gameloop

# ruby /Users/rocco/code/games/turkey_chaser.rb
