dark = Tile.new(:dark,
  n: [:tc, :rock, :dark, :br, :bl],
  e: [:mr, :br, :rock, :dark],
  w: [:ml, :bl, :rock, :dark],
  s: [:rock, :dark],
)
rock = Tile.new(:rock, rules: dark.rules)
torch = Tile.new(:torch,
  n: [:torch, :light],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tl, :ml],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tr, :mr],
  s: [:barrel, :torch, :chest, :light, :top, :tr, :tl, :tm],
)
light = Tile.new(:light, rules: torch.rules)
barrel = Tile.new(:barrel,
  n: [:torch, :light],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tl, :ml],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tr, :mr],
  s: [:tr, :tl, :tm],
)
chest = Tile.new(:chest, rules: barrel.rules)
tl = Tile.new(:tl,
  n: [:barrel, :torch, :chest, :light, :base],
  e: [:bl, :tc, :tr],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base],
  s: [:ml, :bl],
)
tr = Tile.new(:tr,
  n: [:barrel, :torch, :chest, :light, :base],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base],
  w: [:tl, :tc, :br],
  s: [:mr, :br],
)
tc = Tile.new(:tc,
  n: [:barrel, :torch, :chest, :light, :base],
  e: [:tc, :tr, :bl],
  w: [:tc, :tl, :br],
  s: [:rock, :dark],
)
bl = Tile.new(:bl,
  n: [:ml, :tl],
  e: [:rock, :dark, :br, :mr],
  w: [:tl, :tc],
  s: [:rock, :dark],
)
br = Tile.new(:br,
  n: [:mr, :tr],
  e: [:tc, :tr],
  w: [:rock, :dark, :bl, :ml],
  s: [:rock, :dark],
)
ml = Tile.new(:ml,
  n: [:tl, :ml],
  e: [:rock, :dark, :mr, :br],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base],
  s: [:ml, :bl],
)
mr = Tile.new(:mr,
  n: [:mr, :tr],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base],
  w: [:rock, :dark, :ml, :bl],
  s: [:mr, :br],
)
top = Tile.new(:top,
  n: [:torch, :light],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tl, :ml],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tr, :mr],
  s: [:trunk, :base],
)
trunk = Tile.new(:trunk,
  n: [:top, :trunk],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tl, :ml],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tr, :mr],
  s: [:trunk, :base],
)
base = Tile.new(:base,
  n: [:top, :trunk],
  e: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tl, :ml],
  w: [:barrel, :torch, :chest, :light, :top, :trunk, :base, :tr, :mr],
  s: [:tl, :tc, :tr],
)

Board.draw = Proc.new { |cell|
  yellow = "\e[33m"
  brown = "\e[38;5;130m"
  cyan = "\e[36m"
  cl = "\e[0m"
  print case cell&.tile&.name
  when :barrel  then "#{cyan}®#{cl}"
  when :torch   then "#{yellow}*#{cl}"
  when :chest   then "#{cyan}ç#{cl}"
  when :light   then "#{yellow}##{cl}"
  when :tl      then "#{}┌#{cl}"
  when :tc      then "#{}─#{cl}"
  when :tr      then "#{}┐#{cl}"
  when :ml, :mr then "#{}│#{cl}"
  when :rock    then "#{}o#{cl}"
  when :bl      then "#{}┘#{cl}"
  when :dark    then "#{}.#{cl}"
  when :br      then "#{}└#{cl}"
  when :top     then "#{brown}┬#{cl}"
  when :trunk   then "#{brown}‖#{cl}"
  when :base    then "#{brown}┴#{cl}"
  else "\e[31m#{cell&.tile&.name || "?"}\e[0m"
  end
}
