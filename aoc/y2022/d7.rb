# ruby /Users/rocco/code/games/aoc2022/gen.rb 8
require "json"
require "pry-rails"
input = File.read("/Users/rocco/code/games/aoc2022/d7.txt")
@pwd = ["/"]
@dir = {}

def cd(d)
  return @pwd = [d] if d == "/"
  if d == ".."
    @pwd.pop
  else
    @pwd.push(d)
    nest = @dir
    @pwd.each { |f|
      nest[f] ||= {}
      nest = nest[f]
    }
  end
end

def cur
  nest = @dir
  @pwd.each { |f|
    nest[f] ||= {}
    nest = nest[f]
  }
  nest
end

def find_sizes(dir=@dir, pwd=[], box={})
  dir.each {|key, vals|
    next if key == :content

    box["#{pwd.join(".")}.#{key}"] = find_size(dir[key])
    find_sizes(dir[key], [*pwd, key], box)
  }
  box
end

def find_size(dir=@dir)
  dir.sum do |key, vals|
    if key == :content
      vals.sum { |v| v[:size] }
    else
      find_size(vals)
    end
  end
end

input.split("$").each { |cmd_res|
  cmd, *res = cmd_res.split("\n").map { |s| s.gsub(/^\s*|\s*$/, "") }
  next if cmd.nil?

  if cmd.match?(/^cd/)
    _, *path = cmd.split(" ")
    cd(path.join("/"))
  end

  if cmd.match?(/^ls/)
    cur[:content] ||= []
    res.each { |f|
      size, name = f.split(" ")
      next if size == "dir"
      cur[:content].push(name: name, size: size.to_i)
    }
  end
}

box = find_sizes

# First
# puts box.select { |d, sz| sz <= 100000 }.values.sum

# Second
total = 70000000
used = box["./"]
needed = 30000000
free = total - used
tofree = needed - free

puts box.select { |d, sz| sz >= tofree }.values.sort.first
