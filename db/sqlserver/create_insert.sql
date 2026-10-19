--**********************************************************************************************
--(OPCIONAL) si ya importaste una version anterior, quita los "--" de estas lineas y ejecutalas primero
--**********************************************************************************************
--DROP TABLE REALIZA_VENTA;
--DROP TABLE EXPONE;
--DROP TABLE PRESENTA;
--DROP TABLE FERIA_TEMATICA;
--DROP TABLE CONTIENE;
--DROP TABLE INCLUYE;
--DROP TABLE SE_REALIZA_EN;
--DROP TABLE PUESTO;
--DROP TABLE FERIA;
--DROP TABLE RESPONSABLE;
--DROP TABLE COMERCIANTE;
--DROP TABLE EXPOSITOR;
--DROP TABLE PERSONA;
--DROP TABLE EXPOSICION;
--DROP TABLE PRODUCTO;
--DROP TABLE TEMATICA;
--DROP TABLE SERVICIO;
--DROP TABLE UBICACION;
--DROP TABLE ORGANIZADOR;
--**********************************************************************************************
--CREATE
--**********************************************************************************************
CREATE TABLE ORGANIZADOR (
    idOrganizador INT PRIMARY KEY,
    nombreOrg     NVARCHAR(100) NOT NULL,
    razonSocial   NVARCHAR(150),
    correo        NVARCHAR(100),
    telefonoOrg   NVARCHAR(20)
);
----------------------------------------------------------------------------
CREATE TABLE UBICACION (
    idUbicacion  INT PRIMARY KEY,
    nombreL      NVARCHAR(100) NOT NULL,
    zona         NVARCHAR(80),
    direccionRef NVARCHAR(150),
    tipoLugar    NVARCHAR(50),
    capacidad    INT
);
----------------------------------------------------------------------------
CREATE TABLE SERVICIO (
    idServicio  INT PRIMARY KEY,
    nombreSer   NVARCHAR(100) NOT NULL,
    tipoSer     NVARCHAR(50),
    responsable NVARCHAR(50),
    horario     NVARCHAR(100)
);
----------------------------------------------------------------------------
CREATE TABLE TEMATICA (
    idtematica     INT PRIMARY KEY,
    nombreTem      NVARCHAR(100) NOT NULL,
    descripcionTem NVARCHAR(100)
);
----------------------------------------------------------------------------
CREATE TABLE PRODUCTO (
    idProducto      INT PRIMARY KEY,
    nombreProd      NVARCHAR(100) NOT NULL,
    descripcionProd NVARCHAR(250),
    precio          DECIMAL(10,2) CHECK (precio >= 0),
    stock           INT CHECK (stock >= 0),
    dimensiones     NVARCHAR(50)
);
----------------------------------------------------------------------------
CREATE TABLE EXPOSICION (
    idExpo          INT PRIMARY KEY,
    titulo          NVARCHAR(150) NOT NULL,
    duracionMin     INT,
    descripcionExpo NVARCHAR(300),
    tema            NVARCHAR(100)
);
----------------------------------------------------------------------------
CREATE TABLE PERSONA (
    ci       BIGINT PRIMARY KEY,
    nombre   NVARCHAR(60) NOT NULL,
    paterno  NVARCHAR(60),
    materno  NVARCHAR(60),
    telefono NVARCHAR(20),
    fecNac   DATE,
    sexo     CHAR(1) CHECK (sexo IN ('M', 'F')),
    correo   NVARCHAR(100)
);
----------------------------------------------------------------------------
CREATE TABLE EXPOSITOR (
    ciExpositor   BIGINT PRIMARY KEY,
    tipoExpositor NVARCHAR(60),
    especialidad  NVARCHAR(100),
    institucion   NVARCHAR(150),
    CONSTRAINT fk_expositor_persona
        FOREIGN KEY (ciExpositor) REFERENCES PERSONA(ci)
);
----------------------------------------------------------------------------
CREATE TABLE COMERCIANTE (
    idComerciante BIGINT PRIMARY KEY,
    nit           NVARCHAR(20),
    rubro         NVARCHAR(100),
    licFunc       NVARCHAR(50),
    CONSTRAINT fk_comerciante_persona
        FOREIGN KEY (idComerciante) REFERENCES PERSONA(ci)
);
----------------------------------------------------------------------------
CREATE TABLE RESPONSABLE (
    idResponsable BIGINT PRIMARY KEY,
    cargo         NVARCHAR(80),
    fecAsignacion DATE,
    CONSTRAINT fk_responsable_persona
        FOREIGN KEY (idResponsable) REFERENCES PERSONA(ci)
);
----------------------------------------------------------------------------
CREATE TABLE FERIA (
    idFeria        INT PRIMARY KEY,
    nombreFer      NVARCHAR(100) NOT NULL,
    descripcionFer NVARCHAR(300),
    idOrganizador  INT,
    CONSTRAINT fk_organiza_org
        FOREIGN KEY (idOrganizador) REFERENCES ORGANIZADOR(idOrganizador)
);
----------------------------------------------------------------------------
CREATE TABLE PUESTO (
    idPuesto      INT PRIMARY KEY,
    numero        INT NOT NULL,
    tamanio       NVARCHAR(30),
    idResponsable BIGINT,
    CONSTRAINT fk_puesto
        FOREIGN KEY (idResponsable) REFERENCES RESPONSABLE(idResponsable)
);
-------------------------------Macroentidad-------------------------------------
CREATE TABLE SE_REALIZA_EN (
    idFeria     INT,
    idUbicacion INT,
    fecha_ini   DATE,
    fecha_fin   DATE,
    CONSTRAINT pk_feria_ubicacion PRIMARY KEY (idFeria, idUbicacion),
    CONSTRAINT fk_sre_feria FOREIGN KEY (idFeria) REFERENCES FERIA(idFeria),
    CONSTRAINT fk_sre_ubicacion FOREIGN KEY (idUbicacion) REFERENCES UBICACION(idUbicacion)
);
----------------------------------------------------------------------------
CREATE TABLE INCLUYE (
    idFeria     INT,
    idUbicacion INT,
    idServicio  INT,
    costo       DECIMAL(10,2),
    CONSTRAINT pk_incluye PRIMARY KEY (idFeria, idUbicacion, idServicio),
    CONSTRAINT fk_incluye_sre FOREIGN KEY (idFeria, idUbicacion) REFERENCES SE_REALIZA_EN(idFeria, idUbicacion),
    CONSTRAINT fk_incluye_servicio FOREIGN KEY (idServicio) REFERENCES SERVICIO(idServicio)
);
----------------------------------------------------------------------------
CREATE TABLE CONTIENE (
    idFeria     INT,
    idUbicacion INT,
    idPuesto    INT,
    CONSTRAINT pk_contiene PRIMARY KEY (idFeria, idUbicacion, idPuesto),
    CONSTRAINT fk_contiene_sre FOREIGN KEY (idFeria, idUbicacion) REFERENCES SE_REALIZA_EN(idFeria, idUbicacion),
    CONSTRAINT fk_contiene_puesto FOREIGN KEY (idPuesto) REFERENCES PUESTO(idPuesto)
);
----------------------------------------------------------------------------
CREATE TABLE FERIA_TEMATICA (
    idFeria    INT,
    idTematica INT,
    CONSTRAINT pk_feria_tematica PRIMARY KEY (idFeria, idTematica),
    CONSTRAINT fk_tiene_feria FOREIGN KEY (idFeria) REFERENCES FERIA(idFeria),
    CONSTRAINT fk_tiene_tematica FOREIGN KEY (idTematica) REFERENCES TEMATICA(idTematica)
);
----------------------------------------------------------------------------
CREATE TABLE PRESENTA (
    idPuesto INT,
    idExpo   INT,
    CONSTRAINT pk_presenta PRIMARY KEY (idPuesto, idExpo),
    CONSTRAINT fk_presenta_puesto FOREIGN KEY (idPuesto) REFERENCES PUESTO(idPuesto),
    CONSTRAINT fk_presenta_exposicion FOREIGN KEY (idExpo) REFERENCES EXPOSICION(idExpo)
);
----------------------------------------------------------------------------
CREATE TABLE EXPONE (
    idExpo      INT,
    idExpositor BIGINT,
    CONSTRAINT pk_expone PRIMARY KEY (idExpo, idExpositor),
    CONSTRAINT fk_expone_exposicion FOREIGN KEY (idExpo) REFERENCES EXPOSICION(idExpo),
    CONSTRAINT fk_expone_expositor FOREIGN KEY (idExpositor) REFERENCES EXPOSITOR(ciExpositor)
);
----------------------------------------------------------------------------
CREATE TABLE REALIZA_VENTA (
    idPuesto      INT,
    idProducto    INT,
    idComerciante BIGINT,
    CONSTRAINT pk_realiza_venta PRIMARY KEY (idPuesto, idProducto, idComerciante),
    CONSTRAINT fk_venta_puesto FOREIGN KEY (idPuesto) REFERENCES PUESTO(idPuesto),
    CONSTRAINT fk_venta_producto FOREIGN KEY (idProducto) REFERENCES PRODUCTO(idProducto),
    CONSTRAINT fk_venta_comerciante FOREIGN KEY (idComerciante) REFERENCES COMERCIANTE(idComerciante)
);

--**********************************************************************************************
--INSERT
--**********************************************************************************************
-- ORGANIZADOR (30)
INSERT INTO ORGANIZADOR VALUES (1, 'FeriaEvents S.A.', 'FeriaEvents Sociedad Anonima', 'contacto@feriaevents.com', '77712345');
INSERT INTO ORGANIZADOR VALUES (2, 'Eventos del Sur', 'Eventos del Sur Ltda.', 'info@eventosdelsur.com', '77723456');
INSERT INTO ORGANIZADOR VALUES (3, 'Producciones Andinas', 'Producciones Andinas SRL', 'ventas@produandinas.com', '77734567');
INSERT INTO ORGANIZADOR VALUES (4, 'Grupo Cultural Boliviano', 'Grupo Cultural Boliviano S.A.', 'cultura@grupoBol.com', '77745678');
INSERT INTO ORGANIZADOR VALUES (5, 'Expo Center', 'Expo Center Internacional', 'contacto@expocenter.com', '77756789');
INSERT INTO ORGANIZADOR VALUES (6, 'Feria y Arte', 'Feria y Arte Asociados', 'info@feriayarte.com', '77767890');
INSERT INTO ORGANIZADOR VALUES (7, 'Eventos Corporativos', 'Eventos Corporativos SRL', 'ventas@eventoscorp.com', '77778901');
INSERT INTO ORGANIZADOR VALUES (8, 'Mega Ferias', 'Mega Ferias del Pacifico', 'contacto@megaferias.com', '77789012');
INSERT INTO ORGANIZADOR VALUES (9, 'Camara de Comercio', 'Camara de Comercio Local', 'info@camaracomercio.com', '77790123');
INSERT INTO ORGANIZADOR VALUES (10, 'Instituto Cultural', 'Instituto Cultural Andino', 'cultura@instcult.com', '77801234');
INSERT INTO ORGANIZADOR VALUES (11, 'Feria Gastronomica', 'Feria Gastronomica Boliviana', 'gastro@feriabol.com', '77812345');
INSERT INTO ORGANIZADOR VALUES (12, 'Arte y Tradicion', 'Arte y Tradicion S.A.', 'arte@arteytrad.com', '77823456');
INSERT INTO ORGANIZADOR VALUES (13, 'Expo Tecnologia', 'Expo Tecnologia del Sur', 'tech@expotec.com', '77834567');
INSERT INTO ORGANIZADOR VALUES (14, 'Feria del Libro', 'Feria del Libro Internacional', 'libro@ferialibro.com', '77845678');
INSERT INTO ORGANIZADOR VALUES (15, 'Eventos Juveniles', 'Eventos Juveniles SRL', 'info@eventosjuv.com', '77856789');
INSERT INTO ORGANIZADOR VALUES (16, 'Producciones del Valle', 'Producciones del Valle Ltda.', 'valle@producciones.com', '77867890');
INSERT INTO ORGANIZADOR VALUES (17, 'Feria Artesanal', 'Feria Artesanal Boliviana', 'artesania@feriaart.com', '77878901');
INSERT INTO ORGANIZADOR VALUES (18, 'Eventos Deportivos', 'Eventos Deportivos Nacionales', 'deportes@eventosdep.com', '77889012');
INSERT INTO ORGANIZADOR VALUES (19, 'Feria Educativa', 'Feria Educativa del Sur', 'educa@feriaedu.com', '77890123');
INSERT INTO ORGANIZADOR VALUES (20, 'Grupo Empresarial', 'Grupo Empresarial Andino', 'grupo@empresarial.com', '77901234');
INSERT INTO ORGANIZADOR VALUES (21, 'Expo Salud', 'Expo Salud Bolivia', 'salud@exposalud.com', '77912345');
INSERT INTO ORGANIZADOR VALUES (22, 'Eventos Nocturnos', 'Eventos Nocturnos SRL', 'noche@eventosnoc.com', '77923456');
INSERT INTO ORGANIZADOR VALUES (23, 'Feria Cientifica', 'Feria Cientifica Nacional', 'ciencia@feriacien.com', '77934567');
INSERT INTO ORGANIZADOR VALUES (24, 'Cine y Cultura', 'Cine y Cultura Asociados', 'cine@cinecultura.com', '77945678');
INSERT INTO ORGANIZADOR VALUES (25, 'Turismo Activo', 'Turismo Activo Bolivia', 'turismo@turismoact.com', '77956789');
INSERT INTO ORGANIZADOR VALUES (26, 'Moda y Estilo', 'Moda y Estilo S.A.', 'moda@modayestilo.com', '77967890');
INSERT INTO ORGANIZADOR VALUES (27, 'Eventos Ecologicos', 'Eventos Ecologicos SRL', 'eco@eventoseco.com', '77978901');
INSERT INTO ORGANIZADOR VALUES (28, 'Feria del Cafe', 'Feria del Cafe Boliviano', 'cafe@feriacafe.com', '77989012');
INSERT INTO ORGANIZADOR VALUES (29, 'Arte Urbano', 'Arte Urbano Colectivo', 'urbano@arteurbano.com', '77990123');
INSERT INTO ORGANIZADOR VALUES (30, 'Eventos Internacionales', 'Eventos Internacionales S.A.', 'int@eventosint.com', '78001234');

