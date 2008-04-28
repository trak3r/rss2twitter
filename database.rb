require 'active_record'
require 'shorturl'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :dbfile  => 'rss2twitter.db'
)

class Item < ActiveRecord::Base
  def tweet_limit
    139 # leave one off for fudging
  end

  def short_url
    @cached_short_url ||= ShortURL.shorten(self.link, :tinyurl)
  end

  def to_s
    "#{self.title[0..(tweet_limit-self.short_url.length)]} #{self.short_url}"
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
