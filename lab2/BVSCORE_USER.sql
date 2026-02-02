create table BVS_user_table (
    id number(1) primary key,
    name varchar(10),
    age number(2)
    );
    
create view BVS_view as 
    select name from BVS_user_table;
    
INSERT INTO BVS_user_table (id, name, age) VALUES (1, 'Anna', 25);
INSERT INTO BVS_user_table (id, name, age) VALUES (2, 'Ivan', 30);
INSERT INTO BVS_user_table (id, name, age) VALUES (3, 'Lena', 22);
INSERT INTO BVS_user_table (id, name, age) VALUES (4, 'Oleg', 28);
INSERT INTO BVS_user_table (id, name, age) VALUES (5, 'Dina', 35);

select * from BVS_user_table

select * from BVS_view