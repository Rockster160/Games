require "json"
require "neatjson"

def remove_colors(str)
  str.gsub(/\e\[\d+m/, "")
end

class String
  def colorize(color, on: nil)
    background_color = on
    # There may be a better way to do this, but to avoid filling the String
    #   class with support methods, we use an internal proc here.
    code_from_color_name = proc do |color_name|
      case color_name.to_s.downcase.gsub("light_", "").to_sym
      when :black   then 0
      when :red     then 1
      when :green   then 2
      when :yellow  then 3
      when :blue    then 4
      when :magenta then 5
      when :cyan    then 6
      when :white   then 7
      end
    end

    text_lightness_code = color.to_s.include?("light") ? 9 : 3
    text_color_code = "#{text_lightness_code}#{code_from_color_name.call(color)}"

    background_lightness_code = background_color.to_s.include?("light") ? 10 : 4
    background_color_code = "#{background_lightness_code}#{code_from_color_name.call(background_color)}"

    color_codes = []
    color_codes << text_color_code unless color.nil?
    color_codes << background_color_code unless background_color.nil?

    "\e[#{color_codes.join(';')}m#{remove_colors(self)}\e[0m"
  end
end

def prettify(json)
  json = json.gsub(/,(\S)/, ', \1')
  json = json.gsub(/(\d+)/) { Regexp.last_match(1)&.colorize(:light_magenta) }
  json = json.gsub(/\"(.*?)\"(:?)/) do |found|
    if Regexp.last_match(2) == ":"
      "#{Regexp.last_match(1)}: "&.colorize(:light_yellow)
    else
      Regexp.last_match(1)&.colorize(:green)
    end
  end
  json = json.gsub(/\'(.*?)\'(:?)/) do |found|
    if Regexp.last_match(2) == ":"
      "#{Regexp.last_match(1)}: "&.colorize(:light_yellow)
    else
      Regexp.last_match(1)&.colorize(:light_green)
    end
  end
  json = json.gsub(/(null)/) { Regexp.last_match(1)&.colorize(:light_black) }
  json = json.gsub(/(true|false)/) { Regexp.last_match(1)&.colorize(:light_blue) }
end

input = ARGV[0]
raw = JSON.parse(input) rescue input
json = JSON.neat_generate(raw)
puts prettify(json)
