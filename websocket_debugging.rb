require "websocket-client-simple"
require "json"

def present(hash)
  hash&.inspect&.gsub(/:(\w+)=>/, '\1: ')
end

class CableWebsocket
  def initialize(url, headers: {})
    @spinner = Spinner.new
    @url = url
    @headers = headers
    @last_ping = 0
    @state = :closed
  end

  def connect
    handler = self # Init a local variable that the ws blocks will see
    @ws = WebSocket::Client::Simple.connect(@url, headers: @headers)

    @ws.on(:open) do
      puts "[Connected to ActionCable server]"
    end

    @ws.on(:message) do |message|
      handler.receive(message)
    end

    @ws.on(:close) do |event|
      puts "[Closing: #{event}]"
      if event
        if event.code == 1000
          puts "[Connection closed cleanly]"
        else
          puts "[Connection closed with error code #{event.code}: #{event.reason}]"
        end
      end
      puts "[closed]"
    end

    # Wait for user input, then send as a message to the server
    loop do
      input = gets.chomp
      break if input.downcase == "exit"
      next unless [:open, :closed, :between].include?(input.to_sym)

      @state = input
      broadcast({ action: :receive, state: @state })
    end

    puts "[Done]"

    # Close the connection when done
    @ws.close
  end

  def broadcast(data=nil, command: :message)
    puts "\e[36m→\e[90m #{present(data) || command}\e[0m"
    packet = {
      command: command,
      identifier: JSON.dump(channel: :SocketChannel, channel_id: :garage, user_id: 1)
    }
    packet.merge!({ data: JSON.dump(data) }) unless data.nil?

    @ws.send(JSON.dump(packet))
  end

  def receive(message)
    data = JSON.parse(message.data, symbolize_names: true)
    puts "\e[33m←\e[90m #{present(data)}\e[0m" unless data.dig(:type).to_s.to_sym == :ping
    case data.dig(:type).to_s.to_sym
    when :ping
      @last_ping = data[:message]
      @spinner.tick
      return
    when :welcome
      broadcast(command: :subscribe)
    when :confirm_subscription
      puts "[Fully connected]"
      broadcast({ action: :receive, state: :closed })
    when :disconnect
      puts "\e[31m[DISCONNECTED]\e[0m"
      @ws.close
    else
      if data.dig(:message, :request) == "get"
        broadcast({ action: :receive, state: @state })
      else
        puts "Unknown Message: #{data}"
      end
    end
  end
end

class Spinner
  def initialize = @tick = 0
  def chars = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏".split("")
  def tick
    print("\r  #{chars[(@tick+=1)%chars.length]} \r")
  end
end


if $0 == __FILE__ # This script is being run directly from the command line
  require "base64"
  auth_token = Base64.encode64("Rockster160:#{ENV["LOCAL_ME_PASS"]}").strip
  # server_url = "wss://ardesian.com/cable"
  server_url = "ws://localhost:3141/cable"
  authorization = "Basic #{auth_token}"

  CableWebsocket.new(server_url, headers: { Authorization: authorization }).connect
else # This script is being required in another script
  puts "This script is being required."
end
