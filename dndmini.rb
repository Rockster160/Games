class Dice
  def initialize(str)
    @str = str
  end

  def roll
    rolls, sides = @str.split("d", 2).map { |n| n.to_i if !n.empty? }
    (rolls || 1).times.sum { rand(sides || 6) + 1 }.tap { |v|
      puts "[#{@str}] Rolls: #{(rolls || 1)} Sides: #{sides || 6} == #{v}" if $debug
    }
  end
end

$debug = ARGV[1] == "--debug"
op = ARGV[0].gsub(/\d*d\d*/) { |str| Dice.new(str).roll }
puts op if $debug
puts eval(op)

# p eval(ARGV[0].gsub(/\d*d\d*/){|t|t.split("d",2).map{|n|n.to_i if n[0]}.then{|r,s|(r||1).times.sum{rand(s||6)+1}}})
# p eval(ARGV[0].gsub(/\d*d\d*/){|t|t.split("d",2).map{|n|n.to_i if n[0]}.then{|r,s|(r||1).times.sum{rand(s||6)+1}}})
