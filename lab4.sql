CREATE TABLE contracts(
    referenc VARCHAR2(25) PRIMARY KEY,
    signature DATE DEFAULT SYSDATE,
    num_clauses NUMBER(3) DEFAULT 0 );


CREATE TABLE clauses(
    referenc VARCHAR2(25),
    n_order NUMBER(3),
    cl_date DATE DEFAULT SYSDATE,
    CONSTRAINT PK_clause PRIMARY KEY (referenc,n_order),CONSTRAINT FK_clause FOREIGN KEY (referenc)
    REFERENCES contracts(referenc) ON DELETE CASCADE);

CREATE TABLE contracts_ALL(
    referenc VARCHAR2(25) PRIMARY KEY,
    Signature DATE DEFAULT SYSDATE );

CREATE TABLE clauses_ALL(
    referenc VARCHAR2(25),
    n_order NUMBER(3),
    cl_date DATE DEFAULT SYSDATE,
    CONSTRAINT PK_clause PRIMARY KEY(referenc,n_order),CONSTRAINT FK_clause FOREIGN KEY (referenc)
    REFERENCES contracts_ALL ON DELETE CASCADE);

INSERT INTO contracts_ALL(referenc) VALUES ('ref1');
INSERT INTO contracts_ALL(referenc) VALUES ('ref2');
INSERT INTO clauses_ALL(referenc,n_order) VALUES ('ref1',1);
INSERT INTO clauses_ALL(referenc,n_order) VALUES ('ref1',3);
INSERT INTO clauses_ALL(referenc,n_order) VALUES ('ref2',1);

CREATE OR REPLACE VIEW contracts AS (
    SELECT referenc, signature, COUNT('X') AS num_clausesFROM contracts_ALL JOIN clauses_ALL USING(referenc)GROUP BY (referenc, signature)
    ) WITH CHECK OPTION;

CREATE OR REPLACE VIEW clauses AS (
    SELECT referenc, n_order, cl_date
    FROM clauses_ALL);


CREATE TRIGGER ins_contracts
    INSTEAD OF INSERT ON contracts
    FOR EACH ROW
BEGIN
    INSERT INTO contracts_ALL
        VALUES(:NEW.referenc, :NEW.signature)
END;