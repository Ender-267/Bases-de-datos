clear screen;

DROP TABLE contracts_ALL CASCADE CONSTRAINT;
DROP TABLE clauses_ALL CASCADE CONSTRAINT;
DROP VIEW tablaxxx_ALL CASCADE CONSTRAINT;
DROP VIEW ref_contacts CASCADE CONSTRAINT;
DROP VIEW contracts CASCADE CONSTRAINT;
DROP TABLE privs CASCADE CONSTRAINT;
DROP VIEW clauses CASCADE CONSTRAINT;

CREATE TABLE contracts_ALL(
referenc 		VARCHAR2(25) PRIMARY KEY,
Signature	 	DATE DEFAULT SYSDATE );

CREATE TABLE clauses_ALL(
referenc 	 	VARCHAR2(25),
n_order   		NUMBER(3), 
cl_date 		DATE DEFAULT SYSDATE,
privacy_lvl             NUMBER(2),
CONSTRAINT PK_clause PRIMARY KEY(referenc,n_order),
CONSTRAINT FK_clause FOREIGN KEY (referenc)
REFERENCES contracts_ALL ON DELETE CASCADE);

INSERT INTO contracts_ALL(referenc) VALUES ('ref1');
INSERT INTO contracts_ALL(referenc) VALUES ('ref2');
INSERT INTO clauses_ALL(referenc,n_order) VALUES ('ref1',1);
INSERT INTO clauses_ALL(referenc,n_order) VALUES ('ref1',3);
INSERT INTO clauses_ALL(referenc,n_order) VALUES ('ref2',1);

CREATE OR REPLACE VIEW tablaxxx_ALL AS
select * 
from clauses_ALL t1
NATURAL JOIN contracts_ALL t2;

CREATE OR REPLACE VIEW ref_contacts AS
select referenc
from contracts_ALL
with read only;

ALTER TABLE contracts_ALL
ADD owner VARCHAR2(10);

CREATE OR REPLACE VIEW contracts AS
SELECT * FROM contracts_ALL t1
WHERE (t1.owner=USER)
WITH check option;

CREATE TABLE privs(
    usr VARCHAR2(10),
    security_lvl NUMBER(1)
);

CREATE VIEW clauses AS
SELECT *
FROM (
    SELECT *
    FROM contracts
    NATURAL JOIN
    clauses_ALL
) t1
JOIN
privs t2
ON (t1.privacy_lvl<=t2.security_lvl);

-- @C:\Users\aulavirtual\Desktop\script.sql;