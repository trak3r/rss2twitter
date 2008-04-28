require 'net/http'
require 'net/https'
require 'open-uri'
require 'simple-rss'

def process(rss_url)
  parsed_uri = URI.parse(rss_url)
  http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
  http.use_ssl = 'https' == parsed_uri.scheme
  request = Net::HTTP::Get.new("#{parsed_uri.path}?#{parsed_uri.query}")
  request.basic_auth parsed_uri.user, parsed_uri.password
  response = http.request(request)
  rss_items = SimpleRSS.parse response.body
  return rss_items.items.reverse
end
