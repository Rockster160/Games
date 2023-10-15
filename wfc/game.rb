# grass
# path
# bridge
# water


Tile.new(:grass)
Tile.new(:water, rotatable: true, weight: 0.2,
  n: :water,
  s: :water,
  e: :grass,
  w: :grass,
)
Tile.new(:midwater, weight: 1, alias: :water,
  n: :water,
  s: :water,
  e: :water,
  w: :water,
)
Tile.new(:waterturn, rotatable: true, weight: 0.1, alias: :water,
  n: :water,
  e: :water,
  s: :grass,
  w: :grass,
)
Tile.new(:waterthreeway, rotatable: true, weight: 0, alias: :water,
  n: :water,
  e: :water,
  s: :water,
  w: :grass,
)
# Tile.new(:midbridge, rotatable: true,
#   n: :bridge,
#   s: :bridge,
#   w: :water,
#   e: :water,
# )
# Tile.new(:endbridge, rotatable: true,
#   n: [:bridge, :path],
#   w: :grass,
#   e: :grass,
#   s: [:bridge, :path],
# )
Tile.new(:path, rotatable: true, weight: 0.2,
  n: :path,
  s: :path,
  e: :grass,
  w: :grass,
)
Tile.new(:pathturn, rotatable: true, weight: 0.01, alias: :path,
  n: :path,
  s: :grass,
  e: :path,
  w: :grass,
)
Tile.new(:paththreeway, rotatable: true, weight: 0.01, alias: :path,
  n: :path,
  s: :path,
  e: :path,
  w: :grass,
)
# Tile.new(:double_angle, rotatable: true,
#   n: :wire,
#   s: :wire,
#   e: :wire,
#   w: :wire,
# )
# Tile.new(:threeway, rotatable: true,
#   n: :wire,
#   s: :wire,
#   w: :wire,
# )
# Tile.new(:hole, rotatable: true,
#   n: :wire,
# )
# Tile.new(:center_hole, rotatable: true,
#   n: :wire,
#   s: :wire,
# )

Board.draw = Proc.new { |cell|
  tile = cell.tile

  if tile&.name&.match?(/threeway/)
    char = case tile&.rotation
    when 0 then "├"
    when 1 then "┬"
    when 2 then "┤"
    when 3 then "┴"
    end
  elsif tile&.name&.match?(/turn/)
    char = case tile&.rotation
    when 0 then "└"
    when 1 then "┌"
    when 2 then "┐"
    when 3 then "┘"
    end
  elsif tile&.rotatable
    char = case tile&.rotation
    when 0 then "^"
    when 1 then ">"
    when 2 then "v"
    when 3 then "<"
    end
  end
  char ||= case tile&.name
  when /water/ then "~"
  when /path/ then "#"
  else "."
  end

  print case tile&.name
  when /water/ then "\e[48;5;74m#{char} \e[0m"
  when /grass/ then "\e[48;5;22m#{char} \e[0m"
  when /path/ then "\e[48;5;137m#{char} \e[0m"
  when /bridge/ then "\e[43m= \e[0m"
  # when "a0" then "┘"
  # when "a1" then "└"
  # when "a2" then "┌"
  # when "a3" then "┐"
  # when "t0" then "┤"
  # when "t1" then "┴"
  # when "t2" then "├"
  # when "t3" then "┬"
  # when "s1", "s3" then "─"
  # when "s0", "s2" then "│"
  # when /^d\d$/ then "┼"
  # when /^h\d$/ then "o"
  # when /^c\d$/ then "O"
  # when "b0" then "."
  else
    char = "X" if tile.nil?
    cell&.err? ? "\e[31m#{char} \e[0m" : "\e[38;2;60;60;60m. \e[0m"
  end
}
