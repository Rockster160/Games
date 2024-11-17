#!/usr/bin/env ruby
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Because this is run from ~/Applications, it doesn't source the env vars correctly
raw_env = `env -i sh -c 'set -a; source /Users/rocco/.zshenv && ruby -e "p ENV"'`
new_env_hash = eval(raw_env)
["SHLVL", "PWD", "_"].each { |blacklist| new_env_hash.delete(blacklist) }
new_env_hash.each { |k, v| ENV[k] = v }

# Can't run iCalBuddy from cron! Use launchd
# https://github.com/ali-rantakari/icalBuddy/issues/5

# crontab -l
# -- list
# crontab -e
# -- edit
# * * * * * /Users/rocco/.rbenv/shims/ruby /Users/rocco/code/games/dashboard_automations/refresh_local_dashboard_data.rb
# * * * * * /Users/rocco/.rbenv/shims/ruby /Users/rocco/code/games/dashboard_automations/refresh_local_dashboard_data.tmp.rb
# * * * * * open -g /Applications/RefreshLocalDashboardData.app

require "date"
require "json"
require "open3"
require "rest-client"

class DataManager
  def self.update
    new(self.name.to_s.downcase.to_sym).update
  end

  def self.get
    new(self.name.to_s.downcase.to_sym).get
  end

  def initialize(type)
    @type = type
    @filename = File.join(__dir__, "#{@type}.json")
    begin
      @old_data = JSON.parse(File.read(@filename), symbolize_names: true) if File.exist?(@filename)
      @old_data ||= {}
    rescue JSON::ParserError
      @old_data = {}
    end
    @new_data = @old_data.dup
  end

  def data
    @new_data
  end

  def update
    puts "\e[33m[LOGIT] | Updating: #{@type}\e[0m"
    @new_data = get
    if @new_data.to_json != @old_data.to_json
      formatted_data = data
      failed = false
      [
        "https://ardesian.com/jil/trigger/local_data",
        "http://localhost:3141/jil/trigger/local_data",
      ].each do |url|
        next if formatted_data.nil? || formatted_data.length == 0

        headers = { "Authorization": "Basic #{ENV['PORTFOLIO_AUTH']}" }
        RestClient.post(url, { local_data: { @type => formatted_data } }, headers)
      rescue StandardError => e
        puts "\e[31mFailed: #{e.message}\e[0m"
        failed = true unless url.include?("localhost")
        # no-op - don't fail if servers fail to connect
      end
      File.write(@filename, @new_data.to_json) unless failed
    end
    puts "\e[32m[LOGIT] | Done: #{@type}\e[0m"
  rescue StandardError => e
    puts "\e[31m[LOGIT] | ERROR: #{@type}\e[0m"
    puts "\e[31m[LOGIT] | #{e}\e[0m"
    # No op. Don't care if stuff breaks
  end

  def get
    raise NotImplementedError, "Should be implemented in sub classes"
  end
end

class Contacts < DataManager
  def get
    _stdout, stderr, _status = Open3.capture3("osascript -l JavaScript /Users/rocco/code/games/dashboard_automations/contacts_data.jxa")

    JSON.parse(stderr) # console.log outputs to stderr for some reason
  end
end

class Notes < DataManager
  def get
    _stdout, stderr, _status = Open3.capture3("osascript -l JavaScript /Users/rocco/code/games/dashboard_automations/notes_data.jxa")
    raw_notes = stderr
    date, _title, *items = raw_notes.split("\n")

    {
      timestamp: date,
      items: items,
    }
  end
end

class Reminders < DataManager
  def get
    _stdout, stderr, _status = Open3.capture3("osascript -l JavaScript /Users/rocco/code/games/dashboard_automations/reminders_data.jxa")

    JSON.parse(stderr)
  end
end

