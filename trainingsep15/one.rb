class Color
  def initialize(*color_obj)
    if color_obj.flatten.length == 3
      @rgb = color_obj.flatten.map(&:to_i)
    else
      @hex = color_obj.first.to_s
    end
  end

  def hex
    @hex ||= "#" + @rgb.map { |c| c.to_s(16).rjust(2, "0") }.join.upcase
  end

  def r = @r ||= rgb[0]
  def g = @g ||= rgb[1]
  def b = @b ||= rgb[2]
  def rgb
    @rgb ||= begin
      parts = @hex.sub("#", "").scan(/.{#{@hex.length/3}}/)
      parts = parts.map { |part| part.length == 1 ? part*2 : part }
      parts.map { |part| part.to_i(16) }
    end
  end

  def contrast_code
    black = 0
    white = 37
    # The below magic numbers are measures of relative brightness of each component of a color
    r_lum, g_lum, b_lum = r * 299, g * 587, b * 114
    luminescence = ((r_lum + g_lum + b_lum) / 1000)

    luminescence > 150 ? black : white
  end

  def to_s
    "\e[48;2;#{r};#{g};#{b}m\e[3#{contrast_code}m#{hex}\e[0m"
  end
end

class ColorMapper
  def initialize(mapping)
    @mapping = mapping.to_a.sort_by { |k,v| v }
  end

  def scale(num)
    min, max = @mapping.each_cons(2).find { |a, b| (a[1]..b[1]).cover?(num) }
    return Color.new(@mapping.first[0]) if min.nil? && @mapping.first[1] >= num
    return Color.new(@mapping.last[0]) if min.nil? && @mapping.last[1] <= num

    min_color, min_val = Color.new(min[0]), min[1]
    max_color, max_val = Color.new(max[0]), max[1]

    new_rgb = 3.times.map { |t| scaler(num, min_val, max_val, min_color.rgb[t], max_color.rgb[t]) }
    Color.new(*new_rgb)
  rescue StandardError => e
    binding.pry
  end

  def scaler(val, from_start, from_end, to_start, to_end)
    to_diff = to_end - to_start
    from_diff = from_end - from_start

    (((val - from_start) * to_diff) / from_diff.to_f) + to_start
  end
end


# Kelly
puts "Enter location:"
location = gets.chomp
# location = "Provo"
# ===============================================
# Rocco
require 'net/http'
require 'json'


API_KEY=""
(
  require "httparty"
  json = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{API_KEY}")
)

# (
#   url = URI.parse("https://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{API_KEY}")
#   http = Net::HTTP.new(url.host, url.port)
#   http.use_ssl = true # Use SSL for secure communication if needed
#   request = Net::HTTP::Get.new(url)
#   response = http.request(request)
#   json = JSON.parse(response.body, symbolize_names: true)
# )

# {"coord"=>{"lon"=>-111.8606, "lat"=>40.572},
#  "weather"=>[{"id"=>800, "main"=>"Clear", "description"=>"clear sky", "icon"=>"01d"}],
#  "base"=>"stations",
#  "main"=>{"temp"=>292.42, "feels_like"=>291.63, "temp_min"=>290.21, "temp_max"=>294.75, "pressure"=>1024, "humidity"=>47},
#  "visibility"=>10000,
#  "wind"=>{"speed"=>1.54, "deg"=>100},
#  "clouds"=>{"all"=>0},
#  "dt"=>1694793368,
#  "sys"=>{"type"=>2, "id"=>2013016, "country"=>"US", "sunrise"=>1694783283, "sunset"=>1694828256},
#  "timezone"=>-21600,
#  "id"=>5781061,
#  "name"=>"Sandy City",
#  "cod"=>200}
# =============================================
# Hunter

weather_description = json[:weather][0][:description]
temperature = json[:main][:temp]
feels_like = json[:main][:feels_like]
humidity = json[:main][:humidity]
wind_speed = json[:wind][:speed]
location_name = json[:name]

temperature_celsius = temperature - 273.15
temperature_farenheit = (temperature - 273.15) * 9/5 + 32

# puts "Weather Information for #{location_name}: "
# puts
# puts "Weather Description: #{weather_description.capitalize}"
# puts "Temperature: #{'%.2f' % temperature_celsius}°C (#{'%.2f' % temperature_farenheit}°F)"
# puts "Feels like: #{'%.2f' % (feels_like - 273.15)}°C (#{'%.2f' % ((feels_like - 273.15) * 9/5 + 32)}°F)"
# puts "Humidity: #{humidity}%"
# puts "Wind Speed: #{wind_speed} m/s"


# =========================================
# Rocco Refactor

def k_to_c(k) = k - 273.15
def k_to_f(k) = k_to_c(k) * 9/5 + 32
def color_temp(deg_f)
  temp_mapping = ColorMapper.new(
    "#5B6EE1": 5,  # Icy blue   -- Very cold!🧊
    "#639BFF": 32, # Light Blue -- Freezing  🥶
    "#99E550": 64, # Green      -- Perfect!  😌
    "#FBF236": 78, # Yellow     -- Warm      🌞
    "#AC3232": 96, # Red        -- Hot       🥵
  )
  "\e[38;2;#{temp_mapping.scale(deg_f).rgb.join(";")}m"
end
def show_temp(k)
  color_temp(k_to_f(k))
end

puts "Weather Information for #{location_name}: "
puts
puts "Weather Description: #{weather_description.capitalize}"
puts "Temperature: #{show_temp(temperature)}#{temperature_celsius.round(2)}°C (#{temperature_farenheit.round(2)}°F)\e[0m"
puts "Feels like: #{show_temp(feels_like)}#{k_to_c(feels_like).round(2)}°C (#{k_to_f(feels_like).round(2)}°F)\e[0m"
puts "Humidity: #{humidity}%"
puts "Wind Speed: #{wind_speed} m/s"




# require "httparty"
# API_KEY="19bf129f65280df755e58d01feb92520"
# puts "Enter location:"
# location = gets.chomp
# json = JSON.parse(HTTParty.get("https://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{API_KEY}").body, symbolize_names: true)
# puts "The weather is: #{json[:weather][0][:description]} #{((json[:main][:temp] - 273.15) * 9/5 + 32).round(2)}º"
