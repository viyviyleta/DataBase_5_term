--1--
SELECT 
    PDB_NAME, 
    STATUS 
FROM 
    CDB_PDBS;

SELECT *
FROM DBA_PDBS;
    
--2--
SELECT 
    INSTANCE_NAME, 
    HOST_NAME, 
    STATUS 
FROM 
    V$INSTANCE;
    
--3--  
SELECT *
FROM V$OPTION

SELECT 
    COMP_ID, 
    COMP_NAME, 
    VERSION, 
    STATUS 
FROM 
    DBA_REGISTRY;
    
--4--
CREATE PLUGGABLE DATABASE BVS_PDB
    ADMIN USER bvs_admin IDENTIFIED BY 1111
    FILE_NAME_CONVERT =(
        '/opt/oracle/oradata/FREE/pdbseed/',
        '/opt/oracle/oradata/FREE/BVS_PDB/'
    )
    
ALTER PLUGGABLE DATABASE BVS_PDB OPEN;    

SELECT PDB_NAME, STATUS FROM CDB_PDBS;

ALTER PLUGGABLE DATABASE BVS_PDB OPEN;

--5--
SELECT PDB_NAME, STATUS FROM CDB_PDBS;

--6--
SELECT NAME, CON_ID FROM V$DATABASE;
ALTER SESSION SET CONTAINER = BVS_PDB;


CREATE TABLESPACE bvs_data 
DATAFILE '/opt/oracle/oradata/FREE/BVS_PDB/bvs_data01.dbf' 
SIZE 50M 
AUTOEXTEND ON NEXT 10M 
MAXSIZE UNLIMITED;

create temporary tablespace TS_BVS_PDB_TEMP
tempfile '/opt/oracle/oradata/FREE/BVS_PDB/TS_PDB_BVS_TEMP.dbf'
size 5M
autoextend on next 2M
maxsize 20M;

select * from dba_tablespaces where tablespace_name like '%BVS%'

drop tablespace bvs_data  including contents and datafiles;
drop tablespace TS_BVS_PDB_TEMP including contents and datafiles;



CREATE PROFILE bvs_profile LIMIT
  FAILED_LOGIN_ATTEMPTS 3
  PASSWORD_LIFE_TIME 90
  PASSWORD_REUSE_TIME 30
  PASSWORD_REUSE_MAX 5
  PASSWORD_VERIFY_FUNCTION NULL;
  
drop role RL_PDB_BVSCORE; 
create role RL_PDB_BVSCORE;

grant connect to RL_PDB_BVSCORE;
grant create session to RL_PDB_BVSCORE;
grant create any table to RL_PDB_BVSCORE;
grant drop any table to RL_PDB_BVSCORE;
grant create any view to RL_PDB_BVSCORE;
grant drop any view to RL_PDB_BVSCORE;
grant create any procedure to RL_PDB_BVSCORE;
grant drop any procedure to RL_PDB_BVSCORE;

drop profile PF_BVS
create profile PF_BVS limit
password_life_time 180
sessions_per_user 5
failed_login_attempts 7
password_lock_time 1
password_reuse_time 10
password_grace_time default 
connect_time 180
idle_time 30;

create user Us_BVS_PDB identified by 12345
default tablespace bvs_data
quota unlimited on bvs_data
temporary tablespace TS_BVS_PDB_TEMP
profile PF_BVS
account unlock
password expire;

drop user Us_BVS_PDB;

grant RL_PDB_BVSCORE to Us_BVS_PDB;

ALTER PROFILE PF_BVS LIMIT PASSWORD_LIFE_TIME UNLIMITED;
ALTER USER Us_BVS_PDB IDENTIFIED BY 1111;


--7--
create table BVS_table ( x number(2), y varchar(5));

DROP TABLE BVS_table

insert into BVS_table values (8, 'HELLO');
insert into BVS_table values (6, 'POKA');
commit;

select * from BVS_table;

--8--
select * from dba_tablespaces;
select * from dba_tablespaces where tablespace_name like '%BVS%';
select * from DBA_DATA_FILES;
select * from DBA_TEMP_FILES;
select * from dba_roles;
select * from dba_users;
select * from dba_roles where ROLE like 'RL%';
select * from dba_sys_privs where GRANTEE like 'RL%';
select * from dba_profiles
select * from dba_profiles where PROFILE like 'PF%';


--9--
CREATE USER C##BVS IDENTIFIED BY 1111;
GRANT CREATE SESSION TO C##BVS CONTAINER=ALL;

SHOW CON_NAME;

--10--

ALTER PLUGGABLE DATABASE BVS_PDB CLOSE IMMEDIATE;

DROP PLUGGABLE DATABASE BVS_PDB INCLUDING DATAFILES;

SELECT PDB_NAME FROM CDB_PDBS;

DROP USER C##BVS CASCADE;

