DROP TABLE productos CASCADE CONSTRAINT;
DROP TABLE formatos_comercializacion CASCADE CONSTRAINT;
DROP TABLE tamaño_formato CASCADE CONSTRAINT;
DROP TABLE articulos CASCADE CONSTRAINT;
DROP TABLE compras CASCADE CONSTRAINT;
DROP TABLE pedidos CASCADE CONSTRAINT;
DROP TABLE proveedores CASCADE CONSTRAINT;
DROP TABLE datos_tarjeta CASCADE CONSTRAINT;
DROP TABLE datos_direccion CASCADE CONSTRAINT;
DROP TABLE cliente_generico CASCADE CONSTRAINT;
DROP TABLE cliente_registrado CASCADE CONSTRAINT;
DROP TABLE publicaciones CASCADE CONSTRAINT;
DROP TABLE oferta CASCADE CONSTRAINT;
DROP TABLE descuentos CASCADE CONSTRAINT;

CREATE TABLE cliente_generico(
    id NUMBER(8) NOT NULL,
    telefono NUMBER(16),
    correo_electronico VARCHAR2(32),
    nombre VARCHAR2(16),
    apellido1 VARCHAR2(16),
    apellido2 VARCHAR2(16),
    UNIQUE (nombre, apellido1, apellido2),
    CONSTRAINT pk_cliente_generico PRIMARY KEY (id)
);

CREATE TABLE cliente_registrado(
    id_cliente_generico NUMBER(8) NOT NULL,
    fecha_registro DATE NOT NULL,
    preferencia_contacto VARCHAR2(16) NOT NULL,
    CONSTRAINT pk_clienteregistrado PRIMARY KEY (id_cliente_generico),
    CONSTRAINT fk_id_cliente_generico FOREIGN KEY (id_cliente_generico) REFERENCES cliente_generico(id)
);

CREATE TABLE productos(
    nombre VARCHAR2(256) NOT NULL,
    coffea VARCHAR2(32) NOT NULL,
    varietal VARCHAR2(32) NOT NULL,
    pais_origen VARCHAR2(64) NOT NULL,
    tipo_tostado VARCHAR2(16) NOT NULL,
    descafeinado VARCHAR2(1) NOT NULL,
    CONSTRAINT pk_productos PRIMARY KEY(nombre)
);

CREATE TABLE formatos_comercializacion(
    producto VARCHAR2(256) NOT NULL,
    tipo VARCHAR2(16) NOT NULL,
    CONSTRAINT pk_formatos_comercializacion PRIMARY KEY (producto, tipo),
    CONSTRAINT fk_formatos_comercializacion FOREIGN KEY (producto) REFERENCES productos(nombre)
);

CREATE TABLE tamaño_formato(
    formato VARCHAR2(256) NOT NULL,
    tipo VARCHAR2(16) NOT NULL,
    cantidad NUMBER(10) NOT NULL,
    definicion_cantidad VARCHAR2(16) NOT NULL,
    CONSTRAINT pk_tamano_formato PRIMARY KEY(formato, cantidad, definicion_cantidad),
    CONSTRAINT ck_cantidad CHECK (cantidad>0),
    CONSTRAINT fk_formato FOREIGN KEY (formato, tipo) REFERENCES formatos_comercializacion(producto, tipo)
);

