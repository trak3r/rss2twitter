require 'rubygems'
require 'twitter'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'simple-rss'

require 'lib/database'
require 'lib/item'

class RSS2Twitter

  def initialize(rss_url, screen_name, password)
    @rss_url = rss_url
    @screen_name = screen_name
    @password = password
  end
  
  def parse_and_push
    TweetsDatabase.new(@screen_name)
    for item in pull_items(@rss_url)
      Item.transaction do
        unless Item.find(:all, :conditions => ["link=?", item.link]).first
          twitter ||= Twitter::Base.new(@screen_name, @password)
          new_item = Item.create(:title => item.title, :link => item.link)
          twitter.post(new_item.to_s)
        end
      end
    end
  end

  private

  def pull_items(rss_url)
    parsed_uri = URI.parse(rss_url)
    http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
    http.use_ssl = 'https' == parsed_uri.scheme
    request = Net::HTTP::Get.new("#{parsed_uri.path}?#{parsed_uri.query}")
    request.basic_auth parsed_uri.user, parsed_uri.password
    response = http.request(request)
    rss_items = SimpleRSS.parse response.body
    return rss_items.items.reverse
  end

end