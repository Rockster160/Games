require_relative "../multithreaded_websocket"

# Doesn't work- need to create a custom `connection` object that has the on(event) callbacks defined and then call those within the real ws events

begin
  def receive(msg)
    return if msg[:type] == "pong"

    print "\a"
    puts "Message received: #{msg}"
  end

  # url = "wss://echo.websocket.org"
  # url = "ws://ws.vi-server.org/mirror"
  url = "ws://0.0.0.0:8191"
  # url to connect to
  # headers for auth on connection
  # should have access to local variables?
  localvar = "yep"
  ws = MultithreadedWebsocket.new(url, headers: {}, log: "log.log")
  ws.connect do |connection| # Loops continuously with a `sleep 1` to keep thread open
    # All of the below are optional
    connection.on(:open) do
      puts "Opened!" # puts, p, print, etc is overridden and outputs to the log file
      puts "Should have access to local vars: [#{localvar}]"
    end

    connection.on(:message) do |msg|
      json = ::JSON.parse(msg.data, symbolize_names: true) rescue nil
      case json
      when ::Hash then receive(json)
      when ::Array then receive(json)
      when ::String then "String: #{json}"
      end
    end

    # connection.on(:close) do |e|
    # end
    #
    # connection.on(:error) do |e|
    # end
  end

  loop do
    break if ws.closed?

    print "Type a message to send: "
    input = gets.strip
    ws.close if input.downcase == "exit"
    ws.broadcast(input) # Maybe attempt to parse JSON for sending data?
  end
rescue SystemExit, Interrupt
  ws.close
ensure
  ws.close # Make sure it handles closing twice nicely
end
