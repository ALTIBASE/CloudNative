@echo off

REM WINDOW TITLE
TITLE=ALTIMON

REM 배치 파일을 중지하려면, 
REM taskkill /fi "windowtitle eq ALTIMON"


:_loop

REM 변수 초기화
set IMSI_FILE=
set LOG_FILE=
set ISQL=
set a=
set time=
set date=

REM 변수 설정
set IMSI_FILE=imsi.qry
set LOG_FILE=mon.log.%date%
set ISQL="%ALTIBASE_HOME%\bin\isql.exe" -s localhost -u sys -p manager -silent


REM SYSTEM MEM USAGE
echo. >> %LOG_FILE%
echo %time% >> %LOG_FILE%
tasklist /FI "IMAGENAME eq altibase.exe" >> %LOG_FILE%



REM LOGFILE COUNT
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ; 																																										                                                      
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'LOGFILE_COUNT',                                                                                                                
echo         ^(select OLDEST_LOGFILE_NO from v$log^) as old_log,																						                                                      
echo         ^(select current_logfile from v$archive^) as curr_log,                                                                                               
echo        ^(^(select current_logfile from v$archive^) - ^(select OLDEST_LOGFILE_NO from v$log^)^) as log_gap	                                                      
echo from dual;										                        																								                                                      
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%                                                      
                                                                                        
                                                      

REM MEMSTAT_SUM
echo. >> %LOG_FILE%  
(                                     
echo set linesize 1024; 																																									
echo set colsize 40; 																																											
echo set feedback off; 																																										
echo set heading off ; 																																										
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'MEMSTAT_SUM',                       																		       
echo        trunc^(sum^(MAX_TOTAL_SIZE^)^/1024^/1024, 2^) as max_total_mb,  																		
echo        trunc^(sum^(ALLOC_SIZE^)^/1024^/1024, 2^) as current_mb 	      																		
echo from v$memstat; 
) > %IMSI_FILE%
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%       



REM MEMSTAT LIMIT 30
echo. >> %LOG_FILE%
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ; 													
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'MEMSTAT_LIST',  
echo        name,																     
echo        MAX_TOTAL_SIZE,  										
echo        ALLOC_SIZE       										
echo from v$memstat order by alloc_size desc limit 30;                   
) > %IMSI_FILE%
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%       



