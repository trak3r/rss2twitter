require File.dirname(__FILE__) + '/test_helper'

class Rss2twitterTest < Test::Unit::TestCase

  def test_truncation
    max = 140 # message limit for twitter

    for x in 1..max do
      printf "%d", ( x % 10 )
    end
    printf "\n"

    msg = "You are only coming through in waves. Your lips move but I can't hear what you're saying. I have become comfortably numb. A distant ship's smoke on the horizon."
    printf "%s", msg[0..max]
  end

  def test_shorturl_services
    [ 'rubyurl',
      'tinyurl',
      'shorl',
      'snipurl',
      'metamark',
      'makeashorterlink',
      #  'skinnylink',
      'linktrim',
      'shorterlink',
      'minlink',
      'lns',
      'fyad',
      'd62',
      'shiturl',
      #  'littlink',
      'clipurl',
      'shortify',
      'orz',
      'moourl',
      'urltea'].each do |method|
      printf "%20s: ", method
      begin
        printf "%s", ShortURL.shorten('http://trak3r.blogspot.com', method.to_sym)
      rescue InvalidService, SocketError
        printf "broken!"
      end
      printf "\n"
    end
  end

end