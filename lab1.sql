CREATE TABLE titulacion(
    nombre VARCHAR2(50),
    CONSTRAINT pk_titulacion PRIMARY KEY(nombre)
);
CREATE TABLE asignatura (
    nombre VARCHAR2(100),
    titulacion VARCHAR2(50),
    creditos NUMBER(2) NOT NULL,
    profesor VARCHAR2(50),
    CONSTRAINT pk_asignatura
        PRIMARY KEY(nombre,titulacion),
    CONSTRAINT ck_asignatura CHECK (creditos>0)
);

CREATE TABLE alumno (
    nia NUMBER(9) NOT NULL,
    nombre VARCHAR2(20) NOT NULL,
    primer_apellido VARCHAR2(20) NOT NULL,
    segundo_apellido VARCHAR2(20),
    creditos NUMBER(2) NOT NULL,
    edad NUMBER(3),
    fecha_nacimiento DATE
    CONSTRAINT pk_alumno PRIMARY KEY(nia),
    CONSTRAINT ck_edad CHECK (edad>0 AND edad<120)
);

CREATE TABLE matricula (
    asignatura_nombre VARCHAR2(100) NOT NULL,
    asignatura_titulacion VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES asignatura(nombre),
    CONSTRAINT fk_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES asignatura(titulacion),
    alumno NUMBER(9) NOT NULL,
    CONSTRAINT fk_alumno 
        FOREIGN KEY(alumno) REFERENCES alumno(nia),
    CONSTRAINT pk_alumno PRIMARY KEY(alumno),
    CONSTRAINT pk_asignatura_nombre PRIMARY KEY(asignatura_nombre),
    CONSTRAINT pk_asignatura_titulacion PRIMARY KEY(asignatura_titulacion),
);

CREATE TABLE miembro(
    alumno NUMBER(9) NOT NULL,
    asignatura_nombre VARCHAR2(100) NOT NULL,
    asignatura_titulacion VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES matricula(asignatura_nombre),
    CONSTRAINT fk_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES matricula(asignatura_titulacion),
    CONSTRAINT fk2_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES grupo(asignatura_nombre),
    CONSTRAINT fk2_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES grupo(asignatura_titulacion),
    numGrupo NUMBER(3),
    CONSTRAINT fk_alumno
        FOREIGN KEY(alumno) REFERENCES matricula(alumno),
    CONSTRAINT pk_asignatura_nombre PRIMARY KEY(asignatura_nombre),
    CONSTRAINT pk_asignatura_titulacion PRIMARY KEY(asignatura_titulacion),
    CONSTRAINT pk_alumno PRIMARY KEY(alumno),
    CONSTRAINT ck_numGrupo CHECK (numGrupo>0)
);

CREATE TABLE grupo(
    asignatura_nombre VARCHAR2(100) NOT NULL,
    asignatura_titulacion VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES asignatura(nombre),
    CONSTRAINT fk_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES asignatura(titulacion),
    numGrupo NUMBER(3) NOT NULL,
    CONSTRAINT pk_numGrupo PRIMARY KEY(numGrupo),
    CONSTRAINT ck_numGrupo CHECK (numGrupo>0)
);

CREATE TABLE entrega(
    numPract NUMBER(2) NOT NULL,
    asignatura_nombre VARCHAR2(100) NOT NULL,
    asignatura_titulacion VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES practica(asignatura_nombre),
    CONSTRAINT fk_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES practica(asignatura_titulacion),
    CONSTRAINT fk_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES grupo(asignatura_nombre),
    CONSTRAINT fk_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES grupo(asignatura_titulacion),
    numGrupo NUMBER(3) NOT NULL,
    CONSTRAINT pk_numGrupo FOREIGN KEY(numGrupo)
        REFERENCES grupo(numGrupo),
    fecha_entrega DATE NOT NULL,
    calificacion NUMBER(2) NOT NULL,
    CONSTRAINT ck_calificacion CHECK (calificacion>=0 AND calificacion<=10),
    CONSTRAINT pk_asignatura_nombre PRIMARY KEY(asignatura_nombre),
    CONSTRAINT pk_asignatura_titulacion PRIMARY KEY(asignatura_titulacion),
    CONSTRAINT pk_numGrupo PRIMARY KEY(numGrupo)
);

CREATE TABLE practica(
    asignatura_nombre VARCHAR2(100) NOT NULL,
    asignatura_titulacion VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_asignatura_nombre
        FOREIGN KEY(asignatura_nombre) REFERENCES asignatura(nombre),
    CONSTRAINT fk_asignatura_titulacion
        FOREIGN KEY(asignatura_titulacion) REFERENCES asignatura(titulacion),
    orden NUMBER(2),
    f_ini DATE NOT NULL,
    f_fin DATE NOT NULL,
    CONSTRAINT ck_fecha CHECK (f_ini<f_fin),
    CONSTRAINT pk_asignatura_nombre PRIMARY KEY(asignatura_nombre),
    CONSTRAINT pk_asignatura_titulacion PRIMARY KEY(asignatura_titulacion),
    CONSTRAINT pk_numGrupo PRIMARY KEY(numGrupo),
    CONSTRAINT pk_orden PRIMARY KEY(orden),
    CONSTRAINT ck_orden CHECK (orden>0)
);


DESC asignatura