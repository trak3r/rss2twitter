# borrowed from http://snippets.dzone.com/posts/show/3714
# heavily modified (and improved I hope) by Ted (rss2twitter@rudiment.net)
#
# TODO:
# - convert into gem
# - publish to GitHub

require 'rubygems'
require 'active_record'
require 'ftools'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'simple-rss'
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
    rss_url: 'https://username:password@yoursite.com/index.xml'
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
  if prefs["#{token}"]
    return prefs["#{token}"]
  else
    raise "Please define \"#{token}\" in your YAML file."    
  end
end

path_to_sqlite_db = yamlized(prefs,'path_to_sqlite_db')
twitter_email = yamlized(prefs,'twitter_email')
twitter_password = yamlized(prefs,'twitter_password')
rss_url = yamlized(prefs,'rss_url')
rss_user_agent = yamlized(prefs,'rss_user_agent')

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :dbfile  => path_to_sqlite_db
)

class Item < ActiveRecord::Base
  def to_s
    "#{self.title[0..(130-self.link.length)]} - #{self.link}"
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

#run the beast
parsed_uri = URI.parse(rss_url)
http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)
http.use_ssl = 'https' == parsed_uri.scheme
request = Net::HTTP::Get.new(parsed_uri.path)
request.basic_auth parsed_uri.user, parsed_uri.password
response = http.request(request)

rss_items = SimpleRSS.parse response.body

for item in rss_items.items
  Item.transaction do
    unless existing_item = Item.find(:all, :conditions => ["link=?", item.link]).first
      twitter ||= Twitter::Base.new(twitter_email, twitter_password)
      new_item = Item.create(:title => item.title, :link => item.link) 
      twitter.post(new_item.to_s)
    end
  end
end
