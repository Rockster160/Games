Coord = Struct.new(:x, :y, :color)

class Object
  def present?
    respond_to?(:empty?) ? !empty? : !!self
  end
  def presence
    self if present?
  end
end

module Angle
  module_function

  def d2r(deg)
    deg * (Math::PI / 180)
  end

  def r2d(rad)
    rad / (Math::PI / 180)
  end
end

module TriangleHelpers
  include Angle
  module_function

  def random_triangle
    rawbody = `curl -s https://gardfish.com/random_triangle/`

    vals = rawbody.scan(/(?:Side|Angle) ([abcABC]) (?:has a length of|measures) (\d+.?\d*)/)
    json = vals.each_with_object({}) { |(let, num), obj| obj[let] = num.to_f }
  end

  def get_mismatches(solution, attempt)
    return if solution.none?

    solution, attempt = solution.transform_keys(&:to_sym), attempt.transform_keys(&:to_sym)
    [:a, :b, :c].each_with_object({}) { |let, bads|
      sol_s, sol_a = solution[let], solution[let.to_s.upcase.to_sym]
      att_s, att_a = attempt[let], attempt[let.to_s.upcase.to_sym]

      bads[let] = att_s unless (sol_s-1..sol_s+1).cover?(att_s)
      bads[let.to_s.upcase.to_sym] = att_a unless (sol_a-1..sol_a+1).cover?(att_a)
    }.compact.presence
  end

  def json_to_input(tridata)
    tridata.to_a.sort_by { |k,v| k }.to_h.transform_values { |v| v&.round(1) }.map { |k,v|
      "#{k}=#{v.round(1)}"
    }.join(" ")
  end

  def scale_map(value, fl, fh, tl, th)
    tr = th - tl
    fr = fh - fl

    (value - fl) * tr / fr.to_f + tl
  end
end
