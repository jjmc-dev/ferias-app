from typing import Any
from uuid import uuid4
from sqlalchemy.engine import URL

from app.adapters.base import DatabaseAdapter


# Registro en memoria de las conexiones activas.
_connections: dict[str, DatabaseAdapter] = {}


def register_connection(adapter: DatabaseAdapter) -> str:
    """Registra un adaptador y devuelve su identificador."""
    connection_id = str(uuid4())
    _connections[connection_id] = adapter
    return connection_id


def get_connection(connection_id: str) -> DatabaseAdapter:
    """Recupera una conexión por su identificador."""
    adapter = _connections.get(connection_id)

    if adapter is None:
        raise KeyError("La conexión no existe o ya no está activa.")

    return adapter


def remove_connection(connection_id: str) -> bool:
    """Elimina una conexión del registro en memoria."""
    adapter = _connections.pop(connection_id, None)

    if adapter is None:
        return False

    try:
        adapter.close()
    except Exception:
        pass

    return True

def build_url(engine: str, host: str, port: int, database: str,
              user: str, password: str) -> URL:
    """Arma la URL de SQLAlchemy según el motor (sección 7.2)."""
    if engine == "sqlserver":
        return URL.create(
            "mssql+pyodbc",
            username=user,
            password=password,
            host=host,
            port=port,
            database=database,
            query={
                "driver": "ODBC Driver 18 for SQL Server",
                "TrustServerCertificate": "yes",
            },
        )
    raise ValueError(f"Motor no soportado: {engine}")