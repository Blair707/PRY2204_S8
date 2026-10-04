-- PRY2204 Semana 8 - Taller Mecánico Mikes Ltda.

-- ========== CASO 1: CREACIÓN DE TABLAS ==========

CREATE TABLE pais (
    id_pais  NUMBER(3) GENERATED ALWAYS AS IDENTITY (START WITH 9 INCREMENT BY 3),
    nom_pais VARCHAR2(30) NOT NULL,
    CONSTRAINT pk_pais PRIMARY KEY (id_pais)
);

CREATE TABLE ciudad (
    id_ciudad  NUMBER(3),
    nom_ciudad VARCHAR2(30) NOT NULL,
    cod_pais   NUMBER(3) NOT NULL,
    CONSTRAINT pk_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT fk_ciudad_pais FOREIGN KEY (cod_pais) REFERENCES pais (id_pais)
);

CREATE TABLE sucursal (
    id_sucursal  CHAR(3),
    nom_sucursal VARCHAR2(20) NOT NULL,
    calle        VARCHAR2(20) NOT NULL,
    num_calle    NUMBER(4) NOT NULL,
    cod_ciudad   NUMBER(3) NOT NULL,
    CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal),
    CONSTRAINT fk_sucursal_ciudad FOREIGN KEY (cod_ciudad) REFERENCES ciudad (id_ciudad)
);

CREATE TABLE mecanico (
    cod_mecanico    NUMBER(5) GENERATED ALWAYS AS IDENTITY (START WITH 460 INCREMENT BY 7),
    pnombre         VARCHAR2(20) NOT NULL,
    snombre         VARCHAR2(20) NOT NULL,
    apaterno        VARCHAR2(20) NOT NULL,
    amaterno        VARCHAR2(20) NOT NULL,
    bono_jefatura   NUMBER(10),
    sueldo          NUMBER(10) NOT NULL,
    monto_impuestos NUMBER(10) NOT NULL,
    cod_supervisor  NUMBER(5),
    CONSTRAINT pk_mecanico PRIMARY KEY (cod_mecanico),
    CONSTRAINT fk_mecanico_mecanico FOREIGN KEY (cod_supervisor) REFERENCES mecanico (cod_mecanico)
);

CREATE TABLE servicio (
    id_servicio NUMBER(3),
    descripcion VARCHAR2(100) NOT NULL,
    costo       NUMBER(7) NOT NULL,
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio)
);

CREATE TABLE marca (
    id_marca    NUMBER(2),
    descripcion VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_marca PRIMARY KEY (id_marca)
);

CREATE TABLE modelo (
    id_modelo   NUMBER(5),
    marca_id    NUMBER(2),
    descripcion VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_modelo PRIMARY KEY (id_modelo, marca_id),
    CONSTRAINT fk_modelo_marca FOREIGN KEY (marca_id) REFERENCES marca (id_marca)
);

CREATE TABLE tipo_automovil (
    id_tipo     CHAR(3),
    descripcion VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_tipo_automovil PRIMARY KEY (id_tipo)
);

CREATE TABLE cliente (
    rut      NUMBER(8),
    dv       CHAR(1) NOT NULL,
    pnombre  VARCHAR2(20) NOT NULL,
    snombre  VARCHAR2(20),
    apaterno VARCHAR2(20) NOT NULL,
    amaterno VARCHAR2(20) NOT NULL,
    telefono VARCHAR2(12),
    email    VARCHAR2(40),
    tipo_cli CHAR(1) NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (rut)
);

CREATE TABLE estandar (
    cl_rut            NUMBER(8),
    puntaje_fidelidad NUMBER(10) NOT NULL,
    CONSTRAINT pk_estandar PRIMARY KEY (cl_rut),
    CONSTRAINT fk_estandar_cliente FOREIGN KEY (cl_rut) REFERENCES cliente (rut)
);

CREATE TABLE premium (
    cl_rut         NUMBER(8),
    pesos_clientes NUMBER(10) NOT NULL,
    monto_credito  NUMBER(10),
    CONSTRAINT pk_premium PRIMARY KEY (cl_rut),
    CONSTRAINT fk_premium_cliente FOREIGN KEY (cl_rut) REFERENCES cliente (rut)
);

