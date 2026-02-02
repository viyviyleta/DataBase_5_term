
--2
select regexp_substr(teacher_name, '(\S+)', 1,1)||' ' || substr(regexp_substr(teacher_name, '(\S+)', 1, 2), 1, 1) || '.' || substr(regexp_substr(teacher_name, '(\S+)', 1, 3), 1, 1) || '.' as ФИО from teacher;

--3
    select * from teacher where to_char(birthday, 'd') = 2;

--4 
create or replace view next_month as
select * from teacher where to_char(birthday, 'mm') = (select substr(to_char(trunc(last_day(sysdate)) + 1), 4, 2) from dual);

select * from next_month;

--5
create or replace view number_months as
select to_char(birthday, 'Month') месяц, count(*) количество from teacher group by to_char(birthday, 'Month') having count(*) >= 1
order by Количество desc;

select * from number_months;

--6
declare
    cursor teacher_birthday
    return teacher%rowtype is
    select * from teacher where mod(extract(year from sysdate) - extract(year from birthday) + 1, 5) = 0;
    v_teacher  teacher%rowtype;
begin
    open teacher_birthday;
    fetch teacher_birthday into v_teacher;
    while (teacher_birthday%found)
        loop
        dbms_output.put_line(v_teacher.teacher || ' ' || v_teacher.teacher_name || ' ' || v_teacher.pulpit || ' ' || v_teacher.birthday || ' ' || v_teacher.salary);
        fetch teacher_birthday into v_teacher;
        end loop;
    close teacher_birthday;
end;

--7
declare
    cursor teachers_avg_salary is
    select pulpit, floor(avg(salary)) as avg_salary from teacher group by pulpit;
    cursor faculty_avg_salary is select faculty, trunc(AVG(salary)) from teacher
    join PULPIT P on teacher.pulpit = P.pulpit group by faculty;
    cursor faculties_avg_salary is select AVG(salary) from teacher;
    m_pulpit  teacher.pulpit%type;
    m_salary  teacher.salary%type;
    m_faculty pulpit.faculty%type;
begin
dbms_output.put_line('--------------- По кафедрам -----------------');
    open teachers_avg_salary;
    fetch teachers_avg_salary into m_pulpit, m_salary;
        while (teachers_avg_salary%found)
            loop
                dbms_output.put_line(m_pulpit || ' ' || m_salary);
                fetch teachers_avg_salary into m_pulpit, m_salary;
            end loop;
    close teachers_avg_salary;
dbms_output.put_line('--------------- По факультетам -----------------');
    open faculty_avg_salary;
        fetch faculty_avg_salary into m_faculty, m_salary;
            while (faculty_avg_salary%found)
                loop
                dbms_output.put_line(m_faculty || ' ' || m_salary);
                fetch faculty_avg_salary into m_faculty, m_salary;
                end loop;
    close faculty_avg_salary;
dbms_output.put_line('--------------- По всем факультетам -----------------');
    open faculties_avg_salary;
        fetch faculties_avg_salary into m_salary;
        dbms_output.put_line(round(m_salary, 2));
    close faculties_avg_salary;
end;

--8
declare
  type name_rec is record (
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
  );

  type teacher_rec is record (
    name name_rec,
    salary NUMBER
  );

  teacher1 teacher_rec;
  teacher2 teacher_rec;
begin
  teacher1.name.first_name := 'Кто-то';
  teacher1.name.last_name := 'Какой-то';
  teacher1.salary := 50000;

  teacher2 := teacher1;

  teacher2.salary := 55000;

  dbms_output.put_line('Teacher1: ' || teacher1.name.first_name || ' ' || teacher1.name.last_name || ', Salary: ' || teacher1.salary);
  dbms_output.put_line('Teacher2: ' || teacher2.name.first_name || ' ' || teacher2.name.last_name || ', Salary: ' || teacher2.salary);
end;