#!/bin/bash
result=$(ps -C redshift | grep -o redshift)
if [ "$result" == "redshift" ]
then
redshift -x && pkill redshift && dunstify -r 1 "Screen Temperature Reset." -t 500 
else
redshift -r -l 47.71\:2.76 &
dunstify "Screen Warmth Auto-Adjusting." -r 1 -t 500
fi
