# TODO: Add all sorts of options and things
# * Custom width
# * Option to show % at the end
# * Option to show message at front
# * Custom chars / colors
class ProgressBar
  attr_accessor :total, :current

  def initialize(total)
    @current = 0
    @total = total

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
    print "\r#{show_bar} #{show_percent} #{show_progress}"
  end
end
