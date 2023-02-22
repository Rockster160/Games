filename = "recordings_data"
[
  :id,
  :day,
  :data
]

data = [
  { id: 1, day: "Tue, 30 Mar 2021", data: 19 },
  { id: 2, day: "Wed, 31 Mar 2021", data: 6 },
  { id: 3, day: "Thu, 01 Apr 2021", data: 17 },
  { id: 4, day: "Fri, 02 Apr 2021", data: 0 },
  { id: 5, day: "Sat, 03 Apr 2021", data: 9 },
  { id: 6, day: "Sun, 04 Apr 2021", data: 3 },
  { id: 7, day: "Mon, 05 Apr 2021", data: 14 },
  { id: 8, day: "Tue, 06 Apr 2021", data: 15 },
  { id: 9, day: "Wed, 07 Apr 2021", data: 2 },
  { id: 10, day: "Thu, 08 Apr 2021", data: 18 },
  { id: 11, day: "Fri, 09 Apr 2021", data: 18 },
  { id: 12, day: "Sat, 10 Apr 2021", data: 7 },
  { id: 13, day: "Sun, 11 Apr 2021", data: 0 },
  { id: 14, day: "Mon, 12 Apr 2021", data: 2 },
  { id: 15, day: "Tue, 13 Apr 2021", data: 1 },
  { id: 16, day: "Wed, 14 Apr 2021", data: 11 },
  { id: 17, day: "Thu, 15 Apr 2021", data: 10 },
  { id: 18, day: "Fri, 16 Apr 2021", data: 0 },
  { id: 19, day: "Sat, 17 Apr 2021", data: 15 },
  { id: 20, day: "Sun, 18 Apr 2021", data: 16 },
  { id: 21, day: "Mon, 19 Apr 2021", data: 17 },
  { id: 22, day: "Tue, 20 Apr 2021", data: 2 },
]

class SVG
  attr_accessor :graphics, :width, :height

  def initialize(opts={})
    @filename = opts[:filename]
    @graphics = []
    @width = opts[:width] || 0
    @height = opts[:height] || 0
  end

  def circle(opts)
    @graphics << Graphic.new(:circle, opts)
  end

  def draw
    @graphics.each do |graphic|
      @width = graphic.opts[:cx] if graphic.opts[:cx].present? && graphic.opts[:cx] > @width
      @height = graphic.opts[:cy] if graphic.opts[:cy].present? && graphic.opts[:cy] > @height
    end
    viewBox="-50 -50 #{@width + 50} #{@height + 50}"

    File.open("#{@filename}.svg", "w") do |file|
      file.puts("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"#{viewBox}\" style=\"background: #FAFAFA;\">")
      @graphics.each do |graphic|
        file.puts(graphic.draw)
      end
      file.puts('</svg>')
    end
  end

  def open
    `open -a 'Google Chrome' #{@filename}.svg`
  end

  class Graphic
    attr_accessor :tag, :opts

    def initialize tag, opts
      @tag = tag
      @opts = opts
    end

    def draw
      opts_str = @opts.map do |k, v|
        "#{k}=\"#{v}\""
      end.join(" ")

      "<#{@tag} #{opts_str} />"
    end
  end
end

# Group the data by day, then by value
grouped_data = crsd.each_with_object({}) do |p, obj|
  id, day, num = p.values

  obj[day] ||= { yes: [], no: [] }
  if p[:lead_id].present?
    obj[day][:yes] << p
  else
    obj[day][:no] << p
  end
end


first_day = Date.parse("Thu, 24 Aug 2017")

svg = SVG.new(filename: filename)
svg.graphics << SVG::Graphic.new(:rect, x: 0, y: -50, width: 1300, height: 50, stroke: :black, fill: :none)
grouped_data.each do |day, daydata|
  title = "#{day}\n"
  title += "Lead present: #{daydata[:yes].count} | "
  title += "NO Lead: #{daydata[:no].count}\n"

  x = (day - first_day).to_i
  ycount = daydata[:yes].count
  ncount = daydata[:no].count
  tcount = ycount + ncount

  svg.circle(title: title, cx: x, cy: -(ycount / tcount.to_f)*50, r: 0.5, stroke: :green)
  # svg.circle(title: title, cx: x, cy: -(ncount / tcount.to_f)*50, r: 0.6, stroke: :red)
end
svg.draw
svg.open


# "<circle title='#{}' />"