-- UBICACION (10)
INSERT INTO UBICACION VALUES (1, 'Campo Ferial Central', 'Zona Norte', 'Av. America #1234', 'Campo Abierto', 50);
INSERT INTO UBICACION VALUES (2, 'Centro de Convenciones', 'Zona Sur', 'Calle 15 #456', 'Auditorio', 30);
INSERT INTO UBICACION VALUES (3, 'Parque Metropolitano', 'Zona Este', 'Av. Ecologica #789', 'Parque', 80);
INSERT INTO UBICACION VALUES (4, 'Estadio Departamental', 'Zona Oeste', 'Av. Deportes #321', 'Estadio', 100);
INSERT INTO UBICACION VALUES (5, 'Plaza Principal', 'Centro', 'Plaza 14 de Septiembre', 'Plaza', 25);
INSERT INTO UBICACION VALUES (6, 'Recinto Ferial Sur', 'Zona Sur', 'Av. Panamericana #567', 'Recinto', 60);
INSERT INTO UBICACION VALUES (7, 'Salon Municipal', 'Centro', 'Calle Bolivar #890', 'Salon', 15);
INSERT INTO UBICACION VALUES (8, 'Expo Center Norte', 'Zona Norte', 'Av. Industrial #234', 'Centro Exposiciones', 70);
INSERT INTO UBICACION VALUES (9, 'Coliseo Cerrado', 'Zona Este', 'Calle 6 de Agosto #345', 'Coliseo', 40);
INSERT INTO UBICACION VALUES (10, 'Centro Cultural', 'Centro', 'Calle Sucre #901', 'Centro Cultural', 20);

-- FERIA (14) - organizadores repetidos para que se vea la cardinalidad 1:N
INSERT INTO FERIA VALUES (1, 'Expo Tecnologia 2024', 'Feria de innovacion tecnologica', 1);
INSERT INTO FERIA VALUES (2, 'Feria Gastronomica', 'Muestra de comida tipica', 2);
INSERT INTO FERIA VALUES (3, 'Expo Arte', 'Exposicion de artes visuales', 3);
INSERT INTO FERIA VALUES (4, 'Festival de Musica', 'Conciertos y presentaciones', 4);
INSERT INTO FERIA VALUES (5, 'Feria Deportiva', 'Eventos y competencias', 5);
INSERT INTO FERIA VALUES (6, 'Expo Educacion', 'Oferta academica', 6);
INSERT INTO FERIA VALUES (7, 'Feria de la Salud', 'Servicios medicos', 7);
INSERT INTO FERIA VALUES (8, 'Festival Cultural', 'Tradiciones y costumbres', 8);
INSERT INTO FERIA VALUES (9, 'Expo Moda', 'Disenio y tendencias', 9);
INSERT INTO FERIA VALUES (10, 'Feria Cientifica', 'Investigacion y ciencia', 10);
INSERT INTO FERIA VALUES (11, 'Expo Arte', 'Exposicion de artes visuales', 3);
INSERT INTO FERIA VALUES (12, 'Feria Tecnologica Juvenil', 'Innovacion y robotica para jovenes', 1);
INSERT INTO FERIA VALUES (13, 'Festival Gastronomico Andino', 'Sabores de los Andes', 2);
INSERT INTO FERIA VALUES (14, 'Feria Artesanal Boliviana', 'Artesanias y textiles tradicionales', 1);

-- TEMATICA (8)
INSERT INTO TEMATICA VALUES (1, 'Tecnologia', 'Innovacion y avances tecnologicos');
INSERT INTO TEMATICA VALUES (2, 'Gastronomia', 'Comida tipica y internacional');
INSERT INTO TEMATICA VALUES (3, 'Arte', 'Pintura, escultura y artes visuales');
INSERT INTO TEMATICA VALUES (4, 'Musica', 'Conciertos y presentaciones musicales');
INSERT INTO TEMATICA VALUES (5, 'Deportes', 'Actividades fisicas y competencias');
INSERT INTO TEMATICA VALUES (6, 'Educacion', 'Charlas, talleres y seminarios');
INSERT INTO TEMATICA VALUES (7, 'Salud', 'Bienestar y medicina');
INSERT INTO TEMATICA VALUES (8, 'Cultura', 'Tradiciones y costumbres');
INSERT INTO TEMATICA VALUES (9, 'Ciencia', 'Avances Cientificos');

-- SERVICIO (30)
INSERT INTO SERVICIO VALUES (1, 'Seguridad 24h', 'Seguridad', 'Juan Perez', '08:00 - 20:00');
INSERT INTO SERVICIO VALUES (2, 'Limpieza General', 'Limpieza', 'Maria Lopez', '06:00 - 14:00');
INSERT INTO SERVICIO VALUES (3, 'Catering Premium', 'Alimentacion', 'Carlos Gomez', '10:00 - 22:00');
INSERT INTO SERVICIO VALUES (4, 'Sonido Profesional', 'Audio', 'Pedro Ramirez', '09:00 - 23:00');
INSERT INTO SERVICIO VALUES (5, 'Iluminacion LED', 'Iluminacion', 'Ana Torres', '18:00 - 02:00');
INSERT INTO SERVICIO VALUES (6, 'WiFi Gratuito', 'Tecnologia', 'Luis Flores', '08:00 - 22:00');
INSERT INTO SERVICIO VALUES (7, 'Estacionamiento', 'Transporte', 'Jorge Vargas', '07:00 - 23:00');
INSERT INTO SERVICIO VALUES (8, 'Primeros Auxilios', 'Salud', 'Dra. Elena Rojas', '08:00 - 20:00');
INSERT INTO SERVICIO VALUES (9, 'Guardarropa', 'Atencion', 'Sofia Castro', '10:00 - 22:00');
INSERT INTO SERVICIO VALUES (10, 'Informacion Turistica', 'Atencion', 'Diego Mendoza', '09:00 - 18:00');
INSERT INTO SERVICIO VALUES (11, 'Decoracion', 'Estetica', 'Lucia Herrera', '06:00 - 12:00');
INSERT INTO SERVICIO VALUES (12, 'Fotografia', 'Medios', 'Roberto Silva', '10:00 - 20:00');
INSERT INTO SERVICIO VALUES (13, 'Transmision en Vivo', 'Medios', 'Fernando Paz', '14:00 - 22:00');
INSERT INTO SERVICIO VALUES (14, 'Traduccion', 'Idiomas', 'Carmen Ortiz', '09:00 - 18:00');
INSERT INTO SERVICIO VALUES (15, 'Valet Parking', 'Transporte', 'Andres Rios', '18:00 - 02:00');
INSERT INTO SERVICIO VALUES (16, 'Cafeteria', 'Alimentacion', 'Patricia Nuniez', '07:00 - 21:00');
INSERT INTO SERVICIO VALUES (17, 'Zona VIP', 'Atencion', 'Gabriel Leon', '10:00 - 23:00');
INSERT INTO SERVICIO VALUES (18, 'Audio Guias', 'Tecnologia', 'Valeria Suarez', '09:00 - 17:00');
INSERT INTO SERVICIO VALUES (19, 'Limpieza de Banios', 'Limpieza', 'Miguel Angel', '05:00 - 13:00');
INSERT INTO SERVICIO VALUES (20, 'Control de Accesos', 'Seguridad', 'Daniela Paredes', '07:00 - 19:00');
INSERT INTO SERVICIO VALUES (21, 'Ambulancia', 'Salud', 'Dr. Ricardo Paz', '24 horas');
INSERT INTO SERVICIO VALUES (22, 'Bomberos', 'Seguridad', 'Cap. Luis Rojas', '24 horas');
INSERT INTO SERVICIO VALUES (23, 'Policia', 'Seguridad', 'Tte. Ana Silva', '24 horas');
INSERT INTO SERVICIO VALUES (24, 'Sonido Ambiental', 'Audio', 'DJ Carlos', '10:00 - 22:00');
INSERT INTO SERVICIO VALUES (25, 'Pantallas LED', 'Medios', 'Tec. Jose Ramos', '09:00 - 23:00');
INSERT INTO SERVICIO VALUES (26, 'Catering Vegano', 'Alimentacion', 'Chef Laura', '11:00 - 21:00');
INSERT INTO SERVICIO VALUES (27, 'Barra de Bebidas', 'Alimentacion', 'Bartender Pedro', '18:00 - 02:00');
INSERT INTO SERVICIO VALUES (28, 'Fotocopias', 'Atencion', 'Secretaria', '08:00 - 20:00');
INSERT INTO SERVICIO VALUES (29, 'Carga de Celulares', 'Tecnologia', 'Tec. Marcos', '10:00 - 22:00');
INSERT INTO SERVICIO VALUES (30, 'Zona de Descanso', 'Atencion', 'Recepcionista', '09:00 - 21:00');

