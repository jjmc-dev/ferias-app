DROP TABLE IF EXISTS SE_REALIZA_EN;
DROP TABLE IF EXISTS FERIA;
DROP TABLE IF EXISTS UBICACION;
DROP TABLE IF EXISTS ORGANIZADOR;

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
    idOrganizador INT,
    FOREIGN KEY (idOrganizador) REFERENCES ORGANIZADOR(idOrganizador)
);
CREATE TABLE SE_REALIZA_EN (
    idFeria INT,
    idUbicacion INT,
    fecha_ini DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    PRIMARY KEY (idFeria, idUbicacion),
    FOREIGN KEY (idFeria) REFERENCES FERIA(idFeria),
    FOREIGN KEY (idUbicacion) REFERENCES UBICACION(idUbicacion)
);

INSERT INTO ORGANIZADOR VALUES (1, 'Organizador A'), (2, 'Organizador B');
INSERT INTO UBICACION VALUES (1, 'Plaza Murillo'), (2, 'Parque Urbano');
INSERT INTO FERIA VALUES (1, 'Feria Tecnologica', 1), (2, 'Feria Gastronomica', 1), (3, 'Feria de Arte', 2);
INSERT INTO SE_REALIZA_EN VALUES
    (1, 1, '2024-03-01', '2024-03-05'),
    (1, 2, '2024-03-08', '2024-03-09'),
    (2, 2, '2024-03-10', '2024-03-14');

DROP FUNCTION IF EXISTS fn_total_ferias_organizador;
DROP PROCEDURE IF EXISTS sp_ubicaciones_feria;
DROP PROCEDURE IF EXISTS sp_renombrar_feria;
DROP TRIGGER IF EXISTS trg_validar_fechas_sre;
DROP TRIGGER IF EXISTS trg_validar_fechas_sre_upd;

DELIMITER $$

CREATE FUNCTION fn_total_ferias_organizador(p_idorganizador INT)
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total FROM FERIA WHERE idOrganizador = p_idorganizador;
    RETURN v_total;
END$$

CREATE PROCEDURE sp_ubicaciones_feria(IN p_idferia INT)
BEGIN
    SELECT u.nombreL AS ubicacion, s.fecha_ini AS desde, s.fecha_fin AS hasta
    FROM SE_REALIZA_EN s, UBICACION u
    WHERE s.idUbicacion = u.idUbicacion AND s.idFeria = p_idferia;
END$$

CREATE PROCEDURE sp_renombrar_feria(IN p_idferia INT, IN p_nombre VARCHAR(60))
BEGIN
    UPDATE FERIA SET nombreFer = p_nombre WHERE idFeria = p_idferia;
END$$

CREATE TRIGGER trg_validar_fechas_sre BEFORE INSERT ON SE_REALIZA_EN
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin < NEW.fecha_ini THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fecha_fin no puede ser anterior a fecha_ini';
    END IF;
END$$

CREATE TRIGGER trg_validar_fechas_sre_upd BEFORE UPDATE ON SE_REALIZA_EN
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin < NEW.fecha_ini THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fecha_fin no puede ser anterior a fecha_ini';
    END IF;
END$$

DELIMITER ;