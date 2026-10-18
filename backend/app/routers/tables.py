from fastapi import APIRouter, Depends
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import SQLAlchemyError
from app.schemas import InsertRequest
from app.adapters.base import DatabaseAdapter
from app.dependencies import get_adapter

router = APIRouter(prefix="/tables", tags=["tablas"])


@router.get("")
def listar_tablas(adapter: DatabaseAdapter = Depends(get_adapter)):
    return adapter.list_tables()

@router.get("/{table}/rows")
def obtener_filas(
    table: str,
    limit: int = 100,
    offset: int = 0,
    adapter: DatabaseAdapter = Depends(get_adapter),
):
    try:
        return adapter.get_rows(table, limit, offset)
    except ValueError as e:
        raise HTTPException(400, str(e))


@router.post("/{table}/rows")
def insertar_fila(
    table: str,
    data: InsertRequest,
    adapter: DatabaseAdapter = Depends(get_adapter),
):
    try:
        return adapter.insert_row(table, data.values)
    except ValueError as e:
        raise HTTPException(400, str(e))
    except SQLAlchemyError as e:
        mensaje = str(getattr(e, "orig", e))
        raise HTTPException(400, mensaje)