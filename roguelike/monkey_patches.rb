# require './monkey_patches.rb'
class Object
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end

  def toggle(arg1=true, arg2=false)
    self == arg1 ? arg2 : arg1
  end

  def or(nah='N/A')
    self == nil ? nah : self
  end
end

class Module
  def class_accessible(*attribute_names)
    attribute_names.each do |attribute_name|
      define_singleton_method(attribute_name) do
        class_variable_get("@@#{attribute_name}")
      end
      define_singleton_method("#{attribute_name}=") do |val|
        class_variable_set("@@#{attribute_name}", val)
      end
    end
  end
end

class Fixnum
  def plus_minus
    noise = self * 0.1
    self + rand(-noise.ceil..noise.ceil)
  end
end

class Array
  def search_for(str)
    coords = []
    (self.length - 1).times do |y|
      (self[y].length - 1).times do |x|
        if self[y][x] == str
          coords << {x: x, y: y}
        end
      end
    end
    coords
  end
end

class Hash

  def merge_many(*hashes)
    new_hash = self
    hashes.each do |hash|
      new_hash.merge!(hash)
    end
    new_hash
  end

  def filter(*syms)
    new_hash = {}
    syms.flatten.each do |sym|
      new_hash[sym] = self[sym] if self[sym]
    end
    new_hash
  end

end

class String

  def is_color
    if self.include?("\e")
      self[self.index("\e")..self.index("m")]
    else
      "\e[0m"
    end
  end

  def articlize
    if %w( a e i o u ).include?(self.uncolor[0].downcase)
      "an #{self}"
    elsif self.uncolor == "gold"
      "some gold"
    else
      "a #{self}"
    end
  end

  def override_foreground_with(color)
    reinstate_color = self.gsub /\[0m/, "[0m\e[#{sym_to_escape(color, 'text')}m"
    reinstate_color.gsub /\[(3|9)\d/, "[#{sym_to_escape(color, 'text')}"
    "\e[#{sym_to_escape(color, 'back')}m#{reinstate_color}\e[0m"
  end
  def override_background_with(color)
    reinstate_color = self.gsub /\[0m/, "[0m\e[#{sym_to_escape(color, 'back')}m"
    reinstate_color.gsub /(4|10){1,2}\dm/, "#{sym_to_escape(color, 'back')}m"
    "\e[#{sym_to_escape(color, 'back')}m#{reinstate_color}\e[0m"
  end

  def sym_to_escape(color, type)
    swab = case color
    when :black then ["30", "40"]
    when :red then ["31", "41"]
    when :green then ["32", "42"]
    when :yellow then ["33", "43"]
    when :blue then ["34", "44"]
    when :magenta then ["35", "45"]
    when :cyan then ["36", "46"]
    when :white then ["37", "47"]
    when :light_black then ["90", "100"]
    when :light_red then ["91", "101"]
    when :light_green then ["92", "102"]
    when :light_yellow then ["93", "103"]
    when :light_blue then ["94", "104"]
    when :light_magenta then ["95", "105"]
    when :light_cyan then ["96", "106"]
    when :light_white then ["97", "107"]
    else nil
    end
    return color if swab == nil
    type == 'text' ? swab[0] : swab[1]
  end

  def color(color, background="")
    old_color = self.is_color
    color_text = sym_to_escape(color, 'text')
    color_background = sym_to_escape(background, 'back')
    new_str = ""
    if color_text || color_background
      new_str << "\e[#{color_text}"
      new_str << ";" if color_text && color_background
      new_str << "#{color_background}m"
    end
    new_str << "#{self}#{old_color}"
    new_str
  end

  def uncolor
    while self.include?("\e")
      self[self.index("\e")..self.index("m")] = "" if self.include?("\e")
    end
    self
  end

  def is_solid?
    %w(
      #
      ▒
    ).include?(self.uncolor.split.join)
  end

  def is_unbreakable?
    %w(
      ▒
      >
      <
    ).include?(self.uncolor.split.join)
  end
end

module Math

  def self.greater_of(*args)
    args.sort.last
  end

  def self.less_of(*args)
    args.sort.first
  end

  def self.get_line(x0,y0,x1,y1)
    points = []
    steep = ((y1-y0).abs) > ((x1-x0).abs)

    if steep
      x0,y0 = y0,x0
      x1,y1 = y1,x1
    end

    if x0 > x1
      x0,x1 = x1,x0
      y0,y1 = y1,y0
    end

    deltax = x1-x0
    deltay = (y1-y0).abs
    error = (deltax / 2).to_i
    y = y0
    ystep = nil

    ystep = y0 < y1 ? 1 : -1

    for x in x0..x1
      points << (steep ? {:x => y, :y => x} : {:x => x, :y => y})
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end

    return points
  end

  def self.distance_between(from, to)
    return nil unless from && to
    return Math.sqrt((from[:x] - to[:x])**2 + (from[:y] - to[:y])**2)
  end
end
