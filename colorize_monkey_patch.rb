def colorize_text(str, text_color, background_color=nil)
  colors = {
    black:   0,
    red:     1,
    green:   2,
    yellow:  3,
    blue:    4,
    magenta: 5,
    cyan:    6,
    white:   7,
  }
  shades = {
    text_normal: 3,
    text_light:  9,
    bg_normal:   4,
    bg_light:    10,
  }
  shade = ->(type, col) { shades[[type, col].join("_").to_sym] || 3 }

  text, text_shade = text_color.to_s.split("_").reverse
  txt_code = "#{shade.call(:text, text_shade || :normal)}#{colors[text&.to_sym] || 7}"

  bg, bg_shade = background_color.to_s.split("_").reverse
  bg_code = "#{shade.call(:bg, bg_shade || :normal)}#{colors[bg&.to_sym] || 7}"

  color_code = []
  color_code.push(txt_code) if text_color
  color_code.push(bg_code) if background_color

  "\e[#{color_code.compact.join(';')}m#{str}\e[0m"
end

class String
  def colorize(text_color, background_color=nil)
    colorize_text(self, text_color, background_color)
  end
end

#
# colors = {
#   black:   0,
#   red:     1,
#   green:   2,
#   yellow:  3,
#   blue:    4,
#   magenta: 5,
#   cyan:    6,
#   white:   7,
# }
#
# puts "0".colorize(0)
# puts "nil, 0".colorize(nil, 0)
# colors.each do |color, c|
#   [nil, :light_].each do |typ|
#     puts "#{typ}#{color}".colorize("#{typ}#{color}".to_sym)
#     puts "BG #{typ}#{color}".colorize(nil, "#{typ}#{color}".to_sym)
#   end
# end
