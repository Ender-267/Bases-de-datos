CLEAR SCREEN;
DROP TABLE tabla1 CASCADE CONSTRAINT;
-- Create table tabla1
CREATE TABLE tabla1 (
    id INTEGER,
    salario INTEGER,
    CONSTRAINT pk_tabla1 PRIMARY KEY (id)
);

-- Insert some sample data into tabla1
INSERT INTO tabla1 VALUES (1, 20);
INSERT INTO tabla1 VALUES (2, 11);
INSERT INTO tabla1 VALUES (3, 12);
INSERT INTO tabla1 VALUES (4, 14);
INSERT INTO tabla1 VALUES (5, 13);
INSERT INTO tabla1 VALUES (6, 14);
INSERT INTO tabla1 VALUES (7, 15);
INSERT INTO tabla1 VALUES (8, 16);

CREATE OR REPLACE TRIGGER trigger_tabla1_2
FOR UPDATE OR INSERT ON tabla1
COMPOUND TRIGGER
maximo tabla1.salario%TYPE;
BEFORE STATEMENT IS
BEGIN
    SELECT MIN (salario) * 2
    INTO maximo
    FROM tabla1; 
END BEFORE STATEMENT;
BEFORE EACH ROW IS
BEGIN
    IF :NEW.salario>maximo
    THEN :NEW.salario := maximo;
    END IF; 
END BEFORE EACH ROW;
END trigger_tabla1_2;
/