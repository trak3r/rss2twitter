#!/bin/ruby

require 'rubygems'
require 'shorturl'

[ 'rubyurl',
  'tinyurl',
  'shorl',
  'snipurl',
  'metamark',
  'makeashorterlink',
  'skinnylink',
  'linktrim',
  'shorterlink',
  'minlink',
  'lns',
  'fyad',
  'd62',
  'shiturl',
  'littlink',
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
