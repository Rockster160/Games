#!/Users/rocco/.rbenv/shims/ruby

require "websocket-client-simple"
require "uri"
require "json"
require "base64"
require "pry-rails"
require "rest-client"

puts "Note Watcher startup!"

@prod = true # comment out for local
BASE_HOST = @prod ? "ardesian.com" : "localhost:3141"

SECURE = BASE_HOST.include?("localhost") ? "" : "s"
BASE_URL = "http#{SECURE}://#{BASE_HOST}"
BASE_WS = "ws#{SECURE}://#{BASE_HOST}"
AUTH_TOKEN = Base64.urlsafe_encode64("Rockster160:#{ENV["LOCAL_ME_PASS"]}")

class String
  def titleize
    self
    .gsub(/[-_]+/, " ")
    .gsub(/([A-Z])/, ' \1')
    .gsub(/^ | $/, "")
    .gsub(/\b(?<!\w['])[a-z]/, &:capitalize)
  end

  def parameterize
    self.titleize.downcase
      .gsub(/[^\d\w]/, "-")
      .gsub(/-{2,}/, "-")
      .gsub(/^-|-$/, "")
  end
end

class WatchedDirectory
  attr_accessor :local_match, :server_match, :files, :pulled

  def initialize(local_match, server_match)
    @local_match = local_match
    @server_match = server_match.parameterize
    @files = []
    @pulled = false
  end

  def checkall
    return unless @pulled # Don't push files until we're checked the server for what it has

    Dir[@local_match].each do |filepath|
      file = @files.find { |f| f.filepath == filepath }
      file&.check
      create_server_file(filepath) if file.nil?
    end
  end

  def create_server_file(filepath)
    puts "\e[33m[PUSH NEW][#{filepath}]\e[0m"
    filename = Regexp.new("^" + @local_match.gsub("*", "(.*?)") + "$").match(filepath).to_a[1]
    if filename.nil?
      puts "\e[31m[ERROR] | No match found! local_match(#{@local_match}) filepath(#{filepath})\e[0m"
    end

    json = RestClient.post(
      "#{BASE_URL}/pages",
      {
        page: {
          folder_name: @server_match,
          name: filename.titleize,
          timestamp: File.mtime(filepath).to_i,
          content: File.read(filepath),
        }
      },
      { Authorization: "Bearer #{AUTH_TOKEN}", Accept: "application/json" }
    ).then { |res| JSON.parse(res.body, symbolize_names: true) }
    @files << WatchedFile.new(filepath, json[:id])
  end

  def filename_to_filepath(filename)
    @local_match.gsub("*", filename.parameterize.gsub("-", "_"))
  end

  def create_local_file(page_data)
    # {:id, :timestamp, :name, :folder}
    filepath = filename_to_filepath(page_data[:name])
    puts "\e[36m[PULL NEW][#{filepath}]\e[0m"
    File.write(filepath, "")
    file = WatchedFile.new(filepath, page_data[:id])
    file.pull
    @files << file
  end

  def check(page_data)
    filepath = filename_to_filepath(page_data[:name])
    existing_local = Dir[@local_match].find { |filename| filename == filepath }
    if existing_local.nil?
      create_local_file(page_data)
    else
      file = WatchedFile.new(filepath, page_data[:id])
      file.check(page_data[:timestamp].to_i)
      @files << file
    end
  end
end

class WatchedFile
  attr_accessor :filepath, :server_id, :current_timestamp

  def initialize(filepath, server_id)
    @filepath = filepath
    @server_id = server_id
    @current_timestamp = local_timestamp
  end

  def local_timestamp
    File.mtime(@filepath).to_i
  end

  def pull
    puts "\e[33m[PULL][#{@filepath}](#{@current_timestamp})\e[0m"
    json = RestClient.get(
      "#{BASE_URL}/pages/#{@server_id}",
      { Authorization: "Bearer #{AUTH_TOKEN}", Accept: "application/json" }
    ).then { |res| JSON.parse(res.body, symbolize_names: true) }

    File.write(@filepath, json[:content])
    @current_timestamp = json[:timestamp]
    puts "\e[33m[UPDATED](#{@current_timestamp})\e[0m"
    File.utime(json[:timestamp], json[:timestamp], @filepath)
  end

  def push
    @current_timestamp = local_timestamp
    puts "\e[33m[PUSH][#{@filepath}](#{@current_timestamp})\e[0m"
    RestClient.patch(
      "#{BASE_URL}/pages/#{@server_id}",
      {
        page: {
          content: File.read(@filepath),
          timestamp: local_timestamp,
        }
      },
      { Authorization: "Bearer #{AUTH_TOKEN}", Accept: "application/json" },
    )
  end

  def check(check_timestamp=nil)
    check_timestamp ||= @current_timestamp
    push if check_timestamp.to_i < local_timestamp.to_i
    pull if check_timestamp.to_i > local_timestamp.to_i
  end
end

class Syncer
  attr_accessor :ws, :started, :connected, :last_ping, :files, :directories

  def self.run(uri:, auth_token:, file_mapping:)
    new(uri: uri, auth_token: auth_token, file_mapping: file_mapping).run
  end

  def initialize(uri:, auth_token:, file_mapping:)
    @uri = uri
    @auth_token = auth_token
    @file_mapping = file_mapping
    @directories = []
    @files = []
    file_mapping.each do |filepath, server_id|
      if filepath.include?("*")
        @directories << WatchedDirectory.new(filepath, server_id)
      else
        @files << WatchedFile.new(filepath, server_id)
      end
    end
  end

  def run
    loop do
      @last_ping = 0
      @started = false
      @connected = false
      begin
        @ws = WebSocket::Client::Simple.connect(
          @uri.to_s + "/cable",
          headers: { Authorization: "Bearer #{@auth_token}" },
        )
        syncer = self
        print "\e[33m.\e[0m"

        @ws.on(:message) do |msg|
          syncer.receive(JSON.parse(msg.data, symbolize_names: true))
        end

        @ws.on(:close) do |event|
          puts "Connection closed (code: #{event.code}, reason: #{event.reason})"
          syncer.connected = false
        end

        # This loop keeps the script running
        loop do
          if @started && (!@connected || Time.now.to_i - @last_ping > 5)
            print "\e[31m.\e[0m"
            sleep 1
            break
          end
          @files.each(&:check)
          @directories.each(&:checkall)
          sleep 1 # Just so we're not constantly checking the files
        end
      rescue StandardError => e
        # print "\e[31mx\e[0m"
        puts "\e[31mError: #{e.message}\e[0m"
        binding.pry
        sleep 5 # Wait before attempting to reconnect
      end
    end
  end

  def broadcast(data={}, command: :message)
    @ws.send(JSON.generate({
      command: command,
      identifier: { channel: :PageChannel }.to_json,
      data: data.to_json
    }))
  end

  def receive(data)
    case data.dig(:type).to_s.to_sym
    when :ping
      @started = true
      @connected = true
      @last_ping = data[:message]
    when :welcome
      broadcast(command: :subscribe)
    when :confirm_subscription
      puts "Fully connected"
      broadcast({
        action: :request_timestamps,
        ids: @file_mapping.values,
      })
    when :disconnect
      @ws.close
      @connected = false
    else
      handle(data[:message]) if data[:message]
    end

    def handle(data)
      puts "\e[33m[LOGIT] | #{data[:changes]}\e[0m"
      data[:changes]&.each do |page_data|
        file = @files.find { |file| file.server_id == page_data[:id] }
        file&.check(page_data[:timestamp].to_i)
        next unless file.nil?
        @directories.each { |dir|
          dir.check(page_data) if dir.server_match == page_data[:folder]
          dir.pulled = true
        }
      end
      puts "Message Received: #{data}" unless data[:changes]
    end
  end
end

Syncer.run(
  uri: URI.parse(BASE_WS),
  auth_token: AUTH_TOKEN,
  file_mapping: {
    "/Users/rocco/.zshrc" => 96,
    # Doesn't currently work with nested folders - assumes every folder name is unique
    "/Users/rocco/todo_*.txt" => "/todo",
    "/Users/rocco/code/prm/*" => "/prm",
  }
)

# 1. Create a Launch Agent
# Create a .plist File:
# Create a property list (.plist) file that describes your script and how it should be run. Save it in ~/Library/LaunchAgents/ with a filename like com.rocco.websocket-filewatcher.plist.
# ~/Library/LaunchAgents/com.rocco.websocket-filewatcher.plist.
#
# xml
# Copy code
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>Label</key>
#     <string>com.rocco.websocket-filewatcher</string>
#     <key>ProgramArguments</key>
#     <array>
#         <string>/Users/rocco/code/games/websocket/note_watcher.rb</string>
#     </array>
#     <key>RunAtLoad</key>
#     <true/>
#     <key>KeepAlive</key>
#     <true/>
#     <key>StandardOutPath</key>
#     <string>/Users/rocco/code/games/websocket/log.log</string>
#     <key>StandardErrorPath</key>
#     <string>/Users/rocco/code/games/websocket/err.log</string>
# </dict>
# </plist>
# Make sure to replace /path/to/your/ruby, /path/to/your/script.rb, /path/to/your/log/output.log, and /path/to/your/log/error.log with the actual paths. The RunAtLoad key makes sure the script starts at login, and KeepAlive ensures it's restarted if it exits.
#
# Load the Launch Agent:
# Run the following command to load the launch agent:
#
# bash
# Copy code
# sudo launchctl load ~/Library/LaunchAgents/com.rocco.websocket-filewatcher.plist
# The script will now run at startup.
#
# 2. Implement Restart Mechanism in Your Ruby Script
# To ensure that your Ruby script stays running, you can implement a restart mechanism within the script itself. One way to do this is by wrapping the entire script's logic in a loop. If an exception occurs, the script will sleep for a specified duration and then restart. Add this loop to the outermost scope of your script:
#
# ruby
# Copy code
# loop do
#   begin
#     # Your existing script logic here
#
#   rescue StandardError => e
#     puts "Error: #{e.message}"
#     sleep 5 # wait before attempting to restart
#   end
# end
# This loop will keep the script running indefinitely. If an error occurs, it will print the error message, sleep for 5 seconds (adjust as needed), and then restart.
#
# By combining the launch agent and the restart mechanism in your Ruby script, you should have a setup that starts your script at login and keeps it running continuously. Adjust the paths, sleep durations, and error handling according to your specific requirements.
