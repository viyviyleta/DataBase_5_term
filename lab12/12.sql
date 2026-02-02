alter PLUGGABLE database BVS_PDB open
-- ============================================
-- УДАЛЕНИЕ ВСЕХ ТРИГГЕРОВ
-- ============================================

BEGIN
    FOR t IN (SELECT trigger_name FROM user_triggers
              WHERE table_name = 'FIRST_TABLE' OR table_name = 'AUDIT_' OR table_name = 'FIRST_TABLE_VIEW') LOOP
        EXECUTE IMMEDIATE 'DROP TRIGGER ' || t.trigger_name;
    END LOOP;
END;
/

-- ============================================
-- УДАЛЕНИЕ ПРЕДСТАВЛЕНИЙ
-- ============================================

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW first_table_view';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================
-- УДАЛЕНИЕ ТАБЛИЦ
-- ============================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE first_table CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE audit_ CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================
-- УДАЛЕНИЕ ТРИГГЕРА prevent_drop_table (если есть)
-- ============================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER prevent_drop_table';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/


--1
create table first_table(
id int primary key,
name varchar2(30)
);

--2
begin
	for i in 1 .. 10
        loop
        insert into first_table values(i, 'oracle');
	end loop;
end;
/

select * from first_table;

--3
create or replace trigger before_insert
before insert on first_table
begin
dbms_output.put_line('before_insert');
end;
/

create or replace trigger before_delete
before delete on first_table
begin
dbms_output.put_line('before_delete');
end;
/

create or replace trigger before_update
before update on first_table
begin
dbms_output.put_line('before_update');
end;
/

select * from first_table;

insert into first_table values(11, 'hello');
insert into first_table values(12, 'hello');
delete from first_table where id = 11;
update first_table set name = 'update hello' where id = 11;

--5
create or replace trigger before_insert_row
before insert on first_table
for each row
begin
dbms_output.put_line('before_insert_row');
end;

create or replace trigger before_update_row
before update on first_table
for each row
begin
dbms_output.put_line('before_update_row');
end;

create or replace trigger before_delete_row
before delete on first_table
for each row
begin
dbms_output.put_line('before_delete_row');
end;

select * from first_table;

insert into first_table values(13, 'hello, friend');
delete from first_table where id = 12;
update first_table set name = 'update hello' where id = 13;

--6 
create or replace trigger trigger_dml
before insert or update or delete on first_table
begin
if inserting then
dbms_output.put_line('trigger_dml_inserting');
elsif updating then
dbms_output.put_line('trigger_dml_updating');
elsif deleting then
dbms_output.put_line('trigger_dml_deleting');
end if;
end;

select * from first_table;

insert into first_table values(14, 'hello, friend');
delete from first_table where id = 9;
update first_table set name = 'update hello' where id = 14;


--7
create or replace trigger after_insert
after insert on first_table
begin
dbms_output.put_line('after_insert');
end;

create or replace trigger after_delete
after delete on first_table
begin
dbms_output.put_line('after_delete');
end;

create or replace trigger after_update
after update on first_table
begin
dbms_output.put_line('after_update');
end;

select * from first_table;

insert into first_table values(15, 'hello, friend');
delete from first_table where id = 2;
update first_table set name = 'update hello' where id = 15;

--8
create or replace trigger after_insert_row
after insert on first_table
for each row
begin
dbms_output.put_line('after_insert_row');
end;

create or replace trigger after_update_row
after update on first_table
for each row
begin
dbms_output.put_line('after_update_row');
end;

create or replace trigger after_delete_row
after delete on first_table
for each row
begin
dbms_output.put_line('after_delete_row');
end;

select * from first_table;

insert into first_table values(16, 'hello, friend');
delete from first_table where id = 1;
update first_table set name = 'update hello' where id = 16;

--9
create table AUDIT_(
OperationDate date,
OperationType varchar2(30),
TriggerName varchar2(30),
Data varchar2(50)
);

--10
create or replace trigger dml_before_row
before insert or update or delete
on first_table for each row
begin
if inserting then
dbms_output.put_line('dml_before_row insert');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'insert', 'dml_before_row', :new.id || ' ' || :new.name);
elsif updating then
dbms_output.put_line('dml_before_row update');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'update', 'dml_before_row', :old.id || ' ' || :old.name || '->' || :new.id || ' ' || :new.name);
elsif deleting then
dbms_output.put_line('dml_before_trigger_row delete');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'delete', 'dml_before_row', :old.id || ' ' || :old.name);
end if;
end;

create or replace trigger dml_after_row
after insert or update or delete
on first_table for each row
begin
if inserting then
dbms_output.put_line('dml_after_row insert');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'insert', 'dml_after_row', :new.id || ' ' || :new.name);
elsif updating then
dbms_output.put_line('dml_after_row update');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'update', 'dml_after_row', :old.id || ' ' || :old.name || '->' || :new.id || ' ' || :new.name);
elsif deleting then
dbms_output.put_line('dml_after_row delete');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'delete', 'dml_after_row', :old.id || ' ' || :old.name);
end if;
end;

create or replace trigger dml_before
before insert or update or delete on first_table for each row
begin
if inserting then
dbms_output.put_line('dml_before insert');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'insert', 'dml_before', :new.id || ' ' || :new.name);
elsif updating then
dbms_output.put_line('dml_before update');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'update', 'dml_before', :old.id || ' ' || :old.name || '->' || :new.id || ' ' || :new.name);
elsif deleting then
dbms_output.put_line('dml_before delete');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'delete', 'dml_before', :old.id || ' ' || :old.name);
end if;
end;

create or replace trigger dml_after
after insert or update or delete on first_table for each row
begin
if inserting then
dbms_output.put_line('dml_after insert');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'insert', 'dml_after', :new.id || ' ' || :new.name);
elsif updating then
dbms_output.put_line('dml_after update');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'update', 'dml_after', :old.id || ' ' || :old.name || '->' || :new.id || ' ' || :new.name);
elsif deleting then
dbms_output.put_line('dml_after delete');
insert into AUDIT_ (operationdate, operationtype, triggername, data)
values (sysdate, 'delete', 'dml_after', :old.id || ' ' || :old.name);
end if;
end;

select * from first_table;
select * from AUDIT_;
insert into first_table (id, name) values (21, 'New text');
update first_table set name = 'Updated text' where id = 21;
delete from first_table where id = 21;

--11
insert into first_table (id, name) values (1, 'qqq');

select * from AUDIT_;

--12
drop table first_table;

create or replace trigger prevent_drop_table
before drop on schema
begin
if dictionary_obj_name = 'FIRST_TABLE' then
RAISE_APPLICATION_ERROR(-20000, 'You cannot drop the table first_table');
end if;
end;
/
select * from first_table;
drop trigger prevent_drop_table;

create table first_table(
id int primary key,
name varchar2(30)
);

begin
for i in 1 .. 10
loop
insert into first_table values(i, 'oracle');
end loop;
end;

--13
drop table AUDIT_;

--14
create view first_table_view as select * from first_table;

create or replace trigger instead_of_insert_trigger
instead of insert on first_table_view
begin
if inserting then
dbms_output.put_line('instead_of_insert_trigger');
insert into first_table (id, name) values (11, 'qppqpqpqppqp');
end if;
end instead_of_insert_trigger;
/

insert into first_table_view (id, name) values (11, 'newwewe');

select * from first_table;
select * from first_table_view;