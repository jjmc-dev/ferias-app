from typing import Any

from sqlalchemy import create_engine, text

from .base import DatabaseAdapter


def _q(nombre: str) -> str:
    """Entrecomilla un nombre (tabla, columna, rutina) que ya fue validado contra el catalogo."""
    return '"' + nombre.replace('"', '""') + '"'


class PostgresAdapter(DatabaseAdapter):
    def __init__(self, url: str):
        super().__init__(url)
        self.engine = create_engine(url, pool_pre_ping=True)

    # ---------- conexion ----------
    def test_connection(self) -> bool:
        try:
            with self.engine.connect() as con:
                con.execute(text("SELECT 1"))
            return True
        except Exception:
            return False

    # ---------- tablas ----------
    def list_tables(self) -> list[str]:
        sql = """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = current_schema() AND table_type = 'BASE TABLE'
            ORDER BY table_name
        """
        with self.engine.connect() as con:
            return [fila[0] for fila in con.execute(text(sql))]

    def _tabla_real(self, tabla: str) -> str:
        """Devuelve el nombre tal como esta en el catalogo (sin distinguir mayusculas)."""
        for nombre in self.list_tables():
            if nombre.lower() == tabla.lower():
                return nombre
        raise ValueError(f"La tabla '{tabla}' no existe")

    def get_rows(self, table: str, limit: int = 100, offset: int = 0) -> dict:
        real = self._tabla_real(table)
        sql = f"SELECT * FROM {_q(real)} LIMIT :limite OFFSET :desde"
        with self.engine.connect() as con:
            res = con.execute(text(sql), {"limite": int(limit), "desde": int(offset)})
            return {"columns": list(res.keys()), "rows": [list(f) for f in res]}

    def _columnas(self, tabla_real: str) -> list[str]:
        sql = """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = current_schema() AND table_name = :t
            ORDER BY ordinal_position
        """
        with self.engine.connect() as con:
            return [f[0] for f in con.execute(text(sql), {"t": tabla_real})]

    def insert_row(self, table: str, values: dict) -> dict:
        real = self._tabla_real(table)
        validas = {c.lower(): c for c in self._columnas(real)}
        columnas, params = [], {}
        for i, (col, valor) in enumerate(values.items()):
            if col.lower() not in validas:
                raise ValueError(f"La columna '{col}' no existe en '{real}'")
            columnas.append(_q(validas[col.lower()]))
            params[f"p{i}"] = valor
        if not columnas:
            raise ValueError("No hay valores para insertar")
        marcadores = ", ".join(f":p{i}" for i in range(len(columnas)))
        sql = f"INSERT INTO {_q(real)} ({', '.join(columnas)}) VALUES ({marcadores})"
        with self.engine.begin() as con:
            res = con.execute(text(sql), params)
            return {"inserted": res.rowcount}

    # ---------- rutinas ----------
    def list_routines(self) -> list[dict]:
        sql_rutinas = """
            SELECT routine_name, routine_type, specific_name
            FROM information_schema.routines
            WHERE routine_schema = current_schema()
              AND (data_type IS NULL OR data_type <> 'trigger')
            ORDER BY routine_name
        """
        sql_params = """
            SELECT parameter_name, data_type
            FROM information_schema.parameters
            WHERE specific_schema = current_schema()
              AND specific_name = :esp
              AND parameter_mode IN ('IN', 'INOUT')
            ORDER BY ordinal_position
        """
        resultado = []
        with self.engine.connect() as con:
            for nombre, tipo, especifico in con.execute(text(sql_rutinas)).fetchall():
                params = [
                    {"name": p[0], "type": p[1]}
                    for p in con.execute(text(sql_params), {"esp": especifico})
                ]
                resultado.append({"name": nombre, "type": tipo.lower(), "params": params})
        return resultado

    def _rutina(self, nombre: str, tipo: str) -> dict:
        for r in self.list_routines():
            if r["name"].lower() == nombre.lower():
                if r["type"] != tipo:
                    raise ValueError(f"'{r['name']}' es un {r['type']}, no un {tipo}")
                return r
        raise ValueError(f"La rutina '{nombre}' no existe")

    def _armar_llamada(self, rutina: dict, params: dict):
        recibidos = {k.lower(): v for k, v in params.items()}
        marcadores, valores = [], {}
        for i, p in enumerate(rutina["params"]):
            clave = (p["name"] or "").lower()
            if clave not in recibidos:
                raise ValueError(f"Falta el parametro '{p['name']}'")
            marcadores.append(f"CAST(:p{i} AS {p['type']})")
            valores[f"p{i}"] = recibidos[clave]
        return ", ".join(marcadores), valores

    def call_function(self, name: str, params: dict) -> Any:
        rutina = self._rutina(name, "function")
        marcadores, valores = self._armar_llamada(rutina, params)
        sql = f"SELECT * FROM {_q(rutina['name'])}({marcadores})"
        with self.engine.begin() as con:
            res = con.execute(text(sql), valores)
            columnas = list(res.keys())
            filas = [list(f) for f in res]
        if len(columnas) == 1 and len(filas) == 1:
            return filas[0][0]
        return {"columns": columnas, "rows": filas}

    def call_procedure(self, name: str, params: dict) -> dict:
        rutina = self._rutina(name, "procedure")
        marcadores, valores = self._armar_llamada(rutina, params)
        sql = f"CALL {_q(rutina['name'])}({marcadores})"
        with self.engine.begin() as con:
            res = con.execute(text(sql), valores)
            if res.returns_rows:
                return {"columns": list(res.keys()), "rows": [list(f) for f in res], "messages": []}
        return {"columns": [], "rows": [], "messages": ["Procedimiento ejecutado correctamente"]}

    # ---------- triggers ----------
    def list_triggers(self) -> list[dict]:
        sql_eventos = """
            SELECT trigger_name, event_object_table, event_manipulation, action_timing
            FROM information_schema.triggers
            WHERE trigger_schema = current_schema()
            ORDER BY trigger_name
        """
        sql_def = """
            SELECT t.tgname, pg_get_triggerdef(t.oid)
            FROM pg_trigger t, pg_class c, pg_namespace n
            WHERE c.oid = t.tgrelid AND n.oid = c.relnamespace
              AND n.nspname = current_schema() AND NOT t.tgisinternal
        """
        triggers = {}
        with self.engine.connect() as con:
            for nombre, tabla, evento, momento in con.execute(text(sql_eventos)):
                t = triggers.setdefault(
                    nombre,
                    {"name": nombre, "table": tabla, "events": [], "timing": momento, "definition": None},
                )
                t["events"].append(evento)
            for nombre, definicion in con.execute(text(sql_def)):
                if nombre in triggers:
                    triggers[nombre]["definition"] = definicion
        return list(triggers.values())
