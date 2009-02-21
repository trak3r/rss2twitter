require 'active_record'
require 'lib/item'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

class TweetsDatabase

  def initialize(screen_name)
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :dbfile  => "rss2twitter_#{screen_name}.db"
    )
    unless Item.table_exists?
      ActiveRecord::Schema.define do
        create_table :items do |table|
          table.column :title, :string
          table.column :link, :string
        end
      end
    end
  end

end

