# Tutorial — Módulo 6: Rutinas SQL (SQL Server)

**Autora:** Gabriela Fernandez · **Grupo 5** · Taller de Base de Datos · Base de datos: Ferias de fin de semana (La Paz)

## 1. Objetivo del módulo

Crear, directamente en SQL Server, las **funciones, procedimientos, cursor y trigger** que luego la página web (backend FastAPI + frontend Streamlit) descubre y ejecuta leyendo el catálogo de la base. No se crean tablas nuevas: todo se programa sobre el modelo de ferias existente.

## 2. Archivos

| Archivo | Para qué sirve |
|---|---|
| `db/sqlserver/routines.sql` | Crea las 5 rutinas |
| `db/sqlserver/test_routines.sql` | Consultas para comprobar que funcionan |
| `docs/tutorial-modulo-6.md` | Este tutorial |

## 3. Rutinas creadas

| Tipo | Nombre | Qué hace |
|---|---|---|
| Función | `fn_TotalPuestosFeria(@idFeria)` | Cuenta los puestos de una feria (filas de `CONTIENE`) |
| Función | `fn_CostoServiciosFeria(@idFeria)` | Suma el `costo` de los servicios de una feria (`INCLUYE`) |
| Procedimiento | `sp_ResumenFeria(@idFeria)` | Muestra la feria, su organizador y sus temáticas en una fila |
| Procedimiento con cursor | `sp_PuestosPorUbicacion(@idFeria)` | Recorre con un cursor cada ubicación de la feria y cuenta sus puestos |
| Trigger | `trg_ValidarFechasSRE` | En `SE_REALIZA_EN` rechaza filas con `fecha_fin < fecha_ini` |

## 4. Requisitos

- Contenedor de SQL Server levantado con Docker (Módulo 1).
- Base de datos con tablas y datos cargados desde `create_insert.sql` (Módulo 2).

## 5. Cómo ejecutarlo

Desde la carpeta del proyecto, en PowerShell:

```powershell
docker cp db/sqlserver/routines.sql sqlserver:/tmp/routines.sql
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "TU_PASSWORD" -C -d NOMBRE_BD -i /tmp/routines.sql
```

- `docker cp` copia el archivo dentro del contenedor.
- `sqlcmd` es la herramienta de SQL Server para ejecutar scripts; `-C` confía en el certificado del servidor y `-d` elige la base.
- Reemplaza `TU_PASSWORD` y `NOMBRE_BD` por los valores reales (la contraseña real nunca se sube a Git).

El script usa `CREATE OR ALTER`, así que se puede ejecutar varias veces sin errores.

## 6. Cómo se comprobó

Con `test_routines.sql` se compararon los resultados contra los valores esperados:

| idFeria | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Puestos | 3 | 7 | 5 | 8 | 6 | 4 | 9 | 11 | 6 | 3 | 5 | 8 | 6 | 5 |
| Costo servicios | 1000 | 2950 | 3450 | 4550 | 2900 | 1650 | 3700 | 6100 | 3700 | 1350 | 2350 | 3500 | 3600 | 2350 |

- **Cursor:** para la feria 8 devuelve 4 ubicaciones (3, 3, 2 y 3 puestos) que suman 11, igual que la función.
- **Trigger:** insertar o actualizar una fila con fechas invertidas falla con el mensaje "Fechas invalidas…" y la fila no cambia; una fila con fechas válidas entra sin problema.

## 7. Conceptos clave

- **Función:** devuelve un valor y se usa dentro de un `SELECT`.
- **Procedimiento:** se ejecuta con `EXEC`, puede devolver tablas y hacer varias operaciones.
- **Cursor:** recorre fila por fila el resultado de una consulta (`DECLARE`, `OPEN`, `FETCH`, `CLOSE`, `DEALLOCATE`).
- **Trigger:** código que la base ejecuta sola al insertar o actualizar; la tabla temporal `inserted` contiene las filas nuevas.
- **Parámetros (`@idFeria`):** evitan la inyección SQL porque el valor nunca se pega dentro del texto de la consulta.
- **`CREATE OR ALTER`:** sintaxis de SQL Server para crear o reemplazar una rutina. En Oracle y PostgreSQL se usa `CREATE OR REPLACE`.

## 8. Problemas encontrados y soluciones

| Problema | Causa | Solución |
|---|---|---|
| `routines.sql` quedó vacío en el repositorio | El archivo se creó sin pegar su contenido | Se volvió a copiar el contenido y se guardó con `Ctrl + S` antes del commit |
| `CREATE OR REPLACE` no funciona | Es sintaxis de Oracle/PostgreSQL | En SQL Server se usa `CREATE OR ALTER` |
| *(agregar aquí lo que pase al probar)* | | |