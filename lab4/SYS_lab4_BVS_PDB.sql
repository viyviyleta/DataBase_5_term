show PDBS
ALTER PLUGGABLE DATABASE BVS_PDB OPEN;

--1--
select tablespace_name, file_name, bytes/1024/1024 as size_mb
from dba_data_files

select tablespace_name, file_name, bytes/1024/1024 as size_mb
from dba_temp_files

select * from dba_users

--2--
create tablespace BVS_QDATA
datafile '/opt/oracle/oradata/FREE/BVS_QDATA.dbf' 
size 10 m
offline

alter tablespace BVS_QDATA online
SELECT SYS_CONTEXT('USERENV','CON_NAME') FROM dual;


CREATE USER BVS IDENTIFIED BY 1111
DEFAULT TABLESPACE BVS_QDATA
TEMPORARY TABLESPACE TEMP;

alter user BVS quota 2m on BVS_QDATA;

GRANT CONNECT, RESOURCE TO BVS;

create table BVS.BVS_T1 (
        id number primary key,
        name varchar2(10)
)tablespace BVS_QDATA;

INSERT INTO BVS.BVS_T1 VALUES (1, 'Alpha');
INSERT INTO BVS.BVS_T1 VALUES (2, 'Beta');
INSERT INTO BVS.BVS_T1 VALUES (3, 'Gamma');
COMMIT;

select * from BVS.BVS_T1

--3--
select segment_name, segment_type, owner
from dba_segments
where tablespace_name = 'BVS_QDATA'

select segment_name, segment_type, owner
from dba_segments
where segment_name = 'BVS_T1' and owner = 'BVS'

--4--

drop table BVS.BVS_T1

SELECT segment_name, segment_type, owner
FROM dba_segments
WHERE tablespace_name = 'BVS_QDATA'
ORDER BY segment_type, segment_name;

SELECT segment_name, segment_type, owner
FROM dba_segments
WHERE segment_name = 'BVS_T1' AND owner = 'BVS';

SELECT object_name, original_name, operation, type, droptime
FROM user_recyclebin;


--5--
FLASHBACK TABLE BVS.BVS_T1 TO BEFORE DROP;

select * from BVS.BVS_T1

--6--

BEGIN
  FOR i IN 1..10000 LOOP
    INSERT INTO BVS.BVS_T1 (id, name)
    VALUES (i, 'Name_' || TO_CHAR(i));
  END LOOP;
  COMMIT;
END;
/

select count(*) from BVS.BVS_T1

--7--
select count(*) as extent_count,
       sum(blocks) as total_blocks,
       sum(bytes) as total_bytes
from dba_extents
where segment_name = 'BVS_T1'
  and owner = 'BVS'
  and tablespace_name = 'BVS_QDATA';

select extent_id,
       file_id,
       block_id,
       blocks,
       bytes
from dba_extents
where segment_name = 'BVS_T1'
  and owner = 'BVS'
  and tablespace_name = 'BVS_QDATA'
order by extent_id;

--8--
drop tablespace BVS_QDATA including contents and datafiles

select tablespace_name from dba_tablespaces

--9--
select group#, thread#, sequence#, bytes, members, status
from v$log

select GROUP# from v$log where STATUS = 'CURRENT';

--10--
select MEMBER from v$logfile;

--11--
ALTER SESSION SET CONTAINER = CDB$ROOT;

ALTER SYSTEM SWITCH LOGFILE;
SELECT GROUP#, STATUS, MEMBERS FROM V$LOG;
select current_timestamp from SYS.DUAL;

--12--

alter database add logfile group 4 '/opt/oracle/oradata/FREE/redo04.log' size 50m blocksize 512;
alter database add logfile member '/opt/oracle/oradata/FREE/redo04_1.log' to group 4;
alter database add logfile member '/opt/oracle/oradata/FREE/redo04_2.log' to group 4;

select * from v$log
select * from v$logfile

alter system switch logfile
select group#, thread#, sequence#, bytes, members, status
from v$log

select CURRENT_SCN from v$database

