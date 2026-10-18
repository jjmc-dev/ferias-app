from fastapi import APIRouter, HTTPException

from app.adapters import ADAPTERS
from app.connections import build_url, register_connection
from app.schemas import ConnectRequest

router = APIRouter(tags=["conexión"])


@router.post("/connect")
def connect(data: ConnectRequest):
    engine = data.engine.lower()

    adapter_class = ADAPTERS.get(engine)
    if adapter_class is None:
        raise HTTPException(400, f"Motor no soportado: {data.engine}")

    url = build_url(engine, data.host, data.port,
                    data.database, data.user, data.password)
    adapter = adapter_class(url.render_as_string(hide_password=False))

    if not adapter.test_connection():
        adapter.close()
        raise HTTPException(
            502,
            "No se pudo conectar. Revisa host, puerto, usuario, contraseña y base.",
        )

    return {"connection_id": register_connection(adapter)}