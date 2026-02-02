--1--

-- cat $ORACLE_HOME/network/admin/sqlnet.ora
-- cat #ORACLE_HOME/network/admin/listener.ora

--2--

-- sqlplus / as sysdba

show parameter;

--3--

--- export ORACLE_SID=FREE
--- unset TWO_TASK

SHOW con_name;

SELECT NAME, OPEN_MODE FROM V$PDBS;
ALTER PLUGGABLE DATABASE BVS_PDB OPEN;

ALTER SESSION SET CONTAINER = BVS_PDB;

SELECT TABLESPACE_NAME, STATUS, CONTENTS, EXTENT_MANAGEMENT
FROM DBA_TABLESPACES;

SELECT FILE_ID, FILE_NAME, TABLESPACE_NAME, BYTES/1024/1024 AS SIZE_MB, AUTOEXTENSIBLE
FROM DBA_DATA_FILES
ORDER BY TABLESPACE_NAME;

SELECT *
FROM DBA_ROLES
ORDER BY ROLE;

SELECT USERNAME, ACCOUNT_STATUS, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE
FROM DBA_USERS
ORDER BY USERNAME;

--4--

-- т.к в линуксе нет реестра как в винде, то все параметры заданы через переменные окружения,
-- либо через конфигурационные файлы находящиеся на дисках, чтобы просмотреть, какие переменные
-- окружения были проставлены в линуксе в моем случае, можно посмотреть следующий файл:

-- cat ~/.bashrc

--5--

-- chmod 666 $ORACLE_HOME/network/admin/tnsnames.ora

-- netmgr &

--U1_BVS_PDB =
-- (DESCRIPTION =
--  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
-- (CONNECT_DATA =
--  (SID = BVS_PDB)
-- )
-- )

-- tnsping U1_BVS_PDB


CREATE USER U1_BVS_PDB IDENTIFIED BY 1111;
GRANT CONNECT, RESOURCE TO U1_BVS_PDB;

-- sqlplus U1_BVS_PDB/1111@U1_BVS_PDB

SELECT table_name
FROM user_tables
ORDER BY table_name;

--8--

HELP TIMING;

SET TIMING ON;
select * from IND$;
SET TIMING OFF;


--9--

-- desc test_table

--10--

SELECT owner, segment_name, segment_type, tablespace_name
FROM dba_segments
WHERE owner = 'U1_BVS_PDB';

SELECT table_name FROM user_tables;

--11--

CREATE VIEW SEGMENTS_INFO AS
SELECT 
    COUNT(segment_name) AS segment_count,
    SUM(extents) AS total_extents,
    SUM(blocks) AS total_blocks,
    SUM(bytes)/1024 AS size_kb
FROM user_segments;


SELECT * FROM SEGMENTS_INFO;
