create table BVS_t(x number(3) PRIMARY KEY, s varchar(50));

INSERT INTO BVS_T (x, s) VALUES 
    (111, 'BABICH'),
    (222, 'SEGRENEV'),
    (333, 'MIRONOV'),
    (444, 'BELKO'),
    (555, 'SAVELYEVA'),
    (666, 'SHYTKO'),
    (777, 'POPOVA');
COMMIT

UPDATE BVS_t SET s='new_MIRONOV' WHERE x=333;
UPDATE BVS_t SET s='new_SHYTKO' WHERE x=666;
COMMIT

SELECT * FROM BVS_t WHERE x>333;

SELECT COUNT(*) AS all_str,
       SUM(X) AS sum_x
FROM BVS_T;

DELETE FROM BVS_t WHERE x=666;
COMMIT

CREATE TABLE BVS_t1 (y NUMBER(3), 
                    str_y VARCHAR(10), 
                    x_ref NUMBER(3), 
                    FOREIGN KEY (x_ref) REFERENCES BVS_t(x))

INSERT INTO BVS_t1 VALUES (1, 'BD', 111),
        (2, 'PSKP', 111),
        (3, 'SP', 222),
        (4, 'OOP', 333),
        (5, 'KMS', 222);
COMMIT

SELECT t.x, 
        t.s,
        t1.y,
        t1.str_y
FROM BVS_t t
JOIN BVS_t1 t1 ON t.x=t1.x_ref

SELECT t.x, 
        t.s,
        t1.y,
        t1.str_y
FROM BVS_t t
LEFT JOIN BVS_t1 t1 ON t.x=t1.x_ref

SELECT t.x, 
        t.s,
        t1.y,
        t1.str_y
FROM BVS_t t
RIGHT JOIN BVS_t1 t1 ON t.x=t1.x_ref

DROP TABLE BVS_t1
DROP TABLE BVS_t