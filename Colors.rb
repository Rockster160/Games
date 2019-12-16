def color(str, *com)
  print "\e[#{com.join(';')}m#{str}\e[0m"
end
[3, 9].each { |pre| (0..7).each { |suf| color("▒", (pre.to_s + suf.to_s).to_i) };puts"" }
[4, 10].each { |pre| (0..7).each { |suf| color(" ", (pre.to_s + suf.to_s).to_i) };puts"" }

print "\e[31m#{str}\e[0m"

# 1 bold
# 4 underline
# 7 invert
#
# Single digits -
# #0 Black
# #1 Red
# #2 Green
# #3 Yellow
# #4 Blue
# #5 Magenta
# #6 Cyan
# #7 White
#
# Text
# 3# - Normal
# 9# - Light
# Backgrounds
# 4# - Normal
# 10# - Light
