CLEAR SCREEN;

DROP SEQUENCE coordenadas_seq;
DROP SEQUENCE cliente_generico_id_seq;
DROP TABLE producto CASCADE CONSTRAINT;
DROP TABLE formato_comercializacion CASCADE CONSTRAINT;
DROP TABLE tamaño_formato CASCADE CONSTRAINT;
DROP TABLE articulo CASCADE CONSTRAINT;
DROP TABLE compra CASCADE CONSTRAINT;
DROP TABLE pedido CASCADE CONSTRAINT;
DROP TABLE proveedor CASCADE CONSTRAINT;
DROP TABLE datos_tarjeta CASCADE CONSTRAINT;
DROP TABLE datos_direccion CASCADE CONSTRAINT;
DROP TABLE cliente_generico CASCADE CONSTRAINT;
DROP TABLE cliente_registrado CASCADE CONSTRAINT;
DROP TABLE publicacion CASCADE CONSTRAINT;
DROP TABLE oferta CASCADE CONSTRAINT;
DROP TABLE descuento CASCADE CONSTRAINT;

CREATE TABLE cliente_generico(
    id NUMBER(8) NOT NULL,
    telefono NUMBER(9),
    correo_electronico VARCHAR2(60),
    nombre VARCHAR2(35),
    apellido1 VARCHAR2(30),
    apellido2 VARCHAR2(30),
    CONSTRAINT pk_cliente_generico PRIMARY KEY (id)
);

CREATE TABLE cliente_registrado (
    id_cliente_generico NUMBER(8) NOT NULL,
    nombre_usuario VARCHAR2(64) NOT NULL UNIQUE,
    fecha_registro VARCHAR2(28) NOT NULL,
    preferencia_contacto VARCHAR2(16),
    CONSTRAINT pk_clienteregistrado PRIMARY KEY (id_cliente_generico),
    CONSTRAINT fk_id_cliente_generico FOREIGN KEY (id_cliente_generico) REFERENCES cliente_generico(id)
);

CREATE TABLE producto(
    nombre VARCHAR2(50) NOT NULL,
    coffea VARCHAR2(20) NOT NULL,
    varietal VARCHAR2(30) NOT NULL,
    pais_origen VARCHAR2(15) NOT NULL,
    tipo_tostado VARCHAR2(16) NOT NULL,
    descafeinado VARCHAR2(12) NOT NULL,
    CONSTRAINT pk_producto PRIMARY KEY(nombre)
);

CREATE TABLE datos_direccion(
    coordenadas VARCHAR2(32) NOT NULL,
    tipo_via VARCHAR2(16) NOT NULL,
    nombre_via VARCHAR2(32) NOT NULL,
    numero_inmueble VARCHAR2(3),
    numero_bloque VARCHAR2(3),
    escalera VARCHAR2(2),
    piso VARCHAR2(7),
    puerta VARCHAR2(3),
    codigo_postal NUMBER(5) NOT NULL,
    ciudad VARCHAR2(45) NOT NULL,
    pais VARCHAR2(45) NOT NULL,
    cliente NUMBER(8),
    CONSTRAINT pk_datos_direccion PRIMARY KEY (coordenadas),
    CONSTRAINT fk_cliente2 FOREIGN KEY (cliente) REFERENCES cliente_registrado(id_cliente_generico)
);

