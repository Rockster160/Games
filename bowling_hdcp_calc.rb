# These are a few samples of scores. The more we provide, the more accurate this will be.
# In this case, this is B, me, and Carlos (skipped you because I wasn't sure if they'd mixed scores or if your numbers were accurate)
# The format is total_score_count (not technically pin fall- it's end game scores, but they still call it "pins")
# Then game count
# Then current average
# I would normally do this in a hash or struct, but wrote it like this because it's easier to type on a phone.
scores = [
  # [total, games, hdcp]
  [1580, 9, 33],
  [1671, 9, 23],
  [1366, 9, 56]
]

# (150..250) gives us a "range" which is basically an array of each number between those two.
# This number represents the handicap base. I did a big range here just to be all encompassing.
(150..250).each do |hdcp_base|
  # This line skips the values that aren't divisible by 5. They don't typically use a number like "208" as the base. It's almost always a multiple of 5.
  # Again, this is probably excessive, but I imagine with the rounding that we'd get a couple of false positives.
  next unless hdcp_base % 5 == 0
  # This are the percentage ratios. The percent part of the calculation.
  (70..100).each do |hdcp_factor|
    # Same thing here, the factors are typically a multiple of 5, so skip all of the inbetweens.
    next unless hdcp_factor % 5 == 0
    # This is a sneaky little one-liner.
    # The "next unless" skips the rest of this code block (namely the "puts") since that's what we use to show if we were successful.
    # This pieces can be a little harder to understand because of that, so I'll re-write it a little simpler.
    # next unless scores.all? { |score|
    #   avg = (score[0] / score[1].to_f).round
    #   difference = (hdcp_base - avg) * (hdcp_factor/100.to_f)
    #   difference.ceil == score[2]
    # }
    # puts "#{hdcp_factor}% of #{hdcp_base}"

    # scores.all? is a fancy method kind of like `each`, but it returns a boolean on whether or not every single iteration returned a truthy value or not.
    calculation_matches_expected_hdcp = scores.all? { |score|
      # First we find the average by dividing total pins by the number of games.
      # The `to_f` here helps Ruby know to do exact match and not round... Even though we round right after.
      # I didn't have the round in the beginning because I wasn't sure how/when the averages were rounded.
      # They're rounded normally here (0.3 -> 0, 0.7 -> 1)
      avg = (score[0] / score[1].to_f).round
      # This is the actual calculation.
      # So when we say 85% of 220, that's the math below. (I rearranged the original math to be the same order as how it sounds)
      # Find the percentage. 85% is actually 0.85, so we take 85/100. Again, .to_f stops Ruby from rounding decimal values
      percentage = (hdcp_factor/100.to_f)
      # Now the math/algebra. We multiply the percentage by the difference of the handicap base (the 220) by your current average (B's is 175, for example), so the different would be 45
      difference = percentage * (hdcp_base - avg)
      # The next line we compare this result with what we KNOW the handicap is.
      # This is implicitly returing to that `all?` above. So if this is false, we know that this calculation is incorrect so we can move to the next one.
      # 0.85 * 45 = 38.25
      # .ceil means round, but always round up. So 0.1 rounds to 1. 38.25 rounds to 39. It always goes to the "ceiling"
      # So our difference.ceil here becomes 39, but we KNOW B's handicap is 33.
      # That means our current loop (85% of 220) is NOT correct.
      # That means this is false, which means `scores.all?` is false, which means we can move to the next iteration of the loop.
      difference.ceil == score[2]
    }

    # This is the equivalent of how I had it before. We "broke" out of the loop by saying "next" which means the `puts` line never runs.
    # That's basically the same as wrapping it in an if statement.
    if calculation_matches_expected_hdcp
      puts "#{hdcp_factor}% of #{hdcp_base}"
    end
  end
end

# You'll notice I don't have any gets or user input in this whole script.
# That's what I meant when I said you won't NORMALLY use gets. Most of the time you can provide input in a different way without pausing your command line script.
# This is especially true in a web app. You don't get to pause and have the user enter into a command line.
# It's still helpful when writing little scripts, but you can also just hardcode some inputs like I do with the `scores` array at the beginning.

# So if you run this file with `ruby bowling_hdcp_calc.rb` (or whatever you call it)
# You'll see that it outputs "95% of 210" - so we know that's our value!
# It is TECHNICALLY possible that we would get multiple outputs.
# If that were the case, we would just need to add a few more people's scores to get more accurate.
