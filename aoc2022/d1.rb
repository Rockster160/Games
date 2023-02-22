input = File.read("/Users/rocco/code/games/aoc2022/d1.txt")
elves = input.split("\n\n").map { |elf| elf.split("\n").map(&:to_i) }

# Part 1 - find the elf with the most calories and report how many they had
puts elves.map(&:sum).max

# Part 2 - find the top 3 elves with the most calories and report how many they had all together
puts elves.map(&:sum).sort.last(3).sum
