CONNECT sys AS SYSDBA
--1--
create tablespace TS_BVS
    datafile '\opt\oracle\oradata\FREE\FREEPDB1\TS_SMI.dbf'
    size 7 m
    autoextend on next 5 m
    maxsize 20 m;
    commit;

select TABLESPACE_NAME from dba_tablespaces

drop tablespace TS_BVS including contents and datafiles

--2--
create temporary tablespace TS_BVS_TEMP
    tempfile 'D:\app\TS_BVS_TEMP.dbf'
    size 5 m
    autoextend on next 3 m
    maxsize 30 m;
    commit;

select tablespace_name from dba_tablespaces
select tablespace_name, status from dba_tablespaces

drop tablespace TS_BVS_TEMP including contents and datafiles

--3--
select tablespace_name, 
        contents,
        status
from dba_tablespaces

select tablespace_name,
        file_name,
        bytes/1024/1024 as size_mb
from dba_data_files

select tablespace_name,
        file_name,
        bytes/1024/1024 as size_mb
from dba_temp_files

--4--
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

create role RL_BVSCORE
SELECT role FROM dba_roles WHERE role = 'RL_BVSCORE';
drop role RL_BVSCORE;

grant create session to RL_BVSCORE;

grant create table to RL_BVSCORE;
grant drop table to RL_BVSCORE;

grant create view to RL_BVSCORE;
grant drop view to RL_BVSCORE;

grant create procedure to RL_BVSCORE;
grant drop procedure to RL_BVSCORE;

grant create function to RL_BVSCORE;
grant drop function to RL_BVSCORE;

--5--
select role from dba_roles where role='RL_BVSCORE'

select * from dba_sys_privs where grantee='RL_BVSCORE'

--6--
create profile PF_BVSCORE limit
    password_life_time 180
    sessions_per_user 3
    failed_login_attempts 7
    password_lock_time 1
    password_reuse_time 10
    password_grace_time default
    connect_time 180
    idle_time 30
    
drop profile PF_BVSCORE cascade   

--7--    
select *  from dba_profiles

select * from dba_profiles where profile='PF_BVSCORE'

select * from dba_profiles where profile='DEFAULT'

--8--
create user BVSCORE
    identified by 12345
    default tablespace TS_BVS
    quota unlimited on TS_BVS
    temporary tablespace TS_BVS_TEMP
    profile PF_BVSCORE
    account unlock
    password expire;

grant RL_BVSCORE to BVSCORE;

SELECT username FROM dba_users;
SELECT username, account_status FROM dba_users WHERE username = 'BVSCORE'
SELECT username, status, machine
FROM v$session
WHERE username = 'BVSCORE';

--11--
create tablespace SMI_QDATA
datafile 'SMI-QDATA.dfb'
size 10M
offline;

DROP TABLESPACE SMI_QDATA INCLUDING CONTENTS AND DATAFILES;

select TABLESPACE_NAME, STATUS, CONTENTS from SYS.dba_tablespaces;

alter tablespace SMI_QDATA online;

alter user SMICORE quota 2M on SMI_QDATA;

select tablespace_name, bytes, max_bytes from dba_ts_quotas where username = 'SMICORE';


drop table SMI_T1
create table SMI_T1
(
    m number(2),
    d varchar(10)
) tablespace SMI_QDATA;

insert  into SMI_T1 values (6, 'L');
INSERT into SMI_T1 values (3, 'G');
INSERT into SMI_T1 values (7, 'J');


select * from SMI_T1;


SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'SMICORE';
SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = 'SMICORE';
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'SMICORE';
