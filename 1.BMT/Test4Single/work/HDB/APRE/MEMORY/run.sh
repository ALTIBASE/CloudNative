#!/bin/sh

if [ "$STANDARD_IP" ];
then
    HOST=$STANDARD_IP
else
    HOST="localhost"
fi


if [ "$ALTIBASE_PORT_NO" ];
then
    PORT=$ALTIBASE_PORT_NO
else
    PORT="20300"
fi
osname=`uname`
path=`pwd`
#THRESHOLD="1000000"
THRESHOLD="10000"
UNIT="100"
DBUSER="SYS"
PASSWORD="MANAGER"
OPTION="DSN=$HOST;PORT_NO=$PORT;CONNTYPE=$CONNTYPE"
RECORDS="10000"

STANDARD_REVISION=`svn info $HOME/work/altidev4 | grep Revision | awk '{print $2}'`
export STANDARD_REVISION

STANDARD_INTERFACE="APRE"
export STANDARD_INTERFACE

if [ "$SCALE" ];
then
    RECORDS="$SCALE"
fi

./configure.sh
make clean
make 2> /dev/null
echo

if [ "$osname" = "Linux" ]; then
    rm -rf $HOME/performance/bin/Linux/usage_result
else
    rm -rf $HOME/performance/bin/HP/usage_result
fi

#./clean.sh
echo

case $CONNTYPE in
    "1" )
        export ISQL_CONNECTION="TCP"
        ;;
    "2" )
        export ISQL_CONNECTION="UNIX"
        ;;
    "3" )
        export ISQL_CONNECTION="IPC"
        ;;
    "7" )
	export ISQL_CONNECTION="IPC-DA"
	;;
esac
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f schema.sql
echo

echo "THREADS="$THREADS
echo "START="$START
echo "RECORED="$RECORDS
echo "UNIT="$UNIT
echo "THRESHOLD="$THRESHOLD
echo "TESTMODE="$TEST_MODE
echo $DBUSER $PASSWORD $OPTION


TEST_MODE="Insert"
START="0"
for THREAD in $THREADS
do
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path
./bmt_insert $THREAD $START $RECORDS $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START=`expr $START + $RECORDS`
done


TEST_MODE="Select"
START="0"
for THREAD in $THREADS
do
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path
./bmt_select $THREAD $START $RECORDS $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START=`expr $START + $RECORDS`
done


TEST_MODE="Update"
START="0"
for THREAD in $THREADS
do
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path
./bmt_update $THREAD $START $RECORDS $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION
#is -f count.sql 
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START=`expr $START + $RECORDS`
done


TEST_MODE="Insert+Select"
let START1=$RECORDS*$THREADS_COUNT
START2="0"
for THREAD in $THREADS
do
if [ $THREAD -eq 1 ]
then
echo "Thread Count is 1"
else
export STANDARD_ALLTHREAD=$THREAD
let THREAD1=$THREAD*$ISR_INSERT_RATIO/100
let THREAD2=$THREAD*$ISR_SELECT_RATIO/100
let RECORDS1=$RECORDS*$ISR_INSERT_RATIO/100
let RECORDS2=$RECORDS*$ISR_SELECT_RATIO/100
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path
./bmt_insert $THREAD1 $START1 $RECORDS1 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
./bmt_select $THREAD1 $START2 $RECORDS2 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
iPidCnt=`ps -ef | grep bmt_insert |grep -v grep | wc -l`
iPid=`ps -ef | grep bmt_insert |grep -v grep | awk '{print $2}'`
sPidCnt=`ps -ef | grep bmt_select |grep -v grep |wc -l`
sPid=`ps -ef | grep bmt_select |grep -v grep |awk '{print $2}'`
echo "iPid="$iPid
echo "sPid="$sPid
if [ "$osname" = "Linux" ]; then
    wait
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    if [ $iPidCnt -gt 0 ]; then
        wait $iPid
    else
        echo "iPid=0"
    fi
    if [ $sPidCnt -gt 0 ]; then
        wait $sPid
    else
        echo "sPid=0"
    fi
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START1=`expr $START1 + $RECORDS1`
START2=`expr $START2 + $RECORDS2`
fi
done


