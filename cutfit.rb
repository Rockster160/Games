def parse_mixed_number(mixed_num)
  mixed_num.split.map { |r| Rational(r) }.inject(:+).to_f
end

def to_mixed_number(rational)
  rational = Rational(rational*16, 16)

  truncated = rational.truncate
  decimal = rational - truncated

  if decimal.to_s.split("/").last.to_i > 16
    return truncated + decimal.to_f.round(3)
  end

  if rational < 1
    rational.to_s
  else
    truncated == rational ? truncated.to_s : "#{truncated} #{decimal}"
  end
end

blade = 1/8
cuts = [
  "5x11",
  "5x11",
  "10x4",
  "10x4",
  "5x4",
  "5x4"
]

class Cut
  attr_accessor :w, :h

  def initialize(str) # "5 1/2x11"
    @w, @h = str.split("x").map { |n| parse_mixed_number(n) }
  end

  def wide
  end
end
