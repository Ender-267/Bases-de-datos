DROP producto;
DROP formatos_comercializacion:
DROP tamaño_formato;
DROP articulos;
DROP compras;
DROP pedidos;
DROP proveedor;
DROP datos_tarjeta;
DROP datos_direccion;
DROP cliente_generico;
DROP cliente_registrado;
DROP publicaciones;
DROP oferta;
DROP descuentos;

CREATE TABLE producto (
    nombre VARCHAR2(256) NOT NULL,
    coffea VARCHAR2(32) NOT NULL,
    varietal VARCHAR2(32) NOT NULL,
    pais_origen VARCHAR2(64) NOT NULL,
    tipo_tostado ENUM('natural','torrfacto','mezcla') NOT NULL,
    descafeinado BOOLEAN NOT NULL
    CONSTRAINT pk_producto PRIMARY KEY(nombre)
);

CREATE TABLE formatos_comercializacion(
    producto VARCHAR2(256) NOT NULL
    tipo ENUM('grano crudo','grano tostado','molido','liofilizado','capsulas','preparado') NOT NULL,
    CONSTRAINT pk_formatos_comercializacion PRIMARY KEY (producto, tipo),
    CONSTRAINT fk_producto FOREIGN KEY producto REFERENCES producto(nombre)
);

CREATE TABLE tamaño_formato(
    formato VARCHAR2(256) NOT NULL,
    cantidad NUMBER(10) NOT NULL,
    definicion_cantidad ENUM('volumen','peso') NOT NULL,
    CONSTRAINT pk_tamaño_formato PRIMARY KEY(formato, cantidad, definicion_cantidad),
    CONSTRAINT ck_cantidad CHECK (cantidad>0),
    CONSTRAINT fk_formato FOREIGN KEY formato REFERENCES formatos_comercializacion(producto)
);

CREATE TABLE articulos(
    producto VARCHAR2(256) NOT NULL,
    codigo_barras NUMBER(16) NOT NULL,
    descripcion VARCHAR2(256) NOT NULL,
    envalaje_tamaño NUMBER(8) NOT NULL,
    precio_venta NUMBER(8,2) NOT NULL,
    stock NUMBER(8) DEFAULT 0 NOT NULL,
    min_stock NUMBER(8) DEFAULT 5 NOT NULL,
    max_stock NUMBER(8) DEFAULT 15 NOT NULL,
    comprado NUMBER(16) DEFAULT NULL ON DELETE SET NULL,
    CONSTRAINT pk_articulos PRIMARY KEY (codigo_barras)
    CONSTRAINT ck_envalaje_tamaño CHECK (envalaje_tamaño>=0),
    CONSTRAINT ck_precio_venta CHECK (precio_venta>=0),
    CONSTRAINT ck_stock CHECK (stock>=min_stock AND stock<=max_stock),
    CONSTRAINT ck_min_stock CHECK (min_stock>=0),
    CONSTRAINT ck_max_stock CHECK (max_stock>=0),
    CONSTRAINT fk_producto FOREIGN KEY producto REFERENCES producto(nombre),
    CONSTRAINT fk_envalaje_tamaño FOREIGN KEY envalaje_tamaño REFERENCES tamaño_formato(cantidad),

);

CREATE TABLE compras(
    cliente NUMBER(16) NOT NULL
    fecha DATE NOT NULL,
    direccion_entrega NUMBER(16) NOT NULL,
    tipo_facturacion ENUM('COD', 'banco', 'tarjeta') NOT NULL,
    datos_tarjeta NUMBER(16),
    fecha_pago DATE,
    fecha_entrega DATE,
    precio_total NUMBER(8,2) DEFAULT 0 NOT NULL,
    CONSTRAINT pk_compras PRIMARY KEY (fecha, direccion_entrega),
    CONSTRAINT fk_cliente FOREIGN KEY cliente REFERENCES cliente_generico(id),
    CONSTRAINT ck_precio_total CHECK (precio_total>=0),
    CONSTRAINT ck_tarjeta 
        CHECK ((tipo_facturacion='tajeta' AND datos_tarjeta = NULL AND fecha=fecha_entrega) 
        OR (tipo_facturacion != 'tarjeta' AND datos_tarjeta = NULL))
);

CREATE TABLE pedidos(
    producto VARCHAR2(256) NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('fullfulled', 'placed', 'draft') NOT NULL,
    unidades NUMBER(8) NOT NULL,
    proveedor VARCHAR2(64) ON DELETE SET NULL,
    fecha_recepcion DATE,
    precio_total NUMBER(8,2),

    CONSTRAINT pk_pedidos PRIMARY KEY (articulos),
    CONSTRAINT fk_producto FOREIGN KEY (producto) REFERENCES producto(nombre),
    CONSTRAINT fk_proveedor FOREIGN KEY (proveedor) REFERENCES proveedor(cif),
    CONSTRAINT ck_unidades CHECK (unidades>0),
    CONSTRAINT ck_precio_total CHECK (precio_total>0)
    CONSTRAINT ck_draft CHECK ((estado != 'draft') OR (estado = 'draft' AND proveedor = NULL)),
    CONSTRAINT ck_fullfiled
        CHECK ((estado != 'fullfiled')
        OR (estado = 'fullfiled' AND fecha_recepcion != NULL AND fecha_recepcion>fecha AND precio_total != NULL))
);

