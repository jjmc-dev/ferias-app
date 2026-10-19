-- =====================================================================
-- Archivo: db/sqlserver/test_routines.sql
-- =====================================================================

-- 1) Funciones: deben dar (puestos) 3,7,5,8,6,4,9,11,6,3,5,8,6,5
--    y (costo)  1000,2950,3450,4550,2900,1650,3700,6100,3700,
--               1350,2350,3500,3600,2350
SELECT f.idFeria,
       dbo.fn_TotalPuestosFeria(f.idFeria)   AS puestos,
       dbo.fn_CostoServiciosFeria(f.idFeria) AS costo_servicios
FROM FERIA f
ORDER BY f.idFeria;
GO

-- 2) Procedimiento de resumen
EXEC dbo.sp_ResumenFeria @idFeria = 1;
GO

-- 3) Procedimiento con cursor 
--    (la suma de total_puestos debe coincidir con fn_TotalPuestosFeria)
EXEC dbo.sp_PuestosPorUbicacion @idFeria = 8;
GO

-- 4) Trigger — caso INVÁLIDO: debe FALLAR con "Fechas invalidas..."
--    (cambia idFeria/idUbicacion por una pareja que NO exista en SE_REALIZA_EN)
-- INSERT INTO SE_REALIZA_EN (idFeria, idUbicacion, fecha_ini, fecha_fin)
-- VALUES (1, 10, '2026-05-10', '2026-05-01');

-- 5) Trigger — caso VÁLIDO: debe entrar (luego se borra para no alterar el total de 31 filas)
-- INSERT INTO SE_REALIZA_EN (idFeria, idUbicacion, fecha_ini, fecha_fin)
-- VALUES (1, 10, '2026-05-01', '2026-05-10');
-- DELETE FROM SE_REALIZA_EN WHERE idFeria = 1 AND idUbicacion = 10 AND fecha_ini = '2026-05-01';
