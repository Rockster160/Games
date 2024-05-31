require "websocket-client-simple"
require "thread"
require_relative "./logger"

class WebsocketLogger
  attr_accessor :url, :headers, :logger, :logger_file, :last_ping, :ws, :thread

  def initialize(url, headers: {}, logger_file: "websocket.log")
    @url = url
    @headers = headers
    @logger_file = logger_file
    @logger = Logger.new(logger_file)
    @last_ping = 0
    # @state = :closed
  end

  def connect(open: nil, message: nil, close: nil, error: nil)
    handler = self # local variables are passed to thread
    @thread = Thread.new do
      ws = WebSocket::Client::Simple.connect(handler.url)
      handler.ws = ws

      ws.on(:open) do
        handler.logger.info("Websocket connected.")
        open&.call
      end

      ws.on(:message) do |msg|
        handler.logger.info("Received: #{handler.present(msg)}\n#{handler.present(msg.data)}")
        message&.call(msg)
      end

      ws.on(:close) do |e|
        handler.logger.info("Websocket closed: #{e.code}, #{e.reason}")
        close&.call(e)
        exit
      end

      ws.on(:error) do |e|
        handler.logger.error("Error: #{e.message}")
        error&.call(e)
      end

      Thread.current[:ws] = ws

      loop { sleep 1 }
    end
  end

  def broadcast(message)
    # @thread[:ws].send(message)
    @ws.send(message)
    logger.info("Sent: #{message}")
  end

  def present(data)
    data&.inspect&.gsub(/:(\w+)=>/, '\1: ')
  end
end

begin
  server_url = "wss://platform-websockets-6kqb5ajsla-uc.a.run.app/events/#{ENV["WS_EVENT_ID"]}"
  handler = WebsocketLogger.new(server_url)
  puts "Use `tail -f #{handler.logger}` to view websocket output"
  handler.connect

  loop do
    print "Type a message to send: "
    input = gets.strip
    if input.downcase == "exit"
      handler.thread.kill
      break
    end
    handler.broadcast(input) if handler.thread.alive?
  end
rescue SystemExit, Interrupt
  logger.info("Program interrupted, closing websocket.")
  handler.thread.kill
end
