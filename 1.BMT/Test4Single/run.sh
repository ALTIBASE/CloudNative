#!/bin/sh
while getopts "s:c:g:" arg

do
        case $arg in
        s) STORAGE=$OPTARG ;;
        c) MCOUNT=$OPTARG ;;
	g) MVOLUME=$OPTARG ;;
        esac
done

STORAGE=`echo $STORAGE | tr '[a-z]' '[A-Z]'`

if [ $# -eq 4 ]
then
    if [ $MCOUNT ]
    then
    ./standardbmt.sh HDB APRE $STORAGE $MCOUNT
    else
    export MVOLUME
    ./standardbmt.sh HDB APRE $STORAGE $MVOLUME
    fi
else
    echo "Usage: run.sh -s MEMORY -g 1"
    echo "-s [MEMORY|DISK|VOLATILE]"
    echo "-c MCOUNT"
    echo "-g MVOLUME"
fi
