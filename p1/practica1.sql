CREATE TABLE Producto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    tipo_cafeto VARCHAR(255),
    variedad VARCHAR(255),
    origen VARCHAR(255),
    tipo_tostado ENUM('natural', 'torrefacto', 'mezcla'),
    descafeinado BOOLEAN,
    formatos_comercializacion VARCHAR(255),
    precio_venta_publico DECIMAL(10, 2),
    stock_disponible INT
);



CREATE TABLE Referencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo_barras VARCHAR(255) NOT NULL,
    descripcion_embalaje VARCHAR(255),
    precio_venta_publico DECIMAL(10, 2),
    stock_disponible INT
);



CREATE TABLE PedidoReposicion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_hora_pedido DATETIME,
    unidades_solicitadas INT,
    estado ENUM('draft', 'placed', 'fulfilled'),
    proveedor_asignado INT,
    FOREIGN KEY (proveedor_asignado) REFERENCES Proveedor(id)
);



CREATE TABLE Proveedor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    cif VARCHAR(255) UNIQUE,
    nombre_comercial VARCHAR(255),
    correo_electronico VARCHAR(255) UNIQUE,
    numero_telefono VARCHAR(20) UNIQUE,
    numero_cuenta_bancaria VARCHAR(255),
    direccion_postal_comercial VARCHAR(255),
    pais VARCHAR(100)
);




CREATE TABLE Compra (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_hora_compra DATETIME,
    datos_facturacion VARCHAR(255),
    datos_entrega VARCHAR(255)
);



CREATE TABLE ClienteRegistrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre_usuario VARCHAR(255) UNIQUE,
    contrasena VARCHAR(255),
    fecha_hora_registro DATETIME,
    datos_personales VARCHAR(255),
    informacion_contacto VARCHAR(255),
    preferencia_contacto VARCHAR(255),
    direcciones VARCHAR(255),
    datos_tarjeta_credito VARCHAR(255),
    descuentos_fidelidad VARCHAR(255),
    compras_realizadas VARCHAR(255),
    opiniones_valoraciones_comentarios VARCHAR(255)
);




CREATE TABLE ClienteNoRegistrado (
    id INT PRIMARY KEY AUTO_INCREMENT,
    datos_contacto VARCHAR(255),
    compras_realizadas VARCHAR(255)
);





CREATE TABLE TarjetaCredito (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titular VARCHAR(255),
    compania_financiera VARCHAR(255),
    numero_tarjeta VARCHAR(16) UNIQUE,
    fecha_vencimiento DATE
);




CREATE TABLE Direccion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_via VARCHAR(50),
    nombre_via VARCHAR(255),
    numero_inmueble VARCHAR(20),
    numero_bloque VARCHAR(20),
    escalera VARCHAR(20),
    piso VARCHAR(20),
    puerta VARCHAR(20),
    codigo_postal VARCHAR(10),
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);





CREATE TABLE Comentario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha_hora_publicacion DATETIME,
    puntuacion INT CHECK(puntuacion >= 1 AND puntuacion <= 5),
    titulo VARCHAR(255),
    texto TEXT,
    num_likes INT DEFAULT 0,
    referencia_producto INT,
    etiqueta_refrenda BOOLEAN,
    FOREIGN KEY (referencia_producto) REFERENCES Producto(id)
);