CREATE TABLE compras(
    cliente NUMBER(16) NOT NULL,
    fecha DATE NOT NULL,
    direccion_entrega NUMBER(16) NOT NULL,
    tipo_facturacion VARCHAR2(16) NOT NULL,
    datos_tarjeta NUMBER(16),
    fecha_pago DATE,
    fecha_entrega DATE,
    precio_total NUMBER(8,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_compras PRIMARY KEY (fecha, direccion_entrega),
    CONSTRAINT fk_cliente FOREIGN KEY (cliente) REFERENCES cliente_generico(id),
    CONSTRAINT ck_precio_total CHECK (precio_total>=0),
    CONSTRAINT ck_tarjeta 
        CHECK (((tipo_facturacion='tarjeta' AND datos_tarjeta IS NULL) AND fecha=fecha_entrega) 
        OR (tipo_facturacion != 'tarjeta' AND datos_tarjeta IS NULL))
);

CREATE TABLE articulos(
    producto VARCHAR2(256) NOT NULL,
    codigo_barras NUMBER(16) NOT NULL,
    descripcion VARCHAR2(256) NOT NULL,
    cantidad NUMBER(8) NOT NULL,
    precio_venta NUMBER(8,2) NOT NULL,
    stock NUMBER(8) DEFAULT 0 NOT NULL,
    min_stock NUMBER(8) DEFAULT 5 NOT NULL,
    max_stock NUMBER(8) DEFAULT 15 NOT NULL,
    comprado_fecha DATE DEFAULT NULL,
	comprado_direccion NUMBER(16) DEFAULT NULL,
    CONSTRAINT pk_articulos PRIMARY KEY (codigo_barras),
    CONSTRAINT ck_cantidad2 CHECK (cantidad>=0),
    CONSTRAINT ck_precio_venta CHECK (precio_venta>=0),
    CONSTRAINT ck_stock CHECK (stock>=min_stock AND stock<=max_stock),
    CONSTRAINT ck_min_stock CHECK (min_stock>=0),
    CONSTRAINT ck_max_stock CHECK (max_stock>=0),
    CONSTRAINT fk_producto2 FOREIGN KEY (producto) REFERENCES productos(nombre),
    CONSTRAINT fk_comprado FOREIGN KEY (comprado_fecha, comprado_direccion) REFERENCES compras(fecha, direccion_entrega) ON DELETE SET NULL
);

CREATE TABLE datos_direccion(
    coordenadas VARCHAR2(32) NOT NULL,
    tipo_via VARCHAR2(16) NOT NULL,
    nombre_via VARCHAR2(32) NOT NULL,
    numero_inmueble NUMBER(3),
    numero_bloque NUMBER(3),
    escalera VARCHAR2(2),
    piso NUMBER(2),
    puerta VARCHAR2(2),
    codigo_postal NUMBER(16) NOT NULL,
    ciudad VARCHAR2(16) NOT NULL,
    pais VARCHAR2(16) NOT NULL,
    cliente NUMBER(8),
    CONSTRAINT pk_datos_direccion PRIMARY KEY (coordenadas),
    CONSTRAINT fk_cliente2 FOREIGN KEY (cliente) REFERENCES cliente_registrado(id_cliente_generico)
);

CREATE TABLE proveedores(
    nombre_registrado VARCHAR2(256) UNIQUE NOT NULL,
    cif NUMBER(32) NOT NULL,
    nombre_completo VARCHAR(256) UNIQUE NOT NULL,
    correo_electronico VARCHAR2(32) UNIQUE NOT NULL,
    numero_bancario NUMBER(32) UNIQUE NOT NULL,
    direccion VARCHAR2(32) NOT NULL,
    pais VARCHAR2(32) NOT NULL,
    tiempo_medio NUMBER(4, 2) DEFAULT 0,
    pedidos_satisfechos NUMBER(4) DEFAULT 0,
    CONSTRAINT pk_proveedores PRIMARY KEY (cif),
    CONSTRAINT fk_direccion FOREIGN KEY (direccion) REFERENCES datos_direccion(coordenadas),
    CONSTRAINT ck_tiempo_medio CHECK (tiempo_medio>=0),
    CONSTRAINT ck_pedidos_satisfechos CHECK (pedidos_satisfechos>=0)
);

CREATE TABLE pedidos (
    producto VARCHAR2(256) NOT NULL,
    fecha DATE NOT NULL,
    estado VARCHAR2(16) NOT NULL,
    unidades NUMBER(8) NOT NULL,
    proveedor NUMBER(32),
    fecha_recepcion DATE,
    precio_total NUMBER(8,2),
    CONSTRAINT pk_pedidos PRIMARY KEY (producto),
    CONSTRAINT fk_producto FOREIGN KEY (producto) REFERENCES productos(nombre),
    CONSTRAINT fk_proveedor FOREIGN KEY (proveedor) REFERENCES proveedores(cif) ON DELETE SET NULL,
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

CREATE TABLE publicaciones(
    id NUMBER(8) NOT NULL,
    producto VARCHAR2(256) NOT NULL,
    articulos NUMBER(16),
    puntuacion NUMBER(1) NOT NULL,
    likes NUMBER(5) NOT NULL,
    refrenda VARCHAR(1) NOT NULL,
    cliente NUMBER(8),
    CONSTRAINT pk_publicaciones PRIMARY KEY(id),
    CONSTRAINT fk_producto3 FOREIGN KEY (producto) REFERENCES productos(nombre),
    CONSTRAINT fk_articulos FOREIGN KEY (articulos) REFERENCES articulos(codigo_barras),
    CONSTRAINT fk_cliente4 FOREIGN KEY (cliente) REFERENCES cliente_registrado(id_cliente_generico) ON DELETE SET NULL,
    CONSTRAINT ck_puntuacion CHECK(puntuacion<=5 AND puntuacion>=1),
    CONSTRAINT ck_likes CHECK(likes>=0)
);

CREATE TABLE descuentos(
    cliente NUMBER(8) NOT NULL,
    porcentaje_a_descontar NUMBER(3) NOT NULL,
    fecha_expiracion DATE NOT NULL,
    CONSTRAINT pk_descuentos PRIMARY KEY (cliente, fecha_expiracion),
    CONSTRAINT ck_porcentaje_a_descontar CHECK (porcentaje_a_descontar>=0 AND porcentaje_a_descontar<=100)
);

CREATE TABLE oferta(
    proveedor NUMBER(32) NOT NULL,
    producto VARCHAR2(256) NOT NULL,
    precio NUMBER(8,2),
    CONSTRAINT pk_oferta PRIMARY KEY (proveedor, producto),
    CONSTRAINT fk_proveedor2 FOREIGN KEY (proveedor) REFERENCES proveedores(cif) ON DELETE CASCADE,
    CONSTRAINT fk_producto4 FOREIGN KEY (producto) REFERENCES productos(nombre) ON DELETE CASCADE,
    CONSTRAINT ck_precio CHECK (precio>0)
);