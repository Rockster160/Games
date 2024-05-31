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

SVG.register(:spiral) do |svg, attrs|
  center_x = svg.width/2
  center_y = svg.height/2
  max_rev = attrs.delete(:max_rev) || 10
  progress = attrs.delete(:progress) || 1
  outer_radius = attrs.delete(:size) || [center_x, center_y].min

  # line_width = (max_radius/(max_rev+1).to_f)-1
  # padding = max_line_width
  # outer_radius = max_radius - padding
  # line_width = (outer_radius/max_rev.to_f)-1

  path = ["M#{center_x},#{center_y-outer_radius}"] # Starting at top-center
  (0..max_rev * 360).step(1).each do |angle|
    rotation = 90
    radians = (angle - rotation) * (Math::PI / 180)
    radius = outer_radius * (1 - (angle.to_f / (max_rev*360)))

    x = center_x + radius * Math.cos(radians)
    y = center_y + radius * Math.sin(radians)
    path << "L#{x},#{y} "

    break if angle.to_f > (progress*360)
  end
  path.join(" ")

  svg.path(path.join(" "), **attrs)
end

SVG.write(:svg, filename: "/Users/rocco/code/games/live_svg/file.svg") do |svg|
  svg.width = 400
  svg.height = 400
  # svg.fill = :black
  # svg.stroke = :none

  require "date"
  goal = 1000
  current = goal-740
  done_today = 30
  needed_today = 41

  now = Time.now
  morning = Time.new(now.year, now.month, now.day, 9).to_i
  tonight = Time.new(now.year, now.month, now.day, 18).to_i
  today_progress = ((now.to_i - morning) / (tonight - morning).to_f).clamp(0, 1)
  today_goal_progress = done_today/needed_today.to_f

  today = Date.today
  days_in_month = Date.new(today.year, today.month, -1).day
  month_progress = today.day/days_in_month.to_f
  month_goal_progress = current/goal.to_f

  center_x = svg.width/2
  center_y = svg.height/2
  max_radius = [center_x, center_y].min

  blue = "#0160FF"
  orange = "#FFA001"

  rings = 10
  full_line_width = ([center_x, center_y].min/(rings+1).to_f)-1 # 18.18
  big_circle = max_radius - full_line_width
  small_circle = max_radius - ((full_line_width+1)*2)

  svg.spiral(progress: today_goal_progress, max_rev: rings, size: big_circle, stroke_width: full_line_width, stroke: blue)
  svg.spiral(progress: today_progress, max_rev: rings, size: big_circle, stroke_width: 5, stroke: orange)

  svg.spiral(progress: month_goal_progress, max_rev: rings, size: small_circle, stroke_width: full_line_width, stroke: "rgba(150, 10, 50, 0.5)")
  svg.spiral(progress: month_progress, max_rev: rings, size: small_circle, stroke_width: 5, stroke: "rgba(240, 100, 50, 0.5)")

  # svg.spiral(progress: rand*10, max_rev: rings)
  svg.text(done_today, "50%", "50%", **{
    stroke: blue, fill: blue,
    text_anchor: :middle, dominant_baseline: :middle,
    font_size: 100, font_family: :Arial
  })
end
