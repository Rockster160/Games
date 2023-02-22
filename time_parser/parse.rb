require "time"
require "pry-rails"

class Integer
  def seconds
    self.to_f / (24 * 60 * 60)
  end
  alias :second :seconds

  def minutes
    self.to_f / (24 * 60)
  end
  alias :minute :minutes

  def hours
    self.to_f / 24
  end
  alias :hour :hours

  def days
    self
  end
  alias :day :days

  def weeks
    self * 7
  end
  alias :week :weeks

  def from_now
    DateTime.now + self
  end

  def ago
    DateTime.now - self
  end
end

class DateTime
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def to_h
    {
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      zone: zone,
    }
  end

  def change(hash)
    simplified = simplify_date_hash(to_h.merge(hash))

    DateTime.new(*simplified.values)
  end

  def days_in_month(this_month=self.month, this_year=self.year)
    return 29 if this_month == 2 && Date.gregorian_leap?(this_year)

    COMMON_YEAR_DAYS_IN_MONTH[this_month]
  end

  private

  def simplify_date_hash(hash)
    changed = false

    if hash[:second] > 60
      changed = true
      hash[:second] -= 60
      hash[:minute] += 1
    end

    if hash[:minute] > 60
      changed = true
      hash[:minute] -= 60
      hash[:hour] += 1
    end

    if hash[:hour] > 24
      changed = true
      hash[:hour] -= 24
      hash[:day] += 1
    end

    if hash[:day] > days_in_month
      changed = true
      hash[:day] -= days_in_month
      hash[:month] += 1
    end

    if hash[:month] > 12
      changed = true
      hash[:month] -= 12
      hash[:year] += 1
    end

    DateTime.new(*hash.values) # validate
    hash
  rescue Date::Error => e
    raise e unless changed

    simplify_date_hash(hash)
  end
end

class Parse
  attr_accessor :time

  DAY_START = 9

  def self.call(str)
    new.call(str)
  end

  def call(str)
    @now = DateTime.now
    @time = DateTime.now
    @str = str.dup
    @time_changed = false

    @str = " " + @str.gsub(/^\s*to\b/, "").gsub(/^\btoday\b/, "").gsub("tomorrow") do |found|
      @time += 1.day
      nil
    end

    @str.split(/(?= in )|(?= at )/).each do |part|
      parse_in(part) if part.start_with?(" in ")
      parse_at(part) if part.start_with?(" at ")
    end

    puts @str.strip
    output
  end

  def output
    # "07/28/2021 10:42 AM"
    @time.strftime("%m/%d/%Y %H:%M")
  end

  def time_words
    {
      year:   [:yr],
      month:  [:mth],
      week:   [],
      day:    [],
      hour:   [:hr],
      minute: [:min],
      second: [:sec],
    }
  end

  def parse_in(part)
    @str.gsub!(part, "")
    @time_changed = true

    part = part.gsub(/ an? /, " 1 ")
    num, word = part[/\d+.?\w+/]&.split(/\b/)&.select { |piece| piece.strip.length.to_i > 0 }
    num = (num).strip.to_i
    word = word&.strip
    word ||= :minutes

    if word.start_with?("year")
      @time = @time.change(@time.to_h.tap { |h| h[:year] += num })
    elsif word.start_with?("month")
      @time = @time.change(@time.to_h.tap { |h| h[:month] += num })
    else
      @time += num.send(word)
    end
  end

  def parse_at(part)
    @str.gsub!(part, "")
    @time_changed = true
    found_time = part[/[\d:]+.?[\w]*/]
    merid = found_time[/(a|p)m/i].to_s.upcase

    changes = {}
    hour, min, sec = found_time[/[\d:]*/].split(":")
    changes[:hour] = hour.to_i
    changes[:minute] = min.to_i
    changes[:second] = sec.to_i

    case merid
    when "AM" then nil
    when "PM" then changes[:hour] += 12
    else
      # changes[:hour] += 12 if changes[:hour] < DAY_START
    end

    @time = @time.change(changes)
    @time += 12.hours if @time < @now
  end
end

puts Parse.call(ARGV[0])
