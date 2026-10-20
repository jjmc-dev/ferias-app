# Tutorial Módulo 3 — Backend núcleo

**Grupo 5 · Taller de Base de Datos · Gestión 2/2026**
**Lenguaje:** Python 3.12 · **Framework:** FastAPI · **Acceso a datos:** SQLAlchemy + pyodbc
**Motor probado:** SQL Server 2025 (Docker) · **Rama:** `modulo-3-backend`

---

## 1. Qué hace este módulo

Es el programa que está entre el frontend (Streamlit) y la base de datos. Ofrece una API REST con la que se puede:

- conectarse a una base de datos,
- listar sus tablas y ver sus filas,
- insertar filas (sirve para demostrar triggers),
- listar y ejecutar funciones y procedimientos,
- listar los triggers.

Es **genérico**: no sabe nada de la base de ferias. Todo lo que necesita (tablas, rutinas, triggers) lo descubre leyendo el catálogo de la base. Por eso puede conectarse a la base de otro grupo.

### Idea central: adaptadores

El backend no habla directamente con SQL Server. Habla con una clase abstracta, `DatabaseAdapter`, que define qué operaciones existen. Cada motor tiene su propia clase que la implementa (`SqlServerAdapter` hoy; PostgreSQL, MySQL y Oracle los hará el Módulo 4). Cambiar de motor significa elegir otra clase, sin tocar los endpoints.

```
Frontend ──HTTP/JSON──> Routers (FastAPI) ──> DatabaseAdapter ──> SqlServerAdapter ──> SQL Server
```

---

## 2. Estructura de archivos

```
backend/
├─ requirements.txt
└─ app/
   ├─ main.py            Crea la app, registra routers y formatea los errores
   ├─ connections.py     Registro de conexiones en memoria + build_url()
   ├─ schemas.py         Modelos Pydantic (validan el JSON que llega)
   ├─ dependencies.py    get_adapter(): lee X-Connection-Id y entrega el adaptador
   ├─ routers/
   │  ├─ connection.py   POST /connect
   │  ├─ tables.py       GET /tables, GET y POST /tables/{table}/rows
   │  ├─ routines.py     GET /routines, POST /routines/{name}/call
   │  └─ triggers.py     GET /triggers
   └─ adapters/
      ├─ __init__.py     ADAPTERS = {"sqlserver": SqlServerAdapter}
      ├─ base.py         Clase abstracta DatabaseAdapter (contrato)
      └─ sqlserver.py    Implementación para SQL Server
```

Equivalencias con Node/Express: `routers/` ≈ archivos de rutas, `adapters/` ≈ capa de modelos/acceso a datos, `schemas.py` ≈ DTOs, `Depends(get_adapter)` ≈ middleware.

---

## 3. Requisitos

| Requisito | Para qué |
|---|---|
| Windows 10/11 con PowerShell | Sistema del grupo |
| Python 3.12 | Lenguaje |
| Docker Desktop (WSL2) | Correr SQL Server |
| ODBC Driver 18 for SQL Server | Driver que usa `pyodbc` desde Windows |
| Git / GitHub Desktop | Control de versiones |

Librerías (`requirements.txt`): `fastapi`, `uvicorn[standard]`, `sqlalchemy`, `pyodbc`, `python-dotenv`.

---

## 4. Instalación y ejecución

### 4.1 Entorno virtual e instalación de librerías

