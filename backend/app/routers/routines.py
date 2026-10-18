from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.exc import SQLAlchemyError

from app.adapters.base import DatabaseAdapter
from app.dependencies import get_adapter
from app.schemas import CallRequest

router = APIRouter(prefix="/routines", tags=["rutinas"])


@router.get("")
def listar_rutinas(adapter: DatabaseAdapter = Depends(get_adapter)):
    return adapter.list_routines()


@router.post("/{name}/call")
def llamar_rutina(
    name: str,
    data: CallRequest,
    adapter: DatabaseAdapter = Depends(get_adapter),
):
    try:
        # Buscamos la rutina en el catálogo para saber si es función o procedimiento
        rutina = next(
            (r for r in adapter.list_routines()
             if r["name"].casefold() == name.casefold()),
            None,
        )
        if rutina is None:
            raise HTTPException(404, "La rutina solicitada no existe.")

        if rutina["type"] == "function":
            return adapter.call_function(rutina["name"], data.params)
        return adapter.call_procedure(rutina["name"], data.params)
    except ValueError as e:
        raise HTTPException(400, str(e))
    except SQLAlchemyError as e:
        raise HTTPException(400, str(getattr(e, "orig", e)))