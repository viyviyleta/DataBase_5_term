select * from dba_users;

SHOW USER;
GRANT CREATE JOB TO SYSTEM;
GRANT MANAGE SCHEDULER TO SYSTEM;

--1
drop table export_table;
drop table import_table;
drop table job_status;

create table export_table (
id integer,
some_string nvarchar2(50)
);

create table import_table (
id integer,
some_string nvarchar2(50)
);

create table job_status (
status nvarchar2(50),
error_message nvarchar2(700),
date_of_message date default sysdate
);

insert into export_table (id, some_string) values (1, 'first string');
insert into export_table (id, some_string) values (2, 'second string');
insert into export_table (id, some_string) values (3, 'third string');
insert into export_table (id, some_string) values (4, 'fourth string');
commit;
select * from export_table;
select * from import_table;

--2--3
create or replace procedure procedure_for_job is
  v_error_message varchar2(700);
begin
  for r in (select id, some_string from export_table)
  loop
    insert into import_table (id, some_string)
    values (r.id, r.some_string);
  end loop;

  delete from export_table;

  -- Логируем 
  insert into job_status (status, date_of_message)
  values ('success', SYSDATE);

  commit;
exception
  when others then
    v_error_message := SQLERRM;
    insert into job_status (status, error_message, date_of_message)
    values ('failure', v_error_message, SYSDATE);
    commit;
end procedure_for_job;
/

-- Проверка компиляции
show errors procedure procedure_for_job;

declare
  job_number USER_JOBS.JOB%TYPE;
begin
  DBMS_JOB.SUBMIT(
    job       => job_number,
    what      => 'BEGIN procedure_for_job; END;',
    next_date => SYSDATE,
    interval  => 'SYSDATE + 7'
  );
  commit;
  DBMS_OUTPUT.PUT_LINE('Created job #: ' || job_number);
end;
/

select * from job_status;
select * from export_table;
select * from import_table;

--4
select job, what, last_date, last_sec, next_date, next_sec, next_date, broken from user_jobs;

--5----------!
begin
dbms_job.run(42);
end;

select * from job_status;
select * from export_table;
select * from import_table;

begin
dbms_job.remove(42);
end;


--6--------------------------------------------------------------
begin
dbms_scheduler.create_schedule(
schedule_name => 'schedule_1', 
start_date => sysdate, 
repeat_interval => 'freq=weekly', 
comments => 'schedule_1 weekly'
);
end;

select * from user_scheduler_schedules;

begin
dbms_scheduler.create_program(
program_name => 'program_1', 
program_type => 'stored_procedure', 
program_action => 'procedure_for_job', 
number_of_arguments => 0, 
enabled => true, 
comments => 'program_1'
);
end;

select * from user_scheduler_programs;

begin
dbms_scheduler.create_job(
job_name => 'scheduler_job_2', 
program_name => 'program_1', 
schedule_name => 'schedule_1', 
enabled => true
);
end;

select * from user_scheduler_jobs;

begin
dbms_scheduler.disable('scheduler_job_2');
end;

begin
dbms_scheduler.enable('scheduler_job_2');
end;

begin
dbms_scheduler.run_job('scheduler_job_2');
end;

select * from job_status;

begin
dbms_scheduler.drop_job('scheduler_job_2');
end;





BEGIN
    DBMS_SCHEDULER.DROP_SCHEDULE('schedule_1', force => TRUE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Schedule does not exist or could not be dropped: ' || SQLERRM);
END;

BEGIN
    DBMS_SCHEDULER.DROP_PROGRAM('program_1', force => TRUE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Program does not exist or could not be dropped: ' || SQLERRM);
END;