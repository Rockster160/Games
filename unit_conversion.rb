class Rational
  def to_simplified_s
    truncated = self.truncate
    decimal = self - truncated

    if decimal.to_s.split("/").last.to_i > 16
      return truncated + decimal.to_f.round(3)
    end

    if self < 1
      to_s
    else
      truncated == self ? truncated.to_s : "#{truncated} #{decimal}"
    end
  end
end

def parse_mixed_number(mixed_num)
  whole_num, fraction = mixed_num.split(" ")
  return whole_num.to_i if fraction.nil?

  numerator, denominator = fraction.split("/")

  decimal = denominator.nil? ? "0.#{numerator}".to_f : numerator.to_i / denominator.to_f

  whole_num.to_i + decimal
end

def to_mixed_number(rational)
  Rational(rational*16, 16).to_simplified_s
end

def to_mm(inches)
  # puts "(#{parse_mixed_number(inches) * 25.4})"
  to_mixed_number(parse_mixed_number(inches) * 25.4)
end

def to_in(inches)
  # puts "(#{parse_mixed_number(inches) / 25.4})"
  to_mixed_number(parse_mixed_number(inches) / 25.4)
end

puts "#{to_in(ARGV[1])} in" if ARGV[0] == "mm"
puts "#{to_mm(ARGV[1])} mm" if ARGV[0] == "in"
