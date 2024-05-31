# rm -rf /Users/rocco/imessage_export; imessage-exporter -f txt
# Message.from_file("/Users/rocco/imessage_export/Hype\ in\ the\ Chat🤪\ -\ 2.txt")
# messages = Message.messages

require "pry-rails"
require "date"

# TODO: Parse Reactions
# TODO: Able to show messages (add `def to_s`)
# TODO: Show "near" messages (Find message by text, show 2 previous and 5 following messages)
class ProgressBar
  attr_accessor :total, :current

  def initialize(total)
    @current = 0
    @total = total

    show
  end

  def increment
    @current += 1
    show
  end

  def show
    width = 50
    percent = current/total.to_f
    filled = (width*percent).to_i
    empty = width - filled

    show_bar = "[#{'='*filled}#{' '*empty}]"
    show_percent = "#{(percent*100).round.to_s.rjust(3)}%"
    show_progress = "#{@current.to_s.rjust(total.to_s.length)}/#{total}"
    print "\r#{show_bar} #{show_percent} #{show_progress} "
  end
end

class Message
  attr_accessor :author, :from, :timestamp, :body, :rawdate
  DATE_REGEX = /\w{3} \d{2}, \d{4}  ?\d{1,2}:\d{2}:\d{2} (?:A|P)M/
  CONTACTS = {
    "+18013496903" => :Saya,
    "+18013497798" => :Brendan,
    "Me"           => :Rocco,
  }
  @@messages = []
  def self.messages = @@messages

  def self.from_file(filename)
    raw = File.read(filename)
    split = raw.split(/\n{2,}/)
    total_count = split.length
    bar = ProgressBar.new(total_count)
    while split.length > 0
      msg = []
      loop do
        msg << split.shift
        bar.increment
        break if split.empty? || split.first.start_with?(DATE_REGEX)
      end
      add(msg.join("\n\n"))
    end
    puts # for bar
    self
  end

  def self.add(message)
    match = message.match(/(?<date>#{DATE_REGEX}) ?(?<readat>.*?)\n(?<author>.*?)\n(?<body>.*?)$/m)
    # return puts("\e[33m#{message.sub(/\n*$/, "")}\e[0m") if match.nil?
    return if match.nil?

    Message.new(
      match[:date],
      match[:readat],
      match[:author],
      message[message.index(match[:body])..],
    ).tap { |m| @@messages << m }
  end

  def self.[](rawdate)
    messages.find { |m| m.rawdate == rawdate }
  end

  def self.search(q)
    if q.is_a?(String)
      q = q.downcase
      @@messages.select { |m| m.body.downcase.include?(q) }.reverse
    elsif q.is_a?(Regexp)
      @@messages.select { |m| m.body.match?(q) }.reverse
    else
      puts "\e[31m[ERROR] -- Unknown type: #{q.class}"
    end
  end

  def initialize(date, readat, author, body)
    @rawdate = date
    @timestamp = DateTime.parse(date)
    @from = author
    @author = CONTACTS[author]
    @body = body
    @index = @@messages.length
  end

  def next
    @@messages[@index+1]
  end

  def previous
    @@messages[@index-1]
  end
end

# Message.from_file("/Users/rocco/imessage_export/Hype\ in\ the\ Chat🤪\ -\ 2.txt")
# messages = Message.messages
