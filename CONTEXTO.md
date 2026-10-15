# CONTEXTO DEL PROYECTO — Grupo 5 — Taller de Base de Datos

> **Para la IA (ChatGPT, Gemini, DeepSeek, Claude u otra):** este archivo es el contexto compartido del proyecto.
> Léelo completo antes de responder. La persona que te lo pega es un estudiante universitario del grupo; te dirá
> en qué **módulo** (sección 9) trabaja. Ayúdale solo con ese módulo, respetando el **contrato** de la sección 7
> para que su trabajo encaje con el de sus compañeros.

## 0. Cómo debes ayudar (reglas para la IA)

1. Responde **en español**, con pasos pequeños y comprobables. Evita entregar todo de golpe.
2. **Explica** cada archivo y cada comando importante (qué hace y por qué), porque el estudiante debe poder
   defender su trabajo oralmente ante el docente sin ayuda.
3. El sistema operativo del grupo es **Windows 11** (comandos en PowerShell, no en Linux/bash, salvo que estén
   dentro de un contenedor Docker).
4. **No inventes** nombres de tablas, columnas ni endpoints: usa solo los de este documento. Si falta un dato,
   pregunta.
5. Si el estudiante pega un error, analiza el **mensaje completo** y explica la causa antes de dar la solución.
6. No cambies el contrato de la sección 7 sin avisar: otros módulos dependen de él.
7. Nunca pongas contraseñas reales en el código; usa variables de entorno (`.env`).
8. Usa solo software **gratuito/comunitario** y en su **última versión estable**.

## 1. Qué es el proyecto

Materia: Taller de Base de Datos (docente: Lic. José Luis Zeballos Abasto). Gestión 2/2026.
Grupo 5, integrantes N° de lista: 27, 32, 36, 42, 53, 66 (6 personas).

Tema de la base de datos: **Ferias de fin de semana** en plazas y lugares de La Paz (Bolivia). La base ya fue
diseñada (modelo ER y modelo relacional) y probada en **Oracle**. Existe un script `rev10` con `CREATE TABLE` e
`INSERT` (sintaxis Oracle).

Al grupo le tocó el motor **SQL Server**. En esta etapa hay que construir una **aplicación web** (backend +
frontend) que se conecte a la base de datos y desde la cual se puedan pedir **funciones, procedimientos,
cursores y triggers**.

## 2. Qué pidió el docente (requisitos)

- Un **backend** que conecte con la base de datos (aquí SQL Server) y que esté **diseñado para soportar después
  otros gestores**: PostgreSQL, MySQL, Oracle, etc.
- Un **frontend** desde el cual se hacen las peticiones de funciones, procedimientos, cursores y triggers.
- Lenguaje libre (el grupo eligió **Python**).
- Probarlo en una máquina del grupo con el script `rev10`.
- **Docker es opcional**; el grupo decidió usarlo. Si se usa Docker hay que explicar cómo se hicieron las APIs,
  las conexiones y los requisitos.
- Para el **martes 20 de octubre**: entregar un **tutorial** de cómo instalar el gestor (SQL Server), cómo usarlo
  con Docker, requisitos y cómo hacer la conexión.
- A partir de ahora el grupo recibirá la **base de datos de otro grupo** (en USB) y deberá **conectarla a su
  página**. Por eso la página debe ser **genérica** (funcionar con cualquier base, no solo con ferias).
- Usar versiones **comunitarias, gratuitas y recientes** de los gestores.
- **Todos** los integrantes deben saber explicar qué hicieron y con qué lenguaje; el docente preguntará a
  cualquiera. Quien no sepa pierde la nota de la etapa.
- Si la base (propia o ajena) no funciona, el avance termina ahí: hay que probar bien.

## 3. Decisiones ya tomadas

