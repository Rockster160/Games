require "pry-rails"

class Deck
  attr_accessor :cards

  def initialize
    reshuffle # Start with a full shuffled deck
  end

  def shuffle
    @cards.shuffle!
  end

  def reshuffle
    @cards = [*(2..9), *"TJQKA".chars].product("♠♥♦♣".chars).map(&:join).shuffle
  end

  def draw
    @cards.pop
  end
end

deck = Deck.new
binding.pry
