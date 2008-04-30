require 'rubygems'
require 'twitter'

require 'lib/config'
require 'lib/database'
require 'lib/feed'

def parse_and_push
  settings = Settings.new

  for item in process(settings.rss_url)
    Item.transaction do
      unless existing_item = Item.find(:all, :conditions => ["link=?", item.link]).first
        twitter ||= Twitter::Base.new(settings.twitter_email, settings.twitter_password)
        new_item = Item.create(:title => item.title, :link => item.link) 
        twitter.post(new_item.to_s)
      end
    end
  end
end
