



create tablespace PART_DATA datafile 'part_data01.dbf' size 1G;
create tablespace PART_IDX datafile  'part_idx01.dbf'  size 1G;


-- ���̺� ����
drop table T1_NO_INDEX_NO_DATA;
create table T1_NO_INDEX_NO_DATA  ( c1 varchar(10) ) tablespace SYS_TBS_DATA;


-- ���̺� + �ε��� 
drop table T1_INDEX_NO_DATA;
create table T1_INDEX_NO_DATA  ( c1 varchar(10) ) tablespace SYS_TBS_DATA;

drop index IDX_T1_INDEX_NO_DATA_C1;
create index IDX_T1_INDEX_NO_DATA_C1  on T1_INDEX_NO_DATA ( C1 );



-- ���̺� + �ε��� ������ 
drop table T1_M_INDEX;
create table T1_M_INDEX  ( c1 varchar(10), c2 varchar(10), c3 varchar(10) ) tablespace SYS_TBS_DATA;

drop index IDX_T1_M_INDEX_C1;
create index IDX_T1_M_INDEX_C1  on T1_M_INDEX ( C1 );
drop index IDX_T1_M_INDEX_C2;
create index IDX_T1_M_INDEX_C2  on T1_M_INDEX ( C2 );


-- ��Ƽ�����̺� + �ε��� ����
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



-- ��Ƽ�����̺� +   partitioned index 1�� 
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
) TABLESPACE PART_DATA;

drop index part_t1_idx;
CREATE INDEX PART_T1_idx ON part_t1(i1)
LOCAL
(
PARTITION p_idx1 ON p1 TABLESPACE PART_IDX,
PARTITION p_idx2 ON p2 TABLESPACE PART_IDX,
PARTITION p_idx3 ON p3 TABLESPACE PART_IDX
) ;


-- ��Ƽ�����̺� + Non partitioned index
drop table part_t1_non;
CREATE TABLE part_t1_non
(
I1 INTEGER,
I2 INTEGER
)
PARTITION BY RANGE (I1)
(
PARTITION P1 VALUES LESS THAN (10000) TABLESPACE PART_DATA,
PARTITION P2 VALUES LESS THAN (20000) TABLESPACE PART_DATA,
PARTITION P3 VALUES DEFAULT TABLESPACE PART_DATA
) TABLESPACE PART_DATA;

create index IDX_part_t1_non on part_t1_non ( I1 );



-- ��Ƽ�� ���̺� + partioned index ������  
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
  PARTITION "PMAX" VALUES DEFAULT TABLESPACE PART_DATA 
 ) 
  tablespace SYS_TBS_DISK_DATA; 
  
drop index PART_T2_IDX_01;
create  index PART_T2_IDX_01 on PART_T2(c1, c2) LOCAL 
(
    partition "P201406" on P201406 tablespace PART_IDX,
    partition "P201407" on P201407 tablespace PART_IDX,      
    partition "P201408" on P201408 tablespace PART_IDX,
    partition "P201512" on P201512 tablespace PART_IDX,
    partition "PMAX" on PMAX tablespace PART_IDX) ;  
  
drop index PART_T2_IDX_02;
create  index PART_T2_IDX_02 on PART_T2(c1, c3) LOCAL 
(
    partition "P201406" on P201406 tablespace PART_IDX,
    partition "P201407" on P201407 tablespace PART_IDX,
    partition "P201408" on P201408 tablespace PART_IDX,        
    partition "P201512" on P201512 tablespace PART_IDX,
    partition "PMAX" on PMAX tablespace PART_IDX) ;   
    


    
-- ����Ÿ���̺����̽��� �ε����� �ٸ� ���

drop table T2_DEF;
create table T2_DEF  ( c1 varchar(10) ) tablespace PART_DATA;      

drop index IDX_T2_DEF;
create INDEX IDX_T2_DEF on T2_DEF ( c1 ) tablespace PART_IDX;