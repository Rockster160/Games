require "json"

class Cell
  attr_accessor :body, :alive, :matches

  def initialize(life, body=nil)
    @alive = ["t", "true", "1"].include?(life.to_s)
    @body = (body || life).to_s[0]
  end

  def match!
    @matches = true
  end

  def alive?
    alive == true
  end

  def to_s
    text = alive ? "92" : "37"
    text = "31" if @matches
    color = alive ? "\e[42;#{text}m" : "\e[107;#{text}m"

    "#{color}#{@alive || @matches ? '[]' : '  '}\e[0m"
  end
end

class MultiDimArr < Array
  def initialize(grid)
    new_grid = grid.map.with_index do |row, row_idx|
      row = row.split("") if row.is_a?(String)

      row.map.with_index do |cell_str, cell_idx|
        Cell.new(cell_str)
      end
    end
    super(new_grid)
  end

  def [](x, y=nil)
    return if x < 0 || x > rows.length - 1
    return rows[x] if y.nil?
    return if y < 0 || y > rows.length - 1

    rows[y][x]
  end

  def rows
    self.to_a
  end

  def compare(grid2)
    match = 0
    total = 0

    g2_rows = grid2.rows
    rows.each_with_index do |row, row_idx|
      row.each_with_index do |cell, cell_idx|
        total += 1
        match += 1 if cell.alive? == grid2[cell_idx, row_idx].alive?
      end
    end

    ((match / total.to_f) * 100).round
  end

  def ==(grid2)
    g2_rows = grid2.rows
    rows.map.with_index do |row, idx|
      row.map(&:alive?) == g2_rows[idx].map(&:alive?)
    end.all?
  end

  def draw
    map { |row| row.map { |cell| cell.to_s }.join('') }.join("\n")
  end
end

class MxGrid
  def self.brute_force_match(expected)
    control = MultiDimArr.new(expected)
    width = control.length

    (0..("1"*width).to_i(2)).each do |ruleset|
      rules = ruleset.to_s(2).rjust(width, "0").split("").map(&:to_i)
      test_grid = MxGrid.new(width).generate(rules)
      comparison = control.compare(test_grid)

      break rules if comparison.to_i >= 100
    end
  end

  def self.solve(puzzle, rules)
    puzzle_json = JSON.parse(puzzle.gsub(/(\w)⇒/) { "\"#{$1}\": " })
    grid_size = puzzle_json["g"]
    x_start = puzzle_json["x"] - 1
    y_start = puzzle_json["y"] - 1
    size = puzzle_json["s"]

    grid = MxGrid.new(grid_size).generate(rules)
    binary = size.times.map do |t|
      grid[x_start, y_start + t].match!
      grid[x_start, y_start + t].alive? ? 1 : 0
    end.join("").reverse

    binary.to_i(2)
  end

  def initialize(size)
    @size = size
    head_row = Array.new(@size) { false }
    head_row[0] = true
    @grid = MultiDimArr.new([head_row])
  end

  def generate(rules)
    @size.times do |row_idx|
      next unless @grid[row_idx].nil?

      previous_row ||= @grid.rows.last
      row = @size.times.map do |cell_idx|
        parents_binary = [-1, 0, 1].map do |offset|
          next 0 if cell_idx + offset < 0 || cell_idx + offset > previous_row.length - 1
          parent = previous_row[cell_idx + offset]

          (parent != nil && parent.alive?) ? 1 : 0
        end

        Cell.new(rules[parents_binary.join("").to_i(2)] == 1)
      end
      @grid << row
      previous_row = row
    end

    @grid
  end
end

full_t = Time.now.to_f
rules = MxGrid.brute_force_match([
  %w(1 0 0 0 0 0 0 0),
  %w(1 0 1 1 1 1 1 1),
  %w(1 1 0 0 0 0 0 1),
  %w(0 1 0 1 1 1 0 1),
  %w(0 1 1 0 0 1 1 1),
  %w(0 0 1 0 0 0 0 1),
  %w(1 0 1 0 1 1 0 1),
  %w(1 1 1 1 0 1 1 1)
]) # [1, 0, 1, 0, 0, 1, 1, 0]

puzzles = [
  "{ g⇒8, x⇒2, y⇒3, s⇒5 }",
  "{ g⇒16, x⇒3, y⇒7, s⇒8 }",
  "{ g⇒32, x⇒12, y⇒21, s⇒7 }",
  "{ g⇒64, x⇒34, y⇒45, s⇒9 }",
  "{ g⇒128, x⇒81, y⇒100, s⇒14 }",
  "{ g⇒1024, x⇒32, y⇒920, s⇒42 }"
]

puzzles.each do |puzzle|
  t = Time.now.to_f
  solution = MxGrid.solve(puzzle, rules)
  puts "#{puzzle} = #{solution} -- #{(Time.now.to_f - t).round(3)}s"
end
puts "Total Duration: #{(Time.now.to_f - full_t).round(3)}s"
