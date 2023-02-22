def to50(num)
  leftover = 50 - num
  a = Math.round(leftover / 2)
  b = leftover - a
  [num, a, b]
end

20.times do
  p to50(rand(50))
end
