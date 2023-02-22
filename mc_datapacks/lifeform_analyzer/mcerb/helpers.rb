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

module Helpers
  def lifeform_analyzer
    "{id: \"minecraft:compass\", Count: 1b, tag: { display:{Name:\"{\\\"text\\\":\\\"Life Form Analyzer\\\"}\", Lore: [\"\\\"An ancient artifact\\\"\", \"\\\"Detects impending danger\\\"\"]}, Enchantments: [{id: unbreaking, lvl: 1}], LFA: 1b, HideFlags: 1b }}"
  end
end
