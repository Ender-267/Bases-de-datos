-- referencia: QQI63936Q341480


-- Selecionar referencias con proveedores
SELECT ref.barCode FROM
References ref
JOIN supply_lines sup ON (sup.barCode = ref.barCode) 
JOIN Providers prov ON (prov.taxID = sup.taxID);

-- referencia: QQI63936Q341480

-- Selecionar datos de referencia elegida
SELECT * FROM References WHERE barCode = 'QQI63936Q341480';

-- datos
-- max stock => 3340
-- cur stock => 3277

SELECT cost, taxID FROM Supply_Lines WHERE barCode = 'QQI63936Q341480';

-- proveedores
-- M04240490A => 19,71
-- R63301935R => 19,93

INSERT INTO Replacements (taxID, barCode, orderdate, status, units, deldate, payment)
VALUES ('R63301935R', 'QQI63936Q341480', SYSDATE - 300, 'D', 0, NULL, 0);


-- Output de la tabla
-- R63301935R QQI63936Q341480 16/06/23 D          0                   0

-- Datos esperados despues de ejecucion
-- Units => 63
-- Proveedor => M04240490A
-- orderdate => Fecha de ejecucion
-- Status => P

EXECUTE Caffeine.provider_info('H85660978P');

SELECT * FROM Replacements WHERE barCode = 'QQI63936Q341480';

-- Output de la tabla
-- M04240490A QQI63936Q341480 11/04/24 P         63                   0

SELECT MIN(ref.barCode), prov.taxID, SYSDATE - ROUND(DBMS_RANDOM.VALUE(1, 365)), 'D', 0, NULL, 0
FROM References ref
JOIN Supply_Lines sup ON (ref.barCode = sup.barCode)
JOIN Providers prov ON (sup.taxID = prov.taxID)
GROUP BY prov.taxID;

-- INSERCION EN MASA

INSERT INTO Replacements (taxID, barCode, orderdate, status, units, deldate, payment)
SELECT MIN(prov.taxID), ref.barCode, SYSDATE - ROUND(DBMS_RANDOM.VALUE(1, 365)), 'D', 0, NULL, 0
FROM References ref
JOIN Supply_Lines sup ON ref.barCode = sup.barCode
JOIN Providers prov ON sup.taxID = prov.taxID
GROUP BY ref.barCode;

EXECUTE Caffeine.set_replacement_orders;


EXECUTE Caffeine.set_replacement_orders;
