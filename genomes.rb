require "pry-rails"
require "/Users/rocco/code/games/randcos_density.rb"

def genome_mix(val1, val2, factor: 3)
  num = randcos(factor: factor, intervals: 2)
  min, max = [val1, val2].sort.map(&:to_f)
  min *= 0.9
  max *= 1.1
  (min + (num * (max - min))).round
end

class Trait
  attr_accessor :points, :schema, :behavior

  def self.range(*vals)
    proc { Trait.new(:range, vals).tap(&:roll) }
  end

  def self.spider(*vals)
    proc { Trait.new(:spider, vals).tap(&:roll) }
  end

  def initialize(behavior, schema)
    @behavior = behavior
    @schema = schema
  end

  def inspect
    # content = instance_variables.map { |i|
    #   sprintf("%s=%s", i, instance_variable_get(i).inspect) if ![:@schema, :@behavior].include?(i.to_sym)
    # }.compact.join(" ")
    # "#<#{self.class.name}:0x#{object_id.to_s(16).rjust(16, '0')} #{content}>"
    "#<#{self.class.name} #{@points}>"
  end

  def roll
    case @behavior
    when :range then @points = @schema.map { |max| rand(0..max) }
    # when :spider
    #   sum = @schema.sum
    #   first, *rest = @schema
    #   @points = rest.map { rand(0..sum).tap { |r| sum -= r } }
    #   @points << sum
    end
  end

  def splice(trait)
    # Have to be the same traits - maybe check name?
    new_trait = Trait.new(@behavior, @schema)
    new_trait.points = @points.map.with_index { |val, idx|
      val2 = trait.points[idx]
      genome_mix(val, val2)
    }
    new_trait
  end
end

# class Point
#   attr_accessor :max, :behavior, :val
#   # commonality # chances to mutate if a combo does not already have this trait
#   # 100 - Trait is ALWAYS present
#   # 0 - Trait is Never present and must be artificially added
#   def initialize(max, behavior)
#     @max = max
#     @behavior = behavior
#     roll(false)
#   end
#
#   def roll
#     rand(0..@max)
#   end
# end
# Genome list
# range - each value can be from 0..x
# spider -
GENOME_SCHEMA = {
  flower_color: Trait.range(255, 255, 255), # rgb
  leaf_length: Trait.range(100),
  thorniness: Trait.range(100),
  fragrance: Trait.range(100, 100, 100), # floral, spicy, fruity
  # Most likely this should stay right in the "bell" area
  size: Trait.range(100),
  # Most likely this should stay right in the "bell" area
  # * Maybe even have a variety of sizes: tiny, small, med, large, xl
  # * * Each size is likely to stick near the sizes and unlikely to change drastically between the sizes
  bioluminescence: Trait.range(100),
  # Want this to be a very high tendency towards 0, with small chances to increase
}

class Flower
  attr_accessor :traits

  def initialize(empty: false)
    @traits = {}
    return if empty

    @traits = GENOME_SCHEMA.each_with_object({}) { |(trait_name, trait_proc), flower_traits|
      flower_traits[trait_name] = trait_proc.call
    }
  end

  def splice(flower)
    child = Flower.new(empty: true)
    @traits.each do |trait_name, trait_val|
      child.traits[trait_name] = trait_val.splice(flower.traits[trait_name])
    end
    child
    # For traits not present in self, iterate through `flower` traits as well
  end
end

f1 = Flower.new
puts "\n-- Flower 1"
pp f1
f2 = Flower.new
puts "\n-- Flower 2"
pp f2
f3 = f1.splice(f2)
puts "\n-- Child Flower"
pp f3


# Flower Color: Determines the color of the plant's flowers, such as red, blue, yellow, or even multicolored.
# Leaf Shape: Defines the shape of the plant's leaves, such as oval, lanceolate, lobed, or palmate.
# Thorniness: Determines the presence and density of thorns or spines on the plant's stems or leaves.
# Growth Habit: Defines the overall growth pattern of the plant, such as trailing, upright, creeping, or climbing.
# Fragrance: Determines if the plant emits a pleasant scent, such as floral, fruity, or spicy.
# Size: Defines the overall size of the plant, ranging from small and compact to tall and towering.
# Fruit Type: Determines the type of fruit the plant produces, such as berries, drupes, capsules, or pods.
# Toxicity: Determines if the plant has any toxic or poisonous properties.
# Drought Tolerance: Defines the plant's ability to withstand long periods of drought without withering or dying.
# Bioluminescence: Determines if the plant emits a soft glow in the dark, adding an enchanting element.
# Camouflage: Determines if the plant can blend in with its surroundings, providing natural camouflage.
# Adaptability: Defines the plant's ability to thrive in various environments, such as forests, deserts, or swamps.
# Climbing Mechanism: Determines how the plant climbs, such as tendrils, twining stems, or clinging roots.
# Edible Parts: Determines if any parts of the plant, such as leaves, flowers, or fruits, are edible to creatures.
# Medicinal Properties: Determines if the plant possesses any healing or medicinal properties.
# Defense Mechanism: Defines the plant's defense mechanism, such as emitting toxins, releasing spores, or rapid growth.
# Regeneration: Determines if the plant can regenerate from cuttings or damaged parts.
# Water Retention: Defines the plant's ability to retain water, making it suitable for arid or water-scarce environments.
# Root System: Determines the type and depth of the plant's roots, such as fibrous, taproot, or adventitious.
# Growth Rate: Defines the rate at which the plant grows, ranging from slow-growing to fast-growing.
#
# def combine_genomes(parent1, parent2)
#   combined_genome = {}
#
#   parent1.each do |key, value|
#     if parent2[key]
#       # Reverse bell curve- most likely will be very close to one of the parents, unlikely to be the middle
#       # * Cos tendency- 2 points should be the parents with slight chance to be more or less
#       min, max = [value, parent2[key]].sort
#       combined_genome[key] = rand((min*0.9)..(max*1.1)).round
#     else
#       # Chance to lose this genome
#       combined_genome[key] = value
#     end
#   end
#
#   parent2.each do |key, value|
#     # Chance to lose this genome
#     combined_genome[key] = value unless combined_genome[key]
#   end
#
#   # Small chance to add a new trait?
#   combined_genome
# end
