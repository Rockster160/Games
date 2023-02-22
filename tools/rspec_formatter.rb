# require "pry-rails"
class ErrorShowingFormatter
  RSpec::Core::Formatters.register self, :example_failed

  def initialize(output)
    @output = output
  end

  def example_failed(notification)
    @output << RSpec::Core::Formatters::ConsoleCodes.wrap(" #{notification.example.location.gsub(/^\.\//, "")} ", :failure)
  end
end
