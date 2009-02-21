require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

class TweetsDatabase

  def initialize(screen_name)
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :dbfile  => "rss2twitter_#{screen_name}.db"
    )
  end

end

