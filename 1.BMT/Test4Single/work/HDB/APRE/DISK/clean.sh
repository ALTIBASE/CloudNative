server stop
rm -f $ALTIBASE_HOME/dbs/* $ALTIBASE_HOME/logs/*
server create US7ASCII UTF16
server start
