from fastapi import APIRouter, Depends

from app.adapters.base import DatabaseAdapter
from app.dependencies import get_adapter

router = APIRouter(prefix="/triggers", tags=["triggers"])


@router.get("")
def listar_triggers(adapter: DatabaseAdapter = Depends(get_adapter)):
    return adapter.list_triggers()
