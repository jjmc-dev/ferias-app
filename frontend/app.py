import json
import os
from typing import Any

import requests
import streamlit as st

st.set_page_config(page_title="Sistema Ferias | Modulo 5", page_icon="🎪", layout="wide")

DEFAULT_API = os.getenv("API_BASE_URL", "http://backend:8000").rstrip("/")
TIMEOUT = 20

if "api_base" not in st.session_state:
    st.session_state.api_base = DEFAULT_API
if "connection_id" not in st.session_state:
    st.session_state.connection_id = None
if "connected_config" not in st.session_state:
    st.session_state.connected_config = None


def api_request(method: str, path: str, *, payload=None, connection=False):
    base = st.session_state.api_base.rstrip("/")
    headers = {}
    if connection and st.session_state.connection_id:
        headers["X-Connection-Id"] = st.session_state.connection_id
    try:
        response = requests.request(
            method, f"{base}{path}", json=payload, headers=headers, timeout=TIMEOUT
        )
    except requests.RequestException as exc:
        raise RuntimeError(
            f"No se pudo contactar con la API ({base}). Verifica que FastAPI este activo "
            f"y que API_BASE_URL sea correcto. Detalle: {exc}"
        ) from exc

    try:
        data = response.json() if response.content else {}
    except ValueError:
        data = {"detail": response.text}

    if not response.ok:
        message = data.get("error") or data.get("detail") or str(data)
        raise RuntimeError(f"HTTP {response.status_code}: {message}")
    return data


def get_error_message(exc):
    return str(exc)


def normalize_routines(data):
    # El backend puede devolver una lista directamente o {"routines": [...]}.
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        for key in ("routines", "items", "data", "results"):
            if isinstance(data.get(key), list):
                return data[key]
    return []


def routine_name(item):
    return item.get("name") or item.get("routine_name") or item.get("nombre") or ""


def routine_type(item):
    return str(item.get("type") or item.get("routine_type") or item.get("tipo") or "procedure").lower()


def routine_params(item):
    params = item.get("params") or item.get("parameters") or item.get("parametros") or []
    if isinstance(params, dict):
        return [{"name": k, "type": v} for k, v in params.items()]
    return params if isinstance(params, list) else []


def param_name(param):
    if isinstance(param, str):
        return param.lstrip("@")
    return str(param.get("name") or param.get("parameter_name") or param.get("nombre") or "parametro").lstrip("@")

def param_type(param):
    if isinstance(param, str):
        return "string"
    return str(param.get("type") or param.get("data_type") or param.get("tipo") or "string").lower()


def parse_value(raw: str, kind: str) -> Any:
    kind = kind.lower()
    if raw == "" and any(x in kind for x in ("int", "decimal", "numeric", "float", "real", "money")):
        return None
    if any(x in kind for x in ("int", "bigint", "smallint", "tinyint")):
        return int(raw) if raw.strip() else None
    if any(x in kind for x in ("decimal", "numeric", "float", "real", "money")):
        return float(raw) if raw.strip() else None
    if "bit" in kind or "bool" in kind:
        if raw.lower() in ("1", "true", "si", "sí", "yes"):
            return True
        if raw.lower() in ("0", "false", "no"):
            return False
    return raw if raw != "" else None


def show_result(data):
    st.subheader("Resultado")
    if isinstance(data, dict) and "columns" in data and "rows" in data:
        columns, rows = data.get("columns", []), data.get("rows", [])
        if rows:
            st.dataframe(
                [dict(zip(columns, row)) for row in rows] if columns and isinstance(rows[0], (list, tuple)) else rows,
                use_container_width=True,
            )
        else:
            st.info("La rutina se ejecuto, pero no devolvio filas.")
        if data.get("messages"):
            for message in data["messages"]:
                st.caption(str(message))
    elif isinstance(data, dict) and "value" in data:
        st.code(str(data["value"]))
    else:
        st.json(data)


st.title("🎪 Sistema de Ferias")
st.caption("Modulo 5 · Interfaz Streamlit para el backend FastAPI")

