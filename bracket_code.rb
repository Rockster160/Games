# # Bracket Code
#
# The task is to implement an evaluator for a domain specific language we'll call "bracket code". It should take a string and return a number or somehow represent that the string is malformed, either by crashing or return a non-number value.
#
# All functions in bracket code take two arguments, and an expression is either:
# - A number, which is just a literal
# - func[X:Y], where X and Y are expressions
#
# There is a special anonymous function, [X:Y], which represents addition.
#
# You should implement the evaluator such that it can evaluate normal expressions plus the following functions:
# - sub (subtraction)
# - mul (multiplication)
# - div (division)
# - pow (exponentiation)
# - equal
#
# Some examples:
#
# `[ 1 : 2 ]` = 3
# `mul [ 2 : 4 ]` = 8
# `div [ pow [ 3 : 5 ] : 9 ]` = 27

require "pry-rails"

input = ARGV[0].dup

def bracket_code(str)
  str.gsub!(/\s/, "")

  expressions = { sub: :-, mul: :*, div: :/, pow: :**, equal: :== }

  loop do
    break unless str.match?(/(\w+)?\[([^\[\]]+):([^\[\]]+)\]/)

    str.gsub!(/(\w+)?\[([^\[\]]+):([^\[\]]+)\]/) do
      _, bracket, arg1, arg2 = Regexp.last_match.to_a
      operation = expressions[bracket&.to_sym]
      "(#{arg1}#{operation || :+}#{arg2})"
    end
  end
  eval(str)
end


# bracket_code(input)

tests = [
  "`[ 1 : 2 ]` = 3",
  "`mul [ 2 : 4 ]` = 8",
  "`div [ pow [ 3 : 5 ] : 9 ]` = 27",
  "`div [ pow [ 3 : 5 ] : 9 ]` = 27",
]

tests.each do |exp|
  bracket = exp[/\`.*?\`/][1..-2]
  answer = exp[/ = \d+$/][3..]

  check = bracket_code(bracket) == answer.to_i
  puts "\e[3#{check ? 2 : 1}m#{input} == #{answer}\e[0m"
end

puts bracket_code("equal [ div [ pow [ 3 : [ 5 : 2 ] ] : 9 ] : 243]")
puts bracket_code("equal [ div [ pow [ 3 : [ 5 : 2 ] ] : 9 ] : 243]")