| Tema | Decisión |
|---|---|
| Lenguaje | Python 3.11 o superior (recomendado 3.12) |
| Backend | FastAPI + SQLAlchemy |
| Frontend | Streamlit (Python), consume la API del backend por HTTP |
| Motor principal | SQL Server (imagen Docker `mcr.microsoft.com/mssql/server:2025-latest`) |
| Otros motores (después) | PostgreSQL, MySQL, Oracle |
| Contenedores | Docker Desktop con WSL2 en Windows 11 + `docker compose` |
| Control de versiones | Git (repositorio compartido, una rama por módulo) |
| Meta | Terminar el desarrollo para el fin de semana; lunes y martes para el tutorial |

Notas de SQL Server en Docker (según la documentación de Microsoft): variables `ACCEPT_EULA=Y` y
`MSSQL_SA_PASSWORD=<contraseña fuerte>`; puerto `1433`; por defecto corre como edición **Developer** (gratuita,
no para producción) y se puede usar **Express** con `MSSQL_PID=Express`. Dentro del contenedor, `sqlcmd` está en
`/opt/mssql-tools18/bin/sqlcmd` y se usa con `-C` para confiar en el certificado. La contraseña debe ser fuerte
(mínimo 8 caracteres con mayúsculas, minúsculas y números o símbolos) o el contenedor se apaga.

## 4. Arquitectura

```
Frontend (Streamlit) ──HTTP/JSON──> Backend (FastAPI) ──> Adaptadores por motor ──> Base de datos (Docker)
                                                            ├ SqlServerAdapter
                                                            ├ PostgresAdapter
                                                            ├ MySQLAdapter
                                                            └ OracleAdapter
```

- El frontend **nunca** habla con la base directamente ni manda SQL libre.
- El backend recibe el nombre de una rutina y sus parámetros, valida que **exista en el catálogo** de la base y
  la ejecuta con **parámetros enlazados** (evita inyección SQL).
- Cambiar de motor = cambiar los datos de conexión y usar el adaptador correspondiente.
- Dentro de Docker Compose, los servicios se hablan por **nombre de servicio** (`sqlserver`, `backend`), no por
  `localhost`.

## 5. Estructura de carpetas

```
ferias-app/
├─ docker-compose.yml
├─ .env.example              (variables de ejemplo; el .env real NO se sube a Git)
├─ CONTEXTO.md
├─ db/
│  ├─ sqlserver/             (create_insert.sql, routines.sql)
│  ├─ postgres/
│  ├─ mysql/
│  └─ oracle/                (script rev10 original)
├─ backend/
│  ├─ Dockerfile
│  ├─ requirements.txt
│  └─ app/
│     ├─ main.py             (FastAPI y endpoints)
│     ├─ connections.py      (registro de conexiones activas)
│     └─ adapters/
│        ├─ base.py          (DatabaseAdapter)
│        ├─ sqlserver.py
│        ├─ postgres.py
│        ├─ mysql.py
│        └─ oracle.py
├─ frontend/
│  ├─ Dockerfile
│  ├─ requirements.txt
│  └─ app.py                 (Streamlit)
└─ docs/
   └─ tutorial-modulo-N.md   (una sección por módulo)
```

## 6. Modelo de datos (Ferias)

La fuente de verdad es el script `rev10` (`scrip_create_insert_rev10.txt`). Las tablas y columnas de abajo ya fueron
verificadas contra él; si en el futuro algo difiere, **manda el rev10**.

### Entidades

| Tabla | Llave primaria | Llaves foráneas | Atributos |
|---|---|---|---|
| ORGANIZADOR | idOrganizador | — | nombreOrg, razonSocial, correo, telefonoOrg |
| UBICACION | idUbicacion | — | nombreL, zona, direccionRef, tipoLugar, capacidad |
| SERVICIO | idServicio | — | nombreSer, tipoSer, responsable, horario |
| TEMATICA | idtematica | — | nombreTem, descripcionTem |
| PRODUCTO | idProducto | — | nombreProd, descripcionProd, precio, stock, dimensiones |
| EXPOSICION | idExpo | — | titulo, duracionMin, descripcionExpo, tema |
| PERSONA | ci | — | nombre, paterno, materno, telefono, fecNac, sexo, correo |
| EXPOSITOR | ciExpositor | ciExpositor → PERSONA(ci) | tipoExpositor, especialidad, institucion |
| COMERCIANTE | idComerciante | idComerciante → PERSONA(ci) | nit, rubro, licFunc |
| RESPONSABLE | idResponsable | idResponsable → PERSONA(ci) | cargo, fecAsignacion |
| FERIA | idFeria | idOrganizador → ORGANIZADOR | nombreFer, descripcionFer |
| PUESTO | idPuesto | idResponsable → RESPONSABLE | numero, tamanio |

