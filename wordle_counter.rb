puts `rm -rf /Users/rocco/imessage_export; imessage-exporter -f txt`

require "/Users/rocco/code/games/message_parser.rb"

Message.from_file("/Users/rocco/imessage_export/Hype\ in\ the\ Chat🤪\ -\ 2.txt")
messages = Message.messages

wordles = messages.select { |m| m.body.match?(/Wordle \d{1,3} \d\/6/) }
grouped_scores = wordles.each_with_object({}) do |m, data|
  match = m.body.match(/Wordle (?<day>\d{1,3}) (?<score>\d)\/6/)
  data[match[:day]] ||= {}
  data[match[:day]][m.author] = match[:score].to_i
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
# Rocco won 136 times
# Brendan won 34 times
# Saya won 135 times
# Brendan, Rocco, Saya tied 19 times
# Brendan, Saya tied 18 times
# Rocco, Saya tied 130 times
# Brendan, Rocco tied 15 times

# binding.pry

# failed_wordles = messages.select { |m| m.body.match?(/Wordle \d{1,3} X\/6/) }
# p (failed_wordles.each_with_object({}) do |m, data|
#   data[m.author] ||= 0
#   data[m.author] += 1
# end)
