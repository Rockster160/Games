require "/Users/rocco/code/games/engine/draw.rb"
require "ruby-svg"

require_relative "triangle_helpers"
require_relative "draw_triangle"

class Triangle
  attr_accessor :sides, :angles, :given, :solution
  include Angle

  def self.format_args(args)
    args = args.first while args.is_a?(Array) && args.one?
    case args
    when Hash then args.each_with_object({}) { |(k,v),o| o[k.to_sym] = v.to_f }
    when Array then args.flatten.map { |a| format_args(a) }.inject(&:merge)
    when String
      args.split(" ").each_with_object({}) { |chunk, obj|
        chunk.split("=").tap { |k,v| obj[k.to_sym] = v.to_f }
      }
    else
      puts "\e[31m[LOGIT] | ERROR: Unknown class! [#{args.class}]#{args.inspect}\e[0m"
      binding.pry
    end
  end

  def self.render(*args)
    tri = new(*args)

    DrawTriangle.table(tri)
    DrawTriangle.svg(tri)
  end

  def self.solve(*args)
    new(*args).solve!
  end

  def initialize(*args)
    tridata = self.class.format_args(args)
    @solution = tridata&.length == 6 ? tridata : {}
    @given = tridata&.first(3)&.to_h
    raise "Triangle must have at least 3 inputs" unless @given.length == 3

    @sides = @given.slice(:a, :b, :c)
    @angles = @given.slice(:A, :B, :C).transform_keys(&:downcase)
    raise "Triangle must have at least 1 side" if @sides.length == 0

    # puts "\e[33m#{TriangleHelpers.json_to_input(@given)}\e[0m"
    # puts "\e[32m#{TriangleHelpers.json_to_input(@solution)}\e[0m" if @solution.present?

    solve!
  end

  def area
    solved = to_json
    (solved[:a] * solved[:b] * Math.sin(d2r(solved[:C]))) / 2.to_f
  end

  def solve!
    solve_angles_from_sides if @sides.count == 3
    2.times do # Twice since sometimes we need data we discover elsewhere
      find_angles_from_sum
      solve_sides
      solve_sides_from_angles
    end

    to_json
  end

  def solve_angles_from_sides
    a, b, c = [:a, :b, :c].map { |s| @sides[s] }

    @angles[:a] ||= r2d(Math.acos((c**2 + b**2 - a**2)/(2*c*b).to_f))
    @angles[:b] ||= r2d(Math.acos((a**2 + c**2 - b**2)/(2*a*c).to_f))
    @angles[:c] ||= r2d(Math.acos((a**2 + b**2 - c**2)/(2*a*b).to_f))
  end

  def solve_sides
    a, b, c = [:a, :b, :c].map { |s| @sides[s] }
    aa, ab, ac = [:a, :b, :c].map { |s| @angles[s] }

    @sides[:a] ||= Math.sqrt(c*c + b*b - (2*c*b*Math.cos(d2r(aa)))) if !a && [c, b, aa].all?
    @sides[:b] ||= Math.sqrt(a*a + c*c - (2*a*c*Math.cos(d2r(ab)))) if !b && [a, c, ab].all?
    @sides[:c] ||= Math.sqrt(a*a + b*b - (2*a*b*Math.cos(d2r(ac)))) if !c && [a, b, ac].all?
  end

  def find_angles_from_sum
    return unless @angles.count == 2

    @angles[:a] ||= 180 - @angles.values.sum
    @angles[:b] ||= 180 - @angles.values.sum
    @angles[:c] ||= 180 - @angles.values.sum
  end

  def solve_sides_from_angles
    ratio = sin_law([:a, :b, :c].find { |letter| @sides[letter] && @angles[letter] })
    return if ratio.nil?

    [:a, :b, :c].each do |letter|
      next if @sides[letter] && @angles[letter]

      @sides[letter] = Math.sin(d2r(@angles[letter])) / ratio if @angles[letter]
      @angles[letter] = r2d(Math.asin(@sides[letter] * ratio)) if @sides[letter]
    end
  end

  def sin_law(letter)
    Math.sin(d2r(@angles[letter])) / @sides[letter].to_f if letter
  end

  def cos_law(yc) # The letter matching the side you're solving for
    ya, yb = [:a, :b, :c] - [yc] # Letters
    sa, sb, sc = [ya, yb, yc].map { |sym| @sides[sym] } # Sides

    @sides[yc] = Math.sqrt(sa**2 + sb**2 - (2*sa*sb*Math.cos(d2r(@angles[yc])))) if sc.blank? && [sa, sb, @angles[yc]].all?
  end

  def to_json
    [:a, :b, :c].each_with_object({}) do |let, obj|
      obj[let] = @sides[let]
      obj[let.upcase] = @angles[let]
    end
  end
end

# test_triangles = [
#   nil,                                 # 0
#   { a: 8, b: 6, c: 7 },                # 1
#   { A: 46.8, B: 90, c: 172 },          # 2
#   { C: 46.8, A: 90, b: 172 },          # 3
#   { A: 60, B: 60, c: 100 },            # 4
#   { C: 90, A: 45, b: 50 },             # 5
#   { a: 27, A: 95, b: 16 },             # 6
#   { a: 270, A: 95, b: 160 },           # 7
#   { b: 258, c: 305, C: 81.2 },         # 8
#
#   {"b"=>210.0,"c"=>208.0,"A"=>7.95},   # 9 - string keys
#   { b: 210.0, c: 208.0, A: 7.95 },     # 10
#   "b=210.0 c=208.0 A=7.95",            # 11 - single string
#   ["b=210.0", "c=208.0", "A=7.95"],    # 12 - array of strings
#
#   "b=258 c=305 C=81.2",                # 13
#
#   {:A=>23.08, :a=>99.0, :C=>66.92,     # 14 - solution (with rounding error)
#     :b=>250.0, :c=>230.0, :B=>90.0},
#   ["A=31.9", "b=225.0", "C=82.2",       # 15 - solution (working)
#     "a=130.0", "B=66.0", "c=244.0"]
# ]


# Triangle.render(
#   [*ARGV].flatten.presence || test_triangles[15].presence || TriangleHelpers.random_triangle
# )
# [LOGIT] | {:A=>23.08, :a=>99.0, :C=>66.92}
# [LOGIT] | {:A=>23.08, :a=>99.0, :C=>66.92, :b=>250.0, :c=>230.0, :B=>90.0}


# [LOGIT] | {:b=>259.0, :a=>61.0, :A=>13.35}
# ┌─────────┬─────────┐
# │  a 61.0 │ A 13.4° │
# │ b 259.0 │ B 78.6° │
# │ c 264.0 │ C 88.0° │
# └─────────┴─────────┘
