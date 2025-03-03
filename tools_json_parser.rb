require "json"
require "pry-rails"

class ToolsJsonParser
  class << self
    def timestamp_regex
      # Fri, 21 Oct 2022 10:50:00.000000000 MDT -06:00
      @timestamp_regex ||= begin
        # wdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        /\w{3}, \d{1,2} \w{3} \d{4} \d{1,2}:\d{2}:\d{2}(?:\.\d+)? \w{3} -?\d{2}:\d{2}/
      end
    end

    def gen_token(text)
      loop do
        token = ("a".."z").to_a.sample(5).join("")
        break token unless text.include?(token)
      end
    end

    def parse(ojson)
      return ojson if ojson.is_a?(Hash) || ojson.is_a?(Array)
      # str_json = ojson.respond_to?(:to_json) ? ojson.to_json : ojson.to_s
      JSON.parse(ojson.strip.gsub(/\n/, "").gsub(/ {2,}/, " "))
    rescue JSON::ParserError
      raw_json = ojson.to_s.dup
      # token = gen_token(raw_json)
      # # ========== Convert Hashrocket to regular JSON ========
      # # -- Replace dates
      # # NOTE: The below will replace timestamps already in strings with a string wrapped timestamp.
      # # This CAN break real JSON string match since the quotes won't be escaped.
      raw_json.gsub!(timestamp_regex, '"\1"')
      # -- Replace nil->null
      raw_json.gsub!(/\bnil\b/, "null")

      # Handle colons inside string values
      raw_json.gsub!(/("[^"]*")/) { |found| found.gsub(":", "\\u003A") }
      raw_json.gsub!(/('[^']*')/) { |found| found.gsub(":", "\\u003A") }

      # Replace hashrockets with JSON format
      raw_json.gsub!(/:(\w+)\s*=>/, '"\1": ') # :key =>
      raw_json.gsub!(/"([^"]*)"\s*=>/, '"\1": ') # "key" =>
      raw_json.gsub!(/'([^']*)'\s*=>/, '"\1": ') # 'key' =>

      # Convert symbolized keys to strings
      raw_json.gsub!(/\b(\w+):/, '"\1": ')

      # Convert symbolized values to strings
      raw_json.gsub!(/[^\"]:([a-z]\w*)\b/i, '"\1"')
      # Clear whitespace at beginning and end
      raw_json.gsub!(/^\s*|\s*$/, "")
      # ==================================================== Error?
      # If there is a problem, it's probably here, adding escaped newlines in real json.
      # Ideally this is only done inside of strings.
      # Replace newlines
      raw_json.gsub!("\n", "\\n")
      # raw_json.gsub!(token, "\"")

      raw_json.empty? ? "\e[90mnull\e[0m" : JSON.parse(raw_json)
    end

    def color(color_sym, txt="")
      color_code = {
        orange:        "38;5;214", # 256 code
        black:         "30",
        light_black:   "90",
        red:           "31",
        light_red:     "91",
        green:         "32",
        light_green:   "92",
        pine_green:    "38;2;50;150;50",
        yellow:        "33",
        light_yellow:  "93",
        blue:          "34",
        light_blue:    "94",
        aqua:          "38;2;86;182;194", # rgb code
        magenta:       "35",
        light_magenta: "95",
        # purple:        "38;2;200;0;200", # rgb code
        cyan:          "36",
        light_cyan:    "96",
        white:         "37",
        light_white:   "97",
      }[color_sym]
      "\e[#{color_code}m#{txt}"
    end

    def indent(n=0)
      "  "*n.clamp(0..)
    end

    def pretty_object(obj, indent_level=1, multiline: true)
      nl = multiline ? "\n" : ""
      dent = multiline ? indent(indent_level) : " "
      outdent = multiline ? indent(indent_level-1) : " "
      case obj
      when Hash
        return color(:white, "{}") if obj.none?
        longest_key = obj.keys.sort_by(&:length).last&.length.to_i + ": ".length
        longest_key = 0 if !multiline
        # longest_key = obj.keys.sort_by(&:length).last&.length.to_i + "\"\": ".length
        "#{color(:white)}{#{nl}" + obj.map { |k, v|
          "#{dent}#{color(:orange, "#{k}: ".ljust(longest_key))}" + pretty_object(v, indent_level+1)
          # "#{dent}#{color(:orange, "\"#{k}\": ".ljust(longest_key))}" + pretty_object(v, indent_level+1)
        }.join("#{color(:white)},#{nl}") + "#{nl}#{outdent}#{color(:white)}}"
      when Array
        return color(:white, "[]") if obj.none?
        "#{color(:white)}[#{nl}" + obj.map { |v|
          dent + pretty_object(v, indent_level+1)
        }.join("#{color(:white)},#{nl}") + "#{nl}#{outdent}#{color(:white)}]"
      when String
        color(:pine_green, obj.to_json)
      when Symbol
        color(:aqua, ":#{obj.to_s.gsub("\"", "\\\"")}")
      when Numeric
        color(:yellow, obj)
      when NilClass
        color(:light_black, :null)
      when TrueClass, FalseClass
        color(:magenta, obj)
      else
        pretty_object(obj.to_s, indent_level)
        # color(:red, "DEAD[#{obj}]")
      end
    end

    def pretty(json, multiline: true)
      pretty_object(parse(json), multiline: multiline)
    end
  end
end

# if ARGV&.length.to_i > 0
#   puts ToolsJsonParser.pretty(ARGV.join(" "))
# end
