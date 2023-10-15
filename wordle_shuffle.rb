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

  def attempt(word_mind)
    if word_mind.include?("⬛") || word_mind.include?("🟨")
      word = word_mind[/^\w+/].upcase
      mind = word_mind[/\W+$/]
    else
      word, mind = word_mind.upcase.split("-")
    end

    word.split("").each_with_index do |letter, idx|
      case (mind || [])[idx]
      when "🟩", "G" then @green[idx] = letter
      when "⬛", "B" then @black << letter
      when "🟨", "Y" then @yellow[idx] << letter
      end
    end
  end

  def guess
    available = @yellow.map { |ls| ls }.flatten.uniq - @green
    word = @green.dup

    while_try = 6
    while word.include?("*") && available.any? && while_try > 0
      while_try -= 1
      indices = word.map.with_index { |letter, idx| idx if letter == "*" }.compact
      insert_at = indices.shuffle.shuffle.sample

      loop_try = 6
      letter = while loop_try > 0 do
        loop_try -= 1

        l = available.shuffle.shuffle.last

        unless @yellow[insert_at].include?(l)
          available -= [l]
          break l
        end
      end

      word[insert_at] = letter || "*"
    end

    return guess if while_try <= 0
    word.join
  end

  def replace_wildcard_with_possibles(word)
    @left.map { |letter|
      idx = word.index("*")
      next if @yellow[idx].include?(letter)
      word.sub("*", letter)
    }.compact
  end

  def possibilities(guesses)
    @left = ("A".."Z").to_a - @black
    possibles = []
    guesses.each do |guess|
      guess_possibles = guesses
      # wild_idxs = (0..guess.count("*")).find_all { |t| guess[t] == "*" }

      guess.count("*").times do |t|
        guess_possibles = guess_possibles.map { |possible_guess|
          replace_wildcard_with_possibles(possible_guess)
        }.flatten
      end

      possibles += guess_possibles
    end
    possibles.sort.uniq
  end
end

word = Word.new

if ARGV == 0
  puts "🟩⬛🟨"
else
  ARGV.each do |arg|
    next if arg == "-c"
    word.attempt(arg)
  end
end

# float⬛⬛⬛⬛⬛ miner⬛🟨🟨🟨🟨 chest⬛⬛🟨⬛⬛ reign🟨🟨🟩⬛🟨
guesses = 50.times.map {
  begin
    word.guess
  rescue SystemStackError
    nil
  end
}.compact.uniq.sort
# puts word.inspect
puts guesses
if ARGV.include?("-c")
  print "\e[33m"
  puts word.possibilities(guesses)
  print "\e[0m"
end
if ARGV.include?("-C")
  print "\e[32m"
  puts Dictionary.words_at_length(5).map(&:downcase) & word.possibilities(guesses).map(&:downcase)
  print "\e[0m"
end
