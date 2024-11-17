states = %w(░ ▒ ▓)
# █ -- this one is big and ugly

# timer 2s 20

width = 100
# direction = :both # change the delay per tick to not divide by 2 if we want single direction
startup = 1.5 # seconds
# startup = 0.2 # seconds

seconds, count = ARGV&.map(&:to_f)
count = count.to_i

loop do
  break if startup <= 0
  print "\r Get ready! #{startup.round(1)} "
  startup -= 0.1
  sleep 0.1
end

delay_per_tick = (seconds/2.0) / width
frames = states.length
rstates = states.reverse.push(" ").tap(&:shift)
delay_per_frame = delay_per_tick / frames.to_f
print "\e[?25l\r" # Hide Cursor
# puts "Delay: #{delay_per_tick}"
puts "|".center(width+2)
count.times do |t|
  print "\r\e[K[#{" "*width}] #{count-t}" # Full empty bar
  print "\e[2G" # Move to first character of bar

  width.times do |j|
    states.each do |char|
      print "#{char}\b"
      sleep delay_per_frame
    end
    print states.last # Reprint the last char since we do backspaces above
  end

  print "\b" # Step back before the closing bar
  width.times do |j|
    rstates.each do |char|
      print "#{char}\b"
      sleep delay_per_frame
    end
    print "\b"
  end
end
print "\e[?25h" # Show Cursor
puts