TEST_MODE="Select+Update"
START1="0"
let START2=$RECORDS*$THREADS_COUNT
for THREAD in $THREADS
do
if [ $THREAD -eq 1 ]
then
echo "Thread Count is 1"
else
export STANDARD_ALLTHREAD=$THREAD
let THREAD1=$THREAD*$SUR_SELECT_RATIO/100
let THREAD2=$THREAD*$SUR_UPDATE_RATIO/100
let RECORDS1=$RECORDS*$SUR_SELECT_RATIO/100
let RECORDS2=$RECORDS*$SUR_UPDATE_RATIO/100
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path

./bmt_select $THREAD1 $START1 $RECORDS1 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
./bmt_update $THREAD2 $START2 $RECORDS2 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
suPid1Cnt=`ps -ef | grep bmt_select |grep -v grep | wc -l`
suPid1=`ps -ef | grep bmt_select |grep -v grep |awk '{print $2}'`
suPid2Cnt=`ps -ef | grep bmt_update |grep -v grep | wc -l`
suPid2=`ps -ef | grep bmt_update |grep -v grep | awk '{print $2}'`
echo "suPid1="$suPid1
echo "suPid2="$suPid2
if [ "$osname" = "Linux" ]; then
    wait
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    if [ $suPid1Cnt -gt 0 ]; then
        wait $suPid1
    else
        echo
     fi
     if [ $suPid2Cnt -gt 0 ]; then
         wait $suPid2
     else
         echo
     fi
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START1=`expr $START1 + $RECORDS1`
START2=`expr $START2 + $RECORDS2`
fi
done


TEST_MODE="Insert+Select+Update"
let START1=$RECORDS*$THREADS_COUNT*2
let START2=$RECORDS*$THREADS_COUNT
START3="0"
for THREAD in $THREADS
do
if [ $THREAD -eq 1 ]
then
echo "Thread Count is 1"
else
export STANDARD_ALLTHREAD=$THREAD
let THREAD1=$THREAD*$ISUR_INSERT_RATIO/100
let THREAD2=$THREAD*$ISUR_SELECT_RATIO/100
let THREAD3=$THREAD*$ISUR_UPDATE_RATIO/100
let RECORDS1=$RECORDS*$ISUR_INSERT_RATIO/100
let RECORDS2=$RECORDS*$ISUR_SELECT_RATIO/100
let RECORDS3=$RECORDS*$ISUR_UPDATE_RATIO/100
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path
./bmt_insert $THREAD1 $START1 $RECORDS1 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
./bmt_select $THREAD2 $START2 $RECORDS2 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
./bmt_update $THREAD3 $START3 $RECORDS3 $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION &
isuPid1Cnt=`ps -ef | grep bmt_insert |grep -v grep | wc -l`
isuPid1=`ps -ef | grep bmt_insert |grep -v grep |awk '{print $2}'`
isuPid2Cnt=`ps -ef | grep bmt_select |grep -v grep | wc -l`
isuPid2=`ps -ef | grep bmt_select |grep -v grep |awk '{print $2}'`
isuPid3Cnt=`ps -ef | grep bmt_update |grep -v grep | wc -l`
isuPid3=`ps -ef | grep bmt_update |grep -v grep | awk '{print $2}'`
echo "isuPid1="$isuPid1
echo "isuPid2="$isuPid2
echo "isuPid3="$isuPid3
if [ "$osname" = "Linux" ]; then
    wait
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    if [ $isuPid1Cnt -gt 0 ]; then
        wait $isuPid1
    else
        echo
    fi
    if [ $isuPid2Cnt -gt 0 ]; then
       wait $isuPid2
    else
       echo
   fi
   if [ $isuPid3Cnt -gt 0 ]; then
       wait $isuPid3
   else
       echo
   fi
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START1=`expr $START1 + $RECORDS1`
START2=`expr $START2 + $RECORDS2`
START3=`expr $START3 + $RECORDS3`
fi
done


TEST_MODE="Delete"
START="0"
for THREAD in $THREADS
do
export STANDARD_ALLTHREAD="0"
isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f checkpoint.sql
sleep 10

if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usagestart.sh;
else
    cd $HOME/performance/bin/HP;
    ./usagestart.sh &
fi
cd $path
./bmt_delete $THREAD $START $RECORDS $UNIT $THRESHOLD $TEST_MODE $DBUSER $PASSWORD $OPTION
if [ "$osname" = "Linux" ]; then
    cd $HOME/performance/bin/Linux;
    ./usageend.sh;
else
    cd $HOME/performance/bin/HP;
    ./usageend.sh;
fi
cd $path
START=`expr $START + $RECORDS`
done

isql -s $HOST -u $DBUSER -p $PASSWORD -port $PORT -f drop.sql