```powershell
cd ferias-app\backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

- `py -m venv .venv` crea un entorno aislado (equivalente a `node_modules`).
- `Activate.ps1` lo activa; se ve `(.venv)` al inicio de la línea. **Hay que activarlo en cada terminal nueva.**
- `pip install -r requirements.txt` instala las dependencias (como `npm install`).

### 4.2 Levantar SQL Server de prueba con Docker

```powershell
$env:MSSQL_SA_PASSWORD = Ferias_2026#Db
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=$env:MSSQL_SA_PASSWORD" -p 1433:1433 --name sqlserver-test -d mcr.microsoft.com/mssql/server:2025-latest
```

La contraseña debe ser fuerte (mayúsculas, minúsculas, números y símbolos) o el contenedor se apaga. No se escribe en ningún archivo que se suba a Git.

### 4.3 Cargar la base de ferias

```powershell
docker exec sqlserver-test /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "<contraseña>" -C -Q "CREATE DATABASE ferias"
docker cp db\sqlserver\create_insert.sql sqlserver-test:/tmp/create_insert.sql
docker exec sqlserver-test /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "<contraseña>" -C -d ferias -f 65001 -i /tmp/create_insert.sql
```

Verificación: `SELECT COUNT(*) FROM FERIA` debe dar **14** y `PUESTO` debe dar **34**.

### 4.4 Instalar el ODBC Driver 18 (solo si el backend corre fuera de Docker)

Descargar "ODBC Driver 18 for SQL Server" (x64) desde Microsoft e instalarlo. Comprobar:

```powershell
python -c "import pyodbc; print(pyodbc.drivers())"
```

La lista debe incluir `ODBC Driver 18 for SQL Server`.

### 4.5 Ejecutar el backend

```powershell
cd ferias-app\backend
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload
```

- `app.main:app` = paquete `app`, archivo `main.py`, variable `app`.
- `--reload` reinicia el servidor al guardar cambios (como `nodemon`).
- Documentación interactiva: http://127.0.0.1:8000/docs

> Al reiniciarse el servidor se pierden las conexiones (están en memoria). Hay que repetir `POST /connect`.

---

## 5. Endpoints

| Método y ruta | Cuerpo / parámetros | Respuesta |
|---|---|---|
| `GET /health` | — | `{"status": "ok"}` |
| `POST /connect` | `{engine, host, port, database, user, password}` | `{"connection_id": "..."}` |
| `GET /tables` | cabecera `X-Connection-Id` | lista de nombres de tablas |
| `GET /tables/{table}/rows` | `limit`, `offset` | `{"columns": [...], "rows": [...]}` |
| `POST /tables/{table}/rows` | `{"values": {col: valor}}` | `{"inserted": 1}` o error |
| `GET /routines` | — | funciones y procedimientos con parámetros |
| `POST /routines/{name}/call` | `{"params": {...}}` | valor, o `{columns, rows, messages}` |
| `GET /triggers` | — | lista de triggers |

Todos los errores salen como `{"error": "mensaje claro"}` con código HTTP apropiado (400, 401, 404, 422, 502).

### Prueba rápida en /docs

1. `POST /connect` con los datos de la base. Copiar el `connection_id`.
2. En cualquier otro endpoint, pulsar *Try it out* y pegar el id en la cabecera `x-connection-id`.

---

## 6. Cómo funciona (para explicar en clase)

**Flujo de una petición.** El frontend manda JSON. FastAPI lo valida con Pydantic (`schemas.py`). El router pide el adaptador con `Depends(get_adapter)`, que lee la cabecera `X-Connection-Id` y busca el adaptador en el diccionario de `connections.py`. El router llama al método del adaptador, y el adaptador ejecuta el SQL.

**¿Cómo sabe a qué motor conectarse?** El campo `engine` de `POST /connect` se busca en el diccionario `ADAPTERS`. `build_url()` arma la URL de SQLAlchemy de ese motor. Con otro motor (por ejemplo PostgreSQL) solo se agrega una clase y una línea en `ADAPTERS`.

**¿Cómo se evita la inyección SQL?**
1. Los valores van siempre como parámetros enlazados (`:value_0`), nunca concatenados.
2. Los nombres de tabla, columna y rutina se validan contra el catálogo de la base antes de usarse (sin distinguir mayúsculas).
3. Los identificadores se escapan con el `identifier_preparer` de SQLAlchemy.
4. El frontend nunca manda SQL libre.

**¿Por qué `URL.create` y no un texto?** Escapa solos los caracteres especiales de la contraseña (`@`, `/`, `:`).

**Función vs. procedimiento.** Una función devuelve un valor y se usa dentro de un `SELECT` (`SELECT dbo.fn(@x)`). Un procedimiento se ejecuta con `EXEC`, puede devolver un conjunto de filas y modificar datos. El backend descubre cuál es leyendo el catálogo (`sys.objects`), por eso el frontend no tiene que decirlo.

**Catálogo de SQL Server usado:** `sys.objects` y `sys.schemas` (rutinas), `sys.parameters` (parámetros), `sys.triggers` (triggers).

**Seguridad.** Las contraseñas no se imprimen en logs (`hide_password=True` al mostrar URLs). Las conexiones activas viven solo en memoria.

---

## 7. Problemas encontrados y cómo se resolvieron

| Problema | Causa | Solución |
|---|---|---|
| `python` no se reconoce, aparece mensaje de Microsoft Store | Windows intercepta `python` con un alias de la Store | Usar `py`, o desactivar los alias en *Configuración → Aplicaciones → Alias de ejecución de aplicaciones* |
| `python` no se reconoce en una terminal nueva | El entorno virtual no estaba activado | `.\.venv\Scripts\Activate.ps1` |
| `__abstractmethods__` no salía vacío | Los `def` de `sqlserver.py` estaban fuera de la clase (mala indentación) | Indentar 4 espacios todo el cuerpo de la clase |
| `docker ps` falla con `dockerDesktopLinuxEngine` | Docker Desktop no estaba encendido | Abrirlo y esperar "Engine running" |
| `pyodbc.drivers()` no mostraba el Driver 18 | No estaba instalado en Windows | Instalar ODBC Driver 18 y abrir una terminal nueva |
| Un procedimiento aparecía como `function` | `o.type` es `char(2)`: llega `'P '` con espacio | `.strip()` antes de comparar |
| Parámetros salían como `@idFeria` | SQL Server guarda el `@` en `sys.parameters` | `.lstrip("@")` al listarlos; el `EXEC` vuelve a ponerlo |
| `call_function` tenía el esquema `dbo` fijo | Código escrito a mano | `list_routines` devuelve `schema` y `call_function` lo usa |
| `ImportError: cannot import name 'CallRequest'` | Faltaba guardar la clase en `schemas.py` | Agregar y guardar la clase |
| `git` no se reconoce en PowerShell | El repo se maneja con GitHub Desktop | Usar GitHub Desktop para commits y push |

---

## 8. Cambios respecto al contrato (solo agregan, no rompen)

- `DatabaseAdapter` tiene un método `close()` con implementación por defecto.
- `list_routines` devuelve un campo extra `schema`, y los nombres de parámetros van sin `@`.
- Se agregaron `routers/`, `schemas.py` y `dependencies.py` para ordenar el código.

---

## 9. Pendiente

- [ ] **PENDIENTE:** `list_triggers` con `sys.trigger_events` (hoy detecta eventos buscando texto).
- [ ] **PENDIENTE:** `call_procedure` con commit (`engine.begin()`).
- [ ] **PENDIENTE:** Dockerfile del backend con ODBC Driver 18.
- [ ] **PENDIENTE:** probar el trigger `trg_ValidarFechasSRE` y las rutinas oficiales del Módulo 6 cuando estén listas.