-- PRODUCTO (30)
INSERT INTO PRODUCTO VALUES (1, 'Laptop HP', 'Laptop 15 pulgadas 8GB RAM', 3500.00, 50, '35x25x2 cm');
INSERT INTO PRODUCTO VALUES (2, 'Smartphone Samsung', 'Galaxy S23 128GB', 2800.00, 100, '15x7x1 cm');
INSERT INTO PRODUCTO VALUES (3, 'Tablet Lenovo', 'Tablet 10 pulgadas 64GB', 1200.00, 80, '25x17x1 cm');
INSERT INTO PRODUCTO VALUES (4, 'Audifonos Sony', 'Audifonos Bluetooth', 450.00, 200, '18x15x8 cm');
INSERT INTO PRODUCTO VALUES (5, 'Teclado Mecanico', 'Teclado RGB', 350.00, 150, '45x15x5 cm');
INSERT INTO PRODUCTO VALUES (6, 'Mouse Logitech', 'Mouse inalambrico', 120.00, 300, '12x7x4 cm');
INSERT INTO PRODUCTO VALUES (7, 'Monitor LG', 'Monitor 24 pulgadas', 1500.00, 60, '55x40x10 cm');
INSERT INTO PRODUCTO VALUES (8, 'Impresora Epson', 'Impresora multifuncional', 800.00, 40, '45x35x20 cm');
INSERT INTO PRODUCTO VALUES (9, 'Camara Canon', 'Camara reflex profesional', 4500.00, 25, '15x12x8 cm');
INSERT INTO PRODUCTO VALUES (10, 'Disco Duro Externo', 'Disco 1TB USB 3.0', 600.00, 120, '12x8x2 cm');
INSERT INTO PRODUCTO VALUES (11, 'Saltenia', 'Saltenia de carne', 8.00, 500, '10x8x6 cm');
INSERT INTO PRODUCTO VALUES (12, 'Empanada', 'Empanada de queso', 6.00, 400, '10x8x5 cm');
INSERT INTO PRODUCTO VALUES (13, 'Anticucho', 'Anticucho de corazon', 15.00, 300, '20x5x3 cm');
INSERT INTO PRODUCTO VALUES (14, 'Choripan', 'Chorizo a la parrilla', 12.00, 350, '25x8x5 cm');
INSERT INTO PRODUCTO VALUES (15, 'Hamburguesa', 'Hamburguesa completa', 25.00, 200, '15x12x8 cm');
INSERT INTO PRODUCTO VALUES (16, 'Pizza', 'Pizza familiar', 45.00, 150, '35x35x5 cm');
INSERT INTO PRODUCTO VALUES (17, 'Hot Dog', 'Hot dog especial', 10.00, 400, '20x8x5 cm');
INSERT INTO PRODUCTO VALUES (18, 'Tacos', 'Tacos mexicanos', 18.00, 250, '15x10x5 cm');
INSERT INTO PRODUCTO VALUES (19, 'Sushi', 'Sushi variado', 55.00, 100, '25x15x5 cm');
INSERT INTO PRODUCTO VALUES (20, 'Pollo Frito', 'Pollo frito crujiente', 30.00, 180, '20x15x10 cm');
INSERT INTO PRODUCTO VALUES (21, 'Manta Andina', 'Manta tejida a mano', 120.00, 60, '150x120x5 cm');
INSERT INTO PRODUCTO VALUES (22, 'Poncho', 'Poncho de alpaca', 250.00, 40, '140x120x8 cm');
INSERT INTO PRODUCTO VALUES (23, 'Sombrero', 'Sombrero de lana', 80.00, 100, '30x30x15 cm');
INSERT INTO PRODUCTO VALUES (24, 'Bufanda', 'Bufanda de alpaca', 60.00, 120, '150x30x5 cm');
INSERT INTO PRODUCTO VALUES (25, 'Guantes', 'Guantes de lana', 40.00, 150, '25x15x5 cm');
INSERT INTO PRODUCTO VALUES (26, 'Balon de Futbol', 'Balon profesional', 150.00, 80, '22x22x22 cm');
INSERT INTO PRODUCTO VALUES (27, 'Camiseta Deportiva', 'Camiseta de futbol', 120.00, 150, '30x25x5 cm');
INSERT INTO PRODUCTO VALUES (28, 'Zapatillas Running', 'Zapatillas para correr', 350.00, 100, '30x15x12 cm');
INSERT INTO PRODUCTO VALUES (29, 'Libro', 'Libro de literatura', 80.00, 150, '25x18x3 cm');
INSERT INTO PRODUCTO VALUES (30, 'Cuadro', 'Cuadro decorativo', 250.00, 40, '60x50x5 cm');

-- EXPOSICION (30)
INSERT INTO EXPOSICION VALUES (1, 'Innovacion Tecnologica 2024', 120, 'Ultimas tendencias en tecnologia', 'Tecnologia');
INSERT INTO EXPOSICION VALUES (2, 'Sabores Bolivianos', 90, 'Muestra gastronomica nacional', 'Gastronomia');
INSERT INTO EXPOSICION VALUES (3, 'Arte Contemporaneo', 150, 'Obras de artistas locales', 'Arte');
INSERT INTO EXPOSICION VALUES (4, 'Concierto Sinfonico', 180, 'Presentacion de orquesta', 'Musica');
INSERT INTO EXPOSICION VALUES (5, 'Torneo de Futbol', 240, 'Competencia deportiva', 'Deportes');
INSERT INTO EXPOSICION VALUES (6, 'Feria Educativa', 120, 'Oferta academica universitaria', 'Educacion');
INSERT INTO EXPOSICION VALUES (7, 'Salud y Bienestar', 90, 'Charlas sobre salud', 'Salud');
INSERT INTO EXPOSICION VALUES (8, 'Cultura Andina', 150, 'Danzas y tradiciones', 'Cultura');
INSERT INTO EXPOSICION VALUES (9, 'Inteligencia Artificial', 120, 'Avances en IA', 'Tecnologia');
INSERT INTO EXPOSICION VALUES (10, 'Robotica Educativa', 90, 'Robots para ninios', 'Tecnologia');
INSERT INTO EXPOSICION VALUES (11, 'Realidad Virtual', 100, 'Experiencias inmersivas', 'Tecnologia');
INSERT INTO EXPOSICION VALUES (12, 'Ciberseguridad', 100, 'Proteccion digital', 'Tecnologia');
INSERT INTO EXPOSICION VALUES (13, 'Startups Tech', 120, 'Emprendimientos tecnologicos', 'Tecnologia');
INSERT INTO EXPOSICION VALUES (14, 'Pintura Moderna', 120, 'Obras contemporaneas', 'Arte');
INSERT INTO EXPOSICION VALUES (15, 'Escultura en Madera', 100, 'Tallas artesanales', 'Arte');
INSERT INTO EXPOSICION VALUES (16, 'Arte Digital', 90, 'Ilustracion digital', 'Arte');
INSERT INTO EXPOSICION VALUES (17, 'Muralismo', 110, 'Murales urbanos', 'Arte');
INSERT INTO EXPOSICION VALUES (18, 'Fotografia Artistica', 100, 'Fotos de autor', 'Arte');
INSERT INTO EXPOSICION VALUES (19, 'Musica Folklorica', 120, 'Danzas y musica tipica', 'Musica');
INSERT INTO EXPOSICION VALUES (20, 'Rock Nacional', 150, 'Bandas locales', 'Musica');
INSERT INTO EXPOSICION VALUES (21, 'Jazz en Vivo', 90, 'Improvisacion jazz', 'Musica');
INSERT INTO EXPOSICION VALUES (22, 'Danzas Folkloricas', 110, 'Ballet folklorico', 'Cultura');
INSERT INTO EXPOSICION VALUES (23, 'Trajes Tipicos', 90, 'Vestimenta tradicional', 'Cultura');
INSERT INTO EXPOSICION VALUES (24, 'Medicina Natural', 90, 'Plantas medicinales', 'Salud');
INSERT INTO EXPOSICION VALUES (25, 'Nutricion', 80, 'Alimentacion saludable', 'Salud');
INSERT INTO EXPOSICION VALUES (26, 'Astronomia', 120, 'Observacion de estrellas', 'Ciencia');
INSERT INTO EXPOSICION VALUES (27, 'Quimica Divertida', 90, 'Experimentos quimicos', 'Ciencia');
INSERT INTO EXPOSICION VALUES (28, 'Emprendimiento Juvenil', 100, 'Negocios de jovenes', 'Educacion');
INSERT INTO EXPOSICION VALUES (29, 'Marketing Digital', 90, 'Publicidad en redes', 'Educacion');
INSERT INTO EXPOSICION VALUES (30, 'Liderazgo Empresarial', 110, 'Habilidades directivas', 'Educacion');

