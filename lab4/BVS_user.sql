create table BVS_T1 (
        id number primary key,
        name varchar2(10)
)tablespace BVS_QDATA;

INSERT INTO BVS_T1 VALUES (1, 'Alpha');
INSERT INTO BVS_T1 VALUES (2, 'Beta');
INSERT INTO BVS_T1 VALUES (3, 'Gamma');
commit

select * from BVS_T1

drop table BVS_T1