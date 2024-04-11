CREATE OR REPLACE PACKAGE Caffeine AS

    CREATE OR REPLACE PROCEDURE set_replacement_orders
    AS
    BEGIN
        UPDATE Replacements r
        SET units = r.max_stock - r.cur_stock
        FROM 
            (
                SELECT rep.cur_stock, ref.max_stock, sup.ref
                    FROM Replacements rep
                    JOIN Supply_lines sup ON rep.ref = sup.ref
                    JOIN References ref ON sup.ref = ref.barcode
                    WHERE rep.status = 'D' AND r.ref = sup.ref
            );
        

        UPDATE Replacements r
        SET supplier = 
        (
            SELECT supplier
            FROM (
                SELECT rep.supplier as supplier, MIN(rep.cost)
                FROM Replacements rep
                JOIN Supply_lines sup ON rep.ref = sup.ref
                WHERE rep.status = 'D'
                GROUP BY rep.supplier
                ) a
            WHERE a.supplier = r.supplier
        )

        UPDATE Replacements
        SET orderdate = TRUNC(SYSDATE), status = 'P'
        WHERE status = 'D';
    END;

    CREATE OR REPLACE PROCEDURE provideer_info (
    cif IN CHAR(10)
    ) AS
        pedidos NUMBER := 0;
        tiempo_entrega NUMBER := 0;
    BEGIN   
        -- pedidos
        SELECT COUNT(*) INTO pedidos
            FROM Providers prov
            JOIN Supply_lines sup ON (prov.taxID = sup.supplier)
            JOIN Replacements rep ON (rep.ref = sup.ref)
        WHERE (rep.status = 'P' OR rep.status = 'F') AND prov.taxId = cif;
        
        -- tiempo de entrega
        contador NUMBER := 0;
        FOR i IN (
            SELECT (rep.deldate - rep.ordendate) as tiempo_entrega
                FROM Providers prov
                JOIN Supply_lines sup ON (prov.taxID = sup.supplier)
                JOIN Replacements rep ON (rep.ref = sup.ref)
            WHERE rep.status = 'F' AND prov.taxId = cif
        ) LOOP
            contador := contador + 1;
            tiempo_entrega := tiempo_entrega + i.tiempo_entrega;
        END LOOP
        IF contador > 0 THEN
            tiempo_entrega := tiempo_entrega / contador;
        END IF;

        DBMS_OUTPUT.PUT_LINE('El numero de pedidos es' || pedidos);
        DBMS_OUTPUT.PUT_LINE('Tiempo medio de entrega es' || tiempo_entrega);

        FOR i IN 
        (
            SELECT 
                FROM 
                (
                    SELECT repl.ref 
                        FROM 
                            -- Seleciono los providers
                        JOIN Replacements rep ON (rep.supplier = cif)
                )
            
        )


    END provideer_info;
    
/

END Caffeine;