-- PERSONA (50)
INSERT INTO PERSONA VALUES (1000001, 'Juan', 'Perez', 'Gomez', '77712345', '1985-03-15', 'M', 'juan.perez@mail.com');
INSERT INTO PERSONA VALUES (1000002, 'Maria', 'Lopez', 'Fernandez', '77723456', '1990-07-22', 'F', 'maria.lopez@mail.com');
INSERT INTO PERSONA VALUES (1000003, 'Carlos', 'Gomez', 'Ruiz', '77734567', '1988-11-10', 'M', 'carlos.gomez@mail.com');
INSERT INTO PERSONA VALUES (1000004, 'Ana', 'Torres', 'Silva', '77745678', '1992-05-05', 'F', 'ana.torres@mail.com');
INSERT INTO PERSONA VALUES (1000005, 'Pedro', 'Ramirez', 'Castro', '77756789', '1980-09-18', 'M', 'pedro.ramirez@mail.com');
INSERT INTO PERSONA VALUES (1000006, 'Lucia', 'Herrera', 'Mendoza', '77767890', '1995-01-30', 'F', 'lucia.herrera@mail.com');
INSERT INTO PERSONA VALUES (1000007, 'Jorge', 'Vargas', 'Rojas', '77778901', '1983-12-12', 'M', 'jorge.vargas@mail.com');
INSERT INTO PERSONA VALUES (1000008, 'Sofia', 'Castro', 'Nuniez', '77789012', '1991-08-08', 'F', 'sofia.castro@mail.com');
INSERT INTO PERSONA VALUES (1000009, 'Diego', 'Mendoza', 'Paz', '77790123', '1987-04-25', 'M', 'diego.mendoza@mail.com');
INSERT INTO PERSONA VALUES (1000010, 'Elena', 'Rojas', 'Suarez', '77801234', '1986-06-14', 'F', 'elena.rojas@mail.com');
INSERT INTO PERSONA VALUES (1000011, 'Luis', 'Flores', 'Paredes', '77812345', '1989-10-20', 'M', 'luis.flores@mail.com');
INSERT INTO PERSONA VALUES (1000012, 'Carmen', 'Ortiz', 'Leon', '77823456', '1993-03-03', 'F', 'carmen.ortiz@mail.com');
INSERT INTO PERSONA VALUES (1000013, 'Roberto', 'Silva', 'Rios', '77834567', '1982-07-17', 'M', 'roberto.silva@mail.com');
INSERT INTO PERSONA VALUES (1000014, 'Patricia', 'Nuniez', 'Vega', '77845678', '1994-09-09', 'F', 'patricia.nunez@mail.com');
INSERT INTO PERSONA VALUES (1000015, 'Fernando', 'Paz', 'Cruz', '77856789', '1984-02-28', 'M', 'fernando.paz@mail.com');
INSERT INTO PERSONA VALUES (1000016, 'Valeria', 'Suarez', 'Mora', '77867890', '1996-11-11', 'F', 'valeria.suarez@mail.com');
INSERT INTO PERSONA VALUES (1000017, 'Gabriel', 'Leon', 'Ramos', '77878901', '1981-07-07', 'M', 'gabriel.leon@mail.com');
INSERT INTO PERSONA VALUES (1000018, 'Daniela', 'Paredes', 'Soto', '77889012', '1997-05-19', 'F', 'daniela.paredes@mail.com');
INSERT INTO PERSONA VALUES (1000019, 'Andres', 'Rios', 'Campos', '77890123', '1985-08-23', 'M', 'andres.rios@mail.com');
INSERT INTO PERSONA VALUES (1000020, 'Miguel', 'Angel', 'Torrez', '77901234', '1990-01-01', 'M', 'miguel.angel@mail.com');
INSERT INTO PERSONA VALUES (1000021, 'Laura', 'Fernandez', 'Gutierrez', '77912345', '1987-04-12', 'F', 'laura.fernandez@mail.com');
INSERT INTO PERSONA VALUES (1000022, 'Ricardo', 'Morales', 'Jimenez', '77923456', '1983-08-25', 'M', 'ricardo.morales@mail.com');
INSERT INTO PERSONA VALUES (1000023, 'Paola', 'Vargas', 'Rojas', '77934567', '1992-11-18', 'F', 'paola.vargas@mail.com');
INSERT INTO PERSONA VALUES (1000024, 'Sergio', 'Castro', 'Mendoza', '77945678', '1989-02-07', 'M', 'sergio.castro@mail.com');
INSERT INTO PERSONA VALUES (1000025, 'Natalia', 'Rojas', 'Silva', '77956789', '1991-06-30', 'F', 'natalia.rojas@mail.com');
INSERT INTO PERSONA VALUES (1000026, 'Felipe', 'Gomez', 'Torres', '77967890', '1986-09-14', 'M', 'felipe.gomez@mail.com');
INSERT INTO PERSONA VALUES (1000027, 'Camila', 'Perez', 'Lopez', '77978901', '1994-12-22', 'F', 'camila.perez@mail.com');
INSERT INTO PERSONA VALUES (1000028, 'Andres', 'Suarez', 'Herrera', '77989012', '1985-03-05', 'M', 'andres.suarez@mail.com');
INSERT INTO PERSONA VALUES (1000029, 'Valentina', 'Mendoza', 'Castro', '77990123', '1993-07-19', 'F', 'valentina.mendoza@mail.com');
INSERT INTO PERSONA VALUES (1000030, 'Javier', 'Rios', 'Paz', '78001234', '1988-10-11', 'M', 'javier.rios@mail.com');
INSERT INTO PERSONA VALUES (1000031, 'Isabella', 'Flores', 'Nuniez', '78012345', '1996-01-28', 'F', 'isabella.flores@mail.com');
INSERT INTO PERSONA VALUES (1000032, 'Mateo', 'Ortiz', 'Vega', '78023456', '1984-05-16', 'M', 'mateo.ortiz@mail.com');
INSERT INTO PERSONA VALUES (1000033, 'Sofia', 'Silva', 'Cruz', '78034567', '1990-08-09', 'F', 'sofia.silva@mail.com');
INSERT INTO PERSONA VALUES (1000034, 'Sebastian', 'Nuniez', 'Mora', '78045678', '1982-11-23', 'M', 'sebastian.nunez@mail.com');
INSERT INTO PERSONA VALUES (1000035, 'Mariana', 'Paz', 'Ramos', '78056789', '1995-04-02', 'F', 'mariana.paz@mail.com');
INSERT INTO PERSONA VALUES (1000036, 'Daniel', 'Suarez', 'Soto', '78067890', '1987-07-15', 'M', 'daniel.suarez@mail.com');
INSERT INTO PERSONA VALUES (1000037, 'Alejandra', 'Leon', 'Campos', '78078901', '1993-09-27', 'F', 'alejandra.leon@mail.com');
INSERT INTO PERSONA VALUES (1000038, 'Emilio', 'Paredes', 'Torrez', '78089012', '1981-12-10', 'M', 'emilio.paredes@mail.com');
INSERT INTO PERSONA VALUES (1000039, 'Renata', 'Rios', 'Gutierrez', '78090123', '1997-02-21', 'F', 'renata.rios@mail.com');
INSERT INTO PERSONA VALUES (1000040, 'Tomas', 'Morales', 'Jimenez', '78101234', '1986-06-04', 'M', 'tomas.morales@mail.com');
INSERT INTO PERSONA VALUES (1000041, 'Julieta', 'Vargas', 'Rojas', '78112345', '1992-08-18', 'F', 'julieta.vargas@mail.com');
INSERT INTO PERSONA VALUES (1000042, 'Martin', 'Castro', 'Mendoza', '78123456', '1989-11-01', 'M', 'martin.castro@mail.com');
INSERT INTO PERSONA VALUES (1000043, 'Florencia', 'Rojas', 'Silva', '78134567', '1994-01-14', 'F', 'florencia.rojas@mail.com');
INSERT INTO PERSONA VALUES (1000044, 'Nicolas', 'Gomez', 'Torres', '78145678', '1983-03-26', 'M', 'nicolas.gomez@mail.com');
INSERT INTO PERSONA VALUES (1000045, 'Antonella', 'Perez', 'Lopez', '78156789', '1996-05-08', 'F', 'antonella.perez@mail.com');
INSERT INTO PERSONA VALUES (1000046, 'Facundo', 'Suarez', 'Herrera', '78167890', '1985-07-20', 'M', 'facundo.suarez@mail.com');
INSERT INTO PERSONA VALUES (1000047, 'Micaela', 'Mendoza', 'Castro', '78178901', '1991-10-03', 'F', 'micaela.mendoza@mail.com');
INSERT INTO PERSONA VALUES (1000048, 'Ramiro', 'Rios', 'Paz', '78189012', '1988-12-16', 'M', 'ramiro.rios@mail.com');
INSERT INTO PERSONA VALUES (1000049, 'Agustina', 'Flores', 'Nuniez', '78190123', '1993-02-28', 'F', 'agustina.flores@mail.com');
INSERT INTO PERSONA VALUES (1000050, 'Gonzalo', 'Ortiz', 'Vega', '78201234', '1984-04-12', 'M', 'gonzalo.ortiz@mail.com');

-- EXPOSITOR (25: ci 1000001 - 1000025)
INSERT INTO EXPOSITOR VALUES (1000001, 'Nacional', 'Tecnologia', 'Universidad Tecnica');
INSERT INTO EXPOSITOR VALUES (1000002, 'Internacional', 'Arte', 'Galeria de Arte Moderno');
INSERT INTO EXPOSITOR VALUES (1000003, 'Local', 'Ciencia', 'Instituto de Investigacion');
INSERT INTO EXPOSITOR VALUES (1000004, 'Nacional', 'Cultura', 'Ministerio de Cultura');
INSERT INTO EXPOSITOR VALUES (1000005, 'Internacional', 'Gastronomia', 'Escuela Culinaria');
INSERT INTO EXPOSITOR VALUES (1000006, 'Local', 'Tecnologia', 'Startup Innovadora');
INSERT INTO EXPOSITOR VALUES (1000007, 'Nacional', 'Deportes', 'Liga Deportiva');
INSERT INTO EXPOSITOR VALUES (1000008, 'Internacional', 'Musica', 'Conservatorio Nacional');
INSERT INTO EXPOSITOR VALUES (1000009, 'Local', 'Salud', 'Hospital Universitario');
INSERT INTO EXPOSITOR VALUES (1000010, 'Nacional', 'Educacion', 'Universidad Pedagogica');
INSERT INTO EXPOSITOR VALUES (1000011, 'Internacional', 'Negocios', 'Camara de Comercio');
INSERT INTO EXPOSITOR VALUES (1000012, 'Local', 'Literatura', 'Biblioteca Municipal');
INSERT INTO EXPOSITOR VALUES (1000013, 'Nacional', 'Cine', 'Film Commission');
INSERT INTO EXPOSITOR VALUES (1000014, 'Internacional', 'Fotografia', 'Agencia Fotografica');
INSERT INTO EXPOSITOR VALUES (1000015, 'Local', 'Artesania', 'Asociacion de Artesanos');
INSERT INTO EXPOSITOR VALUES (1000016, 'Nacional', 'Medio Ambiente', 'ONG Ecologica');
INSERT INTO EXPOSITOR VALUES (1000017, 'Internacional', 'Turismo', 'Agencia de Viajes');
INSERT INTO EXPOSITOR VALUES (1000018, 'Local', 'Historia', 'Museo Nacional');
INSERT INTO EXPOSITOR VALUES (1000019, 'Nacional', 'Idiomas', 'Centro de Idiomas');
INSERT INTO EXPOSITOR VALUES (1000020, 'Internacional', 'Videojuegos', 'Estudio de Videojuegos');
INSERT INTO EXPOSITOR VALUES (1000021, 'Local', 'Tecnologia', 'Laboratorio de Innovacion');
INSERT INTO EXPOSITOR VALUES (1000022, 'Nacional', 'Arte', 'Escuela de Bellas Artes');
INSERT INTO EXPOSITOR VALUES (1000023, 'Internacional', 'Ciencia', 'Centro de Investigacion');
INSERT INTO EXPOSITOR VALUES (1000024, 'Local', 'Cultura', 'Casa de la Cultura');
INSERT INTO EXPOSITOR VALUES (1000025, 'Nacional', 'Gastronomia', 'Instituto Culinario');

-- COMERCIANTE (25: ci 1000026 - 1000050, NO se repiten con expositores)
INSERT INTO COMERCIANTE VALUES (1000026, 'NIT1000026', 'Alimentos', 'LIC000026');
INSERT INTO COMERCIANTE VALUES (1000027, 'NIT1000027', 'Ropa', 'LIC000027');
INSERT INTO COMERCIANTE VALUES (1000028, 'NIT1000028', 'Artesanias', 'LIC000028');
INSERT INTO COMERCIANTE VALUES (1000029, 'NIT1000029', 'Electronica', 'LIC000029');
INSERT INTO COMERCIANTE VALUES (1000030, 'NIT1000030', 'Alimentos', 'LIC000030');
INSERT INTO COMERCIANTE VALUES (1000031, 'NIT1000031', 'Ropa', 'LIC000031');
INSERT INTO COMERCIANTE VALUES (1000032, 'NIT1000032', 'Artesanias', 'LIC000032');
INSERT INTO COMERCIANTE VALUES (1000033, 'NIT1000033', 'Electronica', 'LIC000033');
INSERT INTO COMERCIANTE VALUES (1000034, 'NIT1000034', 'Alimentos', 'LIC000034');
INSERT INTO COMERCIANTE VALUES (1000035, 'NIT1000035', 'Ropa', 'LIC000035');
INSERT INTO COMERCIANTE VALUES (1000036, 'NIT1000036', 'Artesanias', 'LIC000036');
INSERT INTO COMERCIANTE VALUES (1000037, 'NIT1000037', 'Electronica', 'LIC000037');
INSERT INTO COMERCIANTE VALUES (1000038, 'NIT1000038', 'Alimentos', 'LIC000038');
INSERT INTO COMERCIANTE VALUES (1000039, 'NIT1000039', 'Ropa', 'LIC000039');
INSERT INTO COMERCIANTE VALUES (1000040, 'NIT1000040', 'Artesanias', 'LIC000040');
INSERT INTO COMERCIANTE VALUES (1000041, 'NIT1000041', 'Electronica', 'LIC000041');
INSERT INTO COMERCIANTE VALUES (1000042, 'NIT1000042', 'Alimentos', 'LIC000042');
INSERT INTO COMERCIANTE VALUES (1000043, 'NIT1000043', 'Ropa', 'LIC000043');
INSERT INTO COMERCIANTE VALUES (1000044, 'NIT1000044', 'Artesanias', 'LIC000044');
INSERT INTO COMERCIANTE VALUES (1000045, 'NIT1000045', 'Electronica', 'LIC000045');
INSERT INTO COMERCIANTE VALUES (1000046, 'NIT1000046', 'Alimentos', 'LIC000046');
INSERT INTO COMERCIANTE VALUES (1000047, 'NIT1000047', 'Ropa', 'LIC000047');
INSERT INTO COMERCIANTE VALUES (1000048, 'NIT1000048', 'Artesanias', 'LIC000048');
INSERT INTO COMERCIANTE VALUES (1000049, 'NIT1000049', 'Electronica', 'LIC000049');
INSERT INTO COMERCIANTE VALUES (1000050, 'NIT1000050', 'Alimentos', 'LIC000050');


