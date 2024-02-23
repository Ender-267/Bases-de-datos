producto(***nombre***, coffea, varietal, origen, tostado, comercializacion, stock, min_stock)

referencia(***codigo_de_barras***, producto, cantidad, precio)

pedido_reposicion(***referencia***, ***fecha_creacion***, fecha_recepcion, unidades, estado)

proveedores(***nombre_registrado***, CIF, ***nombre_registrado_comercial***, ***correo_electronico***, ***direccion_postal***, pais)

pedido_cliente(***cliente***, ***fecha***, ***direccion***, ***referencia***, tipo_de_pago, fecha_de_pago, tarjeta_de_credito, fecha_de_entrega, cantidad, precio_unitario, precio_total)

clientes_registrado(***nombre_usuario***, contraseña, fecha_registro, nombre, p_apellido, s_apellido, telefono, correo_electronico, direccion, tarjeta_de_credito, descuentos)

clientes_noregistrados(***correo electronico***, ***telefono***, nombre, p_apellido, s_apellido, direccion_envio, direccion_facturacion, tarjeta_de_credito, fecha_registro)

tarjeta_de_credito(titular, ***numero***, fecha_expiracion)

dirrecion(tipo_via, nombre_via, numero_immueble, numero_bloque)

descuentos(a_descontar, fecha_validez)

contacto(telefono, correo_electronico)

valoraciones(referencia, puntuacion, titulo, texto, likes, refrenda, usuario_emisor)