REM MEM_DATABASE_USAGE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'MEM_DATABASE_USAGE',                                                     
echo    trunc^(mem_alloc_page_count*32^/1024, 2^) as alloc_mem_mb,
echo    trunc^(mem_free_page_count*32^/1024, 2^) as free_mem_mb   
echo from v$database;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM SYSSTAT_LIST
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 90; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'SYSSTAT_LIST', SEQNUM, NAME, VALUE FROM V$SYSSTAT WHERE SEQNUM ^< 88;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM TABLESPACE USAGE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 50; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'TBS_USAGE', '-' tbs_name,
echo        to_char^(mem_max_db_size^/1024^/1024^) 'MAX^(M^)',
echo        round^(mem_alloc_page_count*32^/1024, 2^) 'TOTAL^(M^)',
echo        trunc^(^(mem_alloc_page_count-mem_free_page_count^)*32^/1024, 2^) 'ALLOC^(M^)',
echo        to_char^(^(SELECT round^(sum^(^(fixed_used_mem + var_used_mem^)^)^/^(1024*1024^), 3^)
echo                   FROM v$memtbl_info^)^) 'USED^(M^)',
echo        trunc^(^(^(mem_alloc_page_count-mem_free_page_count^)*32*1024^)^/mem_max_db_size, 4^)*100 'USAGE^(%^)',
echo        '' state,
echo        '' 'AUTOEXTEND'
echo   FROM v$database
echo  UNION ALL
echo SELECT to_char^(sysdate, 'HH:MI:SS'^) time, 'TBS_USAGE', name tbs_name,
echo        decode^(maxsize, 140737488322560, 'UNDEFINED', maxsize^) 'MAX^(M^)',
echo        ROUND^(allocated_page_count * page_size ^/ 1024 ^/ 1024, 2^) 'TOTAL^(M^)',
echo        ROUND^(nvl^(m.alloc_page_count-m.free_page_count, total_page_count^)*page_size^/1024^/1024, 2^) 'ALLOC^(M^)',
echo        to_char^(mt.used^) 'USED^(M^)',
echo        decode^(maxsize, 140737488322560, ROUND^(^(m.alloc_page_count-m.free_page_count^)*page_size^/ mem_max_db_size*100, 2^), ROUND^(^(m.alloc_page_count-m.free_page_count^)*page_size^/maxsize*100, 2^)^) 'USAGE^(%^)',
echo        decode^(state, 1, 'OFFLINE', 2, 'ONLINE', 5, 'OFFLINE BACKUP', 6, 'ONLINE BACKUP', 128, 'DROPPED', 'DISCARDED'^) state,
echo        decode^(autoextend_mode, 1, 'ON', 'OFF'^) 'AUTOEXTEND'
echo   FROM v$database d,
echo        v$tablespaces t,
echo        v$mem_tablespaces m,
echo        ^(SELECT tablespace_id,
echo                round^(sum^(^(fixed_used_mem + var_used_mem^)^)^/^(1024*1024^), 3^) used
echo           FROM v$memtbl_info
echo          GROUP BY tablespace_id^) mt
echo  WHERE t.id = m.space_id
echo    and id = mt.tablespace_id
echo  UNION ALL
echo SELECT to_char^(sysdate, 'HH:MI:SS'^) time, 'TBS_USAGE', name tbs_name,
echo        to_char^(ROUND^(d.max * page_size ^/ 1024 ^/1024, 2^)^) 'MAX^(M^)',
echo        ROUND^(total_page_count * page_size ^/ 1024 ^/ 1024, 2^) 'TOTAL^(M^)',
echo        decode^(type, 7, ROUND^(^(SELECT ^(sum^(total_extent_count*page_count_in_extent^) * page_size^)^/1024^/1024
echo                           FROM v$udsegs^)+^(SELECT ^(sum^(total_extent_count*page_count_in_extent^) * page_size^)^/1024^/1024
echo                           FROM v$tssegs^), 2^), ROUND^(allocated_page_count * page_size ^/ 1024 ^/ 1024, 2^)^) 'ALLOC^(M^)',
echo        '-' 'USED^(M^)',
echo        decode^(type, 7, ROUND^(^(^(SELECT sum^(total_extent_count*page_count_in_extent^)
echo                                   FROM v$udsegs^)+^(SELECT sum^(total_extent_count*page_count_in_extent^)
echo                                   FROM v$tssegs^)^) ^/ d.max* 100, 2^), ROUND^(allocated_page_count ^/ d.max * 100, 2^)^) 'USAGE^(%^)',
echo        decode^(state, 1, 'OFFLINE', 2, 'ONLINE', 5, 'OFFLINE BACKUP', 6, 'ONLINE BACKUP', 128, 'DROPPED', 'DISCARDED'^) state,
echo        d.autoextend
echo   FROM v$tablespaces t,
echo        ^(SELECT spaceid,
echo                sum^(decode^(maxsize, 0, currsize, maxsize^)^) as max,
echo                decode^(max^(autoextend^), 1, 'ON', 'OFF'^) 'AUTOEXTEND'
echo           FROM v$datafiles
echo          group by spaceid^) d
echo  WHERE t.id = d.spaceid and t.type not in ^(3,4^)  
echo union all   
echo SELECT to_char^(sysdate, 'HH:MI:SS'^) time, 'TBS_USAGE', name tbs_name,
echo        to_char^(ROUND^(d.max * page_size ^/ 1024 ^/1024, 2^)^) 'MAX^(M^)',
echo        ROUND^(total_page_count * page_size ^/ 1024 ^/ 1024, 2^) 'TOTAL^(M^)',
echo        ROUND^(allocated_page_count * page_size ^/ 1024 ^/ 1024, 2^) 'ALLOC^(M^)',                          
echo        to_char^(round^(ds.used^/1024^/1024, 2^)^) 'USED^(M^)',
echo        round^(^(ds.used^)/^(d.max*page_size^)* 100, 2^) 'USAGE^(%^)',
echo        decode^(state, 1, 'OFFLINE', 2, 'ONLINE', 5, 'OFFLINE BACKUP', 6, 'ONLINE BACKUP', 128, 'DROPPED', 'DISCARDED'^) state,
echo        d.autoextend
echo   FROM v$tablespaces t,
echo        ^(SELECT spaceid,
echo                sum^(decode^(maxsize, 0, currsize, maxsize^)^) as max,
echo                decode^(max^(autoextend^), 1, 'ON', 'OFF'^) 'AUTOEXTEND'
echo           FROM v$datafiles
echo          group by spaceid^) d,
echo        ^(select space_id, sum^(TOTAL_USED_SIZE^) used from x$segment group by space_id^) ds
echo   WHERE t.id = d.spaceid 
echo     and ds.space_id = t.id;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM SEGMENT_USAGE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'SEGMENT_USAGE', 
echo        name, sum^(EXTENT_TOTAL_COUNT^)*256 as 'usage^(M^)'
echo from v$tablespaces a,  V$SEGMENT b                        
echo where a.id=b.space_id                                     
echo group by name                                             
echo ORDER BY name;                                            
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   