-- RESPONSABLE (25: mezcla de expositores, comerciantes y algunos nuevos)
INSERT INTO RESPONSABLE VALUES (1000001, 'Coordinador', '2020-06-01');
INSERT INTO RESPONSABLE VALUES (1000002, 'Supervisor', '2021-07-15');
INSERT INTO RESPONSABLE VALUES (1000003, 'Jefe de Area', '2019-08-20');
INSERT INTO RESPONSABLE VALUES (1000004, 'Administrador', '2022-09-10');
INSERT INTO RESPONSABLE VALUES (1000005, 'Coordinador', '2020-10-05');
INSERT INTO RESPONSABLE VALUES (1000006, 'Supervisor', '2021-11-12');
INSERT INTO RESPONSABLE VALUES (1000007, 'Jefe de Area', '2019-12-18');
INSERT INTO RESPONSABLE VALUES (1000008, 'Administrador', '2023-01-22');
INSERT INTO RESPONSABLE VALUES (1000009, 'Coordinador', '2020-02-14');
INSERT INTO RESPONSABLE VALUES (1000010, 'Supervisor', '2021-03-16');
INSERT INTO RESPONSABLE VALUES (1000026, 'Jefe de Area', '2019-04-25');
INSERT INTO RESPONSABLE VALUES (1000027, 'Administrador', '2022-05-08');
INSERT INTO RESPONSABLE VALUES (1000028, 'Coordinador', '2020-06-19');
INSERT INTO RESPONSABLE VALUES (1000029, 'Supervisor', '2021-07-27');
INSERT INTO RESPONSABLE VALUES (1000030, 'Jefe de Area', '2019-08-30');
INSERT INTO RESPONSABLE VALUES (1000031, 'Administrador', '2022-09-11');
INSERT INTO RESPONSABLE VALUES (1000032, 'Coordinador', '2020-10-23');
INSERT INTO RESPONSABLE VALUES (1000033, 'Supervisor', '2021-11-06');
INSERT INTO RESPONSABLE VALUES (1000034, 'Jefe de Area', '2019-12-15');
INSERT INTO RESPONSABLE VALUES (1000035, 'Administrador', '2023-01-29');
INSERT INTO RESPONSABLE VALUES (1000036, 'Coordinador', '2020-02-10');
INSERT INTO RESPONSABLE VALUES (1000037, 'Supervisor', '2021-03-22');
INSERT INTO RESPONSABLE VALUES (1000038, 'Jefe de Area', '2019-05-05');
INSERT INTO RESPONSABLE VALUES (1000039, 'Administrador', '2022-06-18');
INSERT INTO RESPONSABLE VALUES (1000040, 'Coordinador', '2020-07-30');
-- =========================================================
-- 11. PUESTO (30 tuplas)
-- =========================================================
-- FERIA 1: Tecnología (Puestos 1-3)
INSERT INTO PUESTO VALUES (1, 101, 'Grande', 1000001);
INSERT INTO PUESTO VALUES (2, 102, 'Mediano', 1000002);
INSERT INTO PUESTO VALUES (3, 103, 'Pequenio', 1000003);

-- FERIA 2: Gastronomía (Puestos 4-6)
INSERT INTO PUESTO VALUES (4, 104, 'Grande', 1000004);
INSERT INTO PUESTO VALUES (5, 105, 'Mediano', 1000005);
INSERT INTO PUESTO VALUES (6, 106, 'Pequenio', 1000006);

-- FERIA 3: Arte (Puestos 7-9)
INSERT INTO PUESTO VALUES (7, 107, 'Grande', 1000007);
INSERT INTO PUESTO VALUES (8, 108, 'Mediano', 1000008);
INSERT INTO PUESTO VALUES (9, 109, 'Pequenio', 1000009);

-- FERIA 4: Música (Puestos 10-12)
INSERT INTO PUESTO VALUES (10, 110, 'Grande', 1000010);
INSERT INTO PUESTO VALUES (11, 111, 'Mediano', 1000026);
INSERT INTO PUESTO VALUES (12, 112, 'Pequenio', 1000027);

-- FERIA 5: Deportes (Puestos 13-15)
INSERT INTO PUESTO VALUES (13, 113, 'Grande', 1000028);
INSERT INTO PUESTO VALUES (14, 114, 'Mediano', 1000029);
INSERT INTO PUESTO VALUES (15, 115, 'Pequenio', 1000030);

-- FERIA 6: Educación (Puestos 16-18)
INSERT INTO PUESTO VALUES (16, 116, 'Grande', 1000031);
INSERT INTO PUESTO VALUES (17, 117, 'Mediano', 1000032);
INSERT INTO PUESTO VALUES (18, 118, 'Pequenio', 1000033);

-- FERIA 7: Salud (Puestos 19-21)
INSERT INTO PUESTO VALUES (19, 119, 'Grande', 1000034);
INSERT INTO PUESTO VALUES (20, 120, 'Mediano', 1000035);
INSERT INTO PUESTO VALUES (21, 121, 'Pequenio', 1000036);

-- FERIA 8: Cultura (Puestos 22-24)
INSERT INTO PUESTO VALUES (22, 122, 'Grande', 1000037);
INSERT INTO PUESTO VALUES (23, 123, 'Mediano', 1000038);
INSERT INTO PUESTO VALUES (24, 124, 'Pequenio', 1000039);

-- FERIA 9: Moda (Puestos 25-27)
INSERT INTO PUESTO VALUES (25, 125, 'Grande', 1000040);
INSERT INTO PUESTO VALUES (26, 126, 'Mediano', 1000001);
INSERT INTO PUESTO VALUES (27, 127, 'Pequenio', 1000002);

-- FERIA 10: Ciencia (Puestos 28-30)
INSERT INTO PUESTO VALUES (28, 128, 'Grande', 1000003);
INSERT INTO PUESTO VALUES (29, 129, 'Mediano', 1000004);
INSERT INTO PUESTO VALUES (30, 130, 'Pequenio', 1000005);

-- Puestos adicionales (responsables que se repiten: 1000006, 1000007 y 1000026)
INSERT INTO PUESTO VALUES (31, 131, 'Grande', 1000006);
INSERT INTO PUESTO VALUES (32, 132, 'Mediano', 1000026);
INSERT INTO PUESTO VALUES (33, 133, 'Pequenio', 1000007);
INSERT INTO PUESTO VALUES (34, 134, 'Mediano', 1000026);

-- =========================================================
-- 12. SE_REALIZA_EN (cada feria en 1 a 4 ubicaciones y cada ubicacion con varias ferias, sin cruce de fechas)
-- =========================================================
INSERT INTO SE_REALIZA_EN VALUES (1, 1, '2024-03-01', '2024-03-05');
INSERT INTO SE_REALIZA_EN VALUES (2, 2, '2024-03-10', '2024-03-14');
INSERT INTO SE_REALIZA_EN VALUES (3, 3, '2024-03-20', '2024-03-25');
INSERT INTO SE_REALIZA_EN VALUES (3, 7, '2024-03-26', '2024-03-30');
INSERT INTO SE_REALIZA_EN VALUES (4, 4, '2024-04-01', '2024-04-07');
INSERT INTO SE_REALIZA_EN VALUES (5, 5, '2024-04-15', '2024-04-20');
INSERT INTO SE_REALIZA_EN VALUES (6, 6, '2024-05-01', '2024-05-05');
INSERT INTO SE_REALIZA_EN VALUES (7, 7, '2024-05-10', '2024-05-15');
INSERT INTO SE_REALIZA_EN VALUES (8, 8, '2024-05-20', '2024-05-25');
INSERT INTO SE_REALIZA_EN VALUES (9, 9, '2024-06-01', '2024-06-07');
INSERT INTO SE_REALIZA_EN VALUES (10, 10, '2024-06-15', '2024-06-20');

-- Ubicaciones adicionales por feria (N:M)
INSERT INTO SE_REALIZA_EN VALUES (2, 3, '2024-03-16', '2024-03-18');
INSERT INTO SE_REALIZA_EN VALUES (4, 9, '2024-04-10', '2024-04-14');
INSERT INTO SE_REALIZA_EN VALUES (4, 3, '2024-04-20', '2024-04-23');
INSERT INTO SE_REALIZA_EN VALUES (5, 4, '2024-04-22', '2024-04-27');
INSERT INTO SE_REALIZA_EN VALUES (6, 2, '2024-05-08', '2024-05-10');
INSERT INTO SE_REALIZA_EN VALUES (7, 2, '2024-05-18', '2024-05-19');
INSERT INTO SE_REALIZA_EN VALUES (7, 10, '2024-05-22', '2024-05-24');
INSERT INTO SE_REALIZA_EN VALUES (8, 10, '2024-05-28', '2024-05-31');
INSERT INTO SE_REALIZA_EN VALUES (8, 5, '2024-06-05', '2024-06-08');
INSERT INTO SE_REALIZA_EN VALUES (8, 9, '2024-06-12', '2024-06-14');
INSERT INTO SE_REALIZA_EN VALUES (9, 3, '2024-06-10', '2024-06-15');
INSERT INTO SE_REALIZA_EN VALUES (11, 3, '2024-07-01', '2024-07-05');
INSERT INTO SE_REALIZA_EN VALUES (11, 7, '2024-07-08', '2024-07-12');
INSERT INTO SE_REALIZA_EN VALUES (12, 1, '2024-07-15', '2024-07-19');
INSERT INTO SE_REALIZA_EN VALUES (12, 6, '2024-07-22', '2024-07-26');
INSERT INTO SE_REALIZA_EN VALUES (12, 8, '2024-07-29', '2024-07-31');
INSERT INTO SE_REALIZA_EN VALUES (13, 5, '2024-08-01', '2024-08-04');
INSERT INTO SE_REALIZA_EN VALUES (13, 2, '2024-08-08', '2024-08-11');
INSERT INTO SE_REALIZA_EN VALUES (14, 5, '2024-08-15', '2024-08-18');
INSERT INTO SE_REALIZA_EN VALUES (14, 10, '2024-08-22', '2024-08-25');

-- =========================================================
-- 13. INCLUYE (1 a 4 servicios por cada combinacion feria-ubicacion de SE_REALIZA_EN)
-- =========================================================
-- FERIA 1 (Ubic. 1): Seguridad, Limpieza, WiFi
INSERT INTO INCLUYE VALUES (1, 1, 1, 500.00);
INSERT INTO INCLUYE VALUES (1, 1, 2, 300.00);
INSERT INTO INCLUYE VALUES (1, 1, 6, 200.00);

-- FERIA 2 (Ubic. 2): Catering, Limpieza, Estacionamiento
INSERT INTO INCLUYE VALUES (2, 2, 3, 800.00);
INSERT INTO INCLUYE VALUES (2, 2, 2, 300.00);
INSERT INTO INCLUYE VALUES (2, 2, 7, 400.00);

-- FERIA 3 (Ubic. 3): Sonido, Iluminación, Fotografía
INSERT INTO INCLUYE VALUES (3, 3, 4, 600.00);
INSERT INTO INCLUYE VALUES (3, 3, 5, 550.00);
INSERT INTO INCLUYE VALUES (3, 3, 12, 700.00);

-- FERIA 3 (Ubic. 7): Seguridad, Limpieza, Catering
INSERT INTO INCLUYE VALUES (3, 7, 1, 500.00);
INSERT INTO INCLUYE VALUES (3, 7, 2, 300.00);
INSERT INTO INCLUYE VALUES (3, 7, 3, 800.00);

-- FERIA 4 (Ubic. 4): Sonido, Iluminación, Transmisión
INSERT INTO INCLUYE VALUES (4, 4, 4, 600.00);
INSERT INTO INCLUYE VALUES (4, 4, 5, 550.00);
INSERT INTO INCLUYE VALUES (4, 4, 13, 750.00);

