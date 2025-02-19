def to_plural(word)
  if word.end_with?("s", "x", "z", "sh", "ch")
    word + "es"
  elsif word.end_with?("y") && !word[-2].match(/[aeiou]/)
    word[0..-2] + "ies"
  else
    word + "s"
  end
end

def to_singular(word)
  if word.end_with?("ies")
    word[0..-4] + "y"
  else
    word.sub(/s$/, "")
  end
end

class Model
  @all_models = []
  attr_accessor :name

  def self.all_models
    @all_models
  end

  def self.rx(key)
    all_models.map(&key).join("|")
  end

  def self.from(val)
    all_models.find { |model| model.match?(val) } || new(val)
  end

  def initialize(name)
    @name = to_singular(name.to_s.split("_").map { |word| word.sub(/^./) { |char| char.upcase } }.join)

    Model.all_models << self
  end

  def match?(text)
    text = text.to_s
    pascal == text || snake == text || pluralize == text || plural_pascal == text
  end

  def title
    @title ||= snake.split("_").map(&:capitalize).join(" ")
  end

  def plural_title
    @plural_title ||= to_plural(title)
  end

  def pascal
    @name
  end

  def plural_pascal
    @plural_pascal ||= to_plural(@name)
  end

  def snake
    @snake ||= @name.to_s.gsub(/([a-z\d])([A-Z])/, '\1_\2').gsub(/([A-Z])([A-Z][a-z])/, '\1_\2').downcase
  end

  def plural_snake
    pluralize
  end

  def pluralize
    @pluralize ||= to_plural(snake)
  end
end
