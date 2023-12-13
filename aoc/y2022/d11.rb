# $test = true
# ruby /Users/rocco/code/games/aoc2022/gen.rb 12
require "pry-rails"
require "json"
# require "io/console"
# require "io/wait"
require "/Users/rocco/code/games/engine/colorize"; include Colorize
require "/Users/rocco/code/games/engine/draw"; include Draw
# Draw.cell_width = 1
def debug(*args); puts(*args) if $test; end
def d(*args); p(*args) if $test; end
input = File.read("/Users/rocco/code/games/aoc2022/d11.txt")
input = "Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1" if $test

class Monkey
  attr_accessor :num, :items, :operation, :test, :true, :false, :count

  def initialize(text)
    @num = text.match(/Monkey (\d+)/)[1].to_i
    @items = text.match(/Starting items: ((?:\d+(?:, )?)*)/)[1].split(", ").map(&:to_i)
    @operation = text.match(/Operation: new = (.*?)$/)[1]
    @test = text.match(/Test: .*?(\d+)$/)[1].to_i # divisible
    @true = text.match(/If true: .*?(\d+)$/)[1].to_i # monkey
    @false = text.match(/If false: .*?(\d+)$/)[1].to_i # monkey
    @count = 0
  end
end

monkeys = input.split("\n\n").map { |monkey| Monkey.new(monkey) if monkey.match?("Monkey") }.compact

rounds = 10000
divcheat = monkeys.map(&:test).inject(:*)
i = 0
loop do # round
  print "  #{i} #{Draw.clr}\r"
  i += 1
  monkeys.each do |monkey| # turn
    monkey.items = monkey.items.map do |item|
      # inspect = operation
      new = eval(monkey.operation.gsub("old", item.to_s)).floor
      monkey.count += 1
      # (new / 3.to_f).floor # Part 1 -- reduce worry level
      # To avoid numbers getting to huge, find the GCD of all of the monkeys and divmod it since we
      # know that any number over that will repeat divisibility
      new % divcheat # Part 2
    end
    monkey.items.each do |item|
      # test worry -> throw to next monkey
      if item % monkey.test == 0
        monkeys[monkey.true].items << item
      else
        monkeys[monkey.false].items << item
      end
      # item goes to END of list
    end
    monkey.items = []
  end
  break if i == rounds
end

puts monkeys.map { |m| "Monkey #{m.num}: #{m.count}" }
puts monkeys.map(&:count).sort.last(2).inject(:*)
binding.pry
