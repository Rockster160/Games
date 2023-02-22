require "pry-rails"
# •█▒

color_suffix = {
  black:   0,
  red:     1,
  green:   2,
  yellow:  3,
  blue:    4,
  magenta: 5,
  cyan:    6,
  white:   7,
}
style_prefix = {
  normal:    3,
  light:     9,
  normal_bg: 4,
  light_bg:  10,
}

reset_code = "\e[0m"

# example:
puts "\e[#{style_prefix[:normal]}#{color_suffix[:red]}mHello, World!#{reset_code}"
puts "\e[31mHello, World!\e[0m"
puts "\e[3#{color_suffix[:yellow]}mHello, World!\e[0m"
puts "\e[#{style_prefix[:normal_bg]}#{color_suffix[:magenta]}mHello, World!\e[0m"

# Note- if you DON'T use the reset code, the color will continue to apply to your terminal. It's like leaving an open HTML tag- it applies to everything beyond it until you close it.
# The reset code resets EVERYTHING and there is no way to close only a single style, so you have to reapply any styles you want to persist passed it.

class String
  [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white].each_with_index do |color, code|
    define_method(color) do
      "\e[3#{code}m#{self}\e[0m"
    end
  end
end

puts "Hello, World!".magenta



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

def spit(i)
  print "\e[48;5;#{i}m\e[38;5;15m#{"%03d" % i}" # BG
  print "\e[33;5;0m\e[38;5;#{i}m███" # FFG
  print "\e[33;5;0m\e[38;5;#{i}m#{"%03d" % i} [\\e[38;5;#{i}m]"
  # The final 24 colors (232-255) are grayscale starting from a shade slighly lighter than black, ranging up to shade slightly darker than white.
end

# all8bit
# printall
# showall
