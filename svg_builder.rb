require 'pry'
def svg_from_rand(total_points, method, *args, &block)
  # draw_svg(total_points.times.map { send(method, *args) })
  generate_bar(total_points.times.map {
    val = send(method, *args)
    block ? block.call(val) : val
  })
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
  points = scores.tally
  points = points.sort_by { |point_key, point_count| point_count }.reverse
  min_score = points.map {|s,c|s}.min
  max_score = points.map {|s,c|s}.max
  max_count = points.map {|s,c|c}.max # score count
  average = scores.sum / scores.length.to_f
  puts "Low: #{min_score}, High: #{max_score}, Max: #{max_count}, Count: #{scores.count}, Points: #{points.count}"

  File.open("ruby_svg.svg", 'w') do |file|
    file.write(
<<ENDSVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="#{min_score * 0.9} -10 #{max_score * 1.1} #{max_count * 1.1}" style="background: #FAFAFA;">
#{points.map { |score, score_count| "<circle title='#{score} - #{score_count} times' cx='#{score}' cy='#{max_count - score_count}' r='0.5' />" }.join("\n")}
</svg>
ENDSVG
    )
  end
  `open -a Safari ruby_svg.svg`
  #viewBox = <min-x> <min-y> <width> <height>
end

def generate_bar(numbers)
  # Count the occurrences of each number
  occurrences = Hash.new(0)
  numbers.each { |num| occurrences[num] += 1 }

  # Calculate the maximum occurrence for scaling purposes
  max_occurrence = occurrences.values.max

  # SVG dimensions
  width = 1000
  height = 500
  margin = 5
  bar_width = (width - 2 * margin) / numbers.uniq.length.to_f

  # SVG header
  svg = <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}">
  SVG

  # Draw bars for each number
  occurrences.sort_by { |num, count| num }.each_with_index do |(num, count), index|
    x = margin + index * bar_width
    bar_height = count.to_f / max_occurrence * (height - 4 * margin)

    svg << <<~BAR
      <rect x="#{x}" y="#{height - bar_height - margin}" width="#{bar_width}" height="#{bar_height}" fill="steelblue" />
      <text x="#{x + bar_width / 2}" y="#{(height - margin) - 2}" fill="black" text-anchor="middle" font-size="12px">#{num}</text>
      <text x="#{x + bar_width / 2}" y="#{height - bar_height - 2 * margin}" fill="#{count > 1 ? :black : :transparent}" text-anchor="middle" font-size="12px">#{count}</text>
    BAR
  end

  # SVG footer
  svg << '</svg>'

  File.open("ruby_svg.svg", 'w') do |file|
    file.write(svg)
  end
  `open -a Safari ruby_svg.svg`
end



require_relative "color_mapper"
@health_mapping = ColorMapper.new(
  "#A22633": -1, # Red
  "#FEE761": 0,  # Yellow
  "#3E8948": 1,  # Green
)
def colorout(x)
  color = @health_mapping.scale(x)
  rgb = color.rgb.join(";")
  print "\e[48;2;#{rgb}m\e[3#{color.contrast_code}m \e[0m"
  # puts "\e[48;2;#{rgb}m\e[3#{color.contrast_code}m #{x.to_s.rjust(4, " ")} \e[0m"
end

# The god mode function right here
require "/Users/rocco/code/games/randcos_density.rb"
# def randcos(factor:, intervals:)
#   loop do
#     x = rand
#     pdf = (1 + ((factor - 1)*(1 - Math.cos(2*Math::PI*intervals*x))/2))/(factor)
#     break x if rand < pdf
#   end
# end

def genome_mix(val1, val2, factor: 3)
  num = randcos(factor: factor, intervals: 2)
  min, max = [val1, val2].sort.map(&:to_f)
  min *= 0.9
  max *= 1.1
  min + (num * (max - min))
end

# # Genome
# generate_bar(1000.times.map do
#   genome_mix(87, 122).round
# end)

# RandCos
generate_bar(10_000.times.map do
  num = randcos(factor: 3, intervals: 1)
  (num * 50).floor
end)

# scores = svg_from_rand(1000, :normal_distribution, 0, 100, 5)
# scores = svg_from_rand(200, :normal_dist_with_bias, 1, 10, 10, weight: 4)
# scores = svg_from_rand(10000, :linear_skewed_distribution, 0, 100)
# scores = svg_from_rand(100, :linear_skewed_distribution, 1, 10)
# scores = svg_from_rand(1000, :normal_dist_with_bias, 0, 100, 70, 3)
# period = ARGV[0].to_i
# (-period*Math::PI..period*Math::PI).step((period*Math::PI)/50) { |x|
#   x-=Math::PI if period.even?
#   Math.cos(x).tap { |c| colorout(c) }
# }
# cols = 50
# generate_bar(10000.times.map {
#   val = send(:bumps, period)
#   (val * cols).round
# } + (1..cols).to_a)
# draw_svg(ARGV.join(",").split(",").map(&:to_i))
# binding.pry
# puts ARGV#.join(",").split(",").map(&:to_i)
