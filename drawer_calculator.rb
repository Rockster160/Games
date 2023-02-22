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
    to_s
  else
    truncated == rational ? truncated.to_s : "#{truncated} #{decimal}"
  end
end

outer = parse_mixed_number(arg[:outer])
inner = parse_mixed_number(arg[:inner])
tolerance = parse_mixed_number(arg[:tolerance])
outer_cut = parse_mixed_number(arg[:outer_cut])
inner_cut = parse_mixed_number(arg[:inner_cut])
high_wall = parse_mixed_number(arg[:high_wall])
low_wall = parse_mixed_number(arg[:low_wall])
width = parse_mixed_number(arg[:width])
height = parse_mixed_number(arg[:height])

outer_width = width + outer_cut*2 + outer*2 # Add outer to get full cut size
outer_length = height + outer_cut*2 + outer*2 # Add outer to get full cut size

inner_width = width - tolerance + inner_cut*2
inner_length = height - tolerance + inner_cut*2

puts "
  ** 1/2 Sheet **
  Base: #{to_mixed_number(outer_width)} x #{to_mixed_number(outer_length)}
  Width: #{to_mixed_number(outer_width)} x #{to_mixed_number(high_wall + outer_cut)}
  Long: #{to_mixed_number(outer_length)} x #{to_mixed_number(high_wall + outer_cut)}

  ** 1/4 Sheet **
  Base: #{to_mixed_number(inner_width)} x #{to_mixed_number(inner_length)}
  Width: #{to_mixed_number(inner_width)} x #{to_mixed_number(low_wall + inner_cut)}
  Long: #{to_mixed_number(inner_length)} x #{to_mixed_number(low_wall + inner_cut)}
"





class Thing
  class << self
    def outer; 1/2.to_f; end
    def inner; 1/4.to_f; end
    def tolerance; 2/8.to_f; end
    def outer_cut; 3/4.to_f; end
    def inner_cut; 1/2.to_f; end

    def high_wall; 6; end
    def low_wall; 2; end

    def mix_num(n)
      w, f = n.to_s.split(".")

      f_str = case "0.#{f}"
      when "#{1/8.to_f}" then "1/8"
      when "#{2/8.to_f}" then "1/4"
      when "#{3/8.to_f}" then "3/8"
      when "#{4/8.to_f}" then "1/2"
      when "#{5/8.to_f}" then "5/8"
      when "#{6/8.to_f}" then "3/4"
      when "#{7/8.to_f}" then "7/8"
      else
        puts "Not found: #{f}"
        ""
      end

      [w, f_str].map { |s| s.length == 0 ? nil : s }.compact.join(" ")
    end

    def size(w, h)
      # Desired inside w and inside h
      outer_width = w + outer_cut*2 + outer*2 # Add outer to get full cut size
      outer_length = h + outer_cut*2 + outer*2 # Add outer to get full cut size

      inner_width = w - tolerance + inner_cut*2
      inner_length = h - tolerance + inner_cut*2

      puts "
      ** 1/2 Sheet **
      Base: #{mix_num(outer_width)} x #{mix_num(outer_length)}
      Width: #{mix_num(outer_width)} x #{mix_num(high_wall + outer_cut)}
      Long: #{mix_num(outer_length)} x #{mix_num(high_wall + outer_cut)}

      ** 1/4 Sheet **
      Base: #{mix_num(inner_width)} x #{mix_num(inner_length)}
      Width: #{mix_num(inner_width)} x #{mix_num(low_wall + inner_cut)}
      Long: #{mix_num(inner_length)} x #{mix_num(low_wall + inner_cut)}
      "
    end
  end
end

# ruby drawer_calculator.rb 4 11
puts Thing.size(ARGV[0].to_f, ARGV[1].to_f)
