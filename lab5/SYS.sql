--1--с колько памяти выделено под SGA 

select sum(value) from v$sga;

--2-- текущие размеры основных пулов SGA 
show parameter pool_size
select * from v$sga;

--3-- размеры гранулы для каждого пула

select component, granule_size from v$sga_dynamic_components;

--4-- объем доступной свободной памяти в SGA    

select name, bytes 
from v$sgastat
where name = 'free memory';

select current_size from v$sga_dynamic_free_memory;

--5-- максимальный и целевой размер области SGA 

select name, value from v$parameter where name in ('sga_target', 'sga_max_size');

--6-- размеры пулов KEEP, DEFAULT и RECYCLE буферного кэша 

select component, current_size, max_size, min_size from v$sga_dynamic_components where component like '%КЕЕP%' or component like '%DEFAULT%' or component like '%RECYCLE%';

--7--

create table BVS_7(
        id number(2),
        name varchar2(5)
)storage (buffer_pool keep)

insert into BVS_7 (id, name) values (1, 'A');
insert into BVS_7 (id, name) values (2, 'B');
insert into BVS_7 (id, name) values (3, 'C');

select * from BVS_7

select segment_name, segment_type, tablespace_name, buffer_pool from user_segments where segment_name = 'BVS_7';

--8--

create table BVS_8(
n number(10)
) storage (buffer_pool default);

insert into BVS_8 (n) values (3);
insert into BVS_8 (n) values (6);
insert into BVS_8 (n) values (2);

select * from BVS_8;

select segment_name, segment_type, tablespace_name, buffer_pool from user_segments where segment_name = 'BVS_8';

--9-- размер буфера журналов повтора

select name, hash from v$parameter where name = 'log_buffer';

--10-- размер свободной памяти в большом пуле

select * from v$sgastat where name = 'free memory' and pool = 'large pool';

--11--  режимы текущих соединений с инстансом (dedicated, shared)

select username, sid, server, status from v$session where username is not null;

--12-- полный список работающих в настоящее время фоновых процессов

select name, description from v$bgprocess where paddr!=hextoraw('00') order by name;

--13-- список работающих в настоящее время серверных процессов

select *from v$process

--14-- , сколько процессов DBWn работает в настоящий момент

select count(*) from v$bgprocess where paddr!='00' and name like '%DBW%';

--15-- сервисы (точки подключения экземпляра).

select * from v$services

--16-- известные вам параметры диспетчеров

select * from v$dispatcher

--17-- Укажите в списке Windows-сервисов сервис, реализующий процесс LISTENER

-- ps -aux | grep tnslsnr

--18--

-- cat $ORACLE_HOME/network/admin/listener.ora

--19--

-- lsnrctl

--20-- список служб инстанса

select name from dba_services;