PERSONA es la **superclase** (herencia) de EXPOSITOR, COMERCIANTE y RESPONSABLE: comparten el mismo `ci`.

### Tablas de relación

| Tabla | Llave primaria | Relación | Cardinalidad |
|---|---|---|---|
| SE_REALIZA_EN (+ fecha_ini, fecha_fin) | (idFeria, idUbicacion) | FERIA – UBICACION | N:M |
| INCLUYE (+ costo) | (idFeria, idUbicacion, idServicio) | SE_REALIZA_EN – SERVICIO | N:M |
| CONTIENE | (idFeria, idUbicacion, idPuesto) | SE_REALIZA_EN – PUESTO | N:M |
| FERIA_TEMATICA | (idFeria, idTematica) | FERIA – TEMATICA | N:M |
| PRESENTA | (idPuesto, idExpo) | PUESTO – EXPOSICION | N:M |
| EXPONE | (idExpo, idExpositor) | EXPOSICION – EXPOSITOR | N:M |
| REALIZA_VENTA | (idPuesto, idProducto, idComerciante) | PUESTO – PRODUCTO – COMERCIANTE | N:M (ternaria) |

Relaciones 1:N (llave foránea dentro de la tabla): FERIA.idOrganizador y PUESTO.idResponsable.

`INCLUYE` y `CONTIENE` referencian a la **pareja** `(idFeria, idUbicacion)` de `SE_REALIZA_EN`: primero debe existir la
combinación feria–ubicación y luego se le agregan servicios y puestos.

### Equivalencias para portar el script Oracle (rev10)

| Oracle | SQL Server (T-SQL) | PostgreSQL | MySQL |
|---|---|---|---|
| `NUMBER(5)` | `INT` | `INTEGER` | `INT` |
| `NUMBER(10)` (ci, ids de persona) | `BIGINT` | `BIGINT` | `BIGINT` |
| `NUMBER(10,2)` | `DECIMAL(10,2)` | `NUMERIC(10,2)` | `DECIMAL(10,2)` |
| `VARCHAR2(n)` | `NVARCHAR(n)` (texto con `N'...'`) | `VARCHAR(n)` | `VARCHAR(n)` (utf8mb4) |
| `DATE` | `DATE` | `DATE` | `DATE` |
| `TO_DATE('16/03/2024','DD/MM/YYYY')` | `'2024-03-16'` | `'2024-03-16'` | `'2024-03-16'` |
| `COMMIT;` y `FROM DUAL` | no hacen falta | no hace falta DUAL | no hace falta DUAL |
| `SYSDATE` / `NVL` | `GETDATE()` / `ISNULL` | `NOW()` / `COALESCE` | `NOW()` / `IFNULL` |

**Codificación:** los valores de los `INSERT` del rev10 **no llevan tildes ni ñ** (solo algunos comentarios `--`),
así que `VARCHAR` funciona. Aun así se recomienda `NVARCHAR` en SQL Server por si luego se agregan acentos o llega
una base ajena con ellos. Guardar los archivos como UTF-8.
En T-SQL separar bloques con `GO` solo si se ejecuta con `sqlcmd` (no es una sentencia SQL).

### Pistas para portar el rev10 (Módulo 2)

1. El rev10 usa `TO_DATE('dd/mm/yyyy', 'DD/MM/YYYY')` en **137 lugares** (106 líneas). Con un buscar-y-reemplazar con expresión
   regular se convierte todo de una vez: buscar `TO_DATE\('(\d{2})/(\d{2})/(\d{4})',\s*'DD/MM/YYYY'\)` y reemplazar por
   `'$3-$2-$1'` (en VS Code) para dejar fechas ISO `'aaaa-mm-dd'`.
