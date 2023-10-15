chord = (ARGV[0] || 5).to_i # Distance between two far outer points
# Area = 7.757
# edge = 3.09 # Distance between two near outer points
# short_chord = 1.18 # Inner pentagon side length
# long_chord = 1.91 # distance between outer point and inner pentagon
# perimeter = 19.098

require "pry-rails"
require "/Users/rocco/code/games/triangle_solver/triangle.rb"

def pi = Math::PI
def tan(n) = Math.tan(n * (pi/180))
def inner_angles(n_sides) = ((n_sides - 2) * 180) / n_sides.to_f

pentagram_point = 36
pentagon_inner_angle = inner_angles(5) # 108
pent_half_angle = pentagon_inner_angle/2 # 54


edge = Triangle.solve(a: chord, b: chord, C: pentagram_point)[:c] # 3.0902
# 2a + b = chord
# a + b = edge
# a + a + b = chord
# a + edge = chord
a = chord - edge # 1.9098
b = chord - (2*a) # 1.1803
long_chord = a # 1.9098
short_chord = b # 1.1803

pentagon_inner_triangles = Triangle.new(c: short_chord, A: pent_half_angle, B: pent_half_angle)
pentagon_area = pentagon_inner_triangles.area * 5 # 2.39697

outer_tri = Triangle.new(C: pentagram_point, a: long_chord, b: long_chord)
pentagram_area = (outer_tri.area*5) + pentagon_area # 7.7567675

puts "Area: #{pentagram_area}"


## The below is close, but sliiiiightly off.

# edge = Triangle.new(a: chord, b: chord, C: pentagram_point).sides[:c] # 3.0902
# height = Triangle.new(a: edge/2, c: chord, C: 90).sides[:b] # 4.755
# apothem = Triangle.new(a: height/2, b: chord/2, C: pentagram_point/2).sides[:c] # 0.7798 (pentagon mid to middle of edge)
# # pentagon_height = apothem*2
#
# half_pentagon_side = Triangle.new(a: apothem, A: pent_half_angle, B: 90).sides[:c]
# short_chord = pentagon_side = 2*half_pentagon_side # 1.331
# b = short_chord
# long_chord = (chord - short_chord) / 2 # 1.9334
# a = long_chord
# pent_inner_tri = Triangle.new(c: pentagon_side, A: pent_half_angle, B: pent_half_angle)
# pentagon_area = pent_inner_tri.area * 5 # 2.209
#
# mini_tri = Triangle.new(a: long_chord, b: long_chord, A: pent_half_angle)
# mini_tri_area = mini_tri.area # 1.7776
#
# pentagram_area = (mini_tri_area*5) + pentagon_area
#
# puts "Area: #{pentagram_area}"
