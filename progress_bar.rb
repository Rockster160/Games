# TODO: Add all sorts of options and things
# * Custom width
# * Option to show % at the end
# * Option to show message at front
# * Custom chars / colors
class ProgressBar
  attr_accessor :total, :current

  def self.track(total, enumerator, &block)
    bar = new(total)
    enumerator.each do |item|
      block.call(item)
      bar.increment
    end
    bar.finish
  end

  def initialize(total)
    @current = 0
    @total = total
    @start = Time.now

    show
  end

  def increment
    @current += 1
    show
  end

  def show
    width = 50
    percent = current/total.to_f
    filled = (width*percent).to_i
    empty = width - filled

    show_bar = "[#{'='*filled}#{' '*empty}]"
    show_percent = "#{(percent*100).floor.to_s.rjust(3, " ")}%"
    show_progress = "#{@current.to_s.rjust(total.to_s.length)}/#{total}"
    print "\r#{show_bar} #{show_percent} #{show_progress} | #{duration} \e[K"
  end

  def finish
    puts "\nFinished #{@total} records in #{duration}"
  end

  def duration
    return "N/A" unless @start

    seconds = (::Time.now - @start).to_i
    return "<1s" if seconds.to_i <= 1

    time_lengths = {
      s: 1,
      m: 60,
      h: 60 * 60,
      d: 24 * 60 * 60,
      w: 7 * 24 * 60 * 60,
    }

    time_lengths.reverse_each.with_object([]) { |(time, length), durations|
      next if length > seconds
      next if durations.length >= 2 # sig figs

      count = (seconds / length).round
      seconds -= count * length

      durations << "#{count}#{time}"
    }.join(" ")
  end
end