-- FERIA 5 (Ubic. 5): Primeros Auxilios, Seguridad, Estacionamiento
INSERT INTO INCLUYE VALUES (5, 5, 8, 450.00);
INSERT INTO INCLUYE VALUES (5, 5, 1, 500.00);
INSERT INTO INCLUYE VALUES (5, 5, 7, 400.00);

-- FERIA 6 (Ubic. 6): WiFi, Audio Guías, Traducción
INSERT INTO INCLUYE VALUES (6, 6, 6, 200.00);
INSERT INTO INCLUYE VALUES (6, 6, 18, 350.00);
INSERT INTO INCLUYE VALUES (6, 6, 14, 400.00);

-- FERIA 7 (Ubic. 7): Primeros Auxilios, Ambulancia, Limpieza
INSERT INTO INCLUYE VALUES (7, 7, 8, 450.00);
INSERT INTO INCLUYE VALUES (7, 7, 21, 900.00);
INSERT INTO INCLUYE VALUES (7, 7, 2, 300.00);

-- FERIA 8 (Ubic. 8): Decoración, Fotografía, Sonido
INSERT INTO INCLUYE VALUES (8, 8, 11, 500.00);
INSERT INTO INCLUYE VALUES (8, 8, 12, 700.00);
INSERT INTO INCLUYE VALUES (8, 8, 4, 600.00);

-- FERIA 9 (Ubic. 9): Iluminación, Sonido, Zona VIP
INSERT INTO INCLUYE VALUES (9, 9, 5, 550.00);
INSERT INTO INCLUYE VALUES (9, 9, 4, 600.00);
INSERT INTO INCLUYE VALUES (9, 9, 17, 650.00);

-- FERIA 10 (Ubic. 10): WiFi, Pantallas LED, Audio Guías
INSERT INTO INCLUYE VALUES (10, 10, 6, 200.00);
INSERT INTO INCLUYE VALUES (10, 10, 25, 800.00);
INSERT INTO INCLUYE VALUES (10, 10, 18, 350.00);

-- Servicios de las combinaciones adicionales
-- FERIA 2 / UBIC. 3
INSERT INTO INCLUYE VALUES (2, 3, 3, 800.00);
INSERT INTO INCLUYE VALUES (2, 3, 2, 300.00);
INSERT INTO INCLUYE VALUES (2, 3, 16, 350.00);
-- FERIA 4 / UBIC. 9
INSERT INTO INCLUYE VALUES (4, 9, 4, 600.00);
INSERT INTO INCLUYE VALUES (4, 9, 5, 550.00);
INSERT INTO INCLUYE VALUES (4, 9, 24, 450.00);
-- FERIA 4 / UBIC. 3
INSERT INTO INCLUYE VALUES (4, 3, 4, 600.00);
INSERT INTO INCLUYE VALUES (4, 3, 8, 450.00);
-- FERIA 5 / UBIC. 4
INSERT INTO INCLUYE VALUES (5, 4, 8, 450.00);
INSERT INTO INCLUYE VALUES (5, 4, 1, 500.00);
INSERT INTO INCLUYE VALUES (5, 4, 22, 600.00);
-- FERIA 6 / UBIC. 2
INSERT INTO INCLUYE VALUES (6, 2, 6, 200.00);
INSERT INTO INCLUYE VALUES (6, 2, 14, 400.00);
INSERT INTO INCLUYE VALUES (6, 2, 28, 100.00);
-- FERIA 7 / UBIC. 2
INSERT INTO INCLUYE VALUES (7, 2, 8, 450.00);
INSERT INTO INCLUYE VALUES (7, 2, 21, 900.00);
INSERT INTO INCLUYE VALUES (7, 2, 19, 250.00);
-- FERIA 7 / UBIC. 10
INSERT INTO INCLUYE VALUES (7, 10, 8, 450.00);
-- FERIA 8 / UBIC. 10
INSERT INTO INCLUYE VALUES (8, 10, 11, 500.00);
INSERT INTO INCLUYE VALUES (8, 10, 12, 700.00);
INSERT INTO INCLUYE VALUES (8, 10, 9, 150.00);
INSERT INTO INCLUYE VALUES (8, 10, 10, 150.00);
-- FERIA 8 / UBIC. 5
INSERT INTO INCLUYE VALUES (8, 5, 4, 600.00);
INSERT INTO INCLUYE VALUES (8, 5, 11, 500.00);
-- FERIA 8 / UBIC. 9
INSERT INTO INCLUYE VALUES (8, 9, 11, 500.00);
INSERT INTO INCLUYE VALUES (8, 9, 12, 700.00);
INSERT INTO INCLUYE VALUES (8, 9, 1, 500.00);
-- FERIA 9 / UBIC. 3
INSERT INTO INCLUYE VALUES (9, 3, 5, 550.00);
INSERT INTO INCLUYE VALUES (9, 3, 17, 650.00);
INSERT INTO INCLUYE VALUES (9, 3, 12, 700.00);
-- FERIA 11 / UBIC. 3
INSERT INTO INCLUYE VALUES (11, 3, 11, 500.00);
INSERT INTO INCLUYE VALUES (11, 3, 12, 700.00);
INSERT INTO INCLUYE VALUES (11, 3, 1, 500.00);
-- FERIA 11 / UBIC. 7
INSERT INTO INCLUYE VALUES (11, 7, 1, 500.00);
INSERT INTO INCLUYE VALUES (11, 7, 9, 150.00);
-- FERIA 12 / UBIC. 1
INSERT INTO INCLUYE VALUES (12, 1, 6, 200.00);
INSERT INTO INCLUYE VALUES (12, 1, 29, 100.00);
INSERT INTO INCLUYE VALUES (12, 1, 13, 750.00);
-- FERIA 12 / UBIC. 6
INSERT INTO INCLUYE VALUES (12, 6, 6, 200.00);
INSERT INTO INCLUYE VALUES (12, 6, 25, 800.00);
-- FERIA 12 / UBIC. 8
INSERT INTO INCLUYE VALUES (12, 8, 6, 200.00);
INSERT INTO INCLUYE VALUES (12, 8, 25, 800.00);
INSERT INTO INCLUYE VALUES (12, 8, 18, 350.00);
INSERT INTO INCLUYE VALUES (12, 8, 29, 100.00);
-- FERIA 13 / UBIC. 5
INSERT INTO INCLUYE VALUES (13, 5, 3, 800.00);
INSERT INTO INCLUYE VALUES (13, 5, 26, 700.00);
INSERT INTO INCLUYE VALUES (13, 5, 27, 650.00);
-- FERIA 13 / UBIC. 2
INSERT INTO INCLUYE VALUES (13, 2, 3, 800.00);
INSERT INTO INCLUYE VALUES (13, 2, 16, 350.00);
INSERT INTO INCLUYE VALUES (13, 2, 2, 300.00);
-- FERIA 14 / UBIC. 5
INSERT INTO INCLUYE VALUES (14, 5, 1, 500.00);
INSERT INTO INCLUYE VALUES (14, 5, 2, 300.00);
INSERT INTO INCLUYE VALUES (14, 5, 30, 200.00);
-- FERIA 14 / UBIC. 10
INSERT INTO INCLUYE VALUES (14, 10, 11, 500.00);
INSERT INTO INCLUYE VALUES (14, 10, 12, 700.00);
INSERT INTO INCLUYE VALUES (14, 10, 10, 150.00);

-- =========================================================
-- 14. CONTIENE (1 a 4 puestos por combinacion feria-ubicacion; un mismo puesto aparece en varias combinaciones => N:M)
-- =========================================================
-- FERIA 1 / UBIC. 1: Puestos 1-3
INSERT INTO CONTIENE VALUES (1, 1, 1);
INSERT INTO CONTIENE VALUES (1, 1, 2);
INSERT INTO CONTIENE VALUES (1, 1, 3);

-- FERIA 2 / UBIC. 2: Puestos 4-6
INSERT INTO CONTIENE VALUES (2, 2, 4);
INSERT INTO CONTIENE VALUES (2, 2, 5);
INSERT INTO CONTIENE VALUES (2, 2, 6);

INSERT INTO CONTIENE VALUES (2, 3, 4);
INSERT INTO CONTIENE VALUES (2, 3, 5);
INSERT INTO CONTIENE VALUES (2, 3, 6);

-- FERIA 3 / UBIC. 3: Puestos 7-9
INSERT INTO CONTIENE VALUES (3, 3, 7);
INSERT INTO CONTIENE VALUES (3, 3, 8);
INSERT INTO CONTIENE VALUES (3, 3, 9);

-- FERIA 4 / UBIC. 4: Puestos 10-12
INSERT INTO CONTIENE VALUES (4, 4, 10);
INSERT INTO CONTIENE VALUES (4, 4, 11);
INSERT INTO CONTIENE VALUES (4, 4, 12);

-- FERIA 5 / UBIC. 5: Puestos 13-15
INSERT INTO CONTIENE VALUES (5, 5, 13);
INSERT INTO CONTIENE VALUES (5, 5, 14);
INSERT INTO CONTIENE VALUES (5, 5, 15);

-- FERIA 6 / UBIC. 6: Puestos 16-18
INSERT INTO CONTIENE VALUES (6, 6, 16);
INSERT INTO CONTIENE VALUES (6, 6, 17);
INSERT INTO CONTIENE VALUES (6, 6, 18);

-- FERIA 7 / UBIC. 7: Puestos 19-21
INSERT INTO CONTIENE VALUES (7, 7, 19);
INSERT INTO CONTIENE VALUES (7, 7, 20);
INSERT INTO CONTIENE VALUES (7, 7, 21);

-- FERIA 8 / UBIC. 8: Puestos 22-24
INSERT INTO CONTIENE VALUES (8, 8, 22);
INSERT INTO CONTIENE VALUES (8, 8, 23);
INSERT INTO CONTIENE VALUES (8, 8, 24);

-- FERIA 9 / UBIC. 9: Puestos 25-27
INSERT INTO CONTIENE VALUES (9, 9, 25);
INSERT INTO CONTIENE VALUES (9, 9, 26);
INSERT INTO CONTIENE VALUES (9, 9, 27);

-- FERIA 10 / UBIC. 10: Puestos 28-30
INSERT INTO CONTIENE VALUES (10, 10, 28);
INSERT INTO CONTIENE VALUES (10, 10, 29);
INSERT INTO CONTIENE VALUES (10, 10, 30);

