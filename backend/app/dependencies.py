from fastapi import Header, HTTPException

from app.adapters.base import DatabaseAdapter
from app.connections import get_connection


def get_adapter(
    x_connection_id: str | None = Header(default=None),
) -> DatabaseAdapter:
    if not x_connection_id:
        raise HTTPException(401, "Falta la cabecera X-Connection-Id.")
    try:
        return get_connection(x_connection_id)
    except KeyError:
        raise HTTPException(401, "La conexión no existe o ya no está activa.")