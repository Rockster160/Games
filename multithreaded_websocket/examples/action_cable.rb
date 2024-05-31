# Currently working!

require_relative "../multithreaded_websocket"
require "base64"

begin
  @channel = :AmzUpdatesChannel
  @identifier = JSON.dump(channel: @channel)

  url = "ws://localhost:3141/cable"
  auth = "username:password"
  auth = "Rockster160:#{ENV["LOCAL_ME_PASS"]}"
  auth_token = Base64.urlsafe_encode64(auth).strip
  authorization = "Basic #{auth_token}"
  @ws = MultithreadedWebsocket.new(url, headers: { Authorization: authorization }, log: "log.log")

  def inbound(handler, json)
    puts "INBOUND[#{json}]"

    # if json.dig(:message, :request) == "get"
    #   handler.broadcast({ action: :receive, state: @state })
    # else
    #   puts "Unknown Message: #{json}"
    # end
    # {}
  end

  # { action: "change", order_id: order.order_id, item_id: order.item_id, remove: true }

  def broadcast(data, command: :message)
    json = JSON.parse(data) rescue { action: data }

    @ws.broadcast({
      command: command,
      identifier: @identifier,
      data: JSON.dump(json)
    })
  end

  # receive must be a lambda
  receive = lambda do |handler, json|
    # handler comes from the ws body
    puts "\e[33m←\e[90m #{json}\e[0m" unless json.dig(:type).to_s.to_sym == :ping
    case json.dig(:type).to_s.to_sym
    when :ping
      # @ws.last_ping = json[:message]
      # @spinner.tick
      print "."
      return
    when :welcome
      handler.broadcast({ command: :subscribe, identifier: @identifier, type: :confirm_subscription })
    when :confirm_subscription
      puts "[Fully connected]"
      broadcast(:request)
    when :disconnect
      puts "\e[31m[DISCONNECTED]\e[0m"
      handler.close
    else
      inbound(handler, json)
    end
  end

  handler = @ws # scoping magic is making this weird- need to pass this into broadcasts
  @ws.connect do |connection| # Loops continuously with a `sleep 1` to keep thread open
    # All of the below are optional
    connection.on(:open) do
      puts "Opened!"
    end

    connection.on(:message) do |msg|
      json = ::JSON.parse(msg.data, symbolize_names: true) rescue nil
      case json
      when ::Hash then receive.call(handler, json)
      when ::Array then puts("Array: #{json.inspect}")
      when ::String then puts("String: #{json.inspect}")
      else
        puts("Unknown: [#{json.class}|#{msg.class}]: #{json.inspect}\n|#{msg.inspect}")
      end
    end

    # connection.on(:close) do |e|
    # end
    #
    # connection.on(:error) do |e|
    # end
  end

  loop do
    break if @ws.closed?

    print "Type a message to send: "
    input = gets.strip
    @ws.close if input.downcase == "exit"
    # @ws.broadcast(input) # Maybe attempt to parse JSON for sending data?
    broadcast(input)
  end
rescue SystemExit, Interrupt
  @ws&.close # Make sure it handles closing twice nicely
ensure
  @ws&.close # Make sure it handles closing twice nicely
end
