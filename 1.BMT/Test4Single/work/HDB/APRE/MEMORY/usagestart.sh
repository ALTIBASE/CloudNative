rm -f ./usage_collect
INTERVAL=0.5
DBPID=`ps -ef | grep $USER | grep "altibase -p" | grep -v grep | awk '{print $2}'`
top -d $INTERVAL -p $DBPID -b > ./usage_collect &
