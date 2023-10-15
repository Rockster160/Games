require "/Users/rocco/code/games/scrape"
require "/Users/rocco/code/games/color_mapper"

def mapper
  @mapping ||= ColorMapper.new(
    "#A22633": 0.5, # Red
    "#FEE761": 5,   # Yellow
    "#3E8948": 9,   # Green
    "#0160FF": 9.5, # Blue
  )
end

def show(color, txt)
  rgb = color.rgb.join(";")
  "\e[48;2;#{rgb}m\e[3#{color.contrast_code}m #{txt} \e[0m"
end

def load_more
  btns = driver.find_elements(css: "faceplate-partial.top-level")
  return puts("\e[33mNo buttons\e[0m") if btns.none?

  puts("\e[31m[LOGIT] | MANY LOAD BUTTONS FOUND\e[0m") if btns.count > 1
  btn = btns.first
  btn.click if btn.attribute(:innerText).include?("View more comments")
  puts("\e[33m Loading more...\e[0m")
  sleep 1
  # t = Time.now.to_i
  # loop do
  #   break if Time.now.to_i - t > 5
  #   break if driver.find_elements(css: "shreddit-loading").count == 0
  #   sleep 0.5
  # end
  # load_more
rescue Selenium::WebDriver::Error::TimeoutError
  # No op
end

puts " Rating...."

url = ARGV[0].to_s

driver(headless: true)
driver.navigate.to(url)

wait.until { driver.find_element(css: "[slot='title']") }
title = driver.find_element(css: "[slot='title']").attribute(:innerText)
puts "\e[38;2;150;150;150m > \e[4m#{title}\e[0m"

wait.until { driver.find_element(css: "shreddit-comment .md") }
# screenshot!
# show_source
load_more
# binding.pry

ratings = driver.find_elements(css: "shreddit-comment .md").map { |comment|
  text = comment.attribute(:innerText)
  text = text.gsub("Rule 1", "").gsub("3 strikes", "")
  text[/\b\d\b([\.,]\d)?/]&.gsub(",", ".")
}.compact
rating = ratings.map(&:to_f).then { |a| a.sum / a.length if a.length > 0 }&.round(1) || 0

if rating.zero?
  puts "Not enough info found"
  return
end

color = mapper.scale(rating)
# binding.pry if color.nil? || rating.zero?
# binding.pry
puts "From #{ratings.count} ratings:"
puts show(color, rating)