REM DISK_TBL_USAGE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'DISK_TBL_USAGE', 
echo        round^(sum^(DISK_TOTAL_PAGE_CNT^)*8^/1024^) AS 'USED^(M^)'
echo from v$disktbl_info a, v$tablespaces b                                
echo where a.TABLESPACE_ID=b.id group by name                              
echo order by name;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   
                                                     


REM MEM_TBL_USAGE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'MEM_TBL_USAGE',               
echo    table_name,                                                           
echo    FIXED_ALLOC_MEM+VAR_ALLOC_MEM alloc,                                  
echo    ^(FIXED_ALLOC_MEM+VAR_ALLOC_MEM^)-^(FIXED_USED_MEM+VAR_USED_MEM^) free
echo from system_.sys_tables_ a, v$memtbl_info b                              
echo where a.table_oid = b.table_oid                                          
echo order by 2;                                                              
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM SERVICE_THREAD_MODE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'SETVICE_THEAD_MODE', type, count^(*^) cnt from V$service_thread group by type order by 1;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM SERVICE_THREAD_STATE
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'SERVICE_THREAD_STATE', state, count^(*^) cnt from V$service_thread group by state order by 1;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM SESSION_COUNT
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'SESSION_COUNT', count^(*^) as sid_count from v$session;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   


REM SESSION_COMM_NAME
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'SESSION_COMM_NAME', comm_name, count^(*^) from v$session group by comm_name order by 2 desc;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM STATEMENT_COUNT
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'STMT_COUNT', count^(*^) as stmt_count from v$statement;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM STATEMENT_EXEC_COUNT
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'STMT_EXEC_COUNT',
echo        EXECUTE_FLAG,
echo        count^(*^) as stmt_count
echo   from v$statement
echo  group by EXECUTE_FLAG
echo  order by 1;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM MEM_GC
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'MEM_GC',                        
echo    gc_name,                      
echo -- MINMEMSCNINTXS-SCNOFTAIL,     
echo    ADD_OID_CNT-GC_OID_CNT gc_gap 
echo from v$memgc;                    
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   