with st.sidebar:
    st.header("API del backend")
    api_url = st.text_input("URL base de FastAPI", value=st.session_state.api_base)
    if st.button("Guardar URL", use_container_width=True):
        st.session_state.api_base = api_url.strip().rstrip("/")
        st.success("URL actualizada.")
    st.caption("En Docker Compose usa el nombre del servicio, por ejemplo http://backend:8000.")
    if st.button("Comprobar API", use_container_width=True):
        try:
            result = api_request("GET", "/health")
            st.success(f"API disponible: {result}")
        except Exception as exc:
            st.error(get_error_message(exc))

tab_connect, tab_tables, tab_routines, tab_triggers, tab_insert = st.tabs(
    ["🔌 Conexion", "🗂️ Tablas", "⚙️ Funciones y procedimientos", "⚡ Triggers", "➕ Insertar datos"]
)

with tab_connect:
    st.header("Conectar a una base de datos")
    st.write("Los datos se envian al backend. La interfaz no abre conexiones directas con la base de datos.")
    with st.form("connection_form"):
        c1, c2 = st.columns(2)
        with c1:
            engine = st.selectbox("Motor", ["sqlserver", "postgres", "mysql", "oracle"], index=0)
            host = st.text_input("Host", value="sqlserver")
            port_default = {"sqlserver": 1433, "postgres": 5432, "mysql": 3306, "oracle": 1521}[engine]
            port = st.number_input("Puerto", min_value=1, max_value=65535, value=port_default, step=1)
        with c2:
            database_label = "Servicio (Oracle)" if engine == "oracle" else "Base de datos"
            database = st.text_input(database_label, value="ferias")
            user = st.text_input("Usuario", value="sa" if engine == "sqlserver" else "")
            password = st.text_input("Contraseña", type="password")
        submitted = st.form_submit_button("Conectar", type="primary", use_container_width=True)
    if submitted:
        if not host.strip() or not database.strip() or not user.strip() or not password:
            st.error("Completa host, base/servicio, usuario y contraseña.")
        else:
            try:
                data = api_request("POST", "/connect", payload={
                    "engine": engine, "host": host.strip(), "port": int(port),
                    "database": database.strip(), "user": user.strip(), "password": password
                })
                cid = data.get("connection_id")
                if not cid:
                    raise RuntimeError(f"La API no devolvio connection_id: {data}")
                st.session_state.connection_id = cid
                st.session_state.connected_config = {
                    "engine": engine, "host": host.strip(), "port": int(port),
                    "database": database.strip(), "user": user.strip()
                }
                st.success("Conexion establecida.")
                st.json(st.session_state.connected_config)
            except Exception as exc:
                st.error(get_error_message(exc))

    if st.session_state.connection_id:
        st.success("Hay una conexion activa en esta sesion.")
        st.code(st.session_state.connection_id)
        if st.button("Desconectar de la interfaz"):
            st.session_state.connection_id = None
            st.session_state.connected_config = None
            st.info("Se elimino el identificador de esta sesion de Streamlit. Si el backend ofrece un endpoint de desconexion, se puede conectar aqui.")

def require_connection():
    if not st.session_state.connection_id:
        st.warning("Primero abre la pestaña Conexion y conecta una base de datos.")
        return False
    return True

with tab_tables:
    st.header("Explorador de tablas")
    if require_connection():
        a, b = st.columns([1, 1])
        with a:
            if st.button("Cargar lista de tablas", key="load_tables", type="primary"):
                try:
                    data = api_request("GET", "/tables", connection=True)
                    st.session_state.tables_data = data
                except Exception as exc:
                    st.error(get_error_message(exc))
        tables_data = st.session_state.get("tables_data")
        if tables_data is not None:
            tables = tables_data if isinstance(tables_data, list) else tables_data.get("tables", [])
            if tables:
                table = st.selectbox("Tabla", options=tables)
                limit = st.number_input("Cantidad maxima de filas", min_value=1, max_value=500, value=100, step=10)
                offset = st.number_input("Desplazamiento (offset)", min_value=0, value=0, step=10)
                if st.button("Ver registros", key="view_rows"):
                    try:
                        data = api_request("GET", f"/tables/{requests.utils.quote(str(table), safe='')}/rows?limit={int(limit)}&offset={int(offset)}", connection=True)
                        show_result(data)
                    except Exception as exc:
                        st.error(get_error_message(exc))
            else:
                st.info("No se recibio una lista de tablas. Revisa el formato de respuesta del backend.")

