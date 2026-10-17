import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.adapters.registry import construir_url, get_adapter

clave = os.environ["DB_PASS"]

print("=== 1. URLs generadas (la contrasena se oculta al imprimir) ===")
for motor in ("sqlserver", "postgres", "mysql", "oracle"):
    print(motor, "->", construir_url(motor, "localhost", None, "ferias", "usuario", "Cl@ve/123").replace("Cl%40ve%2F123", "****"))

print("\n=== 2. PostgreSQL desde el registro ===")
pg = get_adapter("postgres", "localhost", 5432, "ferias", "postgres", clave)
print(pg.test_connection(), pg.list_tables())

print("\n=== 3. MySQL desde el registro ===")
my = get_adapter("MySQL", "localhost", 3306, "ferias", "root", clave)
print(my.test_connection(), my.list_tables())

print("\n=== 4. Motor inexistente ===")
try:
    get_adapter("mongodb", "localhost", 27017, "x", "u", "p")
except ValueError as e:
    print("Rechazado como se esperaba:", e)

print("\n=== 5. Adaptador que aun no existe ===")
for motor in ("sqlserver", "oracle"):
    try:
        get_adapter(motor, "localhost", None, "ferias", "u", "p")
        print(motor, "-> adaptador cargado")
    except ValueError as e:
        print(motor, "->", e)
