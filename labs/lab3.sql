DROP TABLE contracts_ALL;
DROP TABLE clauses_ALL;


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

CREATE VIEW tablaxxx_ALL(
    select * from clauses_ALL NATURAL JOIN contracts_ALL USING (referenc);
);

CREATE VIEW ref_contacts(
    select referenc from contracts_ALL;
);

