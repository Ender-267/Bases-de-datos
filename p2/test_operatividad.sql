INSERT INTO REPL

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
VALUES ('PLACEHOLDE', 'QQI63936Q341480', SYSDATE - 300, 'D', 0, NULL, 0);
