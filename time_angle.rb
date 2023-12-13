time = ARGV[0] || Time.now.strftime("%H:%M:%S.%L")
hour, minute, second = time.split(":").map(&:to_f)


second_ratio = second.to_i / 60.to_f
minute_ratio = minute.to_i / 60.to_f + (second_ratio / 60.to_f)

hour -= 12 if hour >= 12
hour_ratio = (hour.to_i / 12.to_f) + (minute_ratio / 60.to_f)

minute_angle = minute_ratio * 360
hour_angle = hour_ratio * 360

angle = hour_angle - minute_angle
angle += 360 if angle < 0
angle = 360 - angle if angle > 180


puts "hour_ratio: #{hour_ratio}"
puts "Angle: #{angle.round(2)}"
