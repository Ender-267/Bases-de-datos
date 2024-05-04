clear screen;

DELETE PLAN_TABLE;

set serveroutput on;

set autotrace on;

EXPLAIN PLAN SET statement_id = 'querry_1' FOR
    select * from posts where barcode='OII04455O419282';

EXPLAIN PLAN SET statement_id = 'querry_2' FOR
    select * from posts where product='Compromiso';

EXPLAIN PLAN SET statement_id = 'querry_3' FOR
    select * from posts where score>=4;

EXPLAIN PLAN SET statement_id = 'querry_4' FOR
    select * from posts;

EXPLAIN PLAN SET statement_id = 'querry_5' FOR
    select (quantity*price) as total, bill_town||'/'||bill_country as place
    from orders_clients join client_lines
    using (orderdate,username,town,country)
    where username='chamorro';

SELECT PLAN_TABLE_OUTPUT
    FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,'querry_1','BASIC'));


/