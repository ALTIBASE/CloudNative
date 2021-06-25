
create tablespace PART_DATA datafile 'part_data01.dbf' size 1G;
create tablespace PART_DATA_DEF datafile 'part_def01.dbf' size 1G;
create tablespace PART_IDX datafile 'part_idx01.dbf' size 1G;
alter tablespace PART_IDX add datafile 'part_idx02.dbf' size 1G;
alter tablespace PART_IDX add datafile 'part_idx03.dbf' size 1G;

-- 파티션드 테이블 + 인덱스 없음
drop table range_sales;
CREATE TABLE range_sales
(
prod_id NUMBER(6),
cust_id NUMBER,
time_id DATE
)
PARTITION BY RANGE (time_id)
(
PARTITION Q1_2014 VALUES LESS THAN (TO_DATE('01-APR-2014')),
PARTITION Q2_2014 VALUES LESS THAN (TO_DATE('01-JUL-2014')),
PARTITION Q3_2014 VALUES LESS THAN (TO_DATE('01-OCT-2014')),
PARTITION Q4_2014 VALUES LESS THAN (TO_DATE('01-JAN-2015')),
PARTITION DEF VALUES DEFAULT
) TABLESPACE SYS_TBS_DISK_DATA;

insert into range_sales select  10000, 10000, to_date('01-JAN-2014', 'DD-MON-RRRR') from dual connect by level < 100001;
insert into range_sales select  10000, 10000, to_date('01-JUN-2014', 'DD-MON-RRRR') from dual connect by level < 200001;
insert into range_sales select  10000, 10000, to_date('01-SEP-2014', 'DD-MON-RRRR') from dual connect by level < 150001;
insert into range_sales select  10000, 10000, to_date('01-NOV-2014', 'DD-MON-RRRR') from dual connect by level < 70001;


-- 파티션드 테이블 + 일반 인덱스
-- 5.3.3, 5.5.1, 6.1.1 Non partitioned index 생성 불가 [ERR-31289 : cannot create non-partitioned index on partitioned table.]
-- 6.3.1 은 가능. 

drop table range2;
CREATE TABLE range2
(
prod_id NUMBER(6),
cust_id NUMBER,
time_id DATE
)
PARTITION BY RANGE (time_id)
(
PARTITION Q1_2014 VALUES LESS THAN (TO_DATE('01-APR-2014')),
PARTITION Q2_2014 VALUES LESS THAN (TO_DATE('01-JUL-2014')),
PARTITION Q3_2014 VALUES LESS THAN (TO_DATE('01-OCT-2014')),
PARTITION Q4_2014 VALUES LESS THAN (TO_DATE('01-JAN-2015')),
PARTITION DEF VALUES DEFAULT
) TABLESPACE SYS_TBS_DISK_DATA;

create index range2_idx on range2(prod_id) tablespace PART_IDX;

insert into range2 select  10000, 10000, to_date('01-JAN-2014', 'DD-MON-RRRR') from dual connect by level < 200001;
insert into range2 select  10000, 10000, to_date('01-JUN-2014', 'DD-MON-RRRR') from dual connect by level < 100001;
insert into range2 select  10000, 10000, to_date('01-SEP-2014', 'DD-MON-RRRR') from dual connect by level < 350001;
insert into range2 select  10000, 10000, to_date('01-NOV-2014', 'DD-MON-RRRR') from dual connect by level < 10001;

-- 파티션드 테이블+파티션드인덱스1개
drop table part_t1;
CREATE TABLE PART_T1
(
I1 INTEGER,
I2 INTEGER
)
PARTITION BY RANGE (I1)
(
PARTITION P1 VALUES LESS THAN (10000) TABLESPACE PART_DATA,
PARTITION P2 VALUES LESS THAN (20000) TABLESPACE PART_DATA,
PARTITION P3 VALUES DEFAULT TABLESPACE PART_DATA
) TABLESPACE PART_DATA_DEF;

