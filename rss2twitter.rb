# borrowed from http://snippets.dzone.com/posts/show/3714
#
# TODO:
# - work with HTTPS
# - check for db file existence so you don't have to comment-out code
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

def yamlized(prefs,token)
  raise "Please define \"#{token}\" in your YAML file." unless prefs["#{token}"]    
end

path_to_sqlite_db = yamlized(prefs,'path_to_sqlite_db')
twitter_email = yamlized(prefs,'twitter_email')
twitter_password = yamlized(prefs,'twitter_password')
rss_url = yamlized(prefs,'rss_url')
rss_user_agent = yamlized(prefs,'rss_user_agent')

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