CREATE TABLE compra(
    cliente NUMBER(8) NOT NULL,
    fecha DATE NOT NULL,
    direccion_entrega VARCHAR2(32) NOT NULL,
    tipo_facturacion VARCHAR2(16) NOT NULL,
    datos_tarjeta NUMBER(16),
    fecha_pago DATE,
    fecha_entrega DATE,
    precio_total NUMBER(8,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_compras PRIMARY KEY (fecha, direccion_entrega),
    CONSTRAINT fk_cliente FOREIGN KEY (cliente) REFERENCES cliente_generico(id),
    CONSTRAINT fk_direccion_entrega3 FOREIGN KEY (direccion_entrega) REFERENCES datos_direccion(coordenadas),
    CONSTRAINT ck_precio_total CHECK (precio_total>=0),
    CONSTRAINT ck_tarjeta 
        CHECK (((tipo_facturacion='tarjeta' AND datos_tarjeta IS NULL) AND fecha=fecha_entrega) 
        OR (tipo_facturacion != 'tarjeta' AND datos_tarjeta IS NULL))
);

CREATE TABLE articulo(
    producto VARCHAR2(50) NOT NULL,
    codigo_barras VARCHAR2(15) NOT NULL,
    embalaje_recipiente VARCHAR2(8) NOT NULL,
    embalaje_tamaño NUMBER(8) NOT NULL,
    embalaje_unidad VARCHAR2(8) NOT NULL,
    precio_venta NUMBER(14,2) NOT NULL,
    stock NUMBER(5) DEFAULT 0 NOT NULL,
    min_stock NUMBER(5) DEFAULT 5 NOT NULL,
    max_stock NUMBER(5) DEFAULT 15 NOT NULL,
    tipo_formato VARCHAR2(20) NOT NULL,
    comprado_fecha DATE DEFAULT NULL,
	comprado_direccion NUMBER(16) DEFAULT NULL,
    CONSTRAINT pk_articulos PRIMARY KEY (codigo_barras),
    CONSTRAINT ck_embalaje_tamaño CHECK (embalaje_tamaño>=0),
    CONSTRAINT ck_precio_venta CHECK (precio_venta>=0),
    CONSTRAINT ck_stock CHECK (stock>=min_stock AND stock<=max_stock),
    CONSTRAINT ck_min_stock CHECK (min_stock>=0),
    CONSTRAINT ck_max_stock CHECK (max_stock>=0),
    CONSTRAINT fk_producto2 FOREIGN KEY (producto) REFERENCES producto(nombre),
    CONSTRAINT fk_comprado FOREIGN KEY (comprado_fecha, comprado_direccion) REFERENCES compra(fecha, direccion_entrega) ON DELETE SET NULL
);

CREATE TABLE proveedor(
    nombre_registrado VARCHAR2(35) UNIQUE NOT NULL,
    cif VARCHAR2(10) NOT NULL,
    nombre_completo VARCHAR(90) UNIQUE NOT NULL,
    correo_electronico VARCHAR2(60) UNIQUE NOT NULL,
    telefono VARCHAR2(9) UNIQUE NOT NULL,
    numero_bancario NUMBER(30),
    direccion VARCHAR2(120) NOT NULL,
    pais VARCHAR2(45) NOT NULL,
    tiempo_medio NUMBER(4, 2) DEFAULT 0,
    pedidos_satisfechos NUMBER(4) DEFAULT 0,
    CONSTRAINT pk_proveedores PRIMARY KEY (cif),
    CONSTRAINT ck_tiempo_medio CHECK (tiempo_medio>=0),
    CONSTRAINT ck_pedidos_satisfechos CHECK (pedidos_satisfechos>=0)
);

CREATE TABLE pedido (
    producto VARCHAR2(10) NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR2(16) NOT NULL,
    unidades NUMBER(8) NOT NULL,
    proveedor VARCHAR2(10),
    fecha_recepcion DATE,
    precio_total NUMBER(8,2),
    CONSTRAINT pk_pedidos PRIMARY KEY (producto),
    CONSTRAINT fk_producto FOREIGN KEY (producto) REFERENCES producto(nombre),
    CONSTRAINT fk_proveedor FOREIGN KEY (proveedor) REFERENCES proveedor(cif) ON DELETE SET NULL,
    CONSTRAINT ck_unidades CHECK (unidades > 0),
    CONSTRAINT ck_precio_total2 CHECK (precio_total > 0),
    CONSTRAINT ck_draft CHECK ((estado != 'draft') OR (estado = 'draft' AND proveedor IS NULL)),
    CONSTRAINT ck_fullfiled CHECK ((estado != 'fulfilled') OR ((estado = 'fulfilled' AND fecha_recepcion IS NOT NULL) AND (fecha_recepcion > fecha AND precio_total IS NOT NULL))) -- Fixed condition and OR usage
);

CREATE TABLE datos_tarjeta(
    titular VARCHAR2(128) NOT NULL,
    compañia VARCHAR2(128) NOT NULL,
    numero NUMBER(16) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cliente NUMBER(8),
    CONSTRAINT pk_numero PRIMARY KEY (numero),
    CONSTRAINT fk_cliente3 FOREIGN KEY (cliente) REFERENCES cliente_registrado(id_cliente_generico)
);

CREATE TABLE publicacion(
    id NUMBER(8) NOT NULL,
    producto VARCHAR2(50) NOT NULL,
    articulo VARCHAR2(16),
    puntuacion NUMBER(1) NOT NULL,
    likes NUMBER(5) NOT NULL,
    refrenda VARCHAR(1) NOT NULL,
    cliente VARCHAR2(30),
    CONSTRAINT pk_publicaciones PRIMARY KEY(id),
    CONSTRAINT fk_producto3 FOREIGN KEY (producto) REFERENCES producto(nombre),
    CONSTRAINT fk_articulos FOREIGN KEY (articulo) REFERENCES articulo(codigo_barras),
    CONSTRAINT fk_cliente4 FOREIGN KEY (cliente) REFERENCES cliente_registrado(nombre_usuario) ON DELETE SET NULL,
    CONSTRAINT ck_puntuacion CHECK(puntuacion<=5 AND puntuacion>=1),
    CONSTRAINT ck_likes CHECK(likes>=0)
);

CREATE TABLE descuento(
    cliente NUMBER(8) NOT NULL,
    porcentaje_a_descontar NUMBER(3) NOT NULL,
    fecha_expiracion DATE NOT NULL,
    CONSTRAINT pk_descuentos PRIMARY KEY (cliente, fecha_expiracion),
    CONSTRAINT ck_porcentaje_a_descontar CHECK (porcentaje_a_descontar>=0 AND porcentaje_a_descontar<=100)
);

CREATE TABLE oferta(
    proveedor VARCHAR2(10) NOT NULL,
    producto VARCHAR2(50) NOT NULL,
    precio NUMBER(8,2),
    CONSTRAINT pk_oferta PRIMARY KEY (proveedor, producto),
    CONSTRAINT fk_proveedor2 FOREIGN KEY (proveedor) REFERENCES proveedor(cif) ON DELETE CASCADE,
    CONSTRAINT fk_producto4 FOREIGN KEY (producto) REFERENCES producto(nombre) ON DELETE CASCADE,
    CONSTRAINT ck_precio CHECK (precio>=0)
);


-- producto
insert into producto(nombre, coffea, varietal, pais_origen, tipo_tostado, descafeinado)
(select product, MAX(coffea), MAX(varietal), MAX(origin), MAX(roasting), MAX(decaf) FROM fsdb.catalogue GROUP BY product);

-- atributo
insert into articulo(codigo_barras, producto, embalaje_recipiente, embalaje_tamaño, embalaje_unidad, precio_venta, stock, min_stock, max_stock, tipo_formato)
select
        barcode,
        MIN(product),
        MAX(SUBSTR(packaging, 1, (INSTR(packaging, ' ', 1)))) AS recipiente,
        MAX(TO_NUMBER(REGEXP_SUBSTR(packaging, '\S+', 1, 2))) AS tamano,
        MAX(REPLACE(SUBSTR(packaging, INSTR(packaging, ' ', 5) + 1) , ' ', '')) AS units, --ns porque es 5 pero funciona asi
        MAX(TO_NUMBER(REPLACE(SUBSTR(retail_price, 1, INSTR(retail_price, ' ',1)-1), '.', ','))) AS precio, 
        MAX(TO_NUMBER(cur_stock)) AS cstock, 
        MAX(TO_NUMBER(min_stock)) AS minstock, 
        MAX(TO_NUMBER(max_stock)) AS maxstock, 
        MAX(format) as tipo_formato
        FROM fsdb.catalogue GROUP BY barcode;
-- packaging => pkg  <numero> <unidades>.
-- price => uu.dd ?
-- max_stock/min_stock/cur_stock => numero

-- proveedor
insert into proveedor(nombre_registrado, cif, nombre_completo, correo_electronico, telefono, pais, direccion)
select supplier, 
        MAX(prov_taxid),
        MAX(prov_person),
        MAX(prov_email),
        MAX(prov_mobile),
        MAX(prov_country),
        MAX(prov_address)
FROM fsdb.catalogue 
WHERE prov_taxid IS NOT NULL
GROUP BY supplier;

---> inserción de clientes genéricos
CREATE SEQUENCE cliente_generico_id_seq START WITH 1 INCREMENT BY 1;

INSERT INTO cliente_generico
(id, telefono, correo_electronico, nombre, apellido1, apellido2)
SELECT 
    cliente_generico_id_seq.NEXTVAL,
    client_mobile,
    client_email, 
    client_name, 
    client_surn1, 
    client_surn2
FROM fsdb.trolley;

--- inserción de clientes registrado
INSERT INTO cliente_registrado (id_cliente_generico, nombre_usuario, fecha_registro)
SELECT MAX(t1.id), t2.username, MAX(TO_DATE(t2.reg_date, 'YYYY / MM / DD'))
FROM cliente_generico t1
JOIN fsdb.trolley t2 ON (t1.telefono = t2.client_mobile) AND (t1.correo_electronico = t2.client_email) AND (t1.nombre = t2.client_name) AND
(t1.apellido1 = t2.client_surn1) AND (t1.apellido2 = t2.client_surn2)
WHERE t2.username IS NOT NULL GROUP BY t2.username;


-- direciones
-- no podemos tener coordenadas reales asi q las invento
CREATE SEQUENCE coordenadas_seq START WITH 1 INCREMENT BY 1;

INSERT INTO datos_direccion
(coordenadas, tipo_via, nombre_via, numero_inmueble, numero_bloque, escalera, piso, puerta, codigo_postal, ciudad, pais)
SELECT 
    coordenadas_seq.NEXTVAL, 
    dliv_waytype, 
    dliv_wayname, 
    dliv_gate, 
    TO_NUMBER(dliv_block), 
    TO_NUMBER(dliv_stairw), 
    dliv_floor, 
    dliv_door, 
    TO_NUMBER(dliv_zip),
    dliv_town, 
    dliv_country
FROM 
    fsdb.trolley
WHERE 
    dliv_waytype IS NOT NULL 
    AND dliv_wayname IS NOT NULL 
    AND dliv_zip IS NOT NULL 
    AND dliv_town IS NOT NULL 
    AND dliv_country IS NOT NULL;

INSERT INTO datos_direccion
(coordenadas, tipo_via, nombre_via, numero_inmueble, numero_bloque, escalera, piso, puerta, codigo_postal, ciudad, pais)
SELECT 
    coordenadas_seq.NEXTVAL, 
    bill_waytype, 
    bill_wayname, 
    bill_gate, 
    TO_NUMBER(bill_block), 
    TO_NUMBER(bill_stairw), 
    bill_floor, 
    bill_door, 
    TO_NUMBER(bill_zip),
    bill_town, 
    bill_country
FROM 
    fsdb.trolley
WHERE 
    bill_waytype IS NOT NULL 
    AND bill_wayname IS NOT NULL 
    AND bill_zip IS NOT NULL 
    AND bill_town IS NOT NULL 
    AND bill_country IS NOT NULL;

INSERT INTO datos_direccion(cliente)
SELECT t1.id
FROM cliente_generico t1
JOIN cliente_registrado t2 ON t1.id = t2.id_cliente_generico
JOIN fsdb.trolley t3 ON t2.nombre_usuario = t3.username
WHERE t2.nombre_usuario IS NOT NULL

INSERT INTO oferta(proveedor, producto, precio)
SELECT 
    prov_taxid,
    product,
    REPLACE(SUBSTR(MIN(cost_price), 1, INSTR(MIN(cost_price), ' ',1)-1), '.', ',')
FROM 
    fsdb.catalogue
WHERE supplier IS NOT NULL AND product IS NOT NULL
GROUP BY prov_taxid, product;


INSERT INTO pedido (producto, fecha, estado, unidades, proveedor, fecha_recepcion, precio_total)
SELECT 
    t3.nombre,
    TO_DATE(t1.orderdate, 'DD / MM / YYYY'), 
    CASE
        WHEN MAX(t4.proveedor) IS NULL THEN 'draft'
        WHEN MAX(t1.payment_date) IS NOT NULL THEN 'fulfilled'
        ELSE 'placed'
    END,
    SUM(TO_NUMBER(t1.quantity)),
    t4.proveedor,
    MIN(TO_DATE(t1.payment_date, 'DD / MM / YYYY')), 
    SUM(t4.precio * TO_NUMBER(t1.quantity))
FROM fsdb.trolley t1 
JOIN articulo t2 ON t1.prodtype = t2.tipo_formato
JOIN producto t3 ON t2.producto = t3.nombre AND t1.coffea = t3.coffea AND t1.varietal = t3.varietal
JOIN oferta t4 ON t3.nombre = t4.producto
WHERE t1.prodtype IS NOT NULL
GROUP BY t4.proveedor, t3.nombre, t1.orderdate, t1.payment_date

INSERT INTO datos_tarjeta(titular, compañia, numero, fecha_vencimiento)
SELECT 
    MAX(card_holder),
    MAX(card_company),
    card_number,
    MAX(TO_DATE(card_expiratn, 'MM/YY'))
FROM fsdb.trolley
WHERE card_number IS NOT NULL
GROUP BY card_number;

INSERT INTO compra(cliente, fecha, direccion_entrega, tipo_facturacion, datos_tarjeta, fecha_pago, fecha_entrega, precio_total)
SELECT 
    t2.id
    TO_DATE(t1.orderdate, 'DD / MM / YYYY'),





-- @C:\users\aulavirtual\Desktop\script.sql
    


