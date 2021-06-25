@echo off

echo ALTIMON FOR WINDOWS IS STARTED.

REM WINDOW TITLE
TITLE=ALTIMON FOR WINDOWS

REM 배치 파일을 중지하려면, 
REM taskkill /fi "windowtitle eq ALTIMON FOR WINDOWS"


:_loop

REM 변수 초기화
set LOG_DIR=
set SCRIPT_DIR=
set LOG_FILE=
set ISQL=
set time=
set date=
set cmd=
set res=

REM 변수 설정
set LOG_DIR=ALTIMON_LOG
set SCRIPT_DIR=ALTIMON_SCRIPT
set LOG_FILE=mon.log.%date%
set ISQL="%ALTIBASE_HOME%\bin\isql.exe" -s localhost -u sys -p manager -silent



if not exist %LOG_DIR% (
  mkdir %LOG_DIR% 2>/nul
) 

if not exist %SCRIPT_DIR% (
echo. >> %LOG_DIR%\%LOG_FILE%
echo %time% >> %LOG_DIR%\%LOG_FILE%
echo 'ALTIMON_SCRIPT' FOLDER IS NOT EXIST IN CURRENT FOLDER. THIS BATCH PROGRAM WILL NOT BE EXECUTED SUCCESSFULLY. >> %LOG_DIR%\%LOG_FILE%
goto _sleep
)

if exist %SCRIPT_DIR% goto _run

:_run

REM SYSTEM MEM USAGE
echo. >> %LOG_DIR%\%LOG_FILE%
echo %time% >> %LOG_DIR%\%LOG_FILE%
set cmd="tasklist /FI "IMAGENAME eq altibase.exe"  | find /c "altibase""
FOR /F %%i IN (' %cmd% ') DO SET res=%%i

if %res% == 0 echo ALTIBASE HDB SERVER IS NOT RUNNING. >> %LOG_DIR%\%LOG_FILE% 
if %res% == 1 (
tasklist /FI "IMAGENAME eq altibase.exe" >> %LOG_DIR%\%LOG_FILE% 
)

REM LOGFILE COUNT              
echo. >> %LOG_DIR%\%LOG_FILE%  
%ISQL% -f %SCRIPT_DIR%\all | findstr _MON_ | findstr /v '_MON_ >> %LOG_DIR%\%LOG_FILE%                                                      




REM REM LOGFILE COUNT
REM echo. >> %LOG_DIR%\%LOG_FILE%
REM %ISQL% -f %SCRIPT_DIR%\LOGFILE | findstr LOGFILE_COUNT | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                      
REM                                                                              
REM                                                      
REM REM MEMSTAT_SUM
REM echo. >> %LOG_DIR%\%LOG_FILE%  
REM %ISQL% -f %SCRIPT_DIR%\MEMSTAT_SUM | findstr MEMSTAT_SUM | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                      
REM 
REM 
REM REM MEMSTAT LIMIT 30
REM echo. >> %LOG_DIR%\%LOG_FILE%
REM %ISQL% -f %SCRIPT_DIR%\MEMSTAT_LIST | findstr MEMSTAT_LIST | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                      
REM 
REM 
REM REM MEM_DATABASE_USAGE
REM echo. >> %LOG_DIR%\%LOG_FILE%
REM %ISQL% -f %SCRIPT_DIR%\MEM_DATABASE_USAGE | findstr MEM_DATABASE_USAGE | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                      
REM 
REM                                                         
REM 
REM 
REM 
REM REM TABLESPACE USAGE
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\TBS_USAGE | findstr TBS_USAGE | findstr /v iSQL | findstr /v SELECT >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM DISK_TBL_USAGE
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\DISK_TBL_USAGE | findstr DISK_TBL_USAGE | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM                                                      
REM 
REM REM MEM_TBL_USAGE
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\MEM_TBL_USAGE | findstr MEM_TBL_USAGE | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM SERVICE_THREAD_MODE
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\SERVICE_THREAD | findstr SERVICE_THREAD | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM SESSION_COUNT
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\SESSION_COUNT | findstr SESSION_COUNT | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM SESSION_COMM_NAME
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\SESSION_COMM_NAME | findstr SESSION_COMM_NAME | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM STATEMENT_COUNT
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\STMT_COUNT | findstr STMT_COUNT | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM STATEMENT_EXEC_COUNT
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\STMT_EXEC_COUNT | findstr STMT_EXEC_COUNT | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM MEM_GC
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\MEM_GC | findstr MEM_GC | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM LOCK_DESC
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\LOCK_DESC | findstr LOCK_DESC | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM LOCK_TX_DETAIL
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\LOCK_TX_DETAIL | findstr LOCK_TX_DETAIL | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM LONG_RUN_QUERY
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\LONG_QUERY | findstr LONG_QUERY | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM UTRANS_QUERY
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\UTRANS_QUERY | findstr UTRANS_QUERY | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM REPLICATION_GAP
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\REPLICATION_GAP | findstr _REP_GAP | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           
REM 
REM 
REM REM UNDO_USAGE
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\UNDO_USAGE | findstr UNDO_USAGE | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE%                                                           

REM REM SYSSTAT_LIST
REM echo. >> %LOG_DIR%\%LOG_FILE% 
REM %ISQL% -f %SCRIPT_DIR%\SYSSTAT_LIST | findstr SYSSTAT_LIST | findstr /v iSQL >> %LOG_DIR%\%LOG_FILE% 








REM 30일 전 로그 파일 삭제                                                                                                                                                    
forfiles /P . /M mon.log* /D -30 /C "cmd /c del @file" 2>/nul

:_sleep
 
REM sleep 60
ping -n 60 127.0.0.1 > nul

goto _loop