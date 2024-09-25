require "json"
require "rest-client"

["https://ardesian.com/webhooks/local_ping", "http://localhost:3141/webhooks/local_ping"].each do |url|
  headers = { "Authorization": "Basic #{ENV['PORTFOLIO_AUTH']}" }
  ::RestClient.post(url, {}, headers)
rescue StandardError => e
end
