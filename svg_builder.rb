require 'pry'
def svg_from_rand(total_points, method, *args)
  draw_svg(total_points.times.map { send(method, *args) })
end

def normal_distribution(min, max, height)
  distribution_times = height # This value is the multiple of how much more common the center is than the outsides
  # EG:
  # "1" height is an equal distribution. No Bias.
  # "2" (max - min) / 2 is 2x more likely than min or max
  # "3" (max - min) / 2 is 3x more likely than min or max

  rand_total = 0
  distribution_times.times {rand_total += rand(min + (max - min)) }
  rand_total / distribution_times
end
# Normal "bell curve" distribution

def normal_dist_with_bias(min, max, bias, weight=1)
  weighted_values = weight.times.map { rand * (max - min) + min }
  norm = weighted_values.min_by { |val| (val - bias).abs }
  mix = rand
  puts "\e[33m[LOGIT]#[#{weighted_values.map {|v|v.round(2)}.join(', ')}] min(#{norm.round(2)}) mix(#{mix.round(2)})\e[0m"
  puts "\e[33m[LOGIT]#((#{norm.round(2)} * (1 - #{mix.round(2)})) + (#{bias.round(2)} * #{mix.round(2)})).round\e[0m"
  ((norm * (1 - mix)) + (bias * mix)).round
end
# Normal distribution between numbers- but the crest is at the bias point
# normal_dist_with_bias(1, answer_count, answer_count, weight: 4)

def linear_skewed_distribution(min, max)
  # Max CAN be larger than min in order to get a positively skewed distribution
  ((rand - rand).abs * (1 + max - min) + min).floor
end
# min is linearly more likely than max

def print_vals(points, order=:val)
  points.each do |point_key, point_count|
    puts "#{point_key}: #{point_count}"
  end
end

def draw_svg(scores)
  points = scores.each_with_object(Hash.new(0)) { |score,score_count| score_count[score] += 1 }
  points = points.sort_by { |point_key, point_count| point_count }.reverse
  print_vals(points)
  min_score = points.map {|s,c|s}.min
  max_score = points.map {|s,c|s}.max
  max_count = points.map {|s,c|c}.max
  average = scores.sum / scores.length.to_f

  File.open("ruby_svg.svg", 'w') do |file|
    file.write(
<<ENDSVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="#{min_score - 50} -50 #{max_score + 50} #{max_count + 50}" style="background: #FAFAFA;">
<text x="#{min_score - 10}" y="-45" font-size="#{(max_count + 100)/15}">Min: #{min_score} | Max: #{max_score} | Avg: #{average.round} | Points: #{points.count}</text>
#{points.map { |score, score_count| "<circle title='#{score} - #{score_count} times' cx='#{score + 5}' cy='#{max_count - score_count}' r='0.5' />" }.join("\n")}
</svg>
ENDSVG
    )
  end
  `open -a Safari ruby_svg.svg`
  #viewBox = <min-x> <min-y> <width> <height>
end

# scores = svg_from_rand(1000, :normal_distribution, 0, 100, 5)
# scores = svg_from_rand(200, :normal_dist_with_bias, 1, 10, 10, weight: 4)
# scores = svg_from_rand(10000, :linear_skewed_distribution, 0, 100)
# scores = svg_from_rand(100, :linear_skewed_distribution, 1, 10)
scores = svg_from_rand(1000, :normal_dist_with_bias, 0, 100, 70, 3)
# draw_svg(ARGV.join(",").split(",").map(&:to_i))
# binding.pry
# puts ARGV#.join(",").split(",").map(&:to_i)
