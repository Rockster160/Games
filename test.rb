# Do katas in kata.rb

ALPHABET = ("a".."z").to_a

def str_to_nums(str)
  str.chars.map { |c| ALPHABET.index(c)&.then { |n| n + 1 } || c }
end

def nums_to_output(arr)
  arr.map { |n| n.is_a?(Integer) ? n.to_s.rjust(3, " ") : n }.join(" ")
end

def encode(str, key)
  puts "# -- repeat the key to match input"
  ostr = str.dup
  i = 0
  keystr = ostr.chars.map { |c| ALPHABET.index(c)&.then { |n| key[i%key.length].tap { i += 1 } } || c }.join
  puts keystr
  puts ostr
  puts

  puts "# -- Convert to nums"
  keynums = str_to_nums(keystr)
  strnums = str_to_nums(ostr)
  puts nums_to_output(keynums)
  puts nums_to_output(strnums)
  puts

  puts "# -- Add together"
  sumnums = keynums.map.with_index { |c,i| c.is_a?(Integer) ? (c + strnums[i]) : c  }
  puts nums_to_output(sumnums)
  puts

  puts "# -- Wrap with alphabet (27 -> 1)"
  wrapnums = sumnums.map.with_index { |n, i| n.is_a?(Integer) ? (n%ALPHABET.length) : n }
  puts nums_to_output(wrapnums)
  puts

  puts "# -- Convert back to alphabet"
  sumnums.map.with_index { |n, i|
    next n unless n.is_a?(Integer)

    ALPHABET[(n-1)%ALPHABET.length]
  }.join("")&.tap { |s| puts "#{s}\n\n\n" }
end

def decode(str, key)
  puts "# -- repeat the key to match input"
  ostr = str.dup
  i = 0
  keystr = ostr.chars.map { |c| ALPHABET.index(c)&.then { |n| key[i%key.length].tap { i += 1 } } || c }.join
  puts keystr
  puts ostr
  puts

  puts "# -- Convert to nums"
  keynums = str_to_nums(keystr)
  strnums = str_to_nums(ostr)
  puts nums_to_output(keynums)
  puts nums_to_output(strnums)
  puts

  puts "# -- Subtract key from str"
  sumnums = keynums.map.with_index { |c,i| c.is_a?(Integer) ? (strnums[i] - c) : c  }
  puts nums_to_output(sumnums)
  puts

  puts "# -- Wrap with alphabet (0 -> 26)"
  wrapnums = sumnums.map.with_index { |n, i| n.is_a?(Integer) ? (n%ALPHABET.length) : n }
  puts nums_to_output(wrapnums)
  puts

  puts "# -- Convert back to alphabet"
  sumnums.map.with_index { |n, i|
    next n unless n.is_a?(Integer)

    ALPHABET[(n-1)%ALPHABET.length]
  }.join("")&.tap { |s| puts "#{s}\n\n\n" }
end

puts "\e[33m-- #{decode(encode("hello world", "secret"), "secret")}\e[0m"
