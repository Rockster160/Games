today = Time.now + (2*60*60)

day = ARGV[0].to_s.gsub(/\s/, "")
if day == ""
  raise "Please provide a day" unless today.month == 12
  day = today.day
end

filebase = "/Users/rocco/code/games/aoc2022/d#{day}"

# Ideally, when this is run after the time, grab the name from the page

unless File.exists?("#{filebase}.rb")
  File.open("#{filebase}.rb", "w+") { |f|
    f.puts(File.read("/Users/rocco/code/games/aoc2022/_template.rb").gsub(/\{\{.*?\}\}/) do |found|
      found.gsub("{{nextday}}", (day.to_i + 1).to_s).gsub("{{day}}", day.to_s)
    end)
  }
end

if !File.exists?("#{filebase}.txt") || File.size("#{filebase}.txt") == 0
  require "rest-client"
  File.open("#{filebase}.txt", "w+") do |f|
    f.puts ::RestClient::Request.execute(
      method: :get,
      url: "https://adventofcode.com/#{today.year}/day/#{today.day}/input",
      cookies: { session: ENV["aoccookie"] }
    ).body
  end
end

puts "#{filebase}.rb"
