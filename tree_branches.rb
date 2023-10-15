# require "pry-rails"

input = "
Movement
  Balancing
  Landing
    Bent knee
    Falls
      Back
      Front
      Side
      Squat-back
      Squat-front
      Squat-side
    Ground kong
    Precision
      Bar
      Running
      Standing
    Safety tap
    Spiderman
Vaults
  Butterfly
  Dash
  Gate
  Glide
  Kash
  Kong
  Lazy
  Monkey
  Pop
  Reverse
  Reverse safety
  Rotary
  Safety
  Side
  Speed
  Spin
  Thief
  Turn
Wall-ledge
  Cat
    Gargoyle
    Half
    quarter
    Running
    Sideways
    Standing
  Climb up
  Crane
  Tictac
  Wallrun
  Wall stop
Barwork
  Bar kip
"

def dig_set(obj, keys, value)
  key = keys.first
  if keys.length == 1
    obj[key] = value
  else
    obj[key] = {} unless obj[key]
    dig_set(obj[key], keys.slice(1..-1), value)
  end
end

def list_to_hash(list, indent="  ", line_separator="\n")
  branch = []
  prev_level = 0
  prev_leaf = nil
  list.split(line_separator).each_with_object({}) do |line, hash|
    next if line.to_s.length == 0

    # Count the current level of indent
    current_levels = 0
    loop do
      break unless line.match?(/^#{indent}/)
      current_levels += 1
      line.sub!(/^#{indent}/, "")
    end

    # Compare the previous and current indent to determine nesting
    if prev_level == current_levels # Same nest (sibling of prev)
      # no-op, set the current leaf on the end of the branch
    elsif prev_level < current_levels # Nested inside previous (child of prev)
      branch.push(prev_leaf) # Add the prev_leaf to the branch as a parent
    elsif prev_level > current_levels # Nested outside previous (uncle of prev)
      (prev_level - current_levels).times { branch.pop } # Remove the last leaves until back up
    end

    dig_set(hash, branch + [line], {})
    prev_leaf = line
    prev_level = current_levels
  end
end

class Tree
  attr_accessor :hash

  def self.from_list(list)
    new(list_to_hash(list))
  end

  def initialize(hash)
    @hash = hash
  end

  def each_branch(tree=@hash, upper_branches=[], only_leaves: false, &block)
    tree.each do |branch, stems|
      block.call(branch, upper_branches, stems&.keys) if !only_leaves || stems.none?
      each_branch(stems, upper_branches + [branch], only_leaves: only_leaves, &block)
    end
  end

  def each_leaf(&block)
    each_branch(only_leaves: true, &block)
  end
end

tree = Tree.from_list(input)
tree.each_branch do |leaf, branches, stems|
  puts "\e[36m#{branches.join(".")}.\e[32m#{leaf}\e[90m  #{stems.join(",")}\e[0m"
end
tree.each_leaf do |leaf, branches| # Leaves won't ever have stems
  puts "\e[36m#{branches.join(".")}.\e[32m#{leaf}\e[0m"
end