REM LOCK_DESC
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'LOCK_DESC',
echo        b.session_id as sid,                                                      
echo        b.tx_id as tId,                                                           
echo        b.is_grant as isgran,                                                     
echo        b.lock_desc as Ldesc,                                                     
echo        a.table_name as ltable,                                                   
echo        trunc^(c.total_time^/1000000, 4^) as TTime                                 
echo from system_.sys_tables_ a, v$lock_statement b, v$statement c                    
echo where a.table_oid = b.table_oid                                                  
echo   and   c.session_id = b.session_id                                              
echo   and   c.tx_id      = b.tx_id                                                   
echo   and   ^(c.total_time^/1000000^) ^> 1                                             
echo group by b.session_id, b.tx_id, b.is_grant, total_time, a.table_name, b.lock_desc
echo order by b.session_id, b.tx_id, b.is_grant, total_time, a.table_name, b.lock_desc;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   



REM LOCK_TX_DETAIL
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'LOCK_TX_DETAIL',
echo        tx.id tx_id,
echo        wait_for_trans_id blocked_tx_id,
echo        decode^(tx.status, 0, 'BEGIN', 1, 'PRECOMMIT', 2, 'COMMIT_IN_MEMORY', 3, 'COMMIT', 4, 'ABORT', 5, 'BLOCKED', 6, 'END'^) status,
echo        decode^(tx.log_type, 0, u1.user_name, 'REPLICATION'^) user_name,
echo        decode^(tx.log_type, 0, tx.SESSION_ID, rt.rep_name^) session_id,
echo        decode^(tx.log_type, 0, st.comm_name, rr.peer_ip^) client_ip,
echo        decode^(st.autocommit_flag, 1, 'ON', 'OFF'^) autocommit,
echo        l.lock_desc,
echo        decode^(tx.first_update_time, 0, '0', to_char^(to_date^('1970010109', 'YYYYMMDDHH'^) + tx.first_update_time ^/ ^(60*60*24^), 'MM^/DD HH:MI:SS'^)^) first_update_time,
echo        u2.user_name^|^|'.'^|^|t.table_name table_name,
echo        decode^(tx.LOG_TYPE, 0, substr^(st.query, 1, 40^), 'REMOTE TX_ID '^|^|remote_tid^) current_query,
echo        decode^(tx.DDL_FLAG, 0, 'non-DDL', 'DDL'^) ddl,
echo        decode^(tx.first_undo_next_lsn_fileno, -1, '-', tx.first_undo_next_lsn_fileno^) 'logfile#'
echo   FROM v$transaction tx,
echo        v$lock l left outer join ^(SELECT st.*, ss.autocommit_flag, ss.db_userid, ss.comm_name
echo           FROM v$statement st, v$session ss
echo          WHERE ss.id = st.session_id
echo            and ss.CURRENT_STMT_ID = st.id^) st on l.trans_id = st.tx_id left outer join v$repreceiver_transtbl rt on l.trans_id = rt.local_tid left outer join v$repreceiver rr on rt.rep_name = rr.rep_name left outer join v$lock_wait lw on l.trans_id = lw.trans_id left outer join system_.sys_users_ u1 on st.db_userid = u1.user_id,
echo        system_.sys_tables_ t left outer join system_.sys_users_ u2 on t.user_id = u2.user_id
echo  WHERE tx.id = l.trans_id
echo    and t.table_oid = l.table_oid
echo    and tx.status != 6 ;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   




