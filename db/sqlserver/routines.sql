-- =====================================================================
-- Módulo 6 — Rutinas SQL — Grupo 5 — Ferias de fin de semana
-- Archivo: db/sqlserver/routines.sql
-- Requisito: haber cargado antes create_insert.sql 
--            (tablas y datos rev10).
-- Ejecutar con sqlcmd
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) FUNCIÓN: cantidad de puestos asignados a una feria
--    Cuenta cada fila de CONTIENE (una por ubicación) de esa feria.
-- ---------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TotalPuestosFeria (@idFeria INT)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total = COUNT(*)
    FROM CONTIENE c
    WHERE c.idFeria = @idFeria;

    RETURN ISNULL(@total, 0);
END;
GO

-- ---------------------------------------------------------------------
-- 2) FUNCIÓN: suma del costo de los servicios de una feria (INCLUYE)
-- ---------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CostoServiciosFeria (@idFeria INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = SUM(i.costo)
    FROM INCLUYE i
    WHERE i.idFeria = @idFeria;

    RETURN ISNULL(@total, 0);
END;
GO

-- ---------------------------------------------------------------------
-- 3) PROCEDIMIENTO: resumen de una feria, su organizador y sus temáticas
--    Devuelve UN solo conjunto de resultados (una fila), porque el
--    backend (call_procedure) devuelve {"columns": [...], "rows": [...]}.
--    Las temáticas se juntan en una columna con STRING_AGG.
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_ResumenFeria
    @idFeria INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM FERIA f WHERE f.idFeria = @idFeria)
    BEGIN
        THROW 50002, 'No existe una feria con ese idFeria.', 1;
    END;

    SELECT f.idFeria,
           f.nombreFer,
           f.descripcionFer,
           o.nombreOrg,
           o.razonSocial,
           o.correo,
           o.telefonoOrg,
           ISNULL((SELECT STRING_AGG(t.nombreTem, ', ')
                   FROM FERIA_TEMATICA ft, TEMATICA t
                   WHERE ft.idTematica = t.idtematica
                     AND ft.idFeria = f.idFeria), '(sin tematicas)') AS tematicas
    FROM FERIA f, ORGANIZADOR o
    WHERE f.idOrganizador = o.idOrganizador
      AND f.idFeria = @idFeria;
END;
GO

-- ---------------------------------------------------------------------
-- 4) PROCEDIMIENTO CON CURSOR: puestos por ubicación de una feria
--    El cursor recorre cada ubicación de la feria (SE_REALIZA_EN) y,
--    fila por fila, cuenta sus puestos en CONTIENE.
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_PuestosPorUbicacion
    @idFeria INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM FERIA f WHERE f.idFeria = @idFeria)
    BEGIN
        THROW 50002, 'No existe una feria con ese idFeria.', 1;
    END;

    CREATE TABLE #resultado (
        idUbicacion  INT,
        nombreL      NVARCHAR(100),
        zona         NVARCHAR(100),
        total_puestos INT
    );

    DECLARE @idUbicacion INT,
            @nombreL     NVARCHAR(100),
            @zona        NVARCHAR(100),
            @cantidad    INT;

    DECLARE cur_ubicaciones CURSOR LOCAL FAST_FORWARD FOR
        SELECT u.idUbicacion, u.nombreL, u.zona
        FROM SE_REALIZA_EN s, UBICACION u
        WHERE s.idUbicacion = u.idUbicacion
          AND s.idFeria = @idFeria
        ORDER BY u.idUbicacion;

    OPEN cur_ubicaciones;
    FETCH NEXT FROM cur_ubicaciones INTO @idUbicacion, @nombreL, @zona;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @cantidad = COUNT(*)
        FROM CONTIENE c
        WHERE c.idFeria = @idFeria
          AND c.idUbicacion = @idUbicacion;

        INSERT INTO #resultado (idUbicacion, nombreL, zona, total_puestos)
        VALUES (@idUbicacion, @nombreL, @zona, @cantidad);

        FETCH NEXT FROM cur_ubicaciones INTO @idUbicacion, @nombreL, @zona;
    END;

    CLOSE cur_ubicaciones;
    DEALLOCATE cur_ubicaciones;

    SELECT r.idUbicacion, r.nombreL, r.zona, r.total_puestos
    FROM #resultado r
    ORDER BY r.idUbicacion;

    DROP TABLE #resultado;
END;
GO

-- ---------------------------------------------------------------------
-- 5) TRIGGER: en SE_REALIZA_EN rechaza filas con fecha_fin < fecha_ini
--    AFTER INSERT/UPDATE: si alguna fila de "inserted" es inválida,
--    se deshace la operación (ROLLBACK) y se lanza un error claro.
-- ---------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_ValidarFechasSRE
ON dbo.SE_REALIZA_EN
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted i WHERE i.fecha_fin < i.fecha_ini)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'Fechas invalidas: fecha_fin no puede ser anterior a fecha_ini.', 1;
    END;
END;
GO