drop index part_t1_idx;
CREATE INDEX PART_T1_idx ON part_t1(i1)
LOCAL
(
PARTITION p_idx1 ON p1 TABLESPACE PART_IDX,
PARTITION p_idx2 ON p2 TABLESPACE PART_IDX,
PARTITION p_idx3 ON p3 TABLESPACE PART_IDX
) ;

insert into part_t1 select level, level from dual connect by level < 500001;

-- 파티션드테이블+파티션드인덱스2개
drop table PART_T2;
create table PART_T2
(
    c1 integer,
    c2 integer,
    c3 integer
    
)
PARTITION BY RANGE(c1)
 (
  PARTITION "P201406" VALUES LESS THAN ('201407') TABLESPACE PART_DATA,
  PARTITION "P201407" VALUES LESS THAN ('201408') TABLESPACE PART_DATA,
  PARTITION "P201408" VALUES LESS THAN ('201409') TABLESPACE PART_DATA,
  PARTITION "P201512" VALUES LESS THAN ('201601') TABLESPACE PART_DATA,
  PARTITION "PMAX" VALUES DEFAULT TABLESPACE PART_DATA_DEF ) 
  tablespace SYS_TBS_DISK_DATA; 
 
 insert into part_t2 select 201406, level, level from dual connect by level < 200001;
 insert into part_t2 select 201407, level, level from dual connect by level < 400001;
 insert into part_t2 select 201408, level, level from dual connect by level < 100001;
 insert into part_t2 select 201410, level, level from dual connect by level < 150001;
 insert into part_t2 select 201701, level, level from dual connect by level < 170001;


--create  index "IPINCI_VIRTL_NO_TRT_TXN_IX_01" on PART_T2("MSG_TRT_LOG_SEQ","SYS_CD") LOCAL 
drop index PART_T2_IDX_01;
create  index PART_T2_IDX_01 on PART_T2(c1, c2) LOCAL 
(
    partition "P201406" on P201406 tablespace PART_IDX,
    partition "P201407" on P201407 tablespace PART_IDX,      
    partition "P201408" on P201408 tablespace PART_IDX,
    partition "P201512" on P201512 tablespace PART_IDX,
    partition "PMAX" on PMAX tablespace PART_IDX) ;
    
    
--create  index "IPINCI_VIRTL_NO_TRT_TXN_IX_02" on PART_T2("MSG_TRT_LOG_SEQ","CONN_EMP_ID") LOCAL 
drop index PART_T2_IDX_02;
create  index PART_T2_IDX_02 on PART_T2(c1, c3) LOCAL 
(
    partition "P201406" on P201406 tablespace PART_IDX,
    partition "P201407" on P201407 tablespace PART_IDX,
    partition "P201408" on P201408 tablespace PART_IDX,        
    partition "P201512" on P201512 tablespace PART_IDX,
    partition "PMAX" on PMAX tablespace PART_IDX) ;   






iSQL> select table_id, partition_id, partition_name from system_.sys_table_partitions_ order by 1,2,3;
TABLE_ID    PARTITION_ID PARTITION_NAME        
---------------------------------------------------
115         33          Q1_2014               
115         34          Q2_2014               
115         35          Q3_2014               
115         36          Q4_2014               
115         37          DEF                   
116         38          P1                    
116         39          P2                    
116         40          P3                    
117         41          P201406               
117         42          P201407               
117         43          P201408               
117         44          P201512               
117         45          PMAX                  
13 rows selected.


iSQL> select table_id, TABLE_PARTITION_ID, index_partition_name from system_.sys_index_partitions_ order by 1, 2, 3;
TABLE_ID    TABLE_PARTITION_ID INDEX_PARTITION_NAME  
---------------------------------------------------------
116         38          P_IDX1                
116         39          P_IDX2                
116         40          P_IDX3                
117         41          P201406               
117         41          P201406               
117         42          P201407               
117         42          P201407               
117         43          P201408               
117         43          P201408               
117         44          P201512               
117         44          P201512               
117         45          PMAX                  
117         45          PMAX                  
13 rows selected.