#!/usr/bin/env ruby
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Because this is run from ~/Applications, it doesn't source the env vars correctly
raw_env = `env -i sh -c 'set -a; source /Users/rocco/.zshenv && ruby -e "p ENV"'`
new_env_hash = eval(raw_env)
["SHLVL", "PWD", "_"].each { |blacklist| new_env_hash.delete(blacklist) }
new_env_hash.each { |k, v| ENV[k] = v }

# Can't run from cron! Use launchd
# https://github.com/ali-rantakari/icalBuddy/issues/5

# crontab -l
# -- list
# crontab -e
# -- edit
# * * * * * /Users/rocco/.rbenv/shims/ruby /Users/rocco/code/games/dashboard_automations/refresh_local_dashboard_data.rb
# * * * * * /Users/rocco/.rbenv/shims/ruby /Users/rocco/code/games/dashboard_automations/refresh_local_dashboard_data.tmp.rb
# * * * * * open -g /Applications/RefreshLocalDashboardData.app

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
      @old_data = JSON.parse(File.read(@filename), symbolize_names: true) if File.exists?(@filename)
      @old_data ||= {}
    rescue JSON::ParserError
      @old_data = {}
    end
    @new_data = @old_data.dup
  end

  def update
    puts "\e[33m[LOGIT] | Updating: #{@type}\e[0m"
    @new_data = get
    if @new_data.to_json != @old_data.to_json
      failed = false
      # ["http://localhost:3141/webhooks/local_data"].each do |url|
      ["https://ardesian.com/webhooks/local_data", "http://localhost:3141/webhooks/local_data"].each do |url|
        headers = { "Authorization": "Basic #{ENV['PORTFOLIO_AUTH']}" }
        RestClient.post(url, { local_data: { @type => @new_data } }, headers)
      rescue StandardError => e
        puts "\e[31mFailed: #{e.message}\e[0m"
        failed = true
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
      next if line == ""
      if line.match?(/\w{3} \d{1,2}, \d{4}:#{separators[:section]}/)
        current_day = line[/\w{3} \d{1,2}, \d{4}/]
        next
      end

      title, *parts = line.split(separators[:prop])
      calendar_regex = / \([^\)]*\)$/
      calendar = title[calendar_regex].to_s[2..-2]
      name = title.sub(calendar_regex, "").sub(separators[:bullet], "")

      obj[current_day] ||= []
      data = {
        name: name,
        calendar: calendar,
      }
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
      obj[current_day] << data
    }
  end
end

now = Time.now
# Only refresh at 3am each day -- this can take a long time to run.
Contacts.update if now.hour == 3 && now.min === 0
Calendar.update
## Reminders.update
## Notes.update
# puts Calendar.get
