;; `emacs --batch -l time_angle.el`

(setq current-time (current-time))
(setq decoded-time (decode-time current-time))

(setq hour (nth 2 decoded-time))
(setq minute (nth 1 decoded-time))
(setq second (nth 0 decoded-time))

(if (>= hour 12)
    (setq hour (- hour 12)))

(setq second-ratio (/ (float second) 60.0))
(setq second-offset (/ (float second-ratio) 60.0))

(setq minute-ratio (/ (float minute) 60.0))
(setq minute-ratio (+ minute-ratio second-offset))
(setq minute-offset (/ (float minute-ratio) 60.0))

(setq hour-ratio (/ (float hour) 12.0))
(setq hour-ratio (+ hour-ratio minute-offset))

(setq hour-angle (* hour-ratio 360))
(setq minute-angle (* minute-ratio 360))
(setq angle (- hour-angle minute-angle))

(if (< angle 0)
    (setq angle (+ angle 360)))

(if (> angle 180)
    (setq angle (- 360 angle)))

(message "Current time: %02d:%02d:%02d" hour minute second)
(message "Angle: %.2f" angle)
