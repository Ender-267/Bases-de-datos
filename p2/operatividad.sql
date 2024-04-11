CREATE OR REPLACE PACKAGE Caffeine AS
    PROCEDURE set_replacement_orders;
    PROCEDURE provider_info (cif IN CHAR);

CREATE OR REPLACE PACKAGE BODY Caffeine AS
    PROCEDURE set_replacement_orders AS
    BEGIN
        UPDATE Replacements r
        SET units = (
            SELECT ref.max_stock - ref.cur_stock
                FROM Replacements rep
                JOIN Supply_lines sup ON rep.ref = sup.ref
                JOIN References ref ON sup.ref = ref.barcode
                WHERE rep.status = 'D' AND rep.ref = r.ref
        );
        

        UPDATE Replacements r
        SET supplier = 
        (
            SELECT a.prov
            FROM (
                SELECT rep.supplier as prov, MIN(rep.cost)
                FROM Replacements rep
                JOIN Supply_lines sup ON rep.ref = sup.ref
                WHERE rep.status = 'D'
                GROUP BY rep.supplier
                ) a
            WHERE a.prov = r.supplier
        );

        UPDATE Replacements
        SET orderdate = TRUNC(SYSDATE), status = 'P'
        WHERE status = 'D';
    END set_replacement_orders;

    PROCEDURE provider_info (
        cif IN CHAR(10)
    ) AS
        pedidos NUMBER(10, 2):= 0;
        tiempo_entrega NUMBER(10, 2) := 0;
        contador NUMBER(10, 2) := 0;
        coste_actual NUMBER(10, 2) := 0;
        coste_max NUMBER(10, 2) := 0;
        segundo_coste_max NUMBER(10, 2) := 0;
        coste_minimo NUMBER(10, 2) := 0;
        coste_promedio NUMBER(10, 2) := 0;
        diferencia_coste_promedio NUMBER(10, 2) := 0;
        diferencia_coste_max NUMBER(10, 2) := 0;

    BEGIN   
        -- pedidos
        SELECT COUNT(*) INTO pedidos
            FROM Providers prov
            JOIN Supply_lines sup ON (prov.taxID = sup.supplier)
            JOIN Replacements rep ON (rep.ref = sup.ref)
        WHERE (rep.status = 'P' OR rep.status = 'F') AND prov.taxId = cif;
        
        -- tiempo de entrega
        SELECT AVG(rep.deldate - rep.ordendate) INTO tiempo_entrega
            FROM Providers prov
            JOIN Supply_lines sup ON (prov.taxID = sup.supplier)
            JOIN Replacements rep ON (rep.ref = sup.ref)
            WHERE rep.status = 'F' AND prov.taxId = cif;


        DBMS_OUTPUT.PUT_LINE('El numero de pedidos es' || pedidos);
        DBMS_OUTPUT.PUT_LINE('Tiempo medio de entrega es' || tiempo_entrega);
        
        FOR i IN 
        (
            SELECT ref.barCode
                FROM References ref
                JOIN Supply_lines sup ON (ref.barCode = sup.ref)
                WHERE sup.supplier = cif
        )
        LOOP
            SELECT cost INTO coste_actual
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.ref = sup.ref AND rep.supplier = sup.supplier)
                WHERE sup.supplier = cif AND i = sup AND orderdate = (
                    -- Escoger ultimo pedido
                    SELECT MAX(orderdate) FROM Replacements 
                    WHERE
                    rep.ref = sup.ref AND rep.supplier = sup.supplier AND sup.supplier = cif
                );
            
            SELECT MAX(cost) INTO coste_max
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.ref = sup.ref AND rep.supplier = sup.supplier)
                WHERE sup.supplier = cif AND i = sup.ref;

            SELECT MAX(cost) INTO segundo_coste_max
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.ref = sup.ref AND rep.supplier = sup.supplier)
                WHERE sup.supplier = cif AND i = sup.ref AND cost != coste_max;

            SELECT AVG(cost) INTO coste_promedio
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.ref = sup.ref AND rep.supplier = sup.supplier)
                WHERE sup.supplier = cif AND i = sup.ref AND cost != coste_max;
            
            SELECT min(cost) INTO coste_minimo
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.ref = sup.ref AND rep.supplier = sup.supplier)
                WHERE sup.supplier = cif AND i = sup.ref AND cost != coste_max;

            diferencia_coste_promedio := coste_actual - coste_promedio;
            IF coste_actual != coste_max THEN
                diferencia_coste_max := coste_max - coste_actual;
            ELSE
                diferencia_coste_max := segundo_coste_max - coste_actual;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Para la referencia ' || i || ':');
            DBMS_OUTPUT.PUT_LINE('El coste actual es ' || coste_actual) ;
            DBMS_OUTPUT.PUT_LINE('El coste minimo es ' || coste_minimo);
            DBMS_OUTPUT.PUT_LINE('El coste maximo es' || coste_max);
            DBMS_OUTPUT.PUT_LINE('La diferencia del coste actual con el promedio es ' || diferencia_coste_promedio);
            DBMS_OUTPUT.PUT_LINE('La diferencia del coste maximo con el promedio es ' || diferencia_coste_max);
        END LOOP;

    END provideer_info;

END Caffeine;
/