# [bread]
# dream-ygggb
# dread-bgggg (Black now despite the last letter being "d")

require "pry-rails"
require "/Users/rocco/code/games/dictionary.rb"
# ARGV[0]
# 🟩⬛🟨
class Word
  attr_accessor :green, :yellow, :black

  def initialize
    @green = Array.new(5) { "*" }
    @black = []
    @yellow = Array.new(5) { [] } # Each item is a list of letters NOT in that spot
  end

  def filter(attempt_mind)
    if attempt_mind.include?("⬛") || attempt_mind.include?("🟨")
      attempt = attempt_mind[/^\w+/].upcase
      mind = attempt_mind[/\W+$/]
    else
      attempt, mind = attempt_mind.upcase.split("-")
    end

    attempt.split("").each_with_index do |letter, idx|
      case (mind || [])[idx] || "B"
      when "🟩", "G" then @green[idx] = letter
      when "⬛", "B" then @black << letter
      when "🟨", "Y" then @yellow[idx] << letter
      end
    end
  end

  def to_s
    @green.join
  end

  def possibilities
    5.times.map { |idx|
      possibles_at_char(idx)
    }.then { |matrix|
      yellows = @yellow.flatten.uniq
      matrix.shift.product(*matrix).select { |chars|
        yellows.none? || yellows.all? { |char| chars.include?(char) }
      }
    }.map(&:join)
  end

  def possibles_at_char(idx)
    return [@green[idx]] unless @green[idx] == "*"
    ("A".."Z").to_a - @black - @yellow[idx]
  end
end

word = Word.new

if ARGV == 0
  puts "🟩⬛🟨"
else
  ARGV.each do |arg|
    next if arg.downcase == "-c"
    word.filter(arg)
  end
end

# float⬛⬛⬛⬛⬛ miner⬛🟨🟨🟨🟨 chest⬛⬛🟨⬛⬛ reign🟨🟨🟩⬛🟨
puts word
if ARGV.include?("-c")
  print "\e[33m"
  puts word.possibilities
  print "\e[0m"
end
if ARGV.include?("-C")
  print "\e[32m"
  puts File.read("/Users/rocco/code/games/test.wordle.words").split("\n") & word.possibilities.map(&:downcase)
  print "\e[0m"
end
if ARGV.include?("-D")
  print "\e[94m"
  puts Dictionary.words_at_length(5).map(&:downcase) & word.possibilities.map(&:downcase)
  print "\e[0m"
end
