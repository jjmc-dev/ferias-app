import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.adapters.mysql import MySQLAdapter

clave = os.environ["DB_PASS"]
a = MySQLAdapter(f"mysql+pymysql://root:{clave}@localhost:3306/ferias")


def seccion(titulo):
    print("\n=== " + titulo + " ===")


seccion("1. test_connection")
print(a.test_connection())

seccion("2. list_tables")
print(a.list_tables())

seccion("3. get_rows('feria') con minusculas a proposito")
print(a.get_rows("feria", limit=5))

seccion("4. list_routines")
for r in a.list_routines():
    print(r)

seccion("5. call_function escalar")
print(a.call_function("fn_total_ferias_organizador", {"p_idorganizador": 1}))

seccion("6. call_procedure que devuelve filas")
print(a.call_procedure("sp_ubicaciones_feria", {"p_idferia": 1}))

seccion("7. call_procedure sin filas y comprobacion")
print(a.call_procedure("sp_renombrar_feria", {"p_idferia": 3, "p_nombre": "Feria de Arte (prueba)"}))
print(a.get_rows("FERIA"))

seccion("8. list_triggers")
for t in a.list_triggers():
    print(t)

seccion("9. el trigger debe rechazar fechas invalidas")
try:
    a.insert_row("se_realiza_en", {"idferia": 3, "idubicacion": 1, "fecha_ini": "2024-05-10", "fecha_fin": "2024-05-01"})
    print("ERROR: debio fallar")
except Exception as e:
    print("Rechazado como se esperaba:", str(e).splitlines()[0])

seccion("10. validacion: llamar un procedimiento como si fuera funcion")
try:
    a.call_function("sp_renombrar_feria", {"p_idferia": 3, "p_nombre": "x"})
    print("ERROR: debio fallar")
except ValueError as e:
    print("Rechazado como se esperaba:", e)
