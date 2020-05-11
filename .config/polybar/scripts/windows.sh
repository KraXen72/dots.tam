#!/bin/sh
# SOURCE: https://github.com/aroma1994/polybar-windows
# Somewhat altered to fulfill my needs. Thank you.

active_window=$(xprop -root _NET_ACTIVE_WINDOW|cut -d ' ' -f 5 | \
  sed -e 's/../0&/2')
current_display=$(wmctrl -d|grep "*"|awk '{print $1}')

color0="250F0B"
color1="E7A09E"

active_left="%{F#$color0}%{+u}%{u#$color1} "
active_right=" %{-u}%{F-}"

windows_list=$(wmctrl -lx|awk -vORS="" -vOFS="" \
  -v current_display="$current_display" \
  -v active_window="$active_window" \
  -v active_left="$active_left" \
  -v active_right="$active_right" \
  '{
    if ($2==current_display || $2=="-1") {

      $3=tolower($3)
      n=split($3,window_title,".")

      if ($1==active_window) {
        window_title[n]=active_left window_title[n] active_right
      }

      else {
        window_title[n]=" " window_title[n] " "
      }

      if ( window_title[n] == " yad " ||  window_title[n] == " polybar ") {
        print ""
      }

      else if (i == "") {
        print "%{A1:~/bin/raise_or_minimize "$1":}"window_title[n]"%{A}"
        i = 1
      }

      else {
        print "·%{A1:~/bin/raise_or_minimize "$1":}"window_title[n]"%{A}"
      }
    }
  }')

echo $windows_list
