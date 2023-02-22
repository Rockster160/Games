require "json"
require "net/http"

uri = URI("https://ardesian.com/jarvis")
req = Net::HTTP::Post.new(uri)
req.basic_auth("Rockster160", ENV["LOCAL_ME_PASS"])
req.set_form_data(message: "Hi Jarvis")

res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
puts res.body
