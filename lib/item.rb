require 'shorturl'
require 'active_record'

class Item < ActiveRecord::Base

  def to_s
    "#{self.optimized_title[0..(tweet_limit-self.short_url.length)]} #{self.short_url}"
  end

  protected

  def tweet_limit
    138 # leave one off for fudging
  end

  def short_url
    @cached_short_url ||= ShortURL.shorten(self.link, :fyad)
  end

  def optimized_title
    # for Trac feeds (which is why I wrote this) strip off some
    # extraneous verbiage to save every last precious character
    tidbits = self.title.scan( /^Changeset \[(.*?)\]\: (.*)/ ).flatten
    if 2 == tidbits.length
      return tidbits[1] # sprintf( "%s %s", *tidbits )
    else # not a Trac changeset or we failed to parse it
      return self.title
    end
  end

end
