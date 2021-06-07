DROP TABLE TEST;

DROP TABLESPACE TEST_TBS INCLUDING CONTENTS AND DATAFILES;

CREATE DISK TABLESPACE TEST_TBS DATAFILE 'test.tbs' SIZE 15G REUSE;
CREATE TABLE TEST (
    K01  INTEGER,
    K02  DATE,
    K03  DATE,
    K04  CHAR(10),
    K05  CHAR(10),
    K06  CHAR(10),
    K07  VARCHAR(20),
    K08  VARCHAR(20),
    K09  VARCHAR(20),
    K10  VARCHAR(20),
    K11  DOUBLE,
    K12  DOUBLE,
    K13  DOUBLE,
    K14  CHAR(10),
    K15  VARCHAR(50),
    K16  VARCHAR(50),
    K17  VARCHAR(50),
    K18  VARCHAR(50),
    K19  INTEGER,
    K20  INTEGER,
    K21  CHAR(3),
    K22  CHAR(3),
    K23  CHAR(10),
    K24  INTEGER,
    K25  INTEGER,
    K26  INTEGER,
    K27  INTEGER,
    K28  VARCHAR(30),
    K29  VARCHAR(30),
    K30  VARCHAR(30),
    K31  DATE,
    K32  DOUBLE,
    K33  DOUBLE,
    K34  INTEGER,
    K35  INTEGER,
    K36  CHAR(10),
    K37  CHAR(10),
    K38  VARCHAR(100),
    K39  VARCHAR(100),
    K40  VARCHAR(100),
    K41  INTEGER,
    K42  INTEGER,
    K43  INTEGER,
    K44  DOUBLE,
    K45  DOUBLE,
    K46  CHAR(10),
    K47  CHAR(10),
    K48  DATE,
    K49  DATE,
    K50  CHAR(20),
    K51  DATE,
    K52  INTEGER,
    K53  INTEGER,
    K54  DATE,
    K55  CHAR(20),
    K56  CHAR(20),
    K57  CHAR(20),
    K58  DOUBLE,
    K59  INTEGER,
    K60  VARCHAR(300)
) TABLESPACE TEST_TBS;

ALTER TABLE TEST ADD CONSTRAINT TEST_INDEX PRIMARY KEY ( K01 );
