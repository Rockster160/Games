require "minitest/autorun"
require "time"
require "pry-rails"

# Helper methods
def now
  @now ||= DateTime.now
  now = DateTime.now
  hour += 12 if now.hour >= hour
  DateTime.new(now.year, now.month, now.day, hour, 0, 0, now.zone)
end

def parse(str)
  `ruby /Users/rocco/code/games/time_parser/parse.rb '#{str}'`.strip
end

class TestTimeParsing < Minitest::Test
  # assert_equal("expected", "actual")

  # Relative
  def test_next
    assert_equal(at(10).strftime("%m/%d/%Y %H:%M"), parse("something at 10"))
  end

  def test_tomorrow
    assert_equal((at(10) + 1).strftime("%m/%d/%Y %H:%M"), parse("tomorrow at 10"))
  end

  def test_future
    "in 2 days at 3"

    now = DateTime.now
    in_2_days_at_3 = DateTime.new(now.year, now.month, now.day + 2, 15, 0, 0, now.zone)

    assert_equal(in_2_days_at_3.strftime("%m/%d/%Y %H:%M"), parse("something in 2 days at 3"))
  end
end
