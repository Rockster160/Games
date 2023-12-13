class Line
  def self.to_coord(coord)
    x1, y1 ,x2, y2 = 0, 0, *coord
    between(x1, y1 ,x2, y2)
  end

  def self.between(x1, y1, x2, y2)
    points = []
    steep = ((y2-y1).abs) > ((x2-x1).abs)

    x1,y1,x2,y2 = y1,x1,y2,x2 if steep
    x1,x2,y1,y2 = x2,x1,y2,y1 if x1 > x2

    deltax = x2-x1
    deltay = (y2-y1).abs
    error = (deltax / 2).to_i
    ystep = y1 < y2 ? 1 : -1
    y = y1

    (x1..x2).each do |x|
      points << (steep ? [y,x] : [x,y])
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end

    points
  end
end