2. Cambiar los tipos solo en los `CREATE TABLE` (tabla de equivalencias de arriba).
3. Quitar `COMMIT;` (en SQL Server cada sentencia se confirma sola) y el `FROM DUAL` de la última consulta
   (`... AS TOTAL_TUPLAS FROM DUAL;`).
4. **Fechas válidas:** SQL Server, PostgreSQL y MySQL rechazan fechas que no existen. El rev10 ya corrigió
   `29/02/1993` (1993 no fue bisiesto) a `28/02/1993`; si agregan datos, revisar esto.
5. **Orden** (por las llaves foráneas): crear tablas en el orden del script e insertar en el mismo orden. Para
   volver a empezar, borrar en orden inverso (`DROP TABLE` desde `REALIZA_VENTA` hasta `ORGANIZADOR`).
6. Probar con la consulta de verificación del final del script. **Totales esperados con rev10:**

| Tabla | Filas | Tabla | Filas |
|---|---|---|---|
| ORGANIZADOR | 30 | SE_REALIZA_EN | 31 |
| UBICACION | 10 | INCLUYE | 89 |
| SERVICIO | 30 | CONTIENE | 86 |
| TEMATICA | 9 | FERIA_TEMATICA | 23 |
| PRODUCTO | 30 | PRESENTA | 25 |
| EXPOSICION | 30 | EXPONE | 78 |
| PERSONA | 50 | REALIZA_VENTA | 71 |
| EXPOSITOR / COMERCIANTE / RESPONSABLE | 25 cada una | FERIA / PUESTO | 14 / 34 |
| **TOTAL de tuplas** | **715** | | |

## 7. Contrato del backend (NO cambiar sin avisar)

### 7.1 Clase base de adaptadores (`backend/app/adapters/base.py`)

```python
from abc import ABC, abstractmethod
from typing import Any

class DatabaseAdapter(ABC):
    def __init__(self, url: str):
        """url: cadena de conexión de SQLAlchemy."""

    @abstractmethod
    def test_connection(self) -> bool: ...

    @abstractmethod
    def list_tables(self) -> list[str]: ...

    @abstractmethod
    def get_rows(self, table: str, limit: int = 100, offset: int = 0) -> dict:
        """Devuelve {"columns": [...], "rows": [[...], ...]}. 'table' se valida contra list_tables()."""

    @abstractmethod
    def insert_row(self, table: str, values: dict) -> dict:
        """Inserta con parámetros enlazados. Sirve para demostrar triggers."""

    @abstractmethod
    def list_routines(self) -> list[dict]:
        """[{"name": str, "type": "function"|"procedure", "params": [{"name": str, "type": str}]}]"""

    @abstractmethod
    def call_function(self, name: str, params: dict) -> Any: ...

    @abstractmethod
    def call_procedure(self, name: str, params: dict) -> dict:
        """Devuelve {"columns": [...], "rows": [...]} y, si aplica, {"messages": [...]}."""

    @abstractmethod
    def list_triggers(self) -> list[dict]:
        """[{"name": str, "table": str, "events": [str], "definition": str | None}]"""
```

Registro de motores: `ADAPTERS = {"sqlserver": SqlServerAdapter, "postgres": PostgresAdapter, "mysql": MySQLAdapter, "oracle": OracleAdapter}`.

### 7.2 Cadenas de conexión (SQLAlchemy)

| Motor | Driver Python | URL |
|---|---|---|
| SQL Server | `pyodbc` (+ ODBC Driver 18 en la imagen del backend) | `mssql+pyodbc://USER:PASS@HOST:1433/DB?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes` |
| PostgreSQL | `psycopg` | `postgresql+psycopg://USER:PASS@HOST:5432/DB` |
| MySQL | `pymysql` | `mysql+pymysql://USER:PASS@HOST:3306/DB` |
| Oracle | `oracledb` (modo thin, sin cliente Oracle) | `oracle+oracledb://USER:PASS@HOST:1521/?service_name=SERVICIO` |

