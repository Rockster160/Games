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
      JSON.parse(ojson)
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

      JSON.parse(raw_json)
    # rescue
    #   require "pry-rails"; binding.pry
    end

    def color(color_sym, txt="")
      color_code = {
        orange:        "38;5;214",
        black:         "30",
        light_black:   "90",
        red:           "31",
        light_red:     "91",
        green:         "32",
        light_green:   "92",
        yellow:        "33",
        light_yellow:  "93",
        blue:          "34",
        light_blue:    "94",
        magenta:       "35",
        light_magenta: "95",
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

    def pretty_object(obj, dent=1)
      case obj
      when Hash
        return color(:white, "{}") if obj.none?
        longest_key = obj.keys.sort_by(&:length).last&.length.to_i + "\"\": ".length
        "#{color(:white)}{\n" + obj.map { |k, v|
          "#{indent(dent)}#{color(:orange, "\"#{k}\": ".ljust(longest_key))}" + pretty_object(v, dent+1)
        }.join("#{color(:white)},\n") + "\n#{indent(dent-1)}#{color(:white)}}"
      when Array
        return color(:white, "[]") if obj.none?
        "#{color(:white)}[\n" + obj.map { |v|
          indent(dent) + pretty_object(v, dent+1)
        }.join("#{color(:white)},\n") + "\n#{indent(dent-1)}#{color(:white)}]"
      when String
        color(:light_green, "\"#{obj}\"")
      when Integer, Float
        color(:magenta, obj)
      when NilClass
        color(:light_black, :null)
      when TrueClass, FalseClass
        color(:light_cyan, obj)
      else
        color(:red, "DEAD[#{obj}]")
      end
    end

    def pretty(json)
      pretty_object(parse(json))
    end
  end
end

# if ARGV&.length.to_i > 0
#   puts ToolsJsonParser.pretty(ARGV.join(" "))
# end
