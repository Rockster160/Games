Tile.new(:blank, alias: :wire,
  n: :wall,
  s: :wall,
  e: :wall,
  w: :wall,
)
Tile.new(:straight, rotatable: true, alias: :wire,
  n: :wire,
  s: :wire,
  e: :wall,
  w: :wall,
)
Tile.new(:angle, rotatable: true, alias: :wire,
  n: :wire,
  e: :wire,
  s: :wall,
  w: :wall,
)
Tile.new(:double_angle, rotatable: true, alias: :wire, weight: 0.2,
  n: :wire,
  s: :wire,
  e: :wire,
  w: :wire,
)
Tile.new(:threeway, rotatable: true, alias: :wire,
  n: :wire,
  s: :wire,
  w: :wire,
  e: :wall,
)
# Tile.new(:hole, rotatable: true,
#   n: :wire,
# )
# Tile.new(:center_hole, rotatable: true,
#   n: :wire,
#   s: :wire,
# )

Board.draw = Proc.new { |cell|
  print cell.err? ? "\e[31m" : "\e[32m"
  print case "#{cell&.tile&.name.to_s[0]}#{cell&.tile&.rotation}"
  when "a0"       then "└"
  when "a1"       then "┌"
  when "a2"       then "┐"
  when "a3"       then "┘"
  when "t0"       then "┤"
  when "t1"       then "┴"
  when "t2"       then "├"
  when "t3"       then "┬"
  when "s1", "s3" then "─"
  when "s0", "s2" then "│"
  when /^d\d$/    then "┼"
  when /^h\d$/    then "o"
  when /^c\d$/    then "O"
  when "b0"       then "•"
  else
    "\e[38;2;60;60;60m."
  end
  print "\e[0m"
}