CREATE TABLE automovil (
    patente       CHAR(8),
    annio         NUMBER(4) NOT NULL,
    cant_puertas  NUMBER(1) NOT NULL,
    km            NUMBER(6) NOT NULL,
    color         VARCHAR2(30) NOT NULL,
    cod_tipo_auto CHAR(3) NOT NULL,
    cod_modelo    NUMBER(5) NOT NULL,
    cod_marca     NUMBER(2) NOT NULL,
    cl_rut        NUMBER(8) NOT NULL,
    CONSTRAINT pk_automovil PRIMARY KEY (patente),
    CONSTRAINT fk_automovil_cliente FOREIGN KEY (cl_rut) REFERENCES cliente (rut),
    CONSTRAINT fk_automovil_modelo FOREIGN KEY (cod_modelo, cod_marca) REFERENCES modelo (id_modelo, marca_id),
    CONSTRAINT fk_automovil_tipo FOREIGN KEY (cod_tipo_auto) REFERENCES tipo_automovil (id_tipo)
);

CREATE TABLE mantencion (
    num_mantencion NUMBER(4),
    cod_sucursal   CHAR(3) NOT NULL,
    fecha_ingreso  DATE NOT NULL,
    fecha_salida   DATE,
    patente_auto   CHAR(8),
    cod_mecanico   NUMBER(5) NOT NULL,
    costo_total    NUMBER(7) NOT NULL,
    estado         VARCHAR2(15),
    CONSTRAINT pk_mantencion PRIMARY KEY (num_mantencion),
    CONSTRAINT fk_mant_automovil FOREIGN KEY (patente_auto) REFERENCES automovil (patente),
    CONSTRAINT fk_mant_mecanico FOREIGN KEY (cod_mecanico) REFERENCES mecanico (cod_mecanico),
    CONSTRAINT fk_mant_sucursal FOREIGN KEY (cod_sucursal) REFERENCES sucursal (id_sucursal)
);

CREATE TABLE detalle_servicio (
    mantencion_num NUMBER(4),
    cod_servicio   NUMBER(3),
    descuento_serv NUMBER(4,3) NOT NULL,
    cantidad       NUMBER(3) NOT NULL,
    CONSTRAINT pk_detalle_servicio PRIMARY KEY (mantencion_num, cod_servicio),
    CONSTRAINT fk_detserv_mantencion FOREIGN KEY (mantencion_num) REFERENCES mantencion (num_mantencion),
    CONSTRAINT fk_detserv_servicio FOREIGN KEY (cod_servicio) REFERENCES servicio (id_servicio)
);


-- ========== CASO 2: ALTER TABLE ==========

-- se elimina el atributo derivado
ALTER TABLE mantencion DROP COLUMN costo_total;

-- nueva PK de mantencion (numero + sucursal)
-- primero se saca la FK de detalle_servicio porque depende de la PK vieja
ALTER TABLE detalle_servicio DROP CONSTRAINT fk_detserv_mantencion;
ALTER TABLE mantencion DROP CONSTRAINT pk_mantencion;
ALTER TABLE mantencion ADD CONSTRAINT pk_mantencion PRIMARY KEY (num_mantencion, cod_sucursal);

-- detalle_servicio necesita la sucursal para apuntar a la nueva PK
ALTER TABLE detalle_servicio ADD cod_sucursal CHAR(3) NOT NULL;
ALTER TABLE detalle_servicio DROP CONSTRAINT pk_detalle_servicio;
ALTER TABLE detalle_servicio ADD CONSTRAINT pk_detalle_servicio PRIMARY KEY (mantencion_num, cod_sucursal, cod_servicio);
ALTER TABLE detalle_servicio ADD CONSTRAINT fk_detserv_mantencion
    FOREIGN KEY (mantencion_num, cod_sucursal) REFERENCES mantencion (num_mantencion, cod_sucursal);

ALTER TABLE cliente ADD CONSTRAINT un_cliente_email UNIQUE (email);

ALTER TABLE cliente ADD CONSTRAINT ck_cliente_dv
    CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K'));

ALTER TABLE mecanico ADD CONSTRAINT ck_mecanico_sueldo CHECK (sueldo >= 510000);

ALTER TABLE mantencion ADD CONSTRAINT ck_mantencion_estado
    CHECK (estado IN ('Reserva', 'Ingresado', 'Entregado', 'Anulado'));


-- ========== CASO 3: POBLAMIENTO ==========

CREATE SEQUENCE seq_servicio START WITH 400 INCREMENT BY 2;
CREATE SEQUENCE seq_ciudad START WITH 165 INCREMENT BY 5;

INSERT INTO pais (nom_pais) VALUES ('Chile');
INSERT INTO pais (nom_pais) VALUES ('Peru');
INSERT INTO pais (nom_pais) VALUES ('Colombia');

INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Santiago', 9);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Lima', 12);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Bogotá', 15);

