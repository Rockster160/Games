require "/Users/rocco/code/games/kata/test_framework.rb"
require "pry-rails"

@goods = {
  Hobbits: 1,
  Men:     2,
  Elves:   3,
  Dwarves: 3,
  Eagles:  4,
  Wizards: 10,
}
@evils = {
  "Orcs":     1,
  "Men":      2,
  "Wargs":    2,
  "Goblins":  2,
  "Uruk Hai": 3,
  "Trolls":   5,
  "Wizards": 10,
}

def good_vs_evil(good, evil)
  gp = good.split(" ").map.with_index { |count, idx| count.to_i * @goods[@goods.keys[idx]] }.sum
  ep = evil.split(" ").map.with_index { |count, idx| count.to_i * @evils[@evils.keys[idx]] }.sum

  return "Battle Result: No victor on this battle field" if gp == ep
  return "Battle Result: Evil eradicates all trace of Good" if ep > gp
  return "Battle Result: Good triumphs over Evil" if gp > ep
end

Test.assert_equals(good_vs_evil('1 0 0 0 0 0', '1 0 0 0 0 0 0'), 'Battle Result: No victor on this battle field', 'Should be a tie' )
Test.assert_equals(good_vs_evil('0 0 0 0 0 10', '0 1 1 1 1 0 0'), 'Battle Result: Good triumphs over Evil', 'Good should triumph' )
Test.assert_equals(good_vs_evil('0 0 0 0 0 10', '0 1 1 1 1 0 0'), 'Battle Result: Good triumphs over Evil', 'Good should triumph' )
