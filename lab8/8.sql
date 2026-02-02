    --- export ORACLE_SID=FREE
    --- unset TWO_TASK
    
    -- set serveroutput on 
    
--1

begin 
    null;
end;
/

--2

begin 
    dbms_output.put_line('hello world!');
end;
/

--3 sqlerrm, sqlcode.
begin
    declare 
        a number := 10;
        b number := 0;
        res number;
    begin
        res := a / b;
        dbms_output.put_line(res);
    end;
exception
    when others then
        dbms_output.put_line('код ошибки: ' || sqlcode);
        dbms_output.put_line('сообщение ошибки: ' || sqlerrm);
end;
/

--4 вложенный блок
begin 
    dbms_output.put_line('внешний блок начался');
    begin 
        dbms_output.put_line('внутренний блок начался');
        declare 
            v number := 10 / 0;
        begin 
            null;
        end;
    exception
        when others then
            dbms_output.put_line('внутренний блок поймал ошибку ' || sqlerrm);
    end;
    dbms_output.put_line('внешний блок продолжает работать после внутреннего');
end;
/

--5
show errors;
alter session set plsql_warnings = 'enable:all';
alter session set plsql_warnings = 'disable:all';
show parameter plsql_warnings;

create or replace procedure test_warn is
    x number;
begin
    null;
end;
/

--6

select keyword from v$reserved_words where length = 1;

--7

select keyword from v$reserved_words 
where length > 1 and reserved = 'y' 
order by keyword;

--8

select name, value
from v$parameter
where lower(name) like '%plsql%'
order by name;

show parameters plsql;

--9–17
declare
    a number := 10;
    b number := 3;
    sum_ number;
    diff number;
    mult number;
    div_ number;
    mod_ number;
    
    fixed_num number(6,2) := 123.45;
    rounded_num number(6,-1) := 123.45;
    f_var binary_float := 123456789.123456789;
    d_var binary_double := 123456789.123456789;
    
    exp_num1 number := 1.5e3;
    exp_num2 number := 2.5e-2;
    
    flag_true boolean := true;
    flag_false boolean := false;
begin
    sum_ := a + b;
    diff := a - b;
    mult := a * b;
    div_ := a / b;
    mod_ := mod(a, b);
    
    dbms_output.put_line('10. целые number-переменные: a=' || a || ', b=' || b);
    dbms_output.put_line('11. арифметика:');
    dbms_output.put_line('   сумма = ' || sum_);
    dbms_output.put_line('   разность = ' || diff);
    dbms_output.put_line('   произведение = ' || mult);
    dbms_output.put_line('   деление = ' || div_);
    dbms_output.put_line('   остаток = ' || mod_);

    dbms_output.put_line('12. number с фиксированной точкой: ' || fixed_num);
    dbms_output.put_line('13. number с отрицательным масштабом (округлён): ' || rounded_num);
    dbms_output.put_line('14. binary_float: ' || f_var);
    dbms_output.put_line('15. binary_double: ' || d_var);
    dbms_output.put_line('16. экспоненциальные значения: ' || exp_num1 || ', ' || exp_num2);

    if flag_true then
        dbms_output.put_line('17. boolean: flag_true = true');
    end if;
    if not flag_false then
        dbms_output.put_line('17. boolean: flag_false = false');
    end if;
end;
/

--18
declare 
    c_name constant varchar2(20) := 'violetta';
    c_surname constant char(10) := 'babich';
    c_age constant number := 19;
begin 
    dbms_output.put_line('конкатенация: ' || c_name || ' ' || c_surname);
    dbms_output.put_line('сложение: ' || (c_age + 1));
end;
/

--19
declare
    v_name varchar2(20) := '&test';
    v_copy v_name%type;
begin
    v_copy := 'copied';
    dbms_output.put_line('тип унаследован от v_name: ' || v_copy);
end;
/

--20
declare
    v_std students%rowtype;
begin
    select name
    into v_std.name
    from students
    where rownum = 1;

    dbms_output.put_line('имя: ' || v_std.name);
end;
/

--21
declare
    v_num number := 10;
begin
    if v_num > 0 then
        dbms_output.put_line('число положительное');
    end if;

    if v_num mod 2 = 0 then
        dbms_output.put_line('число чётное');
    else
        dbms_output.put_line('число нечётное');
    end if;

    if v_num < 0 then
        dbms_output.put_line('число отрицательное');
    elsif v_num = 0 then
        dbms_output.put_line('число равно нулю');
    else
        dbms_output.put_line('число положительное');
    end if;

    if v_num > 0 then
        dbms_output.put_line('внешнее условие: число положительное');
        if v_num > 5 then
            dbms_output.put_line('внутреннее условие: число больше 5');
        else
            dbms_output.put_line('внутреннее условие: число меньше или равно 5');
        end if;
    end if;
end;
/

--23
declare
    x pls_integer := 7;
begin
    case
        when x > 8 then dbms_output.put_line('отлично');
        when x between 6 and 8 then dbms_output.put_line('хорошо');
        when x between 4 and 5 then dbms_output.put_line('удовлетворительно');
        else dbms_output.put_line('неудовлетворительно');
    end case;
end;
/

--24
declare
    i number := 1;
begin
    loop
        dbms_output.put_line('loop: i = ' || i);
        i := i + 1;
        exit when i > 3;
    end loop;
end;
/

--25
declare
    i number := 1;
begin
    while i <= 3 loop
        dbms_output.put_line('while: i = ' || i);
        i := i + 1;
    end loop;
end;
/

--26
begin
    for i in 1..3 loop
        dbms_output.put_line('for: i = ' || i);
    end loop;
end;
/