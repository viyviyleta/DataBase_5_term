show pdbs;

ALTER PLUGGABLE DATABASE BVS_PDB OPEN;

ALTER SESSION SET CONTAINER = BVS_PDB;

SELECT username, account_status, created, default_tablespace
FROM dba_users
ORDER BY created DESC;

GRANT CREATE DATABASE LINK TO BVS;
GRANT CREATE PUBLIC DATABASE LINK TO BVS;

CREATE DATABASE LINK link_to_ipp
    CONNECT TO ipp
    IDENTIFIED BY "youtub_245"
    USING 'BVS_IPP';

SELECT table_name FROM all_tables@link_to_ipp WHERE owner = 'IPP';

create table test_link (id number(10), name varchar(10));

-- SELECT
SELECT * FROM T_TEMP@link_to_ipp;

-- INSERT
INSERT INTO T_TEMP@link_to_ipp (code, data) VALUES 
('qqq', 'Violetta');


-- UPDATE
UPDATE T_TEMP@link_to_ipp SET data = 'retyero' WHERE code = 'qqq';
COMMIT;

-- DELETE
DELETE FROM T_TEMP@link_to_ipp WHERE code = 'qqq';
COMMIT;


-- ПРОЦЕДУРЫ и ФУНКЦИИ --
CREATE OR REPLACE PROCEDURE test_proc(p_msg IN VARCHAR2) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Сообщение (BVS_IPP): ' || p_msg);
END;
/

CREATE OR REPLACE PROCEDURE test_proc(
    p_input IN VARCHAR2,
    p_output OUT VARCHAR2
) AS
BEGIN
    p_output := 'Ответ от BVS: Получено сообщение "'||p_input||'"';
    DBMS_OUTPUT.PUT_LINE('Процедура выполнена на удаленном сервере');
END;
/

GRANT EXECUTE ON test_proc TO PUBLIC;
GRANT EXECUTE ON test_func TO PUBLIC;

-- 

SELECT IPP.test_func@link_to_ipp(1) FROM DUAL;

-- Вызов процедуры
BEGIN
    IPP.test_proc@link_to_ipp('Тест');
END;
/

DECLARE
    v_input VARCHAR2(100) := 'Привет из локальной БД!';
    v_output VARCHAR2(500);
BEGIN
    -- Вызов удаленной процедуры с OUT параметром
    IPP.test_proc@link_to_ipp(v_input, v_output);
    
    -- Выводим то, что вернула процедура
    DBMS_OUTPUT.PUT_LINE('Получено от удаленного сервера:');
    DBMS_OUTPUT.PUT_LINE(v_output);
END;
/

-- Создание PUBLIC DB LINK (GLOBAL)

-- public dblink
CREATE PUBLIC DATABASE LINK public_link_ipp
    CONNECT TO ipp
    IDENTIFIED BY "youtub_245"
    USING 'BVS_IPP';
    
    
SELECT * FROM DUAL@public_link_ipp;

-- SELECT
SELECT * FROM T_TEMP@public_link_ipp;

-- INSERT
INSERT INTO T_TEMP@public_link_ipp (code, data) VALUES 
('qqq', 'Violetta');

-- UPDATE
UPDATE T_TEMP@public_link_ipp SET data = 'retyero' WHERE code = 'qqq';
COMMIT;

-- DELETE
DELETE FROM T_TEMP@public_link_ipp WHERE code = 'qqq';
COMMIT;

-- Вызов функции
SELECT IPP.test_func@public_link_ipp(2) FROM DUAL;

-- Вызов процедуры
BEGIN
    IPP.test_proc@public_link_ipp('Через публичный линк');
END;
/

DECLARE
    v_input VARCHAR2(100) := 'Привет через публичный линк!';
    v_output VARCHAR2(500);
BEGIN
    -- Вызов удаленной процедуры с OUT параметром
    IPP.test_proc@public_link_ipp(v_input, v_output);
    
    -- Выводим то, что вернула процедура
    DBMS_OUTPUT.PUT_LINE('Получено от удаленного сервера:');
    DBMS_OUTPUT.PUT_LINE(v_output);
END;
/

