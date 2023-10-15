require "pry-rails"
# •█▒

## Style - Additional arg
# 1 bold
# 4 underline
# 7 invert

## Color - Suffix
# #0 Black
# #1 Red
# #2 Green
# #3 Yellow
# #4 Blue
# #5 Magenta
# #6 Cyan
# #7 White

## Style - Prefix
# 3# - Normal
# 9# - Light
# Backgrounds
# 4# - Normal
# 10# - Light

# ESC[38;2;{r};{g};{b}m	Set foreground color as RGB.
# ESC[48;2;{r};{g};{b}m	Set background color as RGB.
# ESC[38;5;{ID}m	Set foreground color.
# ESC[48;5;{ID}m	Set background color.


def colorprint(str, *com)
  print "\e[#{com.join(';')}m#{str}\e[0m"
end

def all8bit
  [3, 9].each { |pre| (0..7).each { |suf| colorprint("▒", (pre.to_s + suf.to_s).to_i) }; puts "" }
  [4, 10].each { |pre| (0..7).each { |suf| colorprint(" ", (pre.to_s + suf.to_s).to_i) }; puts "" }
end

def printall
  256.times do |i|
    print "\e[48;5;#{i}m\e[38;5;15m #{"%03d" % i} "
  end
end

def showall
  256.times do |i|
    # Print color code in a background and foregroud color
    print "\e[48;5;#{i}m\e[38;5;15m #{"%03d" % i} "
    print "\e[33;5;0m\e[38;5;#{i}m #{"%03d" % i} "

    # Print newline to separate the color blocks
    print "\033[0m\n" if (i + 1) <= 16 ? ((i + 1) % 8 == 0)  : (((i + 1) - 16) % 6 == 0)
    print "\033[0m\n" if (i + 1) <= 16 ? ((i + 1) % 16 == 0) : (((i + 1) - 16) % 36 == 0)
  end
end

def rgb_to_hex(rgb)
  r, g, b = rgb.map { |val| new_val = [val.to_i.round, 0, 255].sort[1].to_s(16); new_val.length == 1 ? "0#{new_val}" : new_val }
  "##{r}#{g}#{b}".upcase
end

def hex_to_rgb(hex)
  hex_without_hash = hex.gsub("#", '')
  if hex_without_hash.length == 6
    return hex_without_hash.scan(/.{2}/).map { |rgb| rgb.to_i(16) }
  elsif hex_without_hash.length == 3
    return hex_without_hash.split('').map { |rgb| "#{rgb}#{rgb}".to_i(16) }
  else
    return nil
  end
end

def spit(i)
  print "\e[48;5;#{i}m\e[38;5;15m#{"%03d" % i}" # BG
  print "\e[33;5;0m\e[38;5;#{i}m███" # FFG
  print "\e[33;5;0m\e[38;5;#{i}m#{"%03d" % i} [\\e[38;5;#{i}m]"
  # The final 24 colors (232-255) are grayscale starting from a shade slighly lighter than black, ranging up to shade slightly darker than white.
end

def scale(value, f1, f2, t1, t2)
  tr = t2 - t1
  fr = f2 - f1

  (value - f1) * tr / fr.to_f + t1
end

def show(color)
  color = color.first if color.is_a?(Array) && color.length == 1
  r, g, b = color.is_a?(String) ? hex_to_rgb(color) : color.map(&:to_i)

  ri, gi, bi = scale(r, 0, 255, 0, 5).round
  gi, bi = [g,b].map { |c| scale(c, 0, 255, 0, 5).floor }
  rn = (ri * 36) + 16 # start val (which block)
  gn = gi * 6 # row offset
  bn = bi # col offset

  spit(rn + gn + bn)
end

# show("#EF1CB1")
# show([239, 28, 177]) # rgb(155, 28, 177)

show(ARGV) if ARGV.length > 0

# all8bit # Basic colors
# printall # inline
showall # formatted nicely
