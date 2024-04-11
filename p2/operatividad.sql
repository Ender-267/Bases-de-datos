CREATE OR REPLACE PACKAGE Caffeine AS
    PROCEDURE set_replacement_orders;
    PROCEDURE provider_info (cif IN CHAR);
END Caffeine;
/

CREATE OR REPLACE PACKAGE BODY Caffeine AS
    PROCEDURE set_replacement_orders AS
    BEGIN
        UPDATE Replacements r
        SET units = (
            SELECT ref.max_stock - ref.cur_stock
                FROM Replacements rep
                JOIN Supply_lines sup ON rep.barCode = sup.barCode
                JOIN References ref ON sup.barCode = ref.barcode
                WHERE rep.status = 'D' AND rep.barCode = r.barCode
        );
        

        UPDATE Replacements r
        SET taxId = 
        (
            SELECT a.prov
            FROM (
                SELECT rep.taxID as prov, MIN(sup.cost)
                FROM Replacements rep
                JOIN Supply_lines sup ON rep.barCode = sup.barCode
                WHERE rep.status = 'D'
                GROUP BY rep.taxID
                ) a
            WHERE a.prov = r.taxID
        );

        UPDATE Replacements
        SET orderdate = SYSDATE, status = 'P'
        WHERE status = 'D';
    END set_replacement_orders;

    PROCEDURE provider_info (
        cif IN CHAR
    ) AS
        pedidos NUMBER(10, 2):= 0;
        tiempo_entrega NUMBER(4) := 0;
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
            JOIN Supply_lines sup ON (prov.taxID = sup.taxId)
            JOIN Replacements rep ON (rep.barCode = sup.barCode)
        WHERE (rep.status = 'P' OR rep.status = 'F') AND prov.taxId = cif;
        
        -- tiempo de entrega
        SELECT AVG(rep.deldate - rep.orderdate) INTO tiempo_entrega
            FROM Providers prov
            JOIN Supply_lines sup ON (prov.taxID = sup.taxId)
            JOIN Replacements rep ON (rep.barCode = sup.barCode)
            WHERE rep.status = 'F' AND prov.taxId = cif;


        DBMS_OUTPUT.PUT_LINE('El numero de pedidos es' || TO_CHAR(pedidos));
        DBMS_OUTPUT.PUT_LINE('Tiempo medio de entrega es' || TO_CHAR(tiempo_entrega));
        
        FOR i IN 
        (
            SELECT ref.barCode
                FROM References ref
                JOIN Supply_lines sup ON (ref.barCode = sup.barCode)
                WHERE sup.taxId = cif
        )
        LOOP
            SELECT cost INTO coste_actual
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.barCode = sup.barCode AND rep.taxId = sup.taxId)
                WHERE sup.taxId = cif AND i.barCode = sup.barCode AND orderdate = (
                    -- Escoger ultimo pedido
                    SELECT MAX(orderdate) FROM Replacements 
                    WHERE
                    rep.barCode = sup.barCode AND rep.taxId = sup.taxId AND sup.taxId = cif
                );
            
            SELECT MAX(cost) INTO coste_max
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.barCode = sup.barCode AND rep.taxId = sup.taxId)
                WHERE sup.taxId = cif AND i.barCode = sup.barCode;

            SELECT MAX(cost) INTO segundo_coste_max
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.barCode = sup.barCode AND rep.taxId = sup.taxId)
                WHERE sup.taxId = cif AND i.barCode = sup.barCode AND coste_actual <> coste_max;

            SELECT AVG(cost) INTO coste_promedio
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.barCode = sup.barCode AND rep.taxId = sup.taxId)
                WHERE sup.taxId = cif AND i.barCode = sup.barCode;
            
            SELECT MIN(cost) INTO coste_minimo
                FROM Replacements rep
                JOIN Supply_lines sup ON (rep.barCode = sup.barCode AND rep.taxId = sup.taxId)
                WHERE sup.taxId = cif AND sup.barCode = i.barCode;

            diferencia_coste_promedio := coste_actual - coste_promedio;
            IF coste_actual <> coste_max THEN
                diferencia_coste_max := coste_max - coste_actual;
            ELSE
                diferencia_coste_max := segundo_coste_max - coste_actual;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Para la referencia ' || i.barCode || ':');
            DBMS_OUTPUT.PUT_LINE('El coste actual es ' || TO_CHAR(coste_actual)) ;
            DBMS_OUTPUT.PUT_LINE('El coste minimo es ' || TO_CHAR(coste_minimo));
            DBMS_OUTPUT.PUT_LINE('El coste maximo es' || TO_CHAR(coste_max));
            DBMS_OUTPUT.PUT_LINE('La diferencia del coste actual con el promedio es ' || TO_CHAR(diferencia_coste_promedio));
            DBMS_OUTPUT.PUT_LINE('La diferencia del coste maximo con el promedio es ' || TO_CHAR(diferencia_coste_max));
        END LOOP;

    END provider_info;
END Caffeine;
/