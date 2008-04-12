# borrowed from http://snippets.dzone.com/posts/show/3714
#
# TODO:
# - work with HTTPS
# - check for db file existence so you don't have to comment-out code
# - load target information from a YAML file or take as a constructor
# - convert into gem
# - publish to GitHub

require 'rubygems'
require 'active_record'
require 'simple-rss'
require 'open-uri'
require 'twitter'
require 'yaml'

yaml_file_name = 'rss2twitter.yml'

def missing_or_empty_yaml(yaml_file_name)
  print <<"EOF"

  Please define a YAML file named #{yaml_file_name}
  containing the following values:

    path_to_sqlite_db: '/PATH/TO/db.sqlite'
    twitter_email: 'yourtwitteremail@bla.com'
    twitter_password: 'secret'
    rss_url: 'http://yoursite.com/index.xml'
    rss_user_agent: 'http://twitter.com/yourbot'

EOF
  exit
end

begin
  prefs = YAML::load_file("#{yaml_file_name}")
rescue
  missing_or_empty_yaml yaml_file_name
end

missing_or_empty_yaml(yaml_file_name) unless prefs

raise "Please define \"path_to_sqlite_db\" in your YAML file." unless prefs['path_to_sqlite_db']
raise "Please define \"twitter_email\" in your YAML file." unless prefs['twitter_email']
raise "Please define \"twitter_password\" in your YAML file." unless prefs['twitter_password']
raise "Please define \"rss_url\" in your YAML file." unless prefs['rss_url']
raise "Please define \"rss_user_agent\" in your YAML file." unless prefs['rss_user_agent']

raise "STOP!  (I wanna go home...)"

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :dbfile  => path_to_sqlite_db
)

#uncomment this section the first time to create the table
#
#ActiveRecord::Schema.define do
#    create_table :item do |table|
#        table.column :title, :string
#        table.column :link, :string
#    end
#end

class Item < ActiveRecord::Base
  def to_s
    "#{self.title[0..(130-self.link.length)]} - #{self.link}"
  end
end

#run the beast
rss_items = SimpleRSS.parse open(rss_url ,"User-Agent" => rss_user_agent)

for item in rss_items.items
  Item.transaction do
    unless existing_item = Item.find(:all, :conditions => ["link=?", item.link]).first
      twitter ||= Twitter::Base.new(twitter_email, twitter_password)
      new_item = Item.create(:title => item.title, :link => item.link) 
      twitter.post(new_item.to_s)
    end
  end
end