### 7.3 Endpoints REST del backend

| Método y ruta | Cuerpo / parámetros | Respuesta |
|---|---|---|
| `GET /health` | — | `{"status": "ok"}` |
| `POST /connect` | `{"engine", "host", "port", "database", "user", "password"}` | `{"connection_id": str}` |
| `GET /tables` | cabecera `X-Connection-Id` | `["FERIA", ...]` |
| `GET /tables/{table}/rows` | `limit`, `offset` | `{"columns": [...], "rows": [...]}` |
| `POST /tables/{table}/rows` | `{"values": {col: valor}}` | `{"inserted": 1}` o error (por ejemplo, de un trigger) |
| `GET /routines` | — | lista de funciones y procedimientos con parámetros |
| `POST /routines/{name}/call` | `{"params": {...}}` | resultado: valor, o `{"columns", "rows"}` |
| `GET /triggers` | — | lista de triggers |

**Mayúsculas y minúsculas en los nombres:** cada motor trata distinto los identificadores. Oracle guarda `FERIA` en
mayúsculas, SQL Server conserva como se creó, PostgreSQL pasa a minúsculas (`feria`) y MySQL en Linux distingue
mayúsculas en nombres de tablas. Por eso el backend debe usar **siempre los nombres tal como los devuelve el catálogo**
(`list_tables`, `list_routines`) y comparar sin distinguir mayúsculas al validar lo que llega del frontend.

Reglas: las conexiones activas se guardan **en memoria** (`connection_id`); las contraseñas no se imprimen en logs;
los nombres de tabla y rutina se validan contra el catálogo de la base antes de usarse.
Los errores se devuelven como `{"error": "mensaje claro"}` con código HTTP apropiado.

## 8. Rutinas que se programarán (T-SQL, SQL Server)

Se escriben sobre la base de ferias **sin cambiar el modelo ER** (no se crean tablas nuevas).

| Tipo | Nombre propuesto | Qué hace |
|---|---|---|
| Función | `fn_TotalPuestosFeria(@idFeria)` | Cantidad de puestos asignados a una feria, contando cada ubicación (filas de CONTIENE) |
| Función | `fn_CostoServiciosFeria(@idFeria)` | Suma de `costo` de los servicios de una feria (usa INCLUYE) |
| Procedimiento | `sp_ResumenFeria(@idFeria)` | Datos de la feria, su organizador y sus temáticas |
| Procedimiento con cursor | `sp_PuestosPorUbicacion(@idFeria)` | Recorre con un cursor cada ubicación de la feria y devuelve cuántos puestos tiene |
| Trigger | `trg_ValidarFechasSRE` | En SE_REALIZA_EN, rechaza filas con `fecha_fin < fecha_ini` |

**Valores esperados con rev10** (sirven para comprobar que las funciones están bien):

| idFeria | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `fn_TotalPuestosFeria` | 3 | 7 | 5 | 8 | 6 | 4 | 9 | 11 | 6 | 3 | 5 | 8 | 6 | 5 |
| `fn_CostoServiciosFeria` | 1000 | 2950 | 3450 | 4550 | 2900 | 1650 | 3700 | 6100 | 3700 | 1350 | 2350 | 3500 | 3600 | 2350 |

Para probar el trigger: insertar en `SE_REALIZA_EN` una fila con `fecha_fin` anterior a `fecha_ini` debe fallar con un
mensaje claro, y una fila con fechas válidas debe entrar.

Los nombres exactos pueden ajustarse, pero el frontend y el backend los descubren automáticamente leyendo el
catálogo (`list_routines`, `list_triggers`), por lo que no deben estar escritos a mano en el código.

## 9. Módulos de trabajo (cada integrante tiene uno)

