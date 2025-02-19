dir = "/Users/rocco/imessage_export"
filenames = Dir.entries(dir).select { |file| file.include?("Hype in the Chat") }
if ENV["USE_CACHE"].nil? || filenames.none? { |filename| !File.file?(filename) }
  puts "Resetting cache!"
  puts `rm -rf /Users/rocco/imessage_export; imessage-exporter -f txt`
end

# ==================== Helpers ====================
require "/Users/rocco/code/games/message_parser.rb" # adds the Message class
require "/Users/rocco/code/games/imessage_table.rb" # adds helper method module
include IMessageTable # adds helper methods
# Extend message class to have wordle attrs
class Message
  attr_accessor :wordle_score, :wordle_day
end
def number_with_delimiter(number, delimiter = ",")
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{delimiter}").reverse
end
# / ==================== Helpers ====================

Message.from_file(*filenames.map { |filename| "#{dir}/#{filename}" })
messages = Message.messages

wordles = messages.select { |m|
  match = m.body.match(/Wordle (?<day>[\d,]*).*?(?<score>[\dX])\/6/)
  next if match.nil? || match[:score].nil?

  m.wordle_score = match[:score] == "X" ? 7 : match[:score].to_i
  m.wordle_day = match[:day].gsub(/[^\d]/, "").to_i
  true
}

def points(wordles)
  now = DateTime.now
  month_start = DateTime.new(now.year, now.month, 1)

  alltime_scores = { Rocco: 0, Saya: 0, Brendan: 0 }
  month_scores = { Rocco: 0, Saya: 0, Brendan: 0 }
  author_wordles = { Rocco: [], Saya: [], Brendan: [] }

  wordles.each do |m|
    next if author_wordles[m.author].include?(m.wordle_day)
    author_wordles[m.author] << m.wordle_day
    next if m.wordle_score > 6

    alltime_scores[m.author] += 7 - m.wordle_score
    next unless m.timestamp > month_start

    month_scores[m.author] += 7 - m.wordle_score
  end

  puts " #{now.strftime("%B")} ".center(17, "-")
  month_scores.sort_by { |k,v| -v }.each do |name, score|
    puts pad_right("#{name}:", 8) + pad_left(number_with_delimiter(score), 6)
  end

  puts " All Time ".center(17, "-")
  alltime_scores.sort_by { |k,v| -v }.each do |name, score|
    puts pad_right("#{name}:", 8) + pad_left(number_with_delimiter(score), 6)
  end
  puts "Last day: #{wordles.max_by { |m| m.wordle_day }.wordle_day}"
end
points(wordles)

def victories(messages)
  wordles = messages.select { |m| m.body.match?(/Wordle [\d,]*.*?[\dX]\/6/) }
  author_wordles = { Rocco: [], Saya: [], Brendan: [] }
  author_scores = { Rocco: [], Saya: [], Brendan: [] }
  grouped_scores = wordles.each_with_object({}) do |m, data|
    match = m.body.match(/Wordle (?<day>[\d,]*).*?(?<score>[\dX])\/6/)
    score = match[:score] == "X" ? 7 : match[:score].to_i
    author_wordles[m.author] << m
    author_scores[m.author] << score
    data[match[:day]] ||= {}
    data[match[:day]][m.author] = score
  end
  # {"219"=>{"Saya"=>4},
  #  "221"=>{"Saya"=>4},
  #  "247"=>{"Saya"=>4, "Rocco"=>5, "Brendan"=>6}}

  wins = {
    Rocco:   0,
    Brendan: 0,
    Saya:    0,
    BRStie:  0,
    BStie:   0,
    RStie:   0,
    BRtie:   0,
  }

  grouped_scores.each do |_day, scores|
    next unless (scores.keys & [:Rocco, :Saya]).length >= 2

    winning_score = scores.values.min
    winners = scores.select { |k,v| v == winning_score }
    if winners.length == 1
      wins[winners.keys.first] += 1
    else
      initials = winners.keys.map { |n| n.to_s[0] }
      wins["#{initials.sort.join("")}tie".to_sym] += 1
    end
  end

  is = {
    "R" => "Rocco",
    "S" => "Saya",
    "B" => "Brendan",
  }
  wins.sort_by { |k,v| -v }.each do |win, count|
    if win.to_s.include?("tie")
      initials = win.to_s.sub(/tie/, "")
      names = initials.split("").map { |i| is[i] }
      puts "#{names.join(", ")} tied #{count} times"
    else
      puts "#{win} won #{count} times"
    end
  end
  puts "Last day: #{grouped_scores.keys.max { |day| day.gsub(/[^\d]/, "").to_i }}"
end
# require "pry-rails"; binding.pry
# Rocco won 136 times
# Brendan won 34 times
# Saya won 135 times
# Brendan, Rocco, Saya tied 19 times
# Brendan, Saya tied 18 times
# Rocco, Saya tied 130 times
# Brendan, Rocco tied 15 times

# puts grouped_scores.to_a.sort_by { |day_str, data| -day_str.gsub(/[^\d]/, "").to_i }.first(20).map { |day_str, data| "#{day_str} | Saya: #{data[:Saya] || "-"} | Rocco: #{data[:Rocco] || "-"}" }


# class String
#   def with_delim
#     self.gsub(/\B(?=(...)*\b)/, ',')
#   end
# end
# (219..1026).each




# failed_wordles = messages.select { |m| m.body.match?(/Wordle \d{1,3} X\/6/) }
# p (failed_wordles.each_with_object({}) do |m, data|
#   data[m.author] ||= 0
#   data[m.author] += 1
# end)

# author_wordles
# author_scores
# grouped_scores
# require "pry-rails"; binding.pry

# def table(array)
#   column_widths = array.map { |layer| layer.map { |cell| cell.to_s.length }.max }
#   array.each do |row|
#     row.each_with_index do |cell, col_index|
#       print cell.to_s.rjust(column_widths[col_index] + 2)  # Add 2 for padding
#     end
#     puts # Move to the next line after each row
#   end
# end

# ==== Averages
# d = author_scores.transform_values { |vs| { count: vs.length, avg: vs.sum / vs.length.to_f } }
# array = [[nil, :Count, :AVG], *d.map {|a,hash| [a, hash[:count], hash[:avg].round(3).to_s.ljust(5, "0")]}]
# table(array)
