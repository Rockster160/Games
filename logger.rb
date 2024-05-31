# @logger = Logger.new("game.log")
# @logger.puts("Quick message") # Timestamp msg
# @logger.log("Quick message") # Timestamp msg
# @logger.debug("Quick message") # [DEBUG](grey)Timestamp msg
# @logger.error("Error message") # [ERROR](red)Timestamp msg

class Logger
  LOG_LEVELS = {
    debug: 0,
    info:  1,
    warn:  2,
    error: 3,
    yay:   4,
    log:   5,
  }
  LOG_COLORS = {
    yay:   32, # green
    debug: 36, # cyan
    info:  90, # grey
    warn:  33, # yellow
    error: 31, # red
  }
  def initialize(filename, log_level=:debug)
    @filename = filename
    @log_level = LOG_LEVELS[log_level] || 0
  end

  def output(msg, level=0)
    return if @filename.nil?
    return if LOG_LEVELS.key?(level) && LOG_LEVELS[level] < @log_level.to_i

    "#{timestamp}#{msg}".tap { |line| File.open(@filename, "a+") { |f| f.puts(line) } }
  end

  def timestamp
    Time.now.strftime("[%dd%mm%y-%H:%M:%S]")
  end

  def log(msg) # Just show a message regardless of log level
    output(msg, :log)
  end
  alias_method :write, :log
  alias_method :puts, :log

  LOG_COLORS.each do |level, color|
    define_method(level) do |msg|
      output("\e[#{color}m[#{level.to_s.upcase}]\e[0m #{msg}", level)
    end
  end
end
