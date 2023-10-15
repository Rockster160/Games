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
