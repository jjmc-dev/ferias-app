from typing import Any

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.engine import URL
from sqlalchemy.exc import SQLAlchemyError

from app.adapters.base import DatabaseAdapter

class SqlServerAdapter(DatabaseAdapter): 
    """Adaptador para trabajar con SQL Server mediante SQLAlchemy."""


    def __init__(self, url: str):
        super().__init__(url)
        self.engine = create_engine(url, pool_pre_ping=True)

    def close(self) -> None:
        """Cierra las conexiones administradas por SQLAlchemy."""
        self.engine.dispose()

    def test_connection(self) -> bool:
        """Comprueba si SQL Server acepta conexiones."""
        try:
            with self.engine.connect() as connection:
                connection.execute(text("SELECT 1"))
            return True
        except SQLAlchemyError:
            return False

    def list_tables(self) -> list[str]:
        """Devuelve los nombres reales de las tablas del catálogo."""
        inspector = inspect(self.engine)
        return inspector.get_table_names()

    def get_rows(
        self, table: str, limit: int = 100, offset: int = 0
    ) -> dict:
        """Devuelve las columnas y filas de una tabla validada."""
        if limit < 1 or limit > 1000:
            raise ValueError("limit debe estar entre 1 y 1000.")
        if offset < 0:
            raise ValueError("offset no puede ser negativo.")

        tables = self.list_tables()
        real_table = next(
            (name for name in tables if name.casefold() == table.casefold()),
            None,
        )
        if real_table is None:
            raise ValueError("La tabla solicitada no existe.")

        quoted_table = self.engine.dialect.identifier_preparer.quote(
            real_table
        )
        query = text(
            f"SELECT * FROM {quoted_table} "
            "ORDER BY (SELECT NULL) "
            "OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY"
        )

        with self.engine.connect() as connection:
            result = connection.execute(
                query, {"offset": offset, "limit": limit}
            )
            return {
                "columns": list(result.keys()),
                "rows": [list(row) for row in result.fetchall()],
            }

    def insert_row(self, table: str, values: dict) -> dict:
        """Inserta una fila con valores enlazados."""
        if not values:
            raise ValueError("Debes proporcionar al menos un valor.")

        inspector = inspect(self.engine)
        tables = inspector.get_table_names()
        real_table = next(
            (name for name in tables if name.casefold() == table.casefold()),
            None,
        )
        if real_table is None:
            raise ValueError("La tabla solicitada no existe.")

        columns = inspector.get_columns(real_table)
        real_columns = {column["name"].casefold(): column["name"] for column in columns}

        normalized_values = {}
        for name, value in values.items():
            real_name = real_columns.get(name.casefold())
            if real_name is None:
                raise ValueError(f"La columna '{name}' no existe.")
            normalized_values[real_name] = value

        preparer = self.engine.dialect.identifier_preparer
        quoted_table = preparer.quote(real_table)
        quoted_columns = [
            preparer.quote(name) for name in normalized_values
        ]
        parameters = {
            f"value_{index}": value
            for index, value in enumerate(normalized_values.values())
        }
        placeholders = [
            f":value_{index}" for index in range(len(parameters))
        ]

        query = text(
            f"INSERT INTO {quoted_table} "
            f"({', '.join(quoted_columns)}) "
            f"VALUES ({', '.join(placeholders)})"
        )

        with self.engine.begin() as connection:
            connection.execute(query, parameters)

        return {"inserted": 1}

    def list_routines(self) -> list[dict]:
        """Lista procedimientos y funciones definidos por el usuario."""
        query = text("""
            SELECT
                o.name AS routine_name,
                o.type AS routine_type,
                s.name AS schema_name
            FROM sys.objects AS o
            INNER JOIN sys.schemas AS s
                ON s.schema_id = o.schema_id
            WHERE o.type IN ('P', 'FN', 'IF', 'TF', 'FS', 'FT')
            AND s.name = SCHEMA_NAME()
            ORDER BY o.name
        """)

        with self.engine.connect() as connection:
            routines = connection.execute(query).mappings().all()

        result = []
        for routine in routines:
            routine_type = (
                "procedure" if routine["routine_type"].strip() == "P" else "function"
            )
            result.append(
                {
                    "name": routine["routine_name"],
                    "schema": routine["schema_name"],
                    "type": routine_type,
                    "params": self._get_routine_params(
                        routine["routine_name"], routine_type
                    ),
                }
            )
        return result

    def _get_routine_params(
        self, name: str, routine_type: str
    ) -> list[dict]:
        """Obtiene los parámetros declarados de una rutina."""
        query = text("""
            SELECT
                p.name AS param_name,
                TYPE_NAME(p.user_type_id) AS param_type
            FROM sys.parameters AS p
            INNER JOIN sys.objects AS o
                ON o.object_id = p.object_id
            INNER JOIN sys.schemas AS s
                ON s.schema_id = o.schema_id
            WHERE o.name = :name
            AND s.name = SCHEMA_NAME()
            AND p.parameter_id > 0
            ORDER BY p.parameter_id
        """)

        with self.engine.connect() as connection:
            params = connection.execute(query, {"name": name}).mappings().all()

        return [
            {"name": param["param_name"].lstrip("@"), "type": param["param_type"]}
            for param in params
        ]

    def call_function(self, name: str, params: dict) -> Any:
        """Ejecuta una función validada en el catálogo."""
        routine = self._find_routine(name, "function")
        routine_name = routine["name"]
        routine_params = routine["params"]

        expected_params = {p["name"] for p in routine_params}
        if set(params) != expected_params:
            raise ValueError(
                "Los parámetros no coinciden con la función."
            )

        preparer = self.engine.dialect.identifier_preparer
        quoted_name = preparer.quote(routine_name)
        schema = preparer.quote(routine["schema"])

        placeholders = [
            f":param_{index}"
            for index in range(len(routine_params))
        ]
        arguments = {
            f"param_{index}": params[param["name"]]
            for index, param in enumerate(routine_params)
        }

        query = text(
            f"SELECT {schema}.{quoted_name}("
            f"{', '.join(placeholders)}) AS result"
        )

        with self.engine.connect() as connection:
            row = connection.execute(query, arguments).first()
            return row[0] if row else None


    def call_procedure(self, name: str, params: dict) -> dict:
        """Ejecuta un procedimiento almacenado validado en el catálogo."""
        routine = self._find_routine(name, "procedure")
        routine_name = routine["name"]
        routine_params = routine["params"]

        expected_params = {p["name"] for p in routine_params}
        if set(params) != expected_params:
            raise ValueError(
                "Los parámetros no coinciden con el procedimiento."
            )

        preparer = self.engine.dialect.identifier_preparer
        quoted_name = preparer.quote(routine_name)

        # Los nombres de parámetros proceden del catálogo validado.
        arguments = {
            f"p{index}": params[param["name"]]
            for index, param in enumerate(routine_params)
        }

        placeholders = [
            f"@{param['name']} = :p{index}"
            for index, param in enumerate(routine_params)
        ]

        sql = (
            f"EXEC {quoted_name} {', '.join(placeholders)}"
            if placeholders
            else f"EXEC {quoted_name}"
        )

        with self.engine.connect() as connection:
            result = connection.execute(text(sql), arguments)

            columns = list(result.keys()) if result.returns_rows else []
            rows = (
                [list(row) for row in result.fetchall()]
                if result.returns_rows
                else []
            )

            return {
                "columns": columns,
                "rows": rows,
                "messages": [],
            }


    def _find_routine(self, name: str, routine_type: str) -> dict:
        """Busca la rutina por nombre y tipo en el catálogo."""
        matches = [
            routine
            for routine in self.list_routines()
            if routine["name"].casefold() == name.casefold()
            and routine["type"] == routine_type
        ]
        if not matches:
            raise ValueError("La rutina solicitada no existe.")
        if len(matches) > 1:
            raise ValueError("Hay varias rutinas con ese nombre.")
        return matches[0]

    def list_triggers(self) -> list[dict]:
        """Lista los triggers de las tablas del esquema actual."""
        query = text("""
            SELECT
                tr.name AS trigger_name,
                OBJECT_NAME(tr.parent_id) AS table_name,
                tr.is_instead_of_trigger AS is_instead_of,
                OBJECT_DEFINITION(tr.object_id) AS definition
            FROM sys.triggers AS tr
            INNER JOIN sys.objects AS parent
                ON parent.object_id = tr.parent_id
            INNER JOIN sys.schemas AS s
                ON s.schema_id = parent.schema_id
            WHERE s.name = SCHEMA_NAME()
            ORDER BY tr.name
        """)

        with self.engine.connect() as connection:
            triggers = connection.execute(query).mappings().all()

        result = []
        for trigger in triggers:
            definition = trigger["definition"] or ""
            events = [
                event
                for event in ("INSERT", "UPDATE", "DELETE")
                if event in definition.upper()
            ]
            result.append(
                {
                    "name": trigger["trigger_name"],
                    "table": trigger["table_name"],
                    "events": events,
                    "definition": trigger["definition"],
                }
            )
        return result