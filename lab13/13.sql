grant create tablespace, drop tablespace to BVSCORE;
alter user BVSCORE quota unlimited on first_tablespace;
alter user BVSCORE quota unlimited on second_tablespace;
alter user BVSCORE quota unlimited on third_tablespace;
alter user BVSCORE quota unlimited on fouth_tablespace;

select * from dba_users;

create tablespace first_tablespace
datafile 'first.dbf'
size 7 m 
autoextend on
maxsize unlimited 
extent management local;

create tablespace second_tablespace
datafile 'second_tablespace.dbf' 
size 7 m 
autoextend on
maxsize unlimited 
extent management local;

create tablespace third_tablespace
datafile 'third_tablespace.dbf' 
size 7 m 
autoextend on
maxsize unlimited 
extent management local;


create tablespace fouth_tablespace
datafile 'fouth_tablespace.dbf' 
size 7 m 
autoextend on
maxsize unlimited 
extent management local;

--1.	Создайте таблицу T_RANGE c диапазонным секционированием. Используйте ключ секционирования типа NUMBER. 
drop table t_range;

create table t_range (
id number,
name varchar2(50)
)
partition by range (id)(
partition p0 values less than (5) tablespace first_tablespace,
partition p1 values less than (15) tablespace second_tablespace,
partition p2 values less than (25) tablespace third_tablespace,
partition p3 values less than (maxvalue) tablespace fouth_tablespace
);

insert into t_range (id, name) values (1, 'fsdvd');
insert into t_range (id, name) values (9, 'fsdvd');
insert into t_range (id, name) values (13, 'fsdvd');
insert into t_range (id, name) values (23, 'fsdvd');
insert into t_range (id, name) values (29, 'fsdvd');

commit;

select * from t_range partition(p0);
select * from t_range partition(p1);
select * from t_range partition(p2);
select * from t_range partition(p3);


--2.	Создайте таблицу T_INTERVAL c интервальным секционированием. Используйте ключ секционирования типа DATE.
drop table t_interval;

create table t_interval(
id date,
name varchar2(50)
)
partition by range (id)
interval(numtoyminterval(1, 'month'))
(
partition p0 values less than (to_date('2020-01-01', 'yyyy-mm-dd')) tablespace first_tablespace,
partition p1 values less than (to_date('2021-02-02', 'yyyy-mm-dd')) tablespace second_tablespace,
partition p2 values less than (to_date('2022-03-03', 'yyyy-mm-dd')) tablespace third_tablespace,
partition p3 values less than (to_date('2023-04-04', 'yyyy-mm-dd')) tablespace fouth_tablespace
);

insert into t_interval (id, name) values('11-11-2019', 'hghghg');
insert into t_interval (id, name) values ('11-11-2020', 'prprpr');
insert into t_interval (id, name) values ('11-11-2021', 'kdkdkd');
insert into t_interval (id, name) values ('05-04-2023', 'alalal');
insert into t_interval (id, name) values ('15-05-2023', 'uguguu');
commit;

select * from t_interval partition (p0);
select * from t_interval partition (p1);
select * from t_interval partition (p2);
select * from t_interval partition (p3);

select partition_name, high_value
from user_tab_partitions
where table_name = 'T_INTERVAL'
order by partition_position;

--3.	Создайте таблицу T_HASH c хэш-секционированием. Используйте ключ секционирования типа VARCHAR2.
drop table  t_hash;

create table t_hash (
id number,
name varchar2(50)
)
partition by hash (name) (
partition p0 tablespace first_tablespace,
partition p1 tablespace second_tablespace,
partition p2 tablespace third_tablespace,
partition p3 tablespace fouth_tablespace
);

insert into t_hash (id, name) values (1, 'one');
insert into t_hash (id, name) values (2, 'two');
insert into t_hash (id, name) values (3, 'three');
insert into t_hash (id, name) values (4, 'fourth');
insert into t_hash (id, name) values (5, 'five');
insert into t_hash (id, name) values (6, 'six');
insert into t_hash (id, name) values (7, 'seven');
insert into t_hash (id, name) values (8, 'eight');
commit;

select * from t_hash partition (p0);
select * from t_hash partition (p1);
select * from t_hash partition (p2);
select * from t_hash partition (p3);

--4.	Создайте таблицу T_LIST со списочным секционированием. Используйте ключ секционирования типа CHAR.
drop table t_list;
create table t_list (
id number,
name char(1)
)
partition by list (name)(
partition p0 values ('a') tablespace first_tablespace,
partition p1 values ('b') tablespace second_tablespace,
partition p2 values ('c') tablespace third_tablespace,
partition p3 values (default) tablespace fouth_tablespace
);

insert into t_list (id, name) values (1, 'a');
insert into t_list (id, name) values (2, 'b');
insert into t_list (id, name) values (3, 'c');
insert into t_list (id, name) values (4, 'd');
insert into t_list (id, name) values (5, 'e');
commit;

select * from t_list partition (p0);
select * from t_list partition (p1);
select * from t_list partition (p2);
select * from t_list partition (p3);

--5.	Введите с помощью операторов INSERT данные в таблицы T_RANGE, T_INTERVAL, T_HASH, T_LIST. Данные должны быть такими, чтобы они разместились по всем секциям. Продемонстрируйте это с помощью SELECT запроса.
--6.	Продемонстрируйте для всех таблиц процесс перемещения строк между секциями, при изменении (оператор UPDATE) ключа секционирования.

alter table t_range enable row movement;
select * from t_range partition (p0);
update t_range set id = 14 where id =1;
select * from t_range partition (p0);
select * from t_range partition (p1);

alter table t_interval enable row movement;
select * from t_interval partition (p0);
update t_interval set id = '11-12-2020' where name = 'hghghg';
select * from t_interval partition (p0);
select * from t_interval partition (p1);
rollback;

alter table t_hash enable row movement;
select * from t_hash partition (p0);
update t_hash set name = 'new fourth' where id =5;
select * from t_hash partition (p0);
select * from t_hash partition (p1);
select * from t_hash partition (p2);
select * from t_hash partition (p3);

alter table t_list enable row movement;
select * from t_list partition (p0);
update t_list set name = 'z' where id = 1;
select * from t_list partition (p0);
select * from t_list partition (p1);
select * from t_list partition (p2);
select * from t_list partition (p3);

--7.	Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE MERGE.
alter table t_range merge partitions p0, p1 into partition partition_merge tablespace first_tablespace;
select * from t_range partition (partition_merge);

--8.	Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE SPLIT.
alter table t_range split partition partition_merge at (14) into (
partition p0 tablespace third_tablespace, 
partition p1 tablespace fouth_tablespace
);
select * from t_range partition (p0);
select * from t_range partition (p1);
select * from t_range partition (p2);
select * from t_range partition (p3);

--9.	Для одной из таблиц продемонстрируйте действие оператора ALTER TABLE EXCHANGE.
create table example(
id number,
name varchar2(50)
);

alter table t_range exchange partition p0 with table example with validation;
select * from example;
select * from t_range partition (p0);