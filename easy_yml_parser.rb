require "/Users/rocco/code/games/tokenizer.rb"
# SurveyName
#   Question1
#     Answer1
#       result: 1
#     Answer2
#       result: 2
#   Question2
#     Answer1
#       result: 1
#     Answer2
#       result: 2

module EasyYmlParser
  module_function

  def parse(raw_data, indent=0)
    return if (raw_data.nil? || raw_data.empty?)

    # Remove comments
    raw_data.gsub!(/(^|\s)#[\w ].*$/, "\1")
    # Remove invisibles
    raw_data.gsub!(/\u0001/, "")

    # Split out raw strings
    tz = Tokenizer.new(raw_data)
    tz.tokenize!(raw_data, /\".*?\"/m)

    # If single line....
    if raw_data.gsub(/^\s*|\s*$/, "").count("\n") == 0
      # Attempt to split by colon, otherwise just return the line as a value
      return parse_single(raw_data) if parse_single(raw_data).is_a?(Symbol)
      return raw_data.gsub(/^\s*|\s*$/, "").split(/: */, 2).then { |k,v|
        k, v = [k, v].map { |str| tz.untokenize!(str)&.gsub(/^"|"$/, "") }
        (v && !v.empty?) ? { k => parse_single(v) } : parse_single(k)
      }
    end

    regex = /(?:^|\n)#{"  "*indent}(\S)/
    return unless raw_data.match?(regex)

    # Have to do some craziness to stop `split` from dropping characters and adding empty objects...
    raw_data.split(regex)[1..].each_slice(2).each_with_object({}) { |(letter, subchunk), obj|
      chunk = "#{letter}#{subchunk}"
      # Key should not have indents (split removed the whitespace), but data will retain indents

      key, data = chunk.split("\n", 2).map { |str| tz.untokenize!(str) }
      key, data = key.split(/: */, 2) if (data.nil? || data.empty?) && key.include?(":")

      obj[key.gsub(/:$/, "")] = EasyYmlParser.parse(data, indent+1) || {}
    }.then { |hash| hash.values.all?({}) ? hash.keys : hash }
  end

  def parse_single(val)
    case val
    when /^\d+$/ then val.to_i # Integer
    when /^\d*\.\d*$/ then val.to_f # Float
    when /^(nil|null)$/ then nil
    when /^(true|t)$/ then true
    when /^(false|f)$/ then false
    when /^\:\w+$/ then val[1..].to_sym
    # Date?
    when /(\{|\[)/
      begin
        JSON.parse(val)
      rescue JSON::ParserError
        val
      end
    else val # String
    end
  end
end

if ENV["DEBUG"]
  # DEBUG=true ruby /Users/rocco/code/games/easy_yml_parser.rb
  require "/Users/rocco/code/games/tools_json_parser.rb";
  json = EasyYmlParser.parse(File.read("/Users/rocco/code/games/rbchance/topics.yml"))
  puts ToolsJsonParser.pretty(json.to_json)
end
