from app.adapters.base import DatabaseAdapter
from app.adapters.sqlserver import SqlServerAdapter

# Registro de motores. El Módulo 4 agregará postgres, mysql y oracle.
ADAPTERS: dict[str, type[DatabaseAdapter]] = {
    "sqlserver": SqlServerAdapter,
}