--13--
ALTER SYSTEM CHECKPOINT;

alter database drop logfile member '/opt/oracle/oradata/FREE/redo04_1.log';
alter database drop logfile member '/opt/oracle/oradata/FREE/redo04_2.log';

select * from v$log

alter database drop logfile group 4;

select * from v$log;

--14--
SELECT NAME, LOG_MODE FROM V$DATABASE;
SELECT INSTANCE_NAME, ARCHIVER, ACTIVE_STATE FROM V$INSTANCE;

--15--
SELECT MAX(sequence#) FROM v$archived_log;

--16--

--- export ORACLE_SID=FREE
--- unset TWO_TAS

--- sqlplus / as sysdba

SHOW CON_NAME
SELECT instance_name,archiver, status  FROM v$instance;
ALTER SESSION SET CONTAINER = CDB$ROOT

SELECT SERVER FROM V$SESSION WHERE AUDSID = SYS_CONTEXT('USERENV','SESSIONID');

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

SELECT log_mode FROM v$database;


SELECT name, open_mode, log_mode FROM v$database;

--17--
SELECT log_mode FROM v$database;

SELECT MAX(sequence#) FROM v$archived_log;

ALTER SYSTEM SWITCH LOGFILE;

SELECT NAME
FROM V$ARCHIVED_LOG
WHERE SEQUENCE# = (
  SELECT MAX(SEQUENCE#)
  FROM V$ARCHIVED_LOG
  WHERE ARCHIVED = 'YES'
);

SELECT SEQUENCE#, FIRST_CHANGE#, NEXT_CHANGE#
FROM V$ARCHIVED_LOG
ORDER BY SEQUENCE#;

--18--
--- То же самое, что и в пункте 16, только меняется 1 команда ---

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE NOARCHIVELOG;
ALTER DATABASE OPEN;





--19--
select name from v$controlfile;

--20--
SHOW PARAMETER CONTROL;

SELECT * FROM V$CONTROLFILE;
    
SELECT * FROM V$CONTROLFILE_RECORD_SECTION;

--21--
SHOW PARAMETER spfile;

--cat /opt/oracle/product/23ai/dbhomeFree/dbs/BVS_PFILE.ORA

--22-------------------------------------------------    -------------------------------------
CREATE PFILE='/opt/oracle/product/23ai/dbhomeFree/dbs/BVS_PFILE.ORA' FROM SPFILE;

--23--

--find /opt/oracle -name 'orapwd*'

-- 24 ---
SHOW PARAMETER diagnostic_dest;

--ls -l /opt/oracle/diag/rdbms/free/FREE/

select * from v$diag_info;

--25--

--find /opt/oracle/diag/rdbms/free/FREE/ -name log.xml
--ls -l /opt/oracle/diag/rdbms/free/FREE/alert/log.xml






--26--

--- Удалить ---

drop table BVS.BVS_T1;

drop user BVS;

drop tablespace BVS_QDATA including contents and datafiles;
--ls -l /opt/oracle/oradata/FREE/BVS_QDATA.dbf
-- rm -rf /opt/oracle/oradata/FREE/BVS_QDATA.dbf

alter database drop logfile group 4;

-- rm -rf /opt/oracle/oradata/FREE/redo04a.log
-- rm -rf /opt/oracle/oradata/FREE/redo04b.log
-- rm -rf /opt/oracle/oradata/FREE/redo04c.log
--ls -l /opt/oracle/oradata/FREE/redo04*

SELECT tablespace_name, file_name FROM dba_temp_files;

-- rm -rf /opt/oracle/product/23ai/dbhomeFree/dbs/arch1_57_*
---------------------------------------------------------------------------------------------------------
-- rm -rf /opt/oracle/product/23ai/dbhomeFree/dbs/BVS_PFILE.ORA

SELECT tablespace_name FROM dba_tablespaces;
SELECT username FROM dba_users WHERE username = 'BVS';
SELECT segment_name FROM dba_segments WHERE owner = 'BVS';

--ls -l /opt/oracle/oradata/FREE/

