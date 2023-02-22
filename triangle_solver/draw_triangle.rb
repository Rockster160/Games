module DrawTriangle
  extend TriangleHelpers
  extend Angle
  module_function

  def table(triangle)
    tridata = triangle.to_json
    format = Proc.new { |let|
      if let.to_s.downcase == let.to_s # side
        "#{let} #{tridata[let]&.round(1) || "?"}"
      else # ang
        "#{let} #{tridata[let]&.round(1) || "?"}°"
      end
    }

    [[:a, :A], [:b, :B], [:c, :C]].each_with_object([]) do |(side, ang), table|
      table << [format[side], format[ang]]
    end.tap { |table|
      Draw.draw_table(table) do |pencil|
        pencil.fg = :cyan

        pencil.sprite("?", "?", :red)
        pencil.sprite("?°", "?°", :red)

        triangle.given.each do |k, v|
          pencil.sprite(format[k], format[k], :grey)
        end

        get_mismatches(triangle.solution, tridata)&.tap { |bads|
          print "\a"
          bads.each do |badsym, badval|
            pencil.sprite(format[badsym], format[badsym], :red)
          end
        }
      end
    }
  end

  def svg(triangle, order: [:A, :B, :C]) # Order is clockwise starting at bottom left
    tridata = triangle.to_json

    svg = SVG.new(:svg) do |svg|
      sides = tridata.slice(:a, :b, :c).values
      s = Proc.new { |v| scale_map(v, 0, sides.max, 0, 100) }
      toside = Proc.new { |sym| sym.to_s.downcase.to_sym }

      point_hash = order.each_with_object({}).with_index { |(ang_sym, obj), idx|
        obj[ang_sym] = case idx
        when 0
          Coord.new(0, 0)
        when 1
          ang, mag = d2r(tridata[order[0]]), s[tridata[toside[order[2]]]]
          Coord.new(Math.cos(ang) * mag, -Math.sin(ang) * mag)
        when 2
          Coord.new(s[tridata[toside[order[1]]]], 0)
        end
      }

      points = []
      order.each_with_index { |ang, idx|
        point = point_hash[ang]
        color, seg = {
          A: ["#0160FF", :BC],
          B: [:green,    :AC],
          C: [:orange,   :AB],
        }[ang]
        point.color = color
        p1, p2 = seg.to_s.chars.map { |l| point_hash[l.to_sym] }
        text_attrs = { font_size: 5, stroke: :none, fill: color }

        # Angle Label
        svg.text(
          "#{ang} #{tridata[ang].round(2)}°",
          point.x + [-2, 0, 2][idx],
          point.y + [2, -2, 2][idx],
          **text_attrs,
          text_anchor: [:end, :middle, :start][idx],
        )

        # Side Label
        midpoint = Coord.new((p1.x+p2.x)/2, (p1.y+p2.y)/2)
        side = ang.to_s.downcase.to_sym
        svg.text(
          "#{side} #{tridata[side].round(2)}",
          midpoint.x + [2, 0, -2][idx],
          midpoint.y + [0, 6, 0][idx],
          **text_attrs,
          text_anchor: [:start, :middle, :end][idx],
        )

        # Line
        svg.line(p1.x, p1.y, p2.x, p2.y, stroke: color, stroke_width: 0.5)

        # Point
        points << point
      }
      points.each do |point|
        svg.point(point.x, point.y, fill: point.color)
      end

      xr = point_hash.values.map(&:x)
      yr = point_hash.values.map(&:y)

      xpad = 30
      ypad = 20
      svg.minx = xr.min - xpad
      svg.miny = yr.min - ypad
      svg.width = (xr.max-xr.min) + xpad*2
      svg.height = (yr.max-yr.min) + ypad*2
      svg.font_family = :monospace
      svg.rect(svg.minx, svg.miny, svg.width, svg.height, stroke: :blue, stroke_width: 0.1)
    end
    # Write to file, if using live-watch, will auto-reload the preview
    File.open("/Users/rocco/code/games/live_svg/file.svg", "w") { |file| file.write(svg.to_svg) }
  end
end
