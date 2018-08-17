#!bin/bash
now=`date`
echo "$now -- cache and stop -- begin"
file="/workspace/dist/GameServer/signal_term.txt"
rm -f "$file"
kill -15 `lsof -t -i :8881`
count=0
while [ ! -f "$file" ]
do
  if [ $count -le 120 ]; then
    echo "wait 5 seconds ..."
    sleep 5
    count=$(($count+1))
  else
     echo "wait toooooo long, exit"
     exit
  fi
done
echo "cache to db ..."
sleep 100
sh start.sh stop
echo "sh start.sh stop -- over"
echo "sleep 5 ..."
sleep 5
now=`date`
echo "$now -- cache and stop -- over"

