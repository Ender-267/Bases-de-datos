select product, MAX(coffea), MAX(varietal), MAX(origin), MAX(roasting), MAX(packaging) FROM fsdb.catalogue GROUP BY product;

select barcode, 
        MAX(product) AS product, 
        MAX(SUBSTR(packaging, INSTR(packaging, ' ', 1)+1, INSTR(packaging, ' ', 2)-1)) AS tipo/*tipo_envalaje*/, 
        MAX(SUBSTR(retail_price, 1, INSTR(retail_price, ' ',1)-1)) AS precio, 
        MAX(CAST(cur_stock AS NUMBER)) AS cstock, 
        MAX(CAST(min_stock AS NUMBER)) AS minstock, 
        MAX(CAST(max_stock AS NUMBER)) AS maxstock, 
        MAX(format) as tipo_formato, 
        MAX(SUBSTR(packaging, INSTR(packaging, ' ', 2)+1, INSTR(packaging, ' ', 3)-1)) AS unidades
        FROM fsdb.catalogue GROUP BY barcode;
-- packaging => pkg  <numero> <unidades>
-- price => uu.dd ?
-- max_stock/min_stock/cur_stock => numero
