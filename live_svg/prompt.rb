# svgwatcher /Users/rocco/code/games/live_svg/svg.rb
require "ruby-svg"

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

SVG.write(:svg, filename: "/Users/rocco/code/games/live_svg/file.svg") do |svg|
  coin_dia = 100
  coin_r = coin_dia/2
  svg.width = coin_dia
  svg.height = coin_dia

  svg.circle(coin_r, coin_r, coin_r-1, stroke: :lightgrey)

  svg.rect(coin_r/2, coin_r/2, coin_r, coin_r, rx: 2, stroke_width: 5)
  svg.path("M 35,40 L 45,50 L 35,60", stroke_width: 5)
  svg.path("M 50,60 L 65,60", stroke_width: 5)
end
