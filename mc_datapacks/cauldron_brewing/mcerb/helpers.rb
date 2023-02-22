class E # Entity
  attr_accessor :queries

  class << self
    def method_missing(method_name, *args)
      new.send(method_name, *args)
    rescue NoMethodError
      binding.pry
      super
    end
  end

  def initialize
    @queries = []
  end

  def q(*query)
    @queries += query
    self
  end

  def type(type_to_match)
    q "type=#{type_to_match}"
  end

  def dist(distance)
    q "distance=..#{distance}"
  end

  def closest(distance=nil)
    dist(distance) unless distance.nil?
    q "limit=1", "sort=nearest"
  end

  def tag(*tags_to_add)
    q *tags_to_add.map { |tag| "tag=#{tag}"}
  end

  def item(id=nil)
    q("nbt={Item:{id:\"minecraft:#{id}\"}}") unless id.nil?

    type(:item)
  end

  def to_s
    inspect
  end

  def inspect
    "@e[#{queries.join(',')}]"
  end
end

class Potion
  attr_accessor :key, :base, :long, :strong, :hex

  def initialize(key, hex, opts={})
    @key = key
    @hex = hex
    @long = true
    @strong = true

    opts.each do |optk, optv|
      instance_variable_set("@#{optk}", optv)
    end
  end

  def title
    key.to_s.split("_").map(&:capitalize).join(" ")
  end

  def camel
    pascal = title.split(" ").join("")
    pascal[0] = pascal[0].downcase
    pascal
  end

  def base?
    true
  end

  def long?
    !!long
  end

  def strong?
    !!strong
  end

  def rgb
    hex.sub("#", "").scan(/../).map { |h| h.to_i(16) }
  end

  def rgb_dec
    rgb.map { |c| (c / 256.to_f).round(2) }
  end
end

module Helpers
  def add_recipe(tag: nil, ing:, effect:, remove: nil)
    condition = tag.nil? ? "" : " if entity @s[tag=#{tag}]"

    entity = E.tag(:brewitem).dist(0.5).item(ing)

    <<~EOF
    execute at @s#{condition} if entity #{entity} run tag @s add successful_brew
    execute at @s#{condition} if entity #{entity} run tag @s add #{effect}#{
    "\nexecute at @s#{condition} if entity #{entity} run tag @s remove #{remove}" if remove }
    EOF
  end

  def potion_item(name)
    "minecraft:potion{Potion:\"minecraft:#{name}\"}"
  end

  def potion_list
    [
      Potion.new(:plain,           "#385DC6"),
      Potion.new(:awkward,         "#9A1A33"),
      Potion.new(:mundane,         "#000000"),
      Potion.new(:thick,           "#000000"),
      Potion.new(:swiftness,       "#7CAFC6"),
      Potion.new(:slowness,        "#5A6C81"),
      Potion.new(:leaping,         "#786297"),
      Potion.new(:strength,        "#932423"),
      Potion.new(:healing,         "#F82423", long: false),
      Potion.new(:harming,         "#430A09", long: false),
      Potion.new(:poison,          "#4E9331"),
      Potion.new(:regeneration,    "#CD5CAB"),
      Potion.new(:fire_resistance, "#E49A3A", strong: false),
      Potion.new(:water_breathing, "#2E5299", strong: false),
      Potion.new(:night_vision,    "#1F1FA1", strong: false),
      Potion.new(:invisibility,    "#7F8392", strong: false),
      Potion.new(:turtle_master,   "#99453A"),
      Potion.new(:slow_falling,    "#F7F8E0", strong: false),
      Potion.new(:weakness,        "#484D48", strong: false),
      Potion.new(:luck,            "#339900", long: false, strong: false),
      Potion.new(:resistance,      "#99453A"),
      Potion.new(:blindness,       "#1F1F23"),
      Potion.new(:confusion,       "#551D4A"),
      Potion.new(:exhaust,         "#4A4217"),
      Potion.new(:haste,           "#D9C043"),
      Potion.new(:hunger,          "#587653"),
    ]
  end
end
