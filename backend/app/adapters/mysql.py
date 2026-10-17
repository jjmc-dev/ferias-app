from typing import Any

from sqlalchemy import create_engine, text

from .base import DatabaseAdapter


def _q(nombre: str) -> str:
    """Entrecomilla con acentos graves un nombre ya validado contra el catalogo."""
    return "`" + nombre.replace("`", "``") + "`"


class MySQLAdapter(DatabaseAdapter):
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
            SELECT table_name AS nombre
            FROM information_schema.tables
            WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE'
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
            SELECT column_name AS nombre
            FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = :t
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
            SELECT routine_name AS nombre, routine_type AS tipo, specific_name AS especifico
            FROM information_schema.routines
            WHERE routine_schema = DATABASE()
            ORDER BY routine_name
        """
        sql_params = """
            SELECT parameter_name AS nombre, data_type AS tipo
            FROM information_schema.parameters
            WHERE specific_schema = DATABASE()
              AND specific_name = :esp
              AND ordinal_position > 0
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

    def _valores_en_orden(self, rutina: dict, params: dict) -> list:
        recibidos = {k.lower(): v for k, v in params.items()}
        valores = []
        for p in rutina["params"]:
            clave = (p["name"] or "").lower()
            if clave not in recibidos:
                raise ValueError(f"Falta el parametro '{p['name']}'")
            valores.append(recibidos[clave])
        return valores

    def call_function(self, name: str, params: dict) -> Any:
        rutina = self._rutina(name, "function")
        valores = self._valores_en_orden(rutina, params)
        marcadores = ", ".join(f":p{i}" for i in range(len(valores)))
        sql = f"SELECT {_q(rutina['name'])}({marcadores}) AS resultado"
        with self.engine.begin() as con:
            return con.execute(text(sql), {f"p{i}": v for i, v in enumerate(valores)}).scalar()

    def call_procedure(self, name: str, params: dict) -> dict:
        rutina = self._rutina(name, "procedure")
        valores = self._valores_en_orden(rutina, params)
        # Un CALL de MySQL puede devolver varios resultados: se usa el cursor del driver.
        raw = self.engine.raw_connection()
        try:
            cur = raw.cursor()
            cur.callproc(rutina["name"], tuple(valores))
            conjuntos = []
            while True:
                if cur.description:
                    conjuntos.append({
                        "columns": [d[0] for d in cur.description],
                        "rows": [list(f) for f in cur.fetchall()],
                    })
                if not cur.nextset():
                    break
            raw.commit()
        finally:
            raw.close()
        if not conjuntos:
            return {"columns": [], "rows": [], "messages": ["Procedimiento ejecutado correctamente"]}
        respuesta = {"columns": conjuntos[0]["columns"], "rows": conjuntos[0]["rows"], "messages": []}
        if len(conjuntos) > 1:
            respuesta["extra_resultsets"] = conjuntos[1:]
        return respuesta

    # ---------- triggers ----------
    def list_triggers(self) -> list[dict]:
        sql = """
            SELECT trigger_name AS nombre, event_object_table AS tabla,
                   event_manipulation AS evento, action_timing AS momento,
                   action_statement AS cuerpo
            FROM information_schema.triggers
            WHERE trigger_schema = DATABASE()
            ORDER BY trigger_name
        """
        triggers = {}
        with self.engine.connect() as con:
            for nombre, tabla, evento, momento, cuerpo in con.execute(text(sql)):
                t = triggers.setdefault(
                    nombre,
                    {"name": nombre, "table": tabla, "events": [], "timing": momento, "definition": cuerpo},
                )
                t["events"].append(evento)
        return list(triggers.values())
