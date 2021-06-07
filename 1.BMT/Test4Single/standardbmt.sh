source ./set_test.env
echo "samesize"

GIGA="774705"
let PORTION=$ISR_INSERT_RATIO*4+$ISUR_INSERT_RATIO*4+500
COUNTS=$(echo "$GIGA $PORTION 100" | awk '{print int($1/$2*$3)}')
echo $COUNTS

if [ $MVOLUME ]
then
    SCALE=$(echo $MVOLUME $COUNTS | awk '{printf "%d\n",$1*$2}')
    export SCALE 
else
    export SCALE=$4
fi

export STORAGE=$3
export TESTNAME=$1"-"$2
echo $TESTNAME

cd "$STANDARD_WORK/$1/$2/$3"
echo "$STANDARD_WORK/$1/$2/$3"
./run_samesize.sh > $STANDARD_LOG/manual_$STANDARD_DATE.log

cd $STANDARD_RESULT
echo $2
./final.sh $3 
