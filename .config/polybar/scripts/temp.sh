#!/bin/bash
temp=$(redshift -p -l 47.71:2.76 > /dev/null 2>&1 | grep temperature | cut -c 20-30)
result=$(ps -C redshift | grep -o redshift)
if [ "$result" == "redshift" ]
then
  echo " ● "
else
  echo " ◎ "
fi
