# rm -rf /Users/rocco/imessage_export; imessage-exporter -f txt
# ruby /Users/rocco/code/games/message_explorer.rb "3855495068"

require_relative "message_parser"

q = ARGV[0].to_s
# q = "1#{q}" if q.length == 10
# q = "+#{q}" if q.length == 11

files = Dir["/Users/rocco/imessage_export/*"].select { |f| f.include?(q) }
if files.length == 1
  messages = Message.from_file(files.first)
  binding.pry
else
  puts "\e[33m[LOGIT] | Multiple matches found\e[0m"
  binding.pry
end

# Fuzzy find file, format message as expected.
# messages = Message.from_file(found_file).messages