with tab_routines:
    st.header("Ejecutar funciones y procedimientos")
    if require_connection():
        if st.button("Descubrir rutinas", type="primary"):
            try:
                st.session_state.routines_data = normalize_routines(api_request("GET", "/routines", connection=True))
            except Exception as exc:
                st.error(get_error_message(exc))
        routines = st.session_state.get("routines_data", [])
        if routines:
            options = [routine_name(item) for item in routines if routine_name(item)]
            selected_name = st.selectbox("Rutina disponible", options=options)
            selected = next((item for item in routines if routine_name(item) == selected_name), {})
            st.caption(f"Tipo: {routine_type(selected)}")
            params = routine_params(selected)
            values = {}
            if params:
                st.write("Introduce los parametros que requiere la rutina:")
                with st.form("routine_call_form"):
                    for index, param in enumerate(params):
                        name = param_name(param)
                        kind = param_type(param)
                        values[name] = st.text_input(f"{name} · {kind}", key=f"routine_{selected_name}_{index}")
                    run_routine = st.form_submit_button("Ejecutar rutina", type="primary")
                if run_routine:
                    try:
                        parsed = {param_name(p): parse_value(values[param_name(p)], param_type(p)) for p in params}
                        result = api_request(
                            "POST", f"/routines/{requests.utils.quote(selected_name, safe='')}/call",
                            payload={"params": parsed}, connection=True
                        )
                        show_result(result)
                    except Exception as exc:
                        st.error(get_error_message(exc))
            else:
                st.info("El catalogo no informa parametros. Se puede intentar ejecutar sin parametros.")
                if st.button("Ejecutar sin parametros"):
                    try:
                        result = api_request("POST", f"/routines/{requests.utils.quote(selected_name, safe='')}/call", payload={"params": {}}, connection=True)
                        show_result(result)
                    except Exception as exc:
                        st.error(get_error_message(exc))
        else:
            st.info("Pulsa «Descubrir rutinas». Las rutinas se cargan desde el catalogo de la base, no estan codificadas a mano.")

with tab_triggers:
    st.header("Triggers de la base de datos")
    if require_connection():
        if st.button("Listar triggers", type="primary"):
            try:
                st.session_state.triggers_data = api_request("GET", "/triggers", connection=True)
            except Exception as exc:
                st.error(get_error_message(exc))
        triggers = st.session_state.get("triggers_data")
        if triggers is not None:
            if isinstance(triggers, dict):
                triggers = triggers.get("triggers", triggers.get("items", []))
            if triggers:
                st.dataframe(triggers, use_container_width=True)
                with st.expander("Ver definiciones completas"):
                    st.json(triggers)
            else:
                st.info("No hay triggers registrados en el catalogo, o el backend devolvio una lista vacia.")

with tab_insert:
    st.header("Insertar datos para probar triggers")
    st.warning("La insercion modifica la base de datos. Usa datos de prueba y verifica las restricciones antes de confirmar.")
    if require_connection():
        st.write("Selecciona una tabla y completa los valores. Las columnas se obtienen de las filas devueltas por el backend; para una tabla vacia, consulta el esquema en la base.")
        table_names = st.session_state.get("tables_data")
        if isinstance(table_names, dict):
            table_names = table_names.get("tables", [])
        if table_names:
            target_table = st.selectbox("Tabla destino", options=table_names, key="insert_table")
            with st.form("insert_form"):
                raw_values = st.text_area(
                    "Valores en formato JSON",
                    value='{\n  "idFeria": 1,\n  "idUbicacion": 1,\n  "fecha_ini": "2026-10-20",\n  "fecha_fin": "2026-10-21"\n}',
                    height=180,
                    help="Usa nombres de columnas reales y tipos compatibles. Este ejemplo es orientativo para SE_REALIZA_EN."
                )
                do_insert = st.form_submit_button("Insertar registro", type="primary")
            if do_insert:
                try:
                    values = json.loads(raw_values)
                    if not isinstance(values, dict):
                        raise ValueError("El JSON debe ser un objeto con formato {columna: valor}.")
                    result = api_request(
                        "POST", f"/tables/{requests.utils.quote(str(target_table), safe='')}/rows",
                        payload={"values": values}, connection=True
                    )
                    st.success("La API acepto la insercion.")
                    show_result(result)
                except Exception as exc:
                    st.error(get_error_message(exc))
        else:
            st.info("Primero carga las tablas desde la pestaña Tablas para habilitar la insercion.")
