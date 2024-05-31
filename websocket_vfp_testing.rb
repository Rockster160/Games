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
      puts "[Connected to WebSocket server]"
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
      # broadcast({ action: :receive, state: @state })
    end

    puts "[Done]"

    # Close the connection when done
    @ws.close
  end

  def broadcast(data=nil, command: :message)
    puts "\e[36m→\e[90m #{present(data) || command}\e[0m"
    # packet = {
    #   command: command,
    #   identifier: JSON.dump(channel: :SocketChannel, channel_id: :garage, user_id: 1)
    # }
    # packet.merge!({ data: JSON.dump(data) }) unless data.nil?

    # @ws.send(JSON.dump(packet))
  end

  def receive(message)
    data = JSON.parse(message.data, symbolize_names: true)
    puts "\e[33m←\e[90m #{present(data)}\e[0m" unless data.dig(:type).to_s.to_sym == :ping
    # case data.dig(:type).to_s.to_sym
    # when :ping
    #   @last_ping = data[:message]
    #   @spinner.tick
    #   return
    # when :welcome
    #   broadcast(command: :subscribe)
    # when :confirm_subscription
    #   puts "[Fully connected]"
    #   broadcast({ action: :receive, state: :closed })
    # when :disconnect
    #   puts "\e[31m[DISCONNECTED]\e[0m"
    #   @ws.close
    # else
    #   if data.dig(:message, :request) == "get"
    #     broadcast({ action: :receive, state: @state })
    #   else
    #     puts "Unknown Message: #{data}"
    #   end
    # end
  end
end

class Spinner
  def initialize = @tick = 0
  def chars = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏".split("")
  def tick
    print("\r  #{chars[(@tick+=1)%chars.length]} \r")
  end
end


# // Good to run this one as-is
# curl -X POST https://events.atscall.me/auth -H "Authorization: Basic $VFP_BASIC_AUTH"
#
# // Need to replace the bearer token from <token> in the previous response, and <session_id> from previous response
# curl -X POST "https://events.atscall.me/request_conn" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d "{\"session_id\": <session_id>}"
#
# // Need to replace the bearer token from <token> in the first response, <session_id> from the first response, and <connection_id> from the second response
# curl -X GET "https://events.atscall.me/connect?session_id=<session_id>&connection_id=<connection_id>" -H "Connection: keep-alive" -H "Authorization: Bearer <token>"

# curl -X GET "https://events.atscall.me/connect?session_id=1186779&connection_id=1186392" -H "Connection: keep-alive" -H "Authorization: Bearer $VFP_AUTH_TOKEN"

require "base64"
# auth_token = Base64.encode64("Rockster160:#{ENV["LOCAL_ME_PASS"]}").strip
# server_url = "wss://ardesian.com/cable"
# server_url = "ws://localhost:3141/cable"
auth_token = ENV["VFP_AUTH_TOKEN"]
authorization = "Basic #{auth_token}"

CableWebsocket.new("https://events.atscall.me/connect?session_id=1186779&connection_id=1186392", headers: { Authorization: authorization, Connection: "Keep-Alive" }).connect
