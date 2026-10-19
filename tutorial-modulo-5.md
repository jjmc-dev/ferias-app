# Módulo 5 — Frontend Streamlit Alumno Hernan Viscarra Arias NRO 66

## Alcance
Este módulo implementa únicamente la interfaz. Consume FastAPI por HTTP/JSON y no abre conexiones directas a los motores SQL. Los endpoints usados son los definidos en el documento del proyecto: `/health`, `/connect`, `/tables`, `/tables/{table}/rows`, `/routines`, `/routines/{name}/call` y `/triggers`.

## Archivos
- `frontend/app.py`: aplicación Streamlit.
- `frontend/requirements.txt`: dependencias.
- `frontend/Dockerfile`: imagen del frontend.

## Ejecutar localmente
Desde la carpeta `frontend`:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
$env:API_BASE_URL = "http://localhost:8000"
streamlit run app.py
```

Abrir `http://localhost:8501`. Asegúrate de que FastAPI esté activo en `http://localhost:8000`.

## Ejecutar con Docker Compose
Integra este servicio en el `docker-compose.yml` que ya tiene el equipo:

```yaml
  frontend:
    build: ./frontend
    environment:
      API_BASE_URL: http://backend:8000
    ports:
      - "8501:8501"
    depends_on:
      - backend
```

Ejecuta desde la raíz del proyecto:

```powershell
docker compose up --build frontend
```

Dentro de Compose, `backend` es el nombre del servicio, por eso se usa `http://backend:8000`, no `localhost`.

## Flujo de prueba
1. Abre `http://localhost:8501`.
2. En **Conexión**, coloca motor, host, puerto, base/servicio, usuario y contraseña.
   - Si SQL Server está en el mismo Compose, el host suele ser `sqlserver`.
   - Puerto SQL Server: `1433`.
3. Pulsa **Conectar**.
4. En **Tablas**, carga la lista y visualiza filas.
5. En **Funciones y procedimientos**, descubre las rutinas publicadas por el catálogo y completa los parámetros que informa el backend.
6. En **Triggers**, consulta los triggers disponibles.
7. En **Insertar datos**, proporciona un objeto JSON de columnas/valores y comprueba la respuesta del backend.

## Preparación para el Módulo 6
El frontend no tiene nombres de funciones, procedimientos ni triggers codificados de forma fija. Cuando el Módulo 6 agregue `fn_TotalPuestosFeria`, `fn_CostoServiciosFeria`, `sp_ResumenFeria`, `sp_PuestosPorUbicacion` y `trg_ValidarFechasSRE` a SQL Server, la interfaz los descubrirá mediante `/routines` y `/triggers`, siempre que el backend exponga los parámetros y resultados según el contrato del proyecto.

## Contrato esperado del backend
- `GET /health` → `{"status":"ok"}`
- `POST /connect` → `{"connection_id":"..."}`
- `GET /tables` → lista de nombres de tabla
- `GET /tables/{table}/rows?limit=100&offset=0` → `{"columns":[...],"rows":[...]}`
- `POST /tables/{table}/rows` con `{"values":{"columna":valor}}`
- `GET /routines` → lista con `name`, `type` y `params`; cada parámetro debería incluir `name` y `type`
- `POST /routines/{name}/call` con `{"params":{...}}`
- `GET /triggers` → lista de triggers

## Nota de integración
El documento de proyecto especifica `X-Connection-Id` para `/tables`, pero no detalla de forma explícita si las demás rutas también requieren esa cabecera. La aplicación la envía a todas las rutas de operaciones de base de datos. Si el backend actual usa otro contrato, ajusta el helper `api_request()` o las rutas correspondientes; no es necesario modificar la arquitectura del frontend.
