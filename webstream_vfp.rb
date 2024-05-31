# // Good to run this one as-is
# curl -X POST https://events.atscall.me/auth -H "Authorization: Basic $VFP_BASIC_AUTH"
#
# // Need to replace the bearer token from <token> in the previous response, and <session_id> from previous response
# curl -X POST "https://events.atscall.me/request_conn" -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d "{\"session_id\": <session_id>}"
#
# // Need to replace the bearer token from <token> in the first response, <session_id> from the first response, and <connection_id> from the second response
# curl -X GET "https://events.atscall.me/connect?session_id=<session_id>&connection_id=<connection_id>" -H "Connection: keep-alive" -H "Authorization: Bearer <token>"

# curl -X GET "https://events.atscall.me/connect?session_id=1186779&connection_id=1186392" -H "Connection: keep-alive" -H "Authorization: Bearer $VFP_AUTH_TOKEN"

# require "base64"
auth_token = ENV["VFP_AUTH_TOKEN"]
authorization = "Basic #{auth_token}"

# CableWebsocket.new(, headers: { Authorization: authorization, Connection: "Keep-Alive" }).connect
require 'net/http'

begin
  uri = URI("https://events.atscall.me/connect")
  uri.query = URI.encode_www_form({
    session_id: "1186790",
    connection_id: "1186403",
  })
  headers = {
    Authorization: authorization,
    Connection: "Keep-Alive",
  }

  Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
    request = Net::HTTP::Get.new(uri, headers)
    # Connection: "Keep-Alive"
    puts "Making request"
    http.request request do |response|
      puts "Got response"
      if response.code == "200"
        response.read_body do |chunk|
          puts "Reading response"
          puts chunk
        end
      else
        puts "\e[31mHTTP Error: #{response.code}\n#{response.body}\e[0m"
      end
    end
  end
rescue StandardError => e
  puts "\e[31mError: #{e.message}\e[0m"
end
