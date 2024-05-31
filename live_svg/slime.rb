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

# SVG.register(:spiral) do |svg, attrs|
#   center_x = svg.width/2
#   center_y = svg.height/2
#   max_rev = attrs.delete(:max_rev) || 10
#   progress = attrs.delete(:progress) || 1
#   outer_radius = attrs.delete(:size) || [center_x, center_y].min
#
#   # line_width = (max_radius/(max_rev+1).to_f)-1
#   # padding = max_line_width
#   # outer_radius = max_radius - padding
#   # line_width = (outer_radius/max_rev.to_f)-1
#
#   path = ["M#{center_x},#{center_y-outer_radius}"] # Starting at top-center
#   (0..max_rev * 360).step(1).each do |angle|
#     rotation = 90
#     radians = (angle - rotation) * (Math::PI / 180)
#     radius = outer_radius * (1 - (angle.to_f / (max_rev*360)))
#
#     x = center_x + radius * Math.cos(radians)
#     y = center_y + radius * Math.sin(radians)
#     path << "L#{x},#{y} "
#
#     break if angle.to_f > (progress*360)
#   end
#   path.join(" ")
#
#   svg.path(path.join(" "), **attrs)
# end

SVG.register(:bezier) do |svg, attrs|
  p1, b1, b2, p2 = attrs.slice(:p1, :b1, :b2, :p2).values
  path = [:M, p1.join(","), :C, *[b1, b2, p2].map { |c| c.join(",") }]
  puts "\e[36m#{path.join(" ")}\e[0m"
  svg.path(path.join(" "), **attrs)

  svg.line(*p1, *b1, stroke: :cyan,  opacity: 0.6)
  svg.point(*b1,     fill:   :cyan,  opacity: 0.4)
  svg.point(*p1,     fill:   :blue,  opacity: 0.4)

  svg.line(*b2, *p2, stroke: :lime,  opacity: 0.6)
  svg.point(*b2,     fill:   :lime,  opacity: 0.4)
  svg.point(*p2,     fill:   :green, opacity: 0.4)
end

bw = true

SVG.write(:svg, filename: "/Users/rocco/code/games/live_svg/file.svg") do |svg|
  svg.width = 100
  svg.height = 100
  # svg.fill = :black
  # svg.stroke = :none

  svg.path("
    M 5 65
    C 0,110 100,110 95,65
    C 90,40 60,45 55,15
    C 53,5 47,5 45,15
    C 40,45 10,40 5,65
  Z", id: :slimeBody, **(bw ? { fill: :black, stroke: :none } : { stroke: "#0160FF", fill: "#0160FFAA" }))
  # svg.bezier(p1: [55,15], b1: [53,5], b2: [47,5], p2: [45,15])
  # svg.bezier(p1: [95,65], b1: [90,40], b2: [60,45], p2: [55,15])
  # svg.bezier(p1: [45,15], b1: [40,45], b2: [10,40], p2: [5,65])

  # smile: 15 away from each edge (of 90)
  svg.path("M 25,75 C 30,90 70,90 75,75", id: :smile, stroke: bw ? :white : :red, stroke_width: 7, stroke_linecap: :round)
  # svg.bezier(p1: [25,75], b1: [30,90], b2: [70,90], p2: [75,75], stroke: :red, stroke_width: 7, stroke_linecap: :round)

  # eyes
  eye = ->(x) {
    svg.circle(x, 60, 8, stroke: :transparent, fill: :white)
    svg.circle(x, 60, 2.5, stroke: :transparent, fill: :black)
  }
  eye[37]
  eye[63]
end
