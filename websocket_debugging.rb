require "websocket-client-simple"
require "json"

def present(data)
  data&.inspect&.gsub(/:(\w+)=>/, '\1: ')
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
      puts "[Connected to server]"
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

      @state = input
      broadcast({ action: :receive, state: @state })
    end

    # Close the connection when done
    @ws.close
    puts "[Done]"
  end

  def broadcast(data=nil)
    puts "\e[36m→\e[90m #{present(data)}\e[0m"

    @ws.send(JSON.dump(data))
  end

  def receive(message)
    puts "\e[33m←\e[90m #{present(message)}\n#{present(message.data)}\e[0m"
    print "\a"
    # data = JSON.parse(message.data, symbolize_names: true)
    # puts "\e[33m←\e[90m #{present(data)}\e[0m" #unless data.dig(:type).to_s.to_sym == :ping
    case data.dig(:type).to_s.to_sym
    when :ping
      puts "Ping!"
      @last_ping = data[:message]
      @spinner.tick
      broadcast({ action: :pong })
      return
    # when :disconnect
    #   puts "\e[31m[DISCONNECTED]\e[0m"
    #   @ws.close
    # else
    #   if data.dig(:message, :request) == "get"
    #     broadcast({ action: :receive, state: @state })
    #   else
    #     puts "Unknown Message: #{data}"
    #   end
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

class Receiver
end


if $0 == __FILE__ # This script is being run directly from the command line
  # require "base64"
  # auth_token = Base64.encode64("Rockster160:#{ENV["LOCAL_ME_PASS"]}").strip
  # server_url = "wss://ardesian.com/cable"
  # server_url = "ws://localhost:3141/cable"
  # authorization = "Basic #{auth_token}"

  CableWebsocket.new(server_url).connect
  # CableWebsocket.new(server_url, headers: { Authorization: authorization }).connect
else # This script is being required in another script
  puts "This script is being required."
end
