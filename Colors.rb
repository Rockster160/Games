require "pry-rails"
# •█▒
# 𓀠

## Style - Additional arg
# 1 bold
# 4 underline
# 3 italic
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

# rgb(1,96,255)

# (0..7).each do |code|
#   # Colors are done using "{escape}{style}{color}m" The "m" ends the escape code for the color args.
#   esc = "\e[" # <-- This is an escape code, normally followed by a handful of special chars
#   normal_style = "3" # 3 is "normal" - can also use 9 for light, 4 for normal background, and 10 for light background
#   light_style = "9" # 3 is "normal" - can also use 9 for light, 4 for normal background, and 10 for light background
#   normal_bg = "4" # 3 is "normal" - can also use 9 for light, 4 for normal background, and 10 for light background
#   light_bg = "10" # 3 is "normal" - can also use 9 for light, 4 for normal background, and 10 for light background
#   end_escape_sequence = "m"
#   clear_code = "\e[0m" # Set the color back to "0" meaning reset all values
#   print "#{esc}#{normal_style}#{code}#{end_escape_sequence}Yay color!#{clear_code}"
#   print "#{esc}#{light_style}#{code}#{end_escape_sequence}-- Light --#{clear_code}"
#   print "#{esc}#{normal_bg}#{code}#{end_escape_sequence} Yay background! #{clear_code}"
#   print "#{esc}#{light_bg}#{code}#{end_escape_sequence} Light background! #{clear_code}"
#   print "\n"
# end

# {
#   black:         30,
#   light_black:   90,
#   red:           31,
#   light_red:     91,
#   green:         32,
#   light_green:   92,
#   yellow:        33,
#   light_yellow:  93,
#   blue:          34,
#   light_blue:    94,
#   magenta:       35,
#   light_magenta: 95,
#   cyan:          36,
#   light_cyan:    96,
#   white:         37,
#   light_white:   97,
# }.map { |color, val|
#   color = color.to_s.gsub("light_", "l.")
#   [
#     "\e[#{val+10}m\e[37m#{color.center(10)}", # light text, color bg
#     "\e[#{val+10}m\e[30m#{color.center(10)}", # dark text, color bg
#     "\e[#{val}m\e[47m#{color.center(10)}", # white bg, color text
#     "\e[#{val}m\e[40m#{color.center(10)}", # dark bg, color text
#   ].join("")
# }.join("\n").then { |s| PrettyLogger.info("\n" + s) }

def colorprint(str, *com)
  print "\e[#{com.join(';')}m#{str}\e[0m"
end

def all8bit
  [3, 9].each { |pre| (0..7).each { |suf| print "\e[#{pre}#{suf}m#{pre}#{suf}\e[0m " }; puts "" }
  [4, 10].each { |pre| (0..7).each { |suf| print "\e[#{pre}#{suf}m \e[0m" }; puts "" }
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
