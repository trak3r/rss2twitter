require 'active_record'
require 'shorturl'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :dbfile  => 'rss2twitter.db'
)

class Item < ActiveRecord::Base

  def to_s
    "#{self.optimized_title[0..(tweet_limit-self.short_url.length)]} #{self.short_url}"
  end
  
  protected 
  
  def tweet_limit
    139 # leave one off for fudging
  end

  def short_url
    @cached_short_url ||= ShortURL.shorten(self.link, :metamark)
  end
  
  def optimized_title
    # for Trac feeds (which is why I wrote this) strip off some
    # extraneous verbiage to save every last precious character
    tidbits = self.title.scan( /^Changeset \[(.*?)\]\: (.*)/ ).flatten
    if 2 == tidbits.length
      return sprintf( "%s %s", *tidbits ) 
    else # not a Trac changeset or we failed to parse it
      return self.title
    end
  end

end

unless Item.table_exists?
  ActiveRecord::Schema.define do
    create_table :items do |table|
        table.column :title, :string
        table.column :link, :string
    end
  end
end
