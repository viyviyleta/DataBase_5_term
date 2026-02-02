--1
declare
    procedure get_teachers(pcode teacher.pulpit%type) as
    begin
        for i in (select * from teacher where pulpit = pcode)
        loop
            dbms_output.put_line(i.teacher_name);
        end loop;
    end get_teachers;
begin
    get_teachers('МиЭП');
end;
/

select * from teacher;

--2
declare
    function get_num_teachers(pcode teacher.pulpit%type) return number
    is 
        num number := 0;
    begin
        select count(*) 
        into num 
        from teacher 
        where pulpit = pcode;

        return num;
    end get_num_teachers;
begin
    dbms_output.put_line(get_num_teachers('МиЭП'));
end;
/

--4
declare 
    procedure get_teachers(fcode faculty.faculty%type) as 
    begin
        for i in (
            select * 
            from teacher 
            join pulpit on teacher.pulpit = pulpit.pulpit 
            where faculty = fcode
        )
        loop
            dbms_output.put_line(i.teacher || i.teacher_name || i.faculty);
        end loop;
    end;
begin
    get_teachers('ИДиП');
end;
/

select * from teacher join pulpit on teacher.pulpit = pulpit.pulpit;

declare 
    procedure get_subjects(pcode subject.pulpit%type) as
    begin 
        for i in (select * from subject where pulpit = pcode)
        loop
            dbms_output.put_line(i.subject_name || ' ' || i.pulpit);
        end loop;
    end;
begin
    get_subjects('ИСиТ');
end;
/

--5
declare
    function get_num_teachers(fcode faculty.faculty%type) return number
    is
        num number := 0;
    begin
        select count(*) 
        into num 
        from teacher
        inner join pulpit p on p.pulpit = teacher.pulpit
        inner join faculty f on f.faculty = p.faculty
        where f.faculty = fcode;

        return num;
    end get_num_teachers;
begin
    dbms_output.put_line(get_num_teachers('ИДиП'));
end;
/

create or replace function get_num_subjects(pcode subject.pulpit%type)
return number
is
    num number := 0;
begin
    select count(*) into num
    from subject
    where pulpit = pcode;

    return num;
end get_num_subjects;
/

begin
    dbms_output.put_line(get_num_subjects('ИСиТ'));
end;
/
--6
create or replace package teachers as
    procedure get_teachers(fcode faculty.faculty%type);
    procedure get_subjects(pcode subject.pulpit%type);

    function get_num_teachers(fcode faculty.faculty%type)
        return number;

    function get_num_subjects(pcode subject.pulpit%type)
        return number;
end teachers;
/

create or replace package body teachers as

    procedure get_teachers(fcode faculty.faculty%type) is
    begin
        for rec in (
            select t.teacher,
                   t.teacher_name,
                   p.faculty
            from teacher t
            join pulpit p on t.pulpit = p.pulpit
            where p.faculty = fcode
        ) loop
            dbms_output.put_line(rec.teacher || ' ' || rec.teacher_name || ' ' || rec.faculty);
        end loop;
    end get_teachers;

    procedure get_subjects(pcode subject.pulpit%type) is
    begin
        for rec in (
            select subject_name, pulpit
            from subject
            where pulpit = pcode
        ) loop
            dbms_output.put_line(rec.subject_name || ' ' || rec.pulpit);
        end loop;
    end get_subjects;

    function get_num_teachers(fcode faculty.faculty%type) return number is
        v_count number;
    begin
        select count(*)
        into v_count
        from teacher t
        join pulpit p on t.pulpit = p.pulpit
        where p.faculty = fcode;

        return v_count;
    end get_num_teachers;

    function get_num_subjects(pcode subject.pulpit%type) return number is
        v_count number;
    begin
        select count(*)
        into v_count
        from subject
        where pulpit = pcode;

        return v_count;
    end get_num_subjects;

end teachers;
/

--7
begin
    dbms_output.put_line('--- Предметы кафедры ИСиТ ---');
    teachers.get_subjects('ИСиТ');

    dbms_output.put_line('');

    dbms_output.put_line('--- Преподаватели факультета ИДиП ---');
    teachers.get_teachers('ИДиП');

    dbms_output.put_line('');

    dbms_output.put_line('Количество преподавателей ИДиП: ' || teachers.get_num_teachers('ИДиП'));


    dbms_output.put_line('Количество предметов ИСиТ: ' || teachers.get_num_subjects('ИСиТ'));
end;
/
