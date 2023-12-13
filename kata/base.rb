require "/Users/rocco/code/games/kata/test_framework.rb"
require "pry-rails"

def thing(a, b, c)
end

Test.assert_equals(thing(1, 2, 3), "Expected return", "Error message")