**Módulo 1 — Infraestructura Docker.** `docker-compose.yml` que levanta `sqlserver`, `backend` y `frontend`;
servicios opcionales `postgres`, `mysql` y `oracle` con *profiles*; carga automática de los scripts de `db/`;
`.env.example`. *Listo cuando:* `docker compose up` deja SQL Server funcionando y se puede conectar.

**Módulo 2 — Base de datos.** Portar `rev10` a SQL Server (prioridad), PostgreSQL y MySQL; verificar con los
`COUNT` de cardinalidad 1:N y N:M que los datos varían. *Listo cuando:* los scripts corren sin errores y los totales
de tablas coinciden con Oracle.

**Módulo 3 — Backend núcleo.** FastAPI, `DatabaseAdapter` base, `SqlServerAdapter`, registro de conexiones y los
endpoints de la sección 7.3. *Listo cuando:* desde el navegador (`/docs` de FastAPI) se conecta, lista tablas y
trae filas.

**Módulo 4 — Multi-motor.** `PostgresAdapter`, `MySQLAdapter` y `OracleAdapter` con sus consultas al catálogo
(cada motor guarda sus tablas, rutinas y triggers en lugares distintos). *Listo cuando:* el mismo backend funciona
con PostgreSQL y MySQL de prueba (Oracle al final, si da el tiempo).

**Módulo 5 — Frontend.** Streamlit: formulario de conexión (motor, host, puerto, base, usuario, contraseña),
explorador de tablas con sus filas, ejecución de funciones y procedimientos con campos de parámetros generados
dinámicamente, lista de triggers y una forma de insertar datos para demostrarlos. *Listo cuando:* conectado a la base
se ven tablas y se ejecuta una rutina.

**Módulo 6 — Rutinas SQL.** Las funciones, procedimientos, cursor y trigger de la sección 8 en T-SQL; opcional,
equivalentes simples en PostgreSQL. *Listo cuando:* cada rutina funciona directamente en SQL Server y la
página las lista y las ejecuta.

**Todos los módulos:** escribir su sección en `docs/tutorial-modulo-N.md` (qué hace, cómo se instaló y ejecutó,
problemas encontrados y cómo se resolvieron), y poder explicar su parte oralmente.

## 10. Convenciones

- **Git:** una rama por módulo (`modulo-1-docker`, `modulo-3-backend`, etc.), commits pequeños con mensajes claros
  y hechos por cada integrante con su propia cuenta (sirve de evidencia de aporte individual).
- **Nombres:** Python en `snake_case`; tablas y columnas del modelo **exactamente** como en la sección 6.
- **Secretos:** `.env` en `.gitignore`; solo se sube `.env.example`.
- **Idioma:** comentarios y documentación en español.
- **Estilo de consultas (del docente):** al unir tablas en SQL se usa el estilo clásico con comas en `FROM` y las
  condiciones en `WHERE`, no `JOIN ... ON`, en los scripts y rutinas de la materia.

## 11. Glosario rápido

- **Backend:** programa que atiende las peticiones y habla con la base de datos.
- **Frontend:** página que ve el usuario.
- **API REST:** conjunto de direcciones (endpoints) que el backend ofrece y el frontend consulta.
- **Adaptador:** clase que oculta las diferencias entre motores (cada motor llama rutinas y lee su catálogo distinto).
- **Docker / contenedor:** "caja" con un programa ya instalado y configurado, igual en cualquier PC.
- **Docker Compose:** archivo que levanta varios contenedores juntos con un comando.
- **Cardinalidad 1:N / N:M:** cuántos registros de una tabla se relacionan con cuántos de otra.
- **Trigger:** código que la base ejecuta sola cuando se inserta, actualiza o borra datos.
- **Cursor:** forma de recorrer fila por fila el resultado de una consulta dentro de una rutina.

## 12. Pendientes por confirmar con el docente

- ¿Las funciones, procedimientos, cursores y triggers los creamos nosotros o vienen con la base de otro grupo?
- Formato exacto del tutorial del martes (documento, video o ambos).
- Qué versión y edición de SQL Server espera (Developer, Express o la última comunitaria).
