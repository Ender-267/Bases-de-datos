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
            SELECT ref.max_stock - ref.cur_stock as units
                FROM Replacements rep
                JOIN References ref ON rep.barCode = ref.barcode
                WHERE rep.status = 'D' AND rep.barCode = r.barCode AND r.orderdate = rep.orderdate
        );
        

        UPDATE Replacements r
        SET taxId = (
            SELECT taxID
            FROM Supply_Lines sup
            WHERE sup.barCode = r.barCode
            AND sup.cost = (
                SELECT MIN(cost)
                FROM Supply_Lines
                WHERE barCode = sup.barCode
            )
        AND ROWNUM = 1 -- Puede que haya precios repetidos
        );


        UPDATE Replacements r
        SET payment = 
            (
                SELECT sup.cost*rep.units
                FROM Replacements rep
                JOIN Supply_lines sup ON rep.barCode = sup.barCode AND rep.taxID = sup.taxID
                WHERE rep.status = 'D' AND r.barCode = rep.barCode AND r.orderdate = rep.orderdate
            );


        UPDATE Replacements r
        SET orderdate = SYSDATE, status = 'P'
        WHERE status = 'D';
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('SOLO SE PERMITE UN PEDIDO POR REFERENCIA Y DIA');

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
            FROM Replacements rep 
        WHERE (rep.status = 'P' OR rep.status = 'F') AND rep.taxId = cif;
        
        -- tiempo de entrega
        SELECT AVG(rep.deldate - rep.orderdate) INTO tiempo_entrega
            FROM Providers prov
            JOIN Supply_lines sup ON (prov.taxID = sup.taxId)
            JOIN Replacements rep ON (rep.barCode = sup.barCode)
            WHERE rep.status = 'F' AND prov.taxId = cif;


        DBMS_OUTPUT.PUT_LINE('El numero de pedidos es ' || TO_CHAR(pedidos));
        DBMS_OUTPUT.PUT_LINE('Tiempo medio de entrega es ' || TO_CHAR(tiempo_entrega));
        
        FOR i IN 
        (
            SELECT barCode
                FROM Supply_Lines
                WHERE taxID = cif
        )
        LOOP
            -- Aunque los Replacements no guardan el coste directamente, lo podemos conseguir con 
            -- precio_total/unidades
            SELECT payment/units INTO coste_actual
                FROM Replacements
                WHERE taxID = cif AND i.barCode = barCode
                AND orderdate = 
                    (
                    SELECT MAX(orderdate)
                    FROM Replacements
                    WHERE taxID = cif AND i.barCode = barCode
                    );


            SELECT MAX(payment/units) INTO coste_max
                FROM Replacements
                WHERE taxID = cif AND i.barCode = barCode
                AND orderdate > ADD_MONTHS(SYSDATE, -12);
                
            SELECT MAX(payment/units) INTO segundo_coste_max
                FROM Replacements
                WHERE taxID = cif AND i.barCode = barCode
                AND orderdate > ADD_MONTHS(SYSDATE, -12)
                AND payment/units < coste_max;

            SELECT MIN(payment/units) INTO coste_minimo
                FROM Replacements
                WHERE taxID = cif AND i.barCode = barCode
                AND orderdate > ADD_MONTHS(SYSDATE, -12);
            
            SELECT AVG(payment/units) INTO coste_promedio
                FROM Replacements
                WHERE taxID = cif AND i.barCode = barCode;

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