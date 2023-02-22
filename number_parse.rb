require "rspec"
require "pry-rails"

def big_nums
  {
    trillion:  1000000000000,
    billion:   1000000000,
    million:   1000000,
    thousand:  1000,
    hundred:   100,
  }
end

def small_nums
  {
    **tens,
    **teens,
    **ones,
  }
end

def tens
  {
    ninety:    90,
    eighty:    80,
    seventy:   70,
    sixty:     60,
    fifty:     50,
    forty:     40,
    thirty:    30,
    twenty:    20,
  }
end

def teens
  {
    nineteen:  19,
    eighteen:  18,
    seventeen: 17,
    sixteen:   16,
    fifteen:   15,
    fourteen:  14,
    thirteen:  13,
    twelve:    12,
    eleven:    11,
    ten:       10,
  }
end

def ones
  {
    nine:      9,
    eight:     8,
    seven:     7,
    six:       6,
    five:      5,
    four:      4,
    three:     3,
    two:       2,
    one:       1,
    zero:      0,
  }
end

def all_nums
  {
    **big_nums,
    **tens,
    **teens,
    **ones,
  }
end

def reg_or(*num_data)
  num_data.flatten.map { |d| d.is_a?(Hash) ? d.keys : d }.flatten.join("|")
end

def log10(num)
  Math.log10(num)
end
def power10?(num)
  return true if num.zero?
  l = log10(num)
  l == l.round
end

def parseNum(words)
  mem = 0
  ans = 0
  words.split(/ +/).each { |word|
    num = all_nums[word.to_sym]
    next if num.nil?
    # Mem just stores the previous number in case we need to do multiply logic to it without
    #   affecting the rest of the `ans`.
    # If we hit a zero, it means the mem doesn't need to do anything and we have nothing to add.
    # In this case, just reset mem and move on.
    next mem = num if mem == 0

    # If the num is a large num/power of 10 (million, thousand, etc...) then we multiply with num
    # "two hundred"
    # mem = 2
    # num = 100
    # 2 * 100 = 200
    if num > 100 && big_nums.value?(num)
      # Add the multiplied value to our final num, then reset our mem
      ans += (mem * num)
      next mem = 0
    end

    # If num is 100, multiple num like the big nums above, but don't reset mem
    # Otherwise add (40 + 6)
    num == 100 ? mem *= num : mem += num
  }
  ans + mem
end

def words_to_nums(str)
  str.gsub(/(\ba )?\b(#{reg_or(all_nums)})([ -]?(#{reg_or(all_nums, :and, :a)}))*\b/) do |found|
    # Clean up
    found.gsub!(/\ba (#{reg_or(big_nums)})/, 'one \1') # Replace "a" with "one"
    found.gsub!(/(#{reg_or(big_nums)}) and (#{reg_or(small_nums)})/, '\1 \2') # Remove "and" between big->small
    found.gsub!(/(#{reg_or(all_nums)}) ?- ?(#{reg_or(all_nums)})/, '\1 \2') # Remove "-" between any
    # Split different chunks of numbers
    found.gsub!(/(#{reg_or(ones, teens)}) (#{reg_or(small_nums)})/, '\1 | \2')
    found.gsub!(/(#{reg_or(tens)}) (#{reg_or(teens, tens)})/, '\1 | \2')
    found.gsub!(/(#{reg_or(tens)}) (hundred)/, '\1 | \2')
    found.gsub!(/(#{reg_or(all_nums)}) (\1)/, '\1 | \2')
    found.gsub!(/(#{reg_or(all_nums)}) and (#{reg_or(all_nums)})/, '\1 | and | \2')
    found.gsub!(/(#{reg_or(all_nums)}) and\b/, '\1 | and')
    found.gsub!(/\band (#{reg_or(all_nums)})/, 'and | \1')
    big_nums.keys.each_with_index do |num_name, idx|
      next if num_name == :hundred # Nothing under hundred to check
      # Replace any big nums followed by a smaller (million thousand is bad, but thousand million is fine)
      found.gsub!(/(#{num_name}) (#{reg_or(big_nums.keys[(idx+1)..-1])})/, '\1 | \2')
    end

    # Split the separate words and parse each one
    found.split(" | ").map { |num|
      if num.match?(/(#{reg_or(all_nums)})/)
        parseNum(num)
      else
        num
      end
    }.join(" ")
  end
end
s.split(/\-| and | /)
(s.split(" ")-["and"])

RSpec.describe do
  context "when passed numbers" do
    specify { expect(words_to_nums("thousand million")).to eq("1000000000") }
    specify { expect(words_to_nums("nineteen thousand")).to eq("19000") }
    specify { expect(words_to_nums("nineteen hundred")).to eq("1900") }
    specify { expect(words_to_nums("ninety thousand")).to eq("90000") }
    specify { expect(words_to_nums("a thousand")).to eq("1000") }
    specify { expect(words_to_nums("three hundred and sixty four billion eight hundred and ninety five million and four hundred and fifty seven thousand eight hundred and ninety eight")).to eq("364895457898") }
    specify { expect(words_to_nums("hundred thousand")).to eq("100000") }
    specify { expect(words_to_nums("one hundred twelve")).to eq("112") }
    specify { expect(words_to_nums("one hundred and twelve")).to eq("112") }
    specify { expect(words_to_nums("seventy-two")).to eq("72") }
    specify { expect(words_to_nums("seven million four hundred fifty-six thousand one hundred twenty-three")).to eq("7456123") }
    specify { expect(words_to_nums("three million two hundred and six")).to eq("3000206") }
    specify { expect(words_to_nums("eighteen hundred")).to eq("1800") }
    specify { expect(words_to_nums("thousand one")).to eq("1001") }
  end

  context "when passed incompatible numbers" do
    specify { expect(words_to_nums("ninety seventeen")).to eq("90 17") }
    specify { expect(words_to_nums("ninety hundred")).to eq("90 100") }
    specify { expect(words_to_nums("one and three")).to eq("1 and 3") }
    specify { expect(words_to_nums("thousand hundred")).to eq("1000 100") }
    specify { expect(words_to_nums("hundred hundred")).to eq("100 100") }
    specify { expect(words_to_nums("one two")).to eq("1 2") }
    specify { expect(words_to_nums("seven hundred and twenty one four")).to eq("721 4") }
  end

  context "when passed numbers and words" do
    specify { expect(words_to_nums("I am twenty-nine")).to eq("I am 29") }
    specify { expect(words_to_nums("My kids are one three and six")).to eq("My kids are 1 3 and 6") }
    specify { expect(words_to_nums("Take the fifteen and turn right")).to eq("Take the 15 and turn right") }
    specify { expect(words_to_nums("This sentence doesn't have numbers")).to eq("This sentence doesn't have numbers") }
  end
end

puts words_to_nums("99% of the time the number is <10, so it would be easy to just do a direct replace, but now I can take three hundred and sixty four billion eight hundred and ninety five million and four hundred and fifty seven thousand eight hundred and ninety eight and convert it to 364895457898 even if it's in the middle of a sentence!")
#
# if ARGV[0] != 'four_is_magic.rb'
#   do_magic(ARGV[0])
# end
