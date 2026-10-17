import os
from sqlalchemy import create_engine, text

clave = os.environ["DB_PASS"]

URLS = {
    "postgres": f"postgresql+psycopg://postgres:{clave}@localhost:5432/ferias",
    "mysql": f"mysql+pymysql://root:{clave}@localhost:3306/ferias",
}

for nombre, url in URLS.items():
    try:
        with create_engine(url).connect() as con:
            print(nombre, "OK ->", con.execute(text("SELECT 1")).scalar())
    except Exception as e:
        print(nombre, "ERROR ->", e)