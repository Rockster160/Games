STDIN.each_line.count{|l|t=@o.to_i<l.to_i;@o=l;t}-1

[1, 2, 3].count { |num| num.even? }


# 1581

previous_number = nil

puts STDIN.each_line.count { |current_line|
  less_than_prior = previous_number && previous_number.to_i < current_line.to_i
  previous_number = current_line
  less_than_prior
}
# p STDIN.readlines.each_cons(2).count{|l,c|c.to_i<l.to_i}
