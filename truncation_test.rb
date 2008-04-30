#!/bin/ruby

max = 140 # message limit for twitter

for x in 1..max do
  printf "%d", ( x % 10 )
end
printf "\n"

msg = "You are only coming through in waves. Your lips move but I can't hear what you're saying. I have become comfortably numb. A distant ship's smoke on the horizon."
printf "%s", msg[0..max]