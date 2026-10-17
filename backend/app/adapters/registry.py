from importlib import import_module

from sqlalchemy.engine import URL

# motor -> (archivo dentro de adapters, nombre de la clase)
MOTORES = {
    "sqlserver": ("sqlserver", "SqlServerAdapter"),
    "postgres": ("postgres", "PostgresAdapter"),
    "mysql": ("mysql", "MySQLAdapter"),
    "oracle": ("oracle", "OracleAdapter"),
}

# motor -> (driver de SQLAlchemy, puerto por defecto)
DRIVERS = {
    "sqlserver": ("mssql+pyodbc", 1433),
    "postgres": ("postgresql+psycopg", 5432),
    "mysql": ("mysql+pymysql", 3306),
    "oracle": ("oracle+oracledb", 1521),
}


def construir_url(engine, host, port, database, user, password) -> str:
    """Arma la cadena de conexion de SQLAlchemy para el motor indicado."""
    motor = (engine or "").lower()
    if motor not in DRIVERS:
        raise ValueError(f"Motor no soportado: '{engine}'. Opciones: {', '.join(DRIVERS)}")
    driver, puerto_defecto = DRIVERS[motor]
    puerto = int(port) if port else puerto_defecto
    query, base = {}, database
    if motor == "sqlserver":
        query = {"driver": "ODBC Driver 18 for SQL Server", "TrustServerCertificate": "yes"}
    elif motor == "oracle":
        query = {"service_name": database}
        base = None
    url = URL.create(driver, username=user, password=password, host=host, port=puerto, database=base, query=query)
    return url.render_as_string(hide_password=False)


def get_adapter(engine, host, port, database, user, password):
    """Crea el adaptador del motor pedido. El import se hace al momento de usarlo."""
    motor = (engine or "").lower()
    if motor not in MOTORES:
        raise ValueError(f"Motor no soportado: '{engine}'. Opciones: {', '.join(MOTORES)}")
    modulo, clase = MOTORES[motor]
    try:
        paquete = import_module(f".{modulo}", package=__package__)
    except ModuleNotFoundError as e:
        raise ValueError(f"El adaptador de '{motor}' todavia no esta disponible ({e.name})") from e
    url = construir_url(motor, host, port, database, user, password)
    return getattr(paquete, clase)(url)
