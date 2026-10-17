DROP TABLE IF EXISTS SE_REALIZA_EN, FERIA, UBICACION, ORGANIZADOR CASCADE;

CREATE TABLE ORGANIZADOR (
    idOrganizador INT PRIMARY KEY,
    nombreOrg VARCHAR(60) NOT NULL
);
CREATE TABLE UBICACION (
    idUbicacion INT PRIMARY KEY,
    nombreL VARCHAR(60) NOT NULL
);
CREATE TABLE FERIA (
    idFeria INT PRIMARY KEY,
    nombreFer VARCHAR(60) NOT NULL,
    idOrganizador INT REFERENCES ORGANIZADOR(idOrganizador)
);
CREATE TABLE SE_REALIZA_EN (
    idFeria INT REFERENCES FERIA(idFeria),
    idUbicacion INT REFERENCES UBICACION(idUbicacion),
    fecha_ini DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    PRIMARY KEY (idFeria, idUbicacion)
);

INSERT INTO ORGANIZADOR VALUES (1, 'Organizador A'), (2, 'Organizador B');
INSERT INTO UBICACION VALUES (1, 'Plaza Murillo'), (2, 'Parque Urbano');
INSERT INTO FERIA VALUES (1, 'Feria Tecnologica', 1), (2, 'Feria Gastronomica', 1), (3, 'Feria de Arte', 2);
INSERT INTO SE_REALIZA_EN VALUES
    (1, 1, '2024-03-01', '2024-03-05'),
    (1, 2, '2024-03-08', '2024-03-09'),
    (2, 2, '2024-03-10', '2024-03-14');

CREATE OR REPLACE FUNCTION fn_total_ferias_organizador(p_idorganizador INT)
RETURNS INT LANGUAGE sql AS $$
    SELECT COUNT(*)::INT FROM FERIA WHERE idOrganizador = p_idorganizador
$$;

CREATE OR REPLACE FUNCTION fn_ubicaciones_feria(p_idferia INT)
RETURNS TABLE (ubicacion VARCHAR, desde DATE, hasta DATE) LANGUAGE sql AS $$
    SELECT u.nombreL, s.fecha_ini, s.fecha_fin
    FROM SE_REALIZA_EN s, UBICACION u
    WHERE s.idUbicacion = u.idUbicacion AND s.idFeria = p_idferia
$$;

CREATE OR REPLACE PROCEDURE sp_renombrar_feria(p_idferia INT, p_nombre VARCHAR)
LANGUAGE sql AS $$
    UPDATE FERIA SET nombreFer = p_nombre WHERE idFeria = p_idferia
$$;

CREATE OR REPLACE FUNCTION trg_fn_validar_fechas() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.fecha_fin < NEW.fecha_ini THEN
        RAISE EXCEPTION 'fecha_fin no puede ser anterior a fecha_ini';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_fechas_sre
BEFORE INSERT OR UPDATE ON SE_REALIZA_EN
FOR EACH ROW EXECUTE FUNCTION trg_fn_validar_fechas();