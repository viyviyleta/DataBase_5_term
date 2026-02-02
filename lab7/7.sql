--1--
create user BVS identified by 1111 account unlock;
grant create materialized view, create view, create public synonym, create any synonym, create cluster, create session, create sequence, create table to BVS;
grant drop any materialized view, drop any view, drop public synonym, drop any synonym, drop any cluster, drop any sequence to BVS;

alter user BVS default tablespace TS_BVS quota unlimited on TS_BVS;

--2---

create SEQUENCE S1  
        start with 1000
        increment by 10
        nominvalue
        nomaxvalue
        nocycle
        nocache
        noorder
        
select S1.nextval from dual;
        
select S1.nextval from dual connect by level <= 5;

select S1.currval from dual;

--3_4--

create SEQUENCE S2
        start with 10
        increment by 10
        maxvalue 100
        nominvalue
        nocycle
        nocache
        noorder
        
select S2.nextval from dual connect by level <= 10;
select S2.nextval from dual;
select S2.currval from dual;

--5--

create SEQUENCE S3
        start with 10
        increment by -10
        minvalue -120
        maxvalue 100 
        nocycle
        order

select S3.nextval from dual connect by level <= 12;
select S3.nextval from dual;
select S3.currval from dual;

--6--

create SEQUENCE S4
        start with 1
        increment by 1
        maxvalue 10
        cache 5
        cycle 
        noorder
        
select S4.nextval from dual connect by level <= 15;
select S4.currval from dual;

--7--

SELECT sequence_name FROM user_sequences;

--8--

create table T1 (
        N1 number(20),
        N2 number(20),
        N3 number(20),
        N4 number(20)
) storage(buffer_pool keep)

begin 
    for i in 1..7 loop
    insert into T1 (N1, N2,N3, N4)
    values (
        S1.nextval,
        S2.nextval,
        S3.nextval,
        S4.nextval
    );
    end loop;
end;
/

select * from T1;

--9--

create cluster ABC(
x number(10),
v varchar(12)
)hashkeys 200;

--10--

create table A (
xa number(10),
va varchar(12),
n varchar(30)
) cluster ABC (xa, va);

insert into A (xa, va, n) values (1, 'table_A', 'Anna');

--11--

create table B (
xb number(10),
vb varchar(12),
nb varchar(30)
) cluster ABC (xb, vb);

insert into B (xb, vb, nb) values (1, 'table_B', 'Boris');

--12--

create table C (
xc number(10),
vc varchar(12),
nc varchar(30)
) cluster ABC (xc, vc);

insert into C (xc, vc, nc) values (1, 'table_C', 'Violetta');

--13--

select table_name from user_tables;

select * from user_clusters where cluster_name = 'ABC';

SELECT 'A' AS source, xa AS x, va AS v, n AS name FROM A
UNION ALL
SELECT 'B', xb, vb, nb FROM B
UNION ALL
SELECT 'C', xc, vc, nc FROM C
ORDER BY x, v;

--14--

create SYNONYM synonyn_C for C;

select * from synonyn_C;

--15--

create public synonym synonim_B for B;

select * from synonim_B;

--16--

create table students (
        id number(10) primary key,
        name varchar(20)
);

create table groups (
        n_group number(10),
        id_student number(10),
        speciality varchar(10),
        constraint fk_student foreign key (id_student) references students(id)
)

INSERT INTO students (id, name) VALUES (1, 'Alice');
INSERT INTO students (id, name) VALUES (2, 'Bob');
INSERT INTO students (id, name) VALUES (3, 'Charlie');


INSERT INTO groups (n_group, id_student, speciality) VALUES (101, 1, 'Math');
INSERT INTO groups (n_group, id_student, speciality) VALUES (102, 2, 'Physics');
INSERT INTO groups (n_group, id_student, speciality) VALUES (103, 2, 'Russian');

create view V1 as select * from students inner join groups on students.id = groups.id_student;

select * from V1

--17--

create materialized view MV 
build immediate 
refresh complete on demand next sysdate + numtodsinterval(2, 'minute') as select * from A inner join B on A.xa = B.xb

select * from A
select * from B

select * from MV

update A set  va='A' where xa=1

exec DBMS_MVIEW.REFRESH('MV');


------------------------DELETE------------------------делать если попросят на лабе сделать заново

drop SEQUENCE S1;
drop SEQUENCE S2;
drop SEQUENCE S3;
drop SEQUENCE S4;

drop table T1;

drop cluster ABC;

drop table A;
drop table B;
drop table C;

drop SYNONYM synonyn_C;
drop synonym synonim_B;

drop table students;
drop table groups;

drop view V1;
drop view MV;





