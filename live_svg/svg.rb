# svgwatcher /Users/rocco/code/games/live_svg/svg.rb
require "/Users/rocco/code/games/svg.rb"

# SVG
#   svg.g(**attrs, &block)
#   svg.path(d, **attrs, &block)
#   svg.text(str, x, y, **attrs, &block)
#   svg.rect(x, y, width, height, **attrs, &block)
#   svg.point(x, y, r=1, **attrs, &block)
#   svg.circle(x, y, r, **attrs, &block)
#   svg.line(x1, y1, x2, y2, **attrs, &block)
#   svg.ellipse(cx, cy, rx, ry, r, **attrs, &block)
#   svg.polyline(*points, **attrs, &block)
#   svg.polygon(*points, **attrs, &block)
#   svg.item(tag, **attrs, &block)

SVG.register(:dot) do |svg, x, y|
  svg.circle(x, y, 3)
end
SVG.register(:linepath) do |svg, *pieces|
  svg.path(pieces.join(" "))
end

SVG.write(:svg, filename: "/Users/rocco/code/games/live_svg/file.svg") do |svg|
  coin_dia = 100
  coin_r = coin_dia/2
  svg.width = coin_dia
  svg.height = coin_dia
  # svg.stroke_width = 3

  svg.circle("")

  # svg.circle(coin_r, coin_r, coin_r-1, stroke: :lightgrey, stroke_width: 1)

  # svg.dot(42, 50)
  # svg.dot(57, 50)
  #
  # svg.dot(42, 35)
  # svg.dot(57, 35)
  #
  # svg.dot(42, 65)
  # svg.dot(57, 65)

  # rcircle = "a 3,-3 1,0,0 6,0 a 3,-3 1,0,0 -6,0"
  #
  # svg.dot(42, 85)
  # svg.dot(57, 85)
  # svg.path("
  #   M 57,83
  #   l 0,-18 -5,-5 0,-10 5,-5 0,-20 8,-8
  #   m 0,-2 #{rcircle}
  # ")
  # svg.path("
  #   M 57,75
  #   l 5,-5 0,-8 -5,-5 0,-5 5,-5 0,-4 4,-4
  #   m 0,-2 #{rcircle}
  # ")
  # svg.path("
  #   M 57,37
  #   l 18,-18 q 0,-1 0,10
  #   l 10,10 0,10 3,0
  #   m 0,0 #{rcircle}
  # ")
  # svg.dot(65, 55)
  # svg.path("
  #   M 67,57
  #   l 10,10
  #   m 0,2.5 #{rcircle}
  # ")
  # svg.linepath(:M, 57,83, :L, 57,65, 51,60, )
  # svg.line(57,83, 57,65)
end
