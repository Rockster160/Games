class RubyParse
  class << self
    def parse(str)
      return str unless str.is_a?(String)

      token = uniq_rand(str)

      json = hashrocket_parse(str)

      JSON.parse(json, symbolize_names: true)
    end

    def uniq_rand(str)
      loop do
        t = ("a".."z").to_a.sample(5).join("")
        break t unless str.include? t
      end
    end

    def hashrocket_parse(hr_json)
      storage = {}

      hr_json.gsub!(/\".*?\"/m) do |match|
        replace = "#{token}(#{storage.keys.count})"
        storage[replace] = match
        replace
      end

      hr_json.gsub!("=>", ": ")
      hr_json.gsub!("nil", "null")

      storage.each do |k, v|
        hr_json.gsub!(k, v)
      end

      hr_json
    end
  end
end