INSERT INTO sucursal VALUES ('S01', 'Providencia', 'Av. A. Varas', 234, 165);
INSERT INTO sucursal VALUES ('S02', 'Las 4 esquinas', 'Av. Latina', 669, 170);
INSERT INTO sucursal VALUES ('S03', 'El Cafetero', 'Av. El Faro', 900, 175);

-- mecánicos: los supervisores (460, 467, 474) se insertan primero
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Jorge', 'Pablo', 'Soto', 'Sierpe', 5400000, 2759000, 223580, NULL);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Pedro', 'Jose', 'Manriquez', 'Corral', NULL, 759000, 23980, NULL);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Sandra', 'Josefa', 'Letelier', 'S.', 0, 659000, 22358, 460);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Felipe', 'M.', 'Vidal', 'A.', NULL, 759000, 23580, 460);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Jose', 'Miguel', 'Troncoso', 'B.', NULL, 659000, 44580, 474);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Juan', 'Pablo', 'Sánchez', 'R.', NULL, 859000, 23380, 474);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Carlos', 'Felipe', 'Soto', 'J.', 0, 597000, 23580, 474);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Alberto', 'P.', 'Cerda', 'Ramírez', NULL, 559000, 22380, 460);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Alejandra', 'Gabriela', 'Infanti', 'R.', NULL, 659000, 22380, 460);
INSERT INTO mecanico (pnombre, snombre, apaterno, amaterno, bono_jefatura, sueldo, monto_impuestos, cod_supervisor)
VALUES ('Roberto', 'Patricio', 'Gutierrez', 'Sosa', NULL, 859000, 22380, 460);

INSERT INTO mantencion (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
VALUES (101, 'S01', TO_DATE('12-04-2023','DD-MM-YYYY'), NULL, NULL, 481, 'Reserva');
INSERT INTO mantencion (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
VALUES (102, 'S02', TO_DATE('21-02-2023','DD-MM-YYYY'), TO_DATE('21-02-2023','DD-MM-YYYY'), NULL, 502, 'Entregado');
INSERT INTO mantencion (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
VALUES (103, 'S02', TO_DATE('09-10-2023','DD-MM-YYYY'), NULL, NULL, 502, 'Anulado');
INSERT INTO mantencion (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
VALUES (104, 'S03', TO_DATE('11-08-2023','DD-MM-YYYY'), TO_DATE('18-08-2023','DD-MM-YYYY'), NULL, 509, 'Entregado');
INSERT INTO mantencion (num_mantencion, cod_sucursal, fecha_ingreso, fecha_salida, patente_auto, cod_mecanico, estado)
VALUES (105, 'S03', TO_DATE('03-12-2023','DD-MM-YYYY'), NULL, NULL, 509, 'Ingresado');

INSERT INTO servicio VALUES (seq_servicio.NEXTVAL, 'Cambio Luces', 45000);
INSERT INTO servicio VALUES (seq_servicio.NEXTVAL, 'Desabolladura', 67000);
INSERT INTO servicio VALUES (seq_servicio.NEXTVAL, 'Revisión Frenos', 30000);
INSERT INTO servicio VALUES (seq_servicio.NEXTVAL, 'Cambio Puerta Trasera', 50000);

COMMIT;


-- ========== CASO 4: INFORMES ==========

-- Informe 1: mecánicos sin bono de jefatura e impuestos menores a 40.000
SELECT cod_mecanico AS "ID MECANICO",
       pnombre || ' ' || apaterno AS "NOMBRE MECANICO",
       sueldo AS "SALARIO",
       monto_impuestos AS "IMPUESTO ACTUAL",
       monto_impuestos * 0.8 AS "IMPUESTO REBAJADO",
       sueldo - (monto_impuestos * 0.8) AS "SUELDO CON REBAJA IMPUESTOS"
FROM mecanico
WHERE bono_jefatura IS NULL
  AND monto_impuestos < 40000
ORDER BY monto_impuestos DESC, apaterno ASC;

-- Informe 2: reajuste del 5% (sueldo entre 600 mil y 900 mil, o sin supervisor)
SELECT cod_mecanico AS "IDENTIFICADOR",
       pnombre || ' ' || snombre || ' ' || apaterno AS "MECANICO",
       sueldo AS "SALARIO ACTUAL",
       sueldo * 0.05 AS "AJUSTE",
       sueldo + (sueldo * 0.05) AS "SUELDO_REAJUSTADO"
FROM mecanico
WHERE sueldo BETWEEN 600000 AND 900000
   OR cod_supervisor IS NULL
ORDER BY sueldo ASC, "MECANICO" DESC;
