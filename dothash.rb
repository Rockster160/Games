require "/Users/rocco/code/games/tools"
#
# json = {
#   a: {
#     b: {
#       c: [1, 2, 3],
#       d: [3, 4, 5]
#     },
#     blank: nil,
#     val: false,
#     some: true,
#     e: :f,
#     g: [
#       {
#         h: 5,
#         i: 9,
#         j: [0]
#       }
#     ]
#   }
# }
# d = Tools.to_dot(json)
#
# puts "d.keys: #{d.keys}"
# puts "d.a.keys: #{d.a.keys}"
# puts "Branches: #{d.branches.transform_keys(&:to_s)}"
#
# expected = {
#   "a.b.c": [1, 2, 3],
#   "a.b.d": [3, 4, 5],
#   "a.blank": nil,
#   "a.val": false,
#   "a.some": true,
#   "a.e": "f",
#   "a.g.0.h": 5,
#   "a.g.0.i": 9,
#   "a.g.0.j": [0],
# }
#
# puts "Expected: #{expected.transform_keys(&:to_s)}"
# puts d.transform_keys(&:to_s) == expected.transform_keys(&:to_s) ? "\e[32mSuccess!\e[0m" : "\e[31mFailure...\e[0m"
# pp d.branches

Tools.branches({ a: nil, b: [1, 2, 3], c: { e: :f, g: [:a2, :b2, :c2], h: {a3: 1, b3: 2, c3: 3} }, d: 1 })