REM LONG_RUN_QUERY
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 100; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'LONG_QUERY',
echo        start_time,                                                                       
echo        session_id sid,                                                                   
echo        comm_name ip,                                                                     
echo        client_pid pid,                                                                   
echo        stmt_id,                                                                          
echo        tx_id,                                                                            
echo        active_flag,                                                                      
echo        execute_flag,                                                                     
echo        begin_flag,                                                                       
echo        trunc^(execute_time^/1000000,2^) rtime,                                            
echo        trunc^(fetch_time^/1000000,2^) ftime,                                              
echo        trunc^(total_time^/1000000,2^) ttime,                                              
echo        substr^(query, 1, 100^) qry
echo from ^( select CASE2^(LAST_QUERY_START_TIME = 0, '1970^/01^/01 12:00:00',                  
echo         TO_CHAR^(TO_DATE^('1970010109','YYYYMMDDHH'^) +                                  
echo         LAST_QUERY_START_TIME^/60^/60^/24 , 'YYYY/MM/DD HH:MI:SS'^)^) as start_time,        
echo               session_id,                                                                
echo               id as stmt_id,                                                             
echo               tx_id,                                                                     
echo               execute_time,                                                              
echo               fetch_time,                                                                
echo               total_time,                                                                
echo               execute_flag,                                                              
echo               begin_flag,                                                                
echo               query                                                                      
echo        FROM v$statement^) a, v$session b                                                 
echo where a.session_id = b.id                                                                
echo   and query not like '%LAST_QUERY_START_TIME%'                                           
echo   and total_time^/1000000 ^> 1                                                             
echo   --and ^(sysdate - to_date^(start_time, 'YYYY^/MM^/DD HH:MI:SS'^)^)*24*60*60 ^>= total_time
echo   and IDLE_START_TIME = 0                                                                
echo   and CURRENT_STMT_ID = stmt_id                                                          
echo order by ttime desc;                                                                     
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   


REM UTRANS_QUERY
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 90; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'UTRANS_QUERY',                                                            
echo        ST.SESSION_ID AS SID,                                       
echo        SS.COMM_NAME AS IP,                                         
echo        SS.client_pid AS PID,                                       
echo        ST.ID AS STMT_ID,                                           
echo        BASE_TIME - TR.FIRST_UPDATE_TIME AS UTRANS_TIME             
echo   FROM V$TRANSACTION TR, V$STATEMENT ST, v$session SS, V$SESSIONMGR
echo  WHERE TR.ID = ST.TX_ID                                            
echo    AND ST.SESSION_ID = SS.ID                                       
echo    AND TR.FIRST_UPDATE_TIME != 0                                   
echo    AND ^(BASE_TIME - tr.FIRST_UPDATE_TIME^) ^> 60;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   




REM REPLICATION_GAP
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'REPLICATION_GAP',
echo        REP_NAME, REP_SN, REP_GAP FROM V$REPGAP GROUP BY REP_NAME, REP_GAP;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   


REM UNDO_DETAIL_1
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 40; 														
echo set feedback off; 		
echo set heading off ;											
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'UNDO_DETAIL_1',
echo        TX_EXT_CNT TX_CNT,
echo        TOTAL_EXT_CNT TOTAL,
echo        USED_EXT_CNT USED,
echo        UNSTEALABLE_EXT_CNT UNSTEAL,
echo        REUSABLE_EXT_CNT REUSE
echo   from v$disk_undo_usage;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   


REM UNDO_DETAIL_2
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 90; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'UNDO_DETAIL_2',
echo        s.id s_id,
echo        s.comm_name,
echo        tx.id tx_id,
echo        tx.TSS_RID,
echo        nvl^(ltrim^(stmt.query^), 'NONE'^) query
echo   from v$transaction tx,
echo        v$statement stmt,
echo        v$session s
echo  where tx.TSS_RID ^<^> 0
echo    AND tx.id = stmt.tx_id
echo    AND tx.session_id = s.id;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   


REM UNDO_DETAIL_3
echo. >> %LOG_FILE% 
(
echo set linesize 1024; 												
echo set colsize 90; 														
echo set feedback off; 													
echo set heading off ;
echo select to_char^(sysdate, 'HH:MI:SS'^) time, 'UNDO_DETAIL_3',
echo        tx.id tx_id,
echo        tx.TSS_RID,
echo        tx.log_type
echo   from v$transaction tx
echo  where tx.TSS_RID ^<^> 0 ;
) > %IMSI_FILE%                                                       
type %IMSI_FILE% | %ISQL% | findstr /V iSQL >> %LOG_FILE%   


REM 30일 전 로그 파일 삭제                                                                                                                                                    
forfiles /P . /M mon.log* /D -30 /C "cmd /c del @file"


REM sleep 60
ping -n 60 127.0.0.1 > nul

goto _loop


