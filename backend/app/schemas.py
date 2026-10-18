from pydantic import BaseModel


class ConnectRequest(BaseModel):
    engine: str
    host: str
    port: int
    database: str
    user: str
    password: str

class InsertRequest(BaseModel):
    values: dict

class CallRequest(BaseModel):
    params: dict = {}