require "websocket-client-simple"
require "json"
require_relative "../logger"

class MultithreadedWebsocket
  attr_accessor :url, :connection, :headers, :logger_file, :logger, :last_ping, :state, :ws

  def initialize(url, headers: {}, log: false)
    @url = url
    @headers = headers
    @logger_file = log
    @logger = Logger.new(@logger_file)
    @last_ping = 0
    @state = :pending
    puts "Use `tail -f #{@logger_file}` to view output" if @logger_file
    @logger.info("Start up")
  end

  def connect(&block)
    handler = self
    logger = @logger
    @thread = Thread.new do
      ws = WebSocket::Client::Simple.connect(handler.url, headers: handler.headers)
      Thread.current[:ws] = ws
      handler.ws = ws
      handler.state = :open

      ws.on(:open) do
        logger.info("Websocket connected.")
      end

      ws.on(:message) do |msg|
        # logger.info("WebSocket Received: #{msg}")
        @last_ping = Time.now
        ws.send(JSON.dump(type: :pong)) if msg.type == :ping
      end

      ws.on(:close) do |exc|
        if exc.respond_to?(:code)
          logger.info("Websocket closed: #{exc.code}, #{exc.reason}")
        else
          logger.info("Websocket closed: [#{exc.class}]: #{exc.try(:message)}")
        end
        exit
      end

      ws.on(:error) do |exc|
        logger.error("Error: [#{exc.class}]: #{exc.message}")
      end

      block.call(ws)

      loop { sleep 1 }
    end
  end

  def present(data)
    data&.inspect&.gsub(/:(\w+)=>/, '\1: ')
  end

  def broadcast(data)
    # Maybe puts an error if thread is not alive?
    return unless alive?

    logger.info("\e[36m→\e[90m #{present(data)}\e[0m")

    @ws&.send(JSON.dump(data))
  end

  def closed?
    @state == :closing || @state == :closed
  end

  def alive?
    !closed? && @thread&.alive?
  end

  def close
    @state = :closed
    @thread.kill if alive?
  end
end
