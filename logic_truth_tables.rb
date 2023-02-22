# require "pry-rails"
require "/Users/rocco/code/games/ascii_table"

input = ARGV.join(" ").then { |s| s.length > 0 ? s : "A && B" }
vars = input.split("").select { |char| char.match?(/[a-z]/i) }.uniq
perms = [0, 1].repeated_permutation(vars.count)

table = AsciiTable.new
table.insert_hr
table << [*vars, nil, input]
table.insert_hr
perms.each do |perm|
  expr = input.dup
  vars.each_with_index { |v, i| expr.gsub!(v, (perm[i] == 1).to_s) }
  table << [*perm, nil, eval(expr) ? "1" : "0"].map { |cell|
    AsciiTable::Cell.new(cell, bg: cell.to_s == "0" ? :red : :green) unless cell.nil?
  }
end
table.insert_hr

table.draw

# ARGV[0].split("").select{|c|c=~/\w/}.uniq.then{|v|
#   [*v,ARGV[0]].join(" | ").tap{|l|puts l,"-"*l.size,*[0,1].repeated_permutation(v.size).map{|m|
#     [*m,eval(ARGV[0].dup.tap{|x|v.size.times{|i|x.gsub!(v[i],"#{m[i]==1}")}})?1:0].join(" | ")
#   }}
# }
# ARGV[0].split("").select{|c|c=~/\w/}.uniq.then{|v|[*v,ARGV[0]].join(" | ").tap{|l|puts l,"-"*l.size,*[0,1].repeated_permutation(v.size).map{|m|[*m,eval(ARGV[0].dup.tap{|x|v.size.times{|i|x.gsub!(v[i],"#{m[i]==1}")}})?1:0].join(" | ")}}}
