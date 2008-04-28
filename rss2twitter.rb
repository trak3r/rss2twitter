# original logic borrowed from http://snippets.dzone.com/posts/show/3714
# heavily modified (and improved I hope) by Ted (rss2twitter@rudiment.net)

require 'rubygems'
require 'twitter'

require 'config'
require 'database'
require 'feed'

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
