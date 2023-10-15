require 'nokogiri'
require 'httparty'

url = ARGV[0].to_s
html = Nokogiri::HTML(HTTParty.get(url).body)
text = html.at('body').inner_text
puts text
