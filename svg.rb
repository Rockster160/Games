class SVG
  attr_accessor(
    :filename, :tag, :attrs,
    :minx, :miny, :width, :height,
    :items,
  )

  def self.open(tag, opts={}, &block)
    new(tag, opts, &block).open
  end

  def self.write(tag, opts={}, &block)
    new(tag, opts, &block).write
  end

  def self.register(method_name, &block)
    define_method(method_name) do |attrs|
      block.call(self, attrs)
    end
  end

  # Allows setting any attrs directly from the instance
  def method_missing(method, *args, &block)
    super unless method.to_s.end_with?("=")

    @attrs[method.to_s[0..-2].to_sym] = args.first
  end

  def initialize(tag, opts={}, &block)
    @attrs = opts[:attrs] || {}
    if tag == :svg
      # Use `self.` since it will auto set the `attr` as an ivar
      self.fill = :transparent
      self.stroke = :black
    end
    @tag = tag
    @filename = (opts[:filename] || :svg).to_s.gsub(/\.svg$/, "")
    @content = opts[:content]
    @minx, @miny, @width, @height = opts[:minx] || 0, opts[:miny] || 0, opts[:width] || 100, opts[:height] || 100
    @items = []

    block&.call(self)
  end

  def g(**attrs, &block)
    @items << SVG.new(:g, attrs: attrs, &block)
  end
  def path(d, **attrs, &block)
    @items << SVG.new(:path, attrs: attrs.merge(d: d), &block)
  end
  def text(str, x, y, **attrs, &block) # https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text
    escaped = str.to_s.gsub("<", "&lt;").gsub(">", "&gt;")
    @items << SVG.new(:text, attrs: attrs.merge(x: x, y: y), content: escaped, &block)
  end
  def rect(x, y, width, height, **attrs, &block)
    @items << SVG.new(:rect, attrs: attrs.merge(x: x, y: y, width: width, height: height), &block)
  end
  # TODO: Should be able to add custom methods on the fly?
  def point(x, y, r=1, **attrs, &block)
    attrs[:fill] ||= @stroke || :black
    attrs[:stroke] ||= @fill || :none
    @items << SVG.new(:circle, attrs: attrs.merge(cx: x, cy: y, r: r), &block)
  end
  def circle(x, y, r, **attrs, &block)
    @items << SVG.new(:circle, attrs: attrs.merge(cx: x, cy: y, r: r), &block)
  end
  def line(x1, y1, x2, y2, **attrs, &block)
    @items << SVG.new(:line, attrs: attrs.merge(x1: x1, y1: y1, x2: x2, y2: y2), &block)
  end
  def ellipse(cx, cy, rx, ry, r, **attrs, &block)
    @items << SVG.new(:ellipse, attrs: attrs.merge(cx: cx, cy: cy, rx: rx, ry: ry), &block)
  end
  def polyline(*points, **attrs, &block)
    @items << SVG.new(:polyline, attrs: attrs.merge(points: points), &block)
  end
  def polygon(*points, **attrs, &block)
    @items << SVG.new(:polygon, attrs: attrs.merge(points: points), &block)
  end
  def item(tag, **attrs, &block)
    @items << SVG.new(tag, attrs: attr, &block)
  end
  # <animate attributeName="|" attributeType="" begin="0" end="" from="" to="" dur="" repeatCount="" fill=""/>

  def grid(minx=@minx, miny=@miny, width=@width, height=@height, **attrs, &block)
    spacing = attrs.delete(:spacing) || 10
    hardgrid = attrs.delete(:hardgrid) || 100
    softcolor = attrs.delete(:softcolor) || :lightgrey
    hardcolor = attrs.delete(:hardcolor) || :grey
    attrs[:stroke_width] ||= 0.1

    startx = (minx/spacing.to_f).floor*spacing
    endx = ((minx+width)/spacing.to_f).ceil*spacing
    starty = (miny/spacing.to_f).floor*spacing
    endy = ((miny+height)/spacing.to_f).ceil*spacing

    @items.prepend(SVG.new(:g, attrs: attrs) do |g|
      startx.step(endx, spacing).each_with_index do |ox, xidx|
        starty.step(endy, spacing).each_with_index do |oy, yidx|
          xcolor = ox % hardgrid == 0 ? hardcolor : softcolor
          g.line(ox, miny, ox, miny+height, stroke: xcolor)

          ycolor = oy % hardgrid == 0 ? hardcolor : softcolor
          g.line(minx, oy, minx+width, oy, stroke: ycolor)
        end
      end
    end)
  end

  def html_tag(tag, n, **attrs, &block)
    # TODO: Need to escape attr vals, in case they have quotes in them
    attr_str = attrs.map { |k,v| "#{k}=\"#{v}\"" }.join(" ")
    content = block&.call
    no_content = content.gsub(/\s/, "").length == 0
    # content.gsub(/\s/, "").length == 0 ? "" : "\n  #{content}\n"
    if no_content
      "<#{tag} #{attr_str} />"
    else
      "<#{tag} #{attr_str}>\n#{content}\n#{"  "*n}</#{tag}>"
    end
  end

  def to_svg(n=0)
    if @tag == :svg
      @attrs = {
        xmlns: "http://www.w3.org/2000/svg",
        viewBox: [@minx, @miny, @width, @height].join(" "),
      }.merge(@attrs)
    end
    @attrs = @attrs.transform_keys { |sym| sym.to_s.split("_").join("-") }

    html_tag(@tag, n, **@attrs) {
      [@content, *items.map { |i| i.to_svg(n+1) }].filter_map { |i|
        next if i.to_s.gsub(/\s/, "").length == 0
        "#{"  "*(n+1)}#{i}"
      }.join("\n")
    }
  end

  def write
    File.open("#{@filename}.svg", "w") { |file| file.write(to_svg) }
  end

  def open
    write
    `open -a Safari '#{@filename}.svg' && sleep 1 && rm '#{@filename}.svg'`
  end
end

# SVG.open(:svg) do |svg| - alternative syntax. Automatically opens the SVG after creation.
# SVG.new(:svg) do |svg|
#   minx = -5
#   miny = -105
#   width = 110
#   height = 110
#
#   svg.minx = -5
#   svg.miny = -105
#   svg.width = 110
#   svg.height = 110
#
#   svg.circle(5, -5, 5)
#   svg.grid(svg.minx, svg.miny, svg.width, svg.height)
# end

# SVG.new(:svg, filename: "my svg") do |svg|
#   svg.stroke = "black"
#   svg.fill = "transparent"
#   svg.g(id: "sup") do |g|
#     g.rect(5, 5, 90, 90)
#     g.text("Words", 10, 5)
#     g.rect(0, 0, 50, 50)
#     g.g do |g|
#       g.text("More Words", 5, 20)
#     end
#   end
# end