CREATE TABLE proveedores(
    nombre_registrado VARCHAR2(256) UNIQUE NOT NULL,
    cif NUMBER(32) NOT NULL,
    nombre_completo VARCHAR(256) UNIQUE NOT NULL,
    correo_electronico VARCHAR2(32) UNIQUE NOT NULL,
    numero_bancario NUMBER(32) UNIQUE NOT NULL,
    direccion_postal NUMBER(16) NOT NULL,
    pais VARCHAR2(32) NOT NULL
    tiempo_medio NUMBER(4, 2) DEFAULT 0,
    pedidos_satisfechos NUMBER(4) DEFAULT 0,
    CONSTRAINT pk_proveedores PRIMARY KEY (cif)
    CONSTRAINT fk_direccion_postal FOREIGN KEY datos_direccion(codigo_postal),
    CONSTRAINT ck_tiempo_medio CHECK (tiempo_medio>=0),
    CONSTRAINT ck_pedidos_satisfechos CHECK (pedidos_satisfechos>=0)
);

CREATE TABLE cliente_generico(
    id NUMBER(8) NOT NULL,
    telefono NUMBER(16),
    correo_electronico VARCHAR2(32),
    nombre VARCHAR2(16),
    apellido1 VARCHAR2(16),
    apellido2 VARCHAR2(16),
    UNIQUE (nombre, apellido1, apellido2)
);

CREATE TABLE cliente_registrado(
    id_cliente_generico NUMBER(8) NOT NULL,
    fecha_registro DATE NOT NULL,
    telefono NUMBER(16),
    correo_electronico VARCHAR2(32),
    nombre VARCHAR2(16) NOT NULL,
    apellido1 VARCHAR2(16) NOT NULL,
    apellido2 VARCHAR2(16),
    preferencia_contacto 
        ENUM('email', 'telefono', 'sms', 'whatsapp', 'facebook', 'wechat', 'qqmobile', 'snapchat', 'telegram') 
        NOT NULL 
        DEFAULT(
            CASE 
                WHEN telefono = NULL THEN 'email'
                ELSE 'sms'
            END
        ),
    CONSTRAINT pk_clienteregistrado PRIMARY KEY (id_cliente_generico),
    CONSTRAINT fk_id_cliente_generico FOREIGN KEY id_cliente_generico REFERENCES cliente_generico(id),
    CONSTRAINT fk_telefono FOREIGN KEY telefono REFERENCES cliente_generico(telefono),
    CONSTRAINT fk_correo_electronico FOREIGN KEY correo_electronico REFERENCES cliente_generico(correo_electronico),
    CONSTRAINT fk_nombre FOREIGN KEY nombre REFERENCES cliente_generico(nombre),
    CONSTRAINT fk_apellido1 FOREIGN KEY apellido1 REFERENCES cliente_generico(apellido1),
    CONSTRAINT fk_apellido2 FOREIGN KEY apellido2 REFERENCES cliente_generico(apellido2),
);

CREATE TABLE datos_tarjeta(
    titular VARCHAR2(128) NOT NULL,
    compañia VARCHAR2(128) NOT NULL,
    numero NUMBER(16) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    cliente NUMBER(8),
    CONSTRAINT pk_numero PRIMARY KEY (numero),
    CONSTRAINT fk_cliente FOREIGN KEY cliente_registrado(id_cliente_generico)
);

CREATE TABLE datos_direccion(
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
    CONSTRAINT pk_datos_direccion 
        PRIMARY KEY (tipo_via, nombre_via, numero_inmueble, numero_bloque, escalera, piso, puerta, codigo_postal, ciudad, pais),
    CONSTRAINT fk_cliente FOREIGN KEY (cliente) REFERENCES cliente_registrado(id_cliente_generico)
);


CREATE TABLE publicaciones(
    id NUMBER(8) NOT NULL,
    producto VARCHAR2(256) NOT NULL,
    articulos NUMBER(16),
    puntuacion NUMBER(1) NOT NULL,
    likes NUMBER(5) NOT NULL,
    refrenda BOOLEAN NOT NULL,
    cliente NUMBER(8) ON DELETE SET NULL,
    CONSTRAINT pk_publicaciones PRIMARY KEY(id),
    CONSTRAINT fk_producto FOREIGN KEY producto REFERENCES productos(nombre),
    CONSTRAINT fk_articulos FOREIGN KEY articulos REFERENCES articulos(codigo_barras),
    CONSTRAINT fk_cliente FOREIGN KEY client REFERENCES cliente_registrado(id_cliente_generico),
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
    proveedor NUMBER(32) ON DELETE CASCADE NOT NULL,
    producto VARCHAR2(256) ON DELETE CASCADE NOT NULL,
    precio NUMBER(8,2),
    CONSTRAINT pk_oferta PRIMARY KEY (proveedor, producto),
    CONSTRAINT fk_proveedor FOREIGN KEY proveedor REFERENCES proveedores(nombre),
    CONSTRAINT fk_producto FOREIGN KEY producto REFERENCES producto(producto),
    CONSTRAINT ck_precio CHECK (precio>0)
);