from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.routers import connection, routines, tables, triggers

app = FastAPI(
    title="API de Bases de Datos",
    description="Backend para conectar y consultar distintos gestores de bases de datos",
    version="1.0.0",
)

app.include_router(connection.router)
app.include_router(tables.router)
app.include_router(triggers.router)
app.include_router(routines.router)

@app.exception_handler(StarletteHTTPException)
async def http_error(request: Request, exc: StarletteHTTPException):
    return JSONResponse(status_code=exc.status_code, content={"error": exc.detail})


@app.exception_handler(RequestValidationError)
async def validation_error(request: Request, exc: RequestValidationError):
    return JSONResponse(status_code=422, content={"error": "Datos inválidos en la petición."})


@app.get("/health")
def health():
    return {"status": "ok"}