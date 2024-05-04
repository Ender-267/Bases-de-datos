-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- TESTS & STATISTICS SCRIPT -----------------------
-- ----------------------------------------------------
-- -- Course: File Structures and DataBases -----------
-- ----------------------------------------------------
-- -- (c) 2024 Javier Calle ---------------------------
-- ------ Carlos III University of Madrid -------------
-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- Part I: Package Definition ----------------------
-- ----------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_COSTES AS

-- WORKLOAD definition
	PROCEDURE PR_WORKLOAD(N NUMBER);
-- Execution of workload (10 times) displaying some measurements 
	PROCEDURE RUN_TEST(ite NUMBER);

END PKG_COSTES;
/

-- ----------------------------------------------------
-- -- Part II: Package BODY ---------------------------
-- ----------------------------------------------------

CREATE OR REPLACE PACKAGE BODY PKG_COSTES AS

-- auxiliary function converting an interval into a number (milliseconds)
FUNCTION interval_to_milliseconds(x INTERVAL DAY TO SECOND ) RETURN NUMBER IS
  BEGIN
    return (((extract( day from x)*24 + extract( hour from x))*60 + extract( minute from x))*60 + extract( second from x))*1000;
  END interval_to_milliseconds;


PROCEDURE PR_WORKLOAD(N NUMBER) IS
-- this year, the WL does not need to distinguish iterations, so N is not taken into account
-- notice that the fourth query appears twice (double the frequency) and the fifth appears four times
-- so each step represents 10% frequency, and no query is repeated immediately
BEGIN

-- STEP 1 - QUERY 1
FOR fila in (
select * from posts where barcode='OII04455O419282'
) LOOP null; END LOOP;

-- STEP 2 - QUERY 5
FOR fila in (
select (quantity*price) as total, bill_town||'/'||bill_country as place 
   	from orders_clients join client_lines using (orderdate,username,town,country) 
 	where username='chamorro'
) LOOP null; END LOOP;

-- STEP 3 - QUERY 2
FOR fila in (
select * from posts where product='Compromiso'
) LOOP null; END LOOP;

-- STEP 4 - QUERY 5
FOR fila in (
select (quantity*price) as total, bill_town||'/'||bill_country as place 
   	from orders_clients join client_lines using (orderdate,username,town,country) 
 	where username='chamorro'
) LOOP null; END LOOP;

-- STEP 5 - QUERY 3
FOR fila in (
select * from posts where score>=4
) LOOP null; END LOOP;

-- STEP 6 - QUERY 5
FOR fila in (
select (quantity*price) as total, bill_town||'/'||bill_country as place 
   	from orders_clients join client_lines using (orderdate,username,town,country) 
 	where username='chamorro'
) LOOP null; END LOOP;

-- STEP 7 - QUERY 4
FOR fila in (
select * from posts
) LOOP null; END LOOP;

-- STEP 8 - QUERY 5
FOR fila in (
select (quantity*price) as total, bill_town||'/'||bill_country as place 
   	from orders_clients join client_lines using (orderdate,username,town,country) 
 	where username='chamorro'
) LOOP null; END LOOP;

-- STEP 9 - QUERY 4
FOR fila in (
select * from posts
) LOOP null; END LOOP;

-- STEP 10 - QUERY 5
FOR fila in (
select (quantity*price) as total, bill_town||'/'||bill_country as place 
   	from orders_clients join client_lines using (orderdate,username,town,country) 
 	where username='chamorro'
) LOOP null; END LOOP;

END PR_WORKLOAD;


PROCEDURE RUN_TEST(ite NUMBER) IS
   t1 TIMESTAMP;
   t2 TIMESTAMP;
   auxt NUMBER := 0;
   g1 NUMBER;
   g2 NUMBER;
   auxg NUMBER := 0;
   localsid NUMBER;
BEGIN
      PKG_COSTES.PR_WORKLOAD(0);  -- idle run for preparing db_buffers
      select distinct sid into localsid from v$mystat;
--- LOOP WORKLOAD ITERATIONS (ite times) --------------------------------
      FOR i IN 1..ite LOOP
        DBMS_OUTPUT.PUT_LINE('Iteration '||i);
--- GET PREVIOUS MEASURES -----------------------------------
        SELECT SYSTIMESTAMP INTO t1 FROM DUAL;
        select S.value into g1
           from (select * from v$sesstat where sid=localsid) S
                join (select * from v$statname where name='consistent gets') using(STATISTIC#);
--- EXECUTION OF THE WORKLOAD -----------------------------------
        PKG_COSTES.PR_WORKLOAD (i);
--- GET AFTER-RUN MEASURES -----------------------------------
        SELECT SYSTIMESTAMP INTO t2 FROM DUAL;
        select S.value into g2
           from (select * from v$sesstat where sid=localsid) S
                join (select * from v$statname where name='consistent gets') using(STATISTIC#);
--- ACCUMULATE MEASURES -----------------------------------
        auxt:= auxt + interval_to_milliseconds(t2-t1);
        auxg:= auxg + g2-g1;
--- END TESTS ---------------------------------------------------
      END LOOP;
      auxt:= auxt / ite;
      auxg:= auxg / ite;
--- DISPLAY RESULTS -----------------------------------
    DBMS_OUTPUT.PUT_LINE('RESULTS AT '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));
    DBMS_OUTPUT.PUT_LINE('TIME CONSUMPTION (run): '|| auxt ||' milliseconds.');
    DBMS_OUTPUT.PUT_LINE('CONSISTENT GETS (workload):'|| auxg ||' acc');
    DBMS_OUTPUT.PUT_LINE('CONSISTENT GETS (weighted average):'|| auxg/10 ||' acc');
END RUN_TEST;


BEGIN
-- alter system flush buffer_cache;
   DBMS_OUTPUT.ENABLE (buffer_size => NULL);

END PKG_COSTES;
/
