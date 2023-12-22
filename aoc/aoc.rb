# Refresh Cookie by using Github Oauth
# Open Network tab, refresh the page
# Click a document that shows up (the year is a good one)
# Headers -> Cookie -> Click+Drag and copy the cookie.
# `envs` -> edit "aoccookie" to be the value you copied.
# Done!

two_hours = 2*60*60
today = Time.now + two_hours # Add 2 hours because aoc is Midnight EST, so 10pm local
year = today.year

day = ARGV[0].to_s.gsub(/\s/, "")
if day == ""
  raise "Please provide a day" unless today.month == 12
  day = today.day
end

root = "/Users/rocco/code/games/aoc"
dir = "#{root}/y#{year}"
filebase = "#{dir}/d#{day}"
rb = "#{filebase}.rb"
txt = "#{filebase}.txt"

# Ideally, when this is run after the time, grab the name from the page

if !File.exists?(rb)
  Dir.mkdir(dir) unless Dir.exist?(dir)
  File.open(rb, "w+") { |f|
    f.puts(File.read("#{root}/_template.rb").gsub(/\{\{.*?\}\}/) { |found|
      {
        "{{timestamp}}": Time.now.strftime("%s %b %-d, %-I:%M%p"),
        "{{nextday}}":   (day.to_i + 1).to_s,
        "{{day}}":       day.to_s,
        "{{year}}":      year.to_s,
      }.each { |find, replace| found.gsub!(find.to_s, replace) }
      found
    })
  }
end

if !File.exists?(txt) || File.size(txt) == 0
  require "rest-client"
  File.open(txt, "w+") { |f|
    f.puts(::RestClient::Request.execute(
      method: :get,
      url: "https://adventofcode.com/#{year}/day/#{day}/input",
      cookies: { session: ENV["aoccookie"] }
    ).body)
  }
  # TODO: Read and output the description/challenge as well
  # Or at least open it!
  `open -a "Google Chrome" "https://adventofcode.com/#{year}/day/#{day}"`
end

puts rb
