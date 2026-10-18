from abc import ABC, abstractmethod
from typing import Any


class DatabaseAdapter(ABC):
    """Contrato común para los adaptadores de bases de datos."""

    def __init__(self, url: str):
        self.url = url

    @abstractmethod
    def test_connection(self) -> bool:
        """Comprueba si se puede conectar a la base de datos."""
        ...

    @abstractmethod
    def list_tables(self) -> list[str]:
        """Devuelve los nombres de las tablas disponibles."""
        ...

    @abstractmethod
    def get_rows(
        self, table: str, limit: int = 100, offset: int = 0
    ) -> dict:
        """Devuelve las columnas y filas de una tabla."""
        ...

    @abstractmethod
    def insert_row(self, table: str, values: dict) -> dict:
        """Inserta una fila usando parámetros enlazados."""
        ...

    @abstractmethod
    def list_routines(self) -> list[dict]:
        """Lista las funciones y los procedimientos disponibles."""
        ...

    @abstractmethod
    def call_function(self, name: str, params: dict) -> Any:
        """Ejecuta una función de la base de datos."""
        ...

    @abstractmethod
    def call_procedure(self, name: str, params: dict) -> dict:
        """Ejecuta un procedimiento almacenado."""
        ...

    @abstractmethod
    def list_triggers(self) -> list[dict]:
        """Lista los triggers de la base de datos."""
        ...
        
    def close(self) -> None:
        """Libera recursos. Los adaptadores pueden sobrescribirlo."""
        pass