-- Los puestos de una feria se trasladan con ella a sus otras ubicaciones, y algunos se reutilizan en otras ferias
-- FERIA 2 / UBIC. 3
INSERT INTO CONTIENE VALUES (2, 3, 32);
-- FERIA 3 / UBIC. 7
INSERT INTO CONTIENE VALUES (3, 7, 7);
INSERT INTO CONTIENE VALUES (3, 7, 8);
-- FERIA 4 / UBIC. 9
INSERT INTO CONTIENE VALUES (4, 9, 10);
INSERT INTO CONTIENE VALUES (4, 9, 11);
INSERT INTO CONTIENE VALUES (4, 9, 12);
-- FERIA 4 / UBIC. 3
INSERT INTO CONTIENE VALUES (4, 3, 10);
INSERT INTO CONTIENE VALUES (4, 3, 11);
-- FERIA 5 / UBIC. 4
INSERT INTO CONTIENE VALUES (5, 4, 13);
INSERT INTO CONTIENE VALUES (5, 4, 14);
INSERT INTO CONTIENE VALUES (5, 4, 15);
-- FERIA 6 / UBIC. 2
INSERT INTO CONTIENE VALUES (6, 2, 16);
-- FERIA 7 / UBIC. 2
INSERT INTO CONTIENE VALUES (7, 2, 19);
INSERT INTO CONTIENE VALUES (7, 2, 20);
INSERT INTO CONTIENE VALUES (7, 2, 21);
-- FERIA 7 / UBIC. 10
INSERT INTO CONTIENE VALUES (7, 10, 19);
INSERT INTO CONTIENE VALUES (7, 10, 20);
INSERT INTO CONTIENE VALUES (7, 10, 21);
-- FERIA 8 / UBIC. 10
INSERT INTO CONTIENE VALUES (8, 10, 22);
INSERT INTO CONTIENE VALUES (8, 10, 23);
INSERT INTO CONTIENE VALUES (8, 10, 24);
-- FERIA 8 / UBIC. 5
INSERT INTO CONTIENE VALUES (8, 5, 22);
INSERT INTO CONTIENE VALUES (8, 5, 23);
INSERT INTO CONTIENE VALUES (8, 5, 24);
-- FERIA 8 / UBIC. 9
INSERT INTO CONTIENE VALUES (8, 9, 22);
INSERT INTO CONTIENE VALUES (8, 9, 23);
-- FERIA 9 / UBIC. 3
INSERT INTO CONTIENE VALUES (9, 3, 25);
INSERT INTO CONTIENE VALUES (9, 3, 26);
INSERT INTO CONTIENE VALUES (9, 3, 27);
-- FERIA 11 / UBIC. 3
INSERT INTO CONTIENE VALUES (11, 3, 7);
INSERT INTO CONTIENE VALUES (11, 3, 8);
INSERT INTO CONTIENE VALUES (11, 3, 9);
-- FERIA 11 / UBIC. 7
INSERT INTO CONTIENE VALUES (11, 7, 7);
INSERT INTO CONTIENE VALUES (11, 7, 9);
-- FERIA 12 / UBIC. 1
INSERT INTO CONTIENE VALUES (12, 1, 1);
INSERT INTO CONTIENE VALUES (12, 1, 2);
INSERT INTO CONTIENE VALUES (12, 1, 3);
-- FERIA 12 / UBIC. 6
INSERT INTO CONTIENE VALUES (12, 6, 1);
INSERT INTO CONTIENE VALUES (12, 6, 2);
INSERT INTO CONTIENE VALUES (12, 6, 31);
-- FERIA 12 / UBIC. 8
INSERT INTO CONTIENE VALUES (12, 8, 1);
INSERT INTO CONTIENE VALUES (12, 8, 31);
-- FERIA 13 / UBIC. 5
INSERT INTO CONTIENE VALUES (13, 5, 4);
INSERT INTO CONTIENE VALUES (13, 5, 5);
INSERT INTO CONTIENE VALUES (13, 5, 6);
-- FERIA 13 / UBIC. 2
INSERT INTO CONTIENE VALUES (13, 2, 4);
INSERT INTO CONTIENE VALUES (13, 2, 5);
INSERT INTO CONTIENE VALUES (13, 2, 32);
-- FERIA 14 / UBIC. 5
INSERT INTO CONTIENE VALUES (14, 5, 24);
INSERT INTO CONTIENE VALUES (14, 5, 33);
INSERT INTO CONTIENE VALUES (14, 5, 34);
-- FERIA 14 / UBIC. 10
INSERT INTO CONTIENE VALUES (14, 10, 24);
INSERT INTO CONTIENE VALUES (14, 10, 33);

-- =========================================================
-- 15. FERIA_TEMATICA (ferias con 1 a 3 temáticas)
-- =========================================================
-- Feria 1: Tecnología
INSERT INTO FERIA_TEMATICA VALUES (1, 1);

-- Feria 2: Gastronomía
INSERT INTO FERIA_TEMATICA VALUES (2, 2);

-- Feria 3: Arte + Música + Cultura (3 temáticas)
INSERT INTO FERIA_TEMATICA VALUES (3, 3);
INSERT INTO FERIA_TEMATICA VALUES (3, 4);
INSERT INTO FERIA_TEMATICA VALUES (3, 8);

-- Feria 4: Música + Cultura (2 temáticas)
INSERT INTO FERIA_TEMATICA VALUES (4, 4);
INSERT INTO FERIA_TEMATICA VALUES (4, 8);

-- Feria 5: Deportes
INSERT INTO FERIA_TEMATICA VALUES (5, 5);

-- Feria 6: Educación
INSERT INTO FERIA_TEMATICA VALUES (6, 6);

-- Feria 7: Salud
INSERT INTO FERIA_TEMATICA VALUES (7, 7);

-- Feria 8: Cultura
INSERT INTO FERIA_TEMATICA VALUES (8, 8);

-- Feria 9: Arte + Tecnología (2 temáticas)
INSERT INTO FERIA_TEMATICA VALUES (9, 3);
INSERT INTO FERIA_TEMATICA VALUES (9, 1);

-- Feria 10: Tecnología + Educación (2 temáticas)
INSERT INTO FERIA_TEMATICA VALUES (10, 1);
INSERT INTO FERIA_TEMATICA VALUES (10, 6);
-- Ferias 11 a 14
INSERT INTO FERIA_TEMATICA VALUES (11, 3);
INSERT INTO FERIA_TEMATICA VALUES (11, 8);
INSERT INTO FERIA_TEMATICA VALUES (12, 1);
INSERT INTO FERIA_TEMATICA VALUES (12, 6);
INSERT INTO FERIA_TEMATICA VALUES (13, 2);
INSERT INTO FERIA_TEMATICA VALUES (13, 8);
INSERT INTO FERIA_TEMATICA VALUES (14, 3);
INSERT INTO FERIA_TEMATICA VALUES (14, 8);

-- =========================================================
-- 16. PRESENTA (puestos de exposición)
-- Regla: Los puestos 1, 2, 7, 8, 9, 16, 17, 22, 23, 28, 29 son de EXPOSICIÓN
-- =========================================================
INSERT INTO PRESENTA VALUES (1, 1);
INSERT INTO PRESENTA VALUES (1, 3);
INSERT INTO PRESENTA VALUES (2, 27);
INSERT INTO PRESENTA VALUES (2, 26);
INSERT INTO PRESENTA VALUES (2, 23);
INSERT INTO PRESENTA VALUES (2, 9);
INSERT INTO PRESENTA VALUES (7, 3);
INSERT INTO PRESENTA VALUES (8, 14);
INSERT INTO PRESENTA VALUES (8, 23);
INSERT INTO PRESENTA VALUES (9, 15);
INSERT INTO PRESENTA VALUES (16, 6);
INSERT INTO PRESENTA VALUES (17, 28);
INSERT INTO PRESENTA VALUES (22, 22);
INSERT INTO PRESENTA VALUES (22, 14);
INSERT INTO PRESENTA VALUES (22, 15);
INSERT INTO PRESENTA VALUES (23, 23);   
INSERT INTO PRESENTA VALUES (28, 26);

-- Presentaciones adicionales
INSERT INTO PRESENTA VALUES (1, 12);
INSERT INTO PRESENTA VALUES (2, 13);
INSERT INTO PRESENTA VALUES (31, 10);
INSERT INTO PRESENTA VALUES (31, 11);
INSERT INTO PRESENTA VALUES (7, 17);
INSERT INTO PRESENTA VALUES (9, 16);
INSERT INTO PRESENTA VALUES (16, 29);
INSERT INTO PRESENTA VALUES (17, 30);

-- =========================================================
-- 17. EXPONE (idExpo, idExpositor) - 3 a 5 expositores por exposición
-- =========================================================
-- Expo 1: Innovación Tecnológica (5 expositores)
INSERT INTO EXPONE VALUES (1, 1000001);
INSERT INTO EXPONE VALUES (1, 1000002);
INSERT INTO EXPONE VALUES (1, 1000003);
INSERT INTO EXPONE VALUES (1, 1000004);
INSERT INTO EXPONE VALUES (1, 1000005);

-- Expo 9: Inteligencia Artificial (4 expositores)
INSERT INTO EXPONE VALUES (9, 1000006);
INSERT INTO EXPONE VALUES (9, 1000007);
INSERT INTO EXPONE VALUES (9, 1000008);
INSERT INTO EXPONE VALUES (9, 1000009);

-- Expo 3: Arte Contemporáneo (5 expositores)
INSERT INTO EXPONE VALUES (3, 1000010);
INSERT INTO EXPONE VALUES (3, 1000011);
INSERT INTO EXPONE VALUES (3, 1000012);
INSERT INTO EXPONE VALUES (3, 1000013);
INSERT INTO EXPONE VALUES (3, 1000014);

-- Expo 14: Pintura Moderna (3 expositores)
INSERT INTO EXPONE VALUES (14, 1000015);
INSERT INTO EXPONE VALUES (14, 1000016);
INSERT INTO EXPONE VALUES (14, 1000017);

-- Expo 15: Escultura en Madera (4 expositores)
INSERT INTO EXPONE VALUES (15, 1000018);
INSERT INTO EXPONE VALUES (15, 1000019);
INSERT INTO EXPONE VALUES (15, 1000020);
INSERT INTO EXPONE VALUES (15, 1000021);

-- Expo 6: Feria Educativa (3 expositores)
INSERT INTO EXPONE VALUES (6, 1000022);
INSERT INTO EXPONE VALUES (6, 1000023);
INSERT INTO EXPONE VALUES (6, 1000024);

-- Expo 28: Emprendimiento Juvenil (4 expositores)
INSERT INTO EXPONE VALUES (28, 1000025);
INSERT INTO EXPONE VALUES (28, 1000001);
INSERT INTO EXPONE VALUES (28, 1000002);
INSERT INTO EXPONE VALUES (28, 1000003);

-- Expo 22: Danzas Folklóricas (3 expositores)
INSERT INTO EXPONE VALUES (22, 1000004);
INSERT INTO EXPONE VALUES (22, 1000005);
INSERT INTO EXPONE VALUES (22, 1000006);

-- Expo 23: Trajes Típicos (5 expositores)
INSERT INTO EXPONE VALUES (23, 1000007);
INSERT INTO EXPONE VALUES (23, 1000008);
INSERT INTO EXPONE VALUES (23, 1000009);
INSERT INTO EXPONE VALUES (23, 1000010);
INSERT INTO EXPONE VALUES (23, 1000011);

-- Expo 26: Astronomía (3 expositores)
INSERT INTO EXPONE VALUES (26, 1000012);
INSERT INTO EXPONE VALUES (26, 1000013);
INSERT INTO EXPONE VALUES (26, 1000014);

-- Expo 27: Química Divertida (4 expositores)
INSERT INTO EXPONE VALUES (27, 1000015);
INSERT INTO EXPONE VALUES (27, 1000016);
INSERT INTO EXPONE VALUES (27, 1000017);
INSERT INTO EXPONE VALUES (27, 1000018);

-- Exposiciones adicionales (el mismo expositor participa en varias exposiciones)
INSERT INTO EXPONE VALUES (10, 1000006);
INSERT INTO EXPONE VALUES (10, 1000021);
INSERT INTO EXPONE VALUES (10, 1000020);
INSERT INTO EXPONE VALUES (11, 1000006);
INSERT INTO EXPONE VALUES (11, 1000020);
INSERT INTO EXPONE VALUES (11, 1000021);
INSERT INTO EXPONE VALUES (12, 1000011);
INSERT INTO EXPONE VALUES (12, 1000021);
INSERT INTO EXPONE VALUES (12, 1000023);
INSERT INTO EXPONE VALUES (13, 1000011);
INSERT INTO EXPONE VALUES (13, 1000006);
INSERT INTO EXPONE VALUES (13, 1000001);
INSERT INTO EXPONE VALUES (16, 1000002);
INSERT INTO EXPONE VALUES (16, 1000014);
INSERT INTO EXPONE VALUES (16, 1000022);
INSERT INTO EXPONE VALUES (17, 1000022);
INSERT INTO EXPONE VALUES (17, 1000002);
INSERT INTO EXPONE VALUES (17, 1000014);
INSERT INTO EXPONE VALUES (19, 1000008);
INSERT INTO EXPONE VALUES (19, 1000004);
INSERT INTO EXPONE VALUES (19, 1000024);
INSERT INTO EXPONE VALUES (20, 1000008);
INSERT INTO EXPONE VALUES (20, 1000013);
INSERT INTO EXPONE VALUES (21, 1000008);
INSERT INTO EXPONE VALUES (21, 1000013);
INSERT INTO EXPONE VALUES (21, 1000019);
INSERT INTO EXPONE VALUES (24, 1000009);
INSERT INTO EXPONE VALUES (24, 1000016);
INSERT INTO EXPONE VALUES (25, 1000009);
INSERT INTO EXPONE VALUES (25, 1000025);
INSERT INTO EXPONE VALUES (29, 1000010);
INSERT INTO EXPONE VALUES (29, 1000011);
INSERT INTO EXPONE VALUES (29, 1000020);
INSERT INTO EXPONE VALUES (30, 1000010);
INSERT INTO EXPONE VALUES (30, 1000011);

-- =========================================================
-- 18. REALIZA_VENTA (idPuesto, idProducto, idComerciante) - mínimo 2-3 productos por puesto de venta
-- Puestos de VENTA: 3, 4, 5, 6, 10, 11, 12, 13, 14, 15, 18, 19, 20, 21, 24, 25, 26, 27, 30
-- =========================================================

-- Puesto 3 (Feria 1 - Tecnología): Productos 1, 2, 3
INSERT INTO REALIZA_VENTA VALUES (3, 1, 1000026);
INSERT INTO REALIZA_VENTA VALUES (3, 2, 1000026);
INSERT INTO REALIZA_VENTA VALUES (3, 3, 1000026);

-- Puesto 4 (Feria 2 - Gastronomía): Productos 11, 12, 13
INSERT INTO REALIZA_VENTA VALUES (4, 11, 1000027);
INSERT INTO REALIZA_VENTA VALUES (4, 12, 1000027);
INSERT INTO REALIZA_VENTA VALUES (4, 13, 1000027);

-- Puesto 5 (Feria 2 - Gastronomía): Productos 14, 15, 16
INSERT INTO REALIZA_VENTA VALUES (5, 14, 1000028);
INSERT INTO REALIZA_VENTA VALUES (5, 15, 1000028);
INSERT INTO REALIZA_VENTA VALUES (5, 16, 1000028);

-- Puesto 6 (Feria 2 - Gastronomía): Productos 17, 18, 19, 20
INSERT INTO REALIZA_VENTA VALUES (6, 17, 1000029);
INSERT INTO REALIZA_VENTA VALUES (6, 18, 1000029);
INSERT INTO REALIZA_VENTA VALUES (6, 19, 1000029);
INSERT INTO REALIZA_VENTA VALUES (6, 20, 1000029);

-- Puesto 10 (Feria 4 - Música): Productos 4, 10
INSERT INTO REALIZA_VENTA VALUES (10, 4, 1000030);
INSERT INTO REALIZA_VENTA VALUES (10, 10, 1000030);

-- Puesto 11 (Feria 4 - Música): Productos 4, 5, 6
INSERT INTO REALIZA_VENTA VALUES (11, 4, 1000031);
INSERT INTO REALIZA_VENTA VALUES (11, 5, 1000031);
INSERT INTO REALIZA_VENTA VALUES (11, 6, 1000031);

-- Puesto 12 (Feria 4 - Música): Productos 7, 8, 9
INSERT INTO REALIZA_VENTA VALUES (12, 7, 1000032);
INSERT INTO REALIZA_VENTA VALUES (12, 8, 1000032);
INSERT INTO REALIZA_VENTA VALUES (12, 9, 1000032);

-- Puesto 13 (Feria 5 - Deportes): Productos 26, 27, 28
INSERT INTO REALIZA_VENTA VALUES (13, 26, 1000033);
INSERT INTO REALIZA_VENTA VALUES (13, 27, 1000033);
INSERT INTO REALIZA_VENTA VALUES (13, 28, 1000033);

-- Puesto 14 (Feria 5 - Deportes): Productos 26, 27, 28
INSERT INTO REALIZA_VENTA VALUES (14, 26, 1000034);
INSERT INTO REALIZA_VENTA VALUES (14, 27, 1000034);
INSERT INTO REALIZA_VENTA VALUES (14, 28, 1000034);

-- Puesto 15 (Feria 5 - Deportes): Productos 26, 27, 28
INSERT INTO REALIZA_VENTA VALUES (15, 26, 1000035);
INSERT INTO REALIZA_VENTA VALUES (15, 27, 1000035);
INSERT INTO REALIZA_VENTA VALUES (15, 28, 1000035);

-- Puesto 18 (Feria 6 - Educación): Productos 29, 30
INSERT INTO REALIZA_VENTA VALUES (18, 29, 1000036);
INSERT INTO REALIZA_VENTA VALUES (18, 30, 1000036);

-- Puesto 19 (Feria 7 - Salud): Productos 11, 12, 15
INSERT INTO REALIZA_VENTA VALUES (19, 11, 1000037);
INSERT INTO REALIZA_VENTA VALUES (19, 12, 1000037);
INSERT INTO REALIZA_VENTA VALUES (19, 15, 1000037);

-- Puesto 20 (Feria 7 - Salud): Productos 13, 14, 16
INSERT INTO REALIZA_VENTA VALUES (20, 13, 1000038);
INSERT INTO REALIZA_VENTA VALUES (20, 14, 1000038);
INSERT INTO REALIZA_VENTA VALUES (20, 16, 1000038);

-- Puesto 21 (Feria 7 - Salud): Productos 17, 18, 19
INSERT INTO REALIZA_VENTA VALUES (21, 17, 1000039);
INSERT INTO REALIZA_VENTA VALUES (21, 18, 1000039);
INSERT INTO REALIZA_VENTA VALUES (21, 19, 1000039);

-- Puesto 24 (Feria 8 - Cultura): Productos 21, 22, 23
INSERT INTO REALIZA_VENTA VALUES (24, 21, 1000040);
INSERT INTO REALIZA_VENTA VALUES (24, 22, 1000040);
INSERT INTO REALIZA_VENTA VALUES (24, 23, 1000040);

-- Puesto 25 (Feria 9 - Moda): Productos 21, 22, 23, 24, 25
INSERT INTO REALIZA_VENTA VALUES (25, 21, 1000041);
INSERT INTO REALIZA_VENTA VALUES (25, 22, 1000041);
INSERT INTO REALIZA_VENTA VALUES (25, 23, 1000041);
INSERT INTO REALIZA_VENTA VALUES (25, 24, 1000041);
INSERT INTO REALIZA_VENTA VALUES (25, 25, 1000041);

-- Puesto 26 (Feria 9 - Moda): Productos 24, 25
INSERT INTO REALIZA_VENTA VALUES (26, 24, 1000042);
INSERT INTO REALIZA_VENTA VALUES (26, 25, 1000042);

-- Puesto 27 (Feria 9 - Moda): Productos 21, 22, 23
INSERT INTO REALIZA_VENTA VALUES (27, 21, 1000043);
INSERT INTO REALIZA_VENTA VALUES (27, 22, 1000043);
INSERT INTO REALIZA_VENTA VALUES (27, 23, 1000043);

-- Puesto 30 (Feria 10 - Ciencia): Productos 29, 30
INSERT INTO REALIZA_VENTA VALUES (30, 29, 1000044);
INSERT INTO REALIZA_VENTA VALUES (30, 30, 1000044);
-- Puestos 32-34 (ferias 13 y 14) y comerciantes que atienden mas de un puesto
INSERT INTO REALIZA_VENTA VALUES (32, 15, 1000045);
INSERT INTO REALIZA_VENTA VALUES (32, 16, 1000045);
INSERT INTO REALIZA_VENTA VALUES (32, 19, 1000045);
INSERT INTO REALIZA_VENTA VALUES (33, 21, 1000046);
INSERT INTO REALIZA_VENTA VALUES (33, 22, 1000046);
INSERT INTO REALIZA_VENTA VALUES (33, 24, 1000046);
INSERT INTO REALIZA_VENTA VALUES (34, 23, 1000047);
INSERT INTO REALIZA_VENTA VALUES (34, 24, 1000047);
INSERT INTO REALIZA_VENTA VALUES (34, 25, 1000047);
INSERT INTO REALIZA_VENTA VALUES (10, 4, 1000026);
INSERT INTO REALIZA_VENTA VALUES (3, 1, 1000027);
INSERT INTO REALIZA_VENTA VALUES (4, 12, 1000028);
INSERT INTO REALIZA_VENTA VALUES (5, 14, 1000029);
INSERT INTO REALIZA_VENTA VALUES (25, 21, 1000040);
INSERT INTO REALIZA_VENTA VALUES (18, 29, 1000044);
--el commmit es necesario

--**********************************************************************************************
--verificacion al finalizar el create y insert
--**********************************************************************************************
SELECT 'ORGANIZADOR' AS TABLA, COUNT(*) AS TOTAL FROM ORGANIZADOR
UNION ALL SELECT 'UBICACION', COUNT(*) FROM UBICACION
UNION ALL SELECT 'SERVICIO', COUNT(*) FROM SERVICIO
UNION ALL SELECT 'TEMATICA', COUNT(*) FROM TEMATICA
UNION ALL SELECT 'PRODUCTO', COUNT(*) FROM PRODUCTO
UNION ALL SELECT 'EXPOSICION', COUNT(*) FROM EXPOSICION
UNION ALL SELECT 'PERSONA', COUNT(*) FROM PERSONA
UNION ALL SELECT 'EXPOSITOR', COUNT(*) FROM EXPOSITOR
UNION ALL SELECT 'COMERCIANTE', COUNT(*) FROM COMERCIANTE
UNION ALL SELECT 'RESPONSABLE', COUNT(*) FROM RESPONSABLE
UNION ALL SELECT 'FERIA', COUNT(*) FROM FERIA
UNION ALL SELECT 'PUESTO', COUNT(*) FROM PUESTO
UNION ALL SELECT 'SE_REALIZA_EN', COUNT(*) FROM SE_REALIZA_EN
UNION ALL SELECT 'INCLUYE', COUNT(*) FROM INCLUYE
UNION ALL SELECT 'CONTIENE', COUNT(*) FROM CONTIENE
UNION ALL SELECT 'FERIA_TEMATICA', COUNT(*) FROM FERIA_TEMATICA
UNION ALL SELECT 'PRESENTA', COUNT(*) FROM PRESENTA
UNION ALL SELECT 'EXPONE', COUNT(*) FROM EXPONE
UNION ALL SELECT 'REALIZA_VENTA', COUNT(*) FROM REALIZA_VENTA;

SELECT 
    (SELECT COUNT(*) FROM ORGANIZADOR) +
    (SELECT COUNT(*) FROM UBICACION) +
    (SELECT COUNT(*) FROM SERVICIO) +
    (SELECT COUNT(*) FROM TEMATICA) +
    (SELECT COUNT(*) FROM PRODUCTO) +
    (SELECT COUNT(*) FROM EXPOSICION) +
    (SELECT COUNT(*) FROM PERSONA) +
    (SELECT COUNT(*) FROM EXPOSITOR) +
    (SELECT COUNT(*) FROM COMERCIANTE) +
    (SELECT COUNT(*) FROM RESPONSABLE) +
    (SELECT COUNT(*) FROM FERIA) +
    (SELECT COUNT(*) FROM PUESTO) +
    (SELECT COUNT(*) FROM SE_REALIZA_EN) +
    (SELECT COUNT(*) FROM INCLUYE) +
    (SELECT COUNT(*) FROM CONTIENE) +
    (SELECT COUNT(*) FROM FERIA_TEMATICA) +
    (SELECT COUNT(*) FROM PRESENTA) +
    (SELECT COUNT(*) FROM EXPONE) +
    (SELECT COUNT(*) FROM REALIZA_VENTA) AS TOTAL_TUPLAS
;