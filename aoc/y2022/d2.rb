require "pry-rails"
input = File.read("/Users/rocco/code/games/aoc2022/d2.txt")
# input = "A Y\nB X\nC Z"

@them = {
  A: :Rock,
  B: :Paper,
  C: :Scissors,
}
@me = {
  X: :Rock,
  Y: :Paper,
  Z: :Scissors,
}
@scores = {
  Rock: 1,
  Paper: 2,
  Scissors: 3,
}
@wins = {
  loss: 0,
  tie: 3,
  win: 6,
}
@should = {
  X: :loss,
  Y: :tie,
  Z: :win,
}

def win?(t, m)
  return if t == m
  return true if m == :Rock && t == :Scissors
  return true if m == :Paper && t == :Rock
  return true if m == :Scissors && t == :Paper
  false
end

def score(t, m)
  case win?(t, m)
  when nil then @scores[m] + @wins[:tie]
  when false then @scores[m] + @wins[:loss]
  when true then @scores[m] + @wins[:win]
  end
end

def follow(input)
  input.split("\n").sum { |round|
    t, m = round.split(" ")
    tshape = @them[t.to_sym]
    mshape = @me[m.to_sym]
    score(tshape, mshape)
  }
end

def smart(input)
  input.split("\n").sum { |round|
    t, m = round.split(" ")
    tshape = @them[t.to_sym]
    keys = @scores.keys
    mshape = (
      case @should[m.to_sym]
      when :loss then keys[(keys.index(tshape) - 1) % 3]
      when :tie then tshape
      when :win then keys[(keys.index(tshape) + 1) % 3]
      end
    )
    score(tshape, mshape)
  }
end

puts smart(input)
