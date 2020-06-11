#!/bin/bash
# Quick and dirty workspace script using tamwm's layout switcher

active_dtop=$(wmctrl -d|grep "*"|awk '{print $10}')
color0="#250F0B"
color3="#F8E5AB"
color4="#DDE8F0"

active_left="%{F$color0}%{B$color3} "
active_right=" %{B-}%{F-}"

active_left_rs_off="%{F$color0}%{B$color4}%{u$color4} "
active_right_rs_off=" %{-u}%{B-}%{F-}"


inactive_left="%{F$color0} "
inactive_right=" %{F-}"

ps -C redshift | grep -o redshift &>/dev/null && redshift_status=1


dtops=$(wmctrl -d|awk -vORS="" -vOFS="" -v active_dtop="$active_dtop" -v active_left="$active_left" -v active_right="$active_right" -v inactive_left="$inactive_left" -v inactive_right="$inactive_right" -v alro="$active_left_rs_off" -v arro="$active_right_rs_off" -v rss="$redshift_status" '
    {
        if ($10==active_dtop) {
            if (rss == 1) {
                item=active_left $10 active_right
            } else {
                item=alro $10 arro
            }
        } else if ($10=="z") {
        next
        } else {
             item=inactive_left $10 inactive_right
        }
        if (rss==1) {
            print "%{A3:redshift -x && pkill redshift:}"
        } else {
            print "%{A3:redshift -r -l 47\:3 &:}"
        }
        $1 = $1 + 1
        if (i == "") {
            print "%{A1:xdotool key super+"$1":}"item"%{A}"
            i = 1
        } else {
            print "%{A1:xdotool key super+"$1":}"item"%{A}"
        }
        print "%{A}"
    }')

echo $dtops
