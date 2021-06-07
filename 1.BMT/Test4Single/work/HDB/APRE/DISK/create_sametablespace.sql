DROP TABLESPACE TEST_TBS INCLUDING CONTENTS AND DATAFILES;
CREATE DISK TABLESPACE TEST_TBS DATAFILE 'test1.tbs' SIZE 20G, 
'test2.tbs' size 20G,
'test3.tbs' size 20G,
'test4.tbs' size 20G,
'test5.tbs' size 20G,
'test6.tbs' size 20G,
'test7.tbs' size 20G
AUTOEXTEND ON NEXT 1M;