class Calendar < DataManager
  def get
    options = [
      :includeOnlyEventsFromNowOn,
      :separateByDate,
      :noRelativeDates,
      :showUIDs,
    ]
    separators = {
      section: "#icalbuddysection#",
      prop: "#icalbuddyprop#",
      newline: "#icalbuddynewline#",
      bullet: "#icalbuddybullet#",
    }
    options_with_vals = {
      excludeCals: "Bills, B18F1275-1162-4B5F-9FA6-6C02C5FE484B",
      includeCalTypes: "CalDAV",
      excludeEventProps: "attendees",
      sectionSeparator: separators[:section],
      propertySeparators: "|#{separators[:prop]}|",
      notesNewlineReplacement: separators[:newline],
      bullet: separators[:bullet],
      includeEventProps: "title,datetime,uid,notes,location",
      propertyOrder: "title,datetime,uid,notes,location",
    }
    options_str = options.map { |opt| "--#{opt}" }.join(" ")
    options_str += " " + options_with_vals.map { |opt, val| "--#{opt} \"#{val}\"" }.join(" ")

    raw_cal = `/opt/homebrew/bin/icalBuddy #{options_str} eventsToday+10`
    # For some reason icalbuddy leaves newlines in locations, so fix that:
    fixed_cal = "#{raw_cal}#{separators[:bullet]}".gsub(/location: (.|\n)*?(#icalbuddybullet#)/m) { |found|
      found.gsub("\n", separators[:newline]).sub(/#{separators[:newline]}#{separators[:bullet]}/, "\n#{separators[:bullet]}")
    }.sub(/#{separators[:bullet]}$/, "").gsub(/#{separators[:newline]}(\w{3} \d{1,2}, \d{4}:#{separators[:section]})/m, "\n" + '\1')

    current_day = ""
    fixed_cal.split("\n").each_with_object({}) { |line, obj|
      next if line.to_s == ""
      if line.match?(/\w{3} \d{1,2}, \d{4}:#{separators[:section]}/)
        current_day = line[/\w{3} \d{1,2}, \d{4}/].to_sym
        next
      end

      title, *parts = line.split(separators[:prop])
      calendar_regex = / \([^\)]*\)$/
      calendar = title[calendar_regex].to_s[2..-2]
      name = title.sub(calendar_regex, "").sub(separators[:bullet], "")

      obj[current_day] ||= []
      data = { name: name, calendar: calendar }
      parts.each do |part|
        partname = part[/\w+: /]
        if partname.nil?
          start_time, end_time = part.split(" - ")
          data[:start_time] = start_time
          data[:end_time] = end_time
          next
        end
        partdata = part.sub(/^#{partname}/, "")
        data[partname[0..-3].to_sym] = partdata.gsub(separators[:newline], "\n").strip
      end
      full_time = "#{current_day} #{data[:start_time]}"
      begin
        timestamp = DateTime.parse(full_time).to_time.to_i
      rescue => e
        timestamp = data[:start_time]
      end
      data[:unix] = "unix:#{timestamp}:#{data[:uid]}"
      obj[current_day] << data
    }
  end

  def data
    all_keys = (@new_data.keys + @old_data.keys).uniq
    changes = {}

    if ARGV.include?("resync")
      changes = @new_data
      all_keys = [] # Prevents the block below from running
    end

    all_keys.each do |date|
      changes[date] = []
      if @new_data.key?(date) && !@old_data.key?(date)
        changes[date] = @new_data[date]
        next
      end
      if !@new_data.key?(date) && @old_data.key?(date)
        @old_data[date].each do |event|
          changes[date] << { unix: event[:unix], remove: true }
        end
        next
      end

      @new_data[date].each do |new_event|
        old_event = @old_data[date].find { |e| e[:unix] == new_event[:unix] }
        next changes[date] << new_event if !old_event
        next changes[date] << new_event if old_event.keys != new_event.keys
        found_change = new_event.find { |key, val| old_event[key] != val }
        changes[date] << new_event if found_change
      end

      @old_data[date].each do |old_event|
        new_event = @new_data[date].find { |e| e[:unix] == old_event[:unix] }
        changes[date] << { unix: old_event[:unix], remove: true } if !new_event
      end
    end
    changes.reject! { |k,v| v.nil? || v.length == 0 }

    return [] if changes.length == 0
    puts changes.to_json

    changes
  end
end

now = Time.now
# Only refresh at 3am each day -- this can take a long time to run.
# Contacts.update if now.hour == 3 && now.min === 0
Calendar.update

lastfile = File.join(__dir__, "lastrun.json") # json just hides the file
File.write(lastfile, DateTime.now)

### Reminders.update
### Notes.update
# puts Calendar.get

# Just a regular ping to update ip addresses
if now.min % 5 == 0
  ["https://ardesian.com/webhooks/local_ping", "http://localhost:3141/webhooks/local_ping"].each do |url|
    headers = { "Authorization": "Basic #{ENV['PORTFOLIO_AUTH']}" }
    ::RestClient.post(url, {}, headers)
  rescue StandardError => e
  end
end
