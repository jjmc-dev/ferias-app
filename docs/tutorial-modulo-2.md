# Módulo 2 — Base de datos SQL Server

**Integrante:** Ariana  
**Rama:** `modulo-2-base-datos`  
**Archivo entregado:** `db/sqlserver/create_insert.sql`


## 1 ¿Qué hace este módulo?

Portar el script `scrip_create_insert_rev10.txt` (sintaxis Oracle) al dialecto
T-SQL de SQL Server, manteniendo exactamente el mismo modelo relacional y los
mismos datos del grupo. El objetivo es que la base de ferias funcione en SQL
Server con los mismos totales que en Oracle.

## 2 Requisitos
- Estar en VScode
- Powershell de vscode donde se a clonado el repositorio en este caso :
    PS C:\Users\Ariana\proyectos\ferias-app>
- Docker Desktop con WSL2 en Windows 11
- Contenedor `mcr.microsoft.com/mssql/server:2025-latest` (lo levanta el Módulo 1)
- Extensión SQL Server (mssql) en VS Code (opcional, para consultar)
- Acceso al archivo `db/oracle/scrip_create_insert_rev10.txt` (fuente de verdad)

## 3 Cómo se convirtió el script 

Se copió el original a `db/sqlserver/create_insert.sql` y se aplicaron equivalencias mediante buscar-y-reemplazar con expresiones regulares en VS Code (`Ctrl + H`, modo `.*`)
_________________________________________________________________________________________
    | Oracle                    | SQL Server        | Reemplazo aplicado                    |
    |---------------------------|-------------------|---------------------------------------|
    | `NUMBER(10,2)`            | `DECIMAL(10,2)`   | `NUMBER\(10,2\)` → `DECIMAL(10,2)`    |
    | `NUMBER(10)`              | `BIGINT`          | `NUMBER\(10\)` → `BIGINT`             |
    | `NUMBER(n)`               | `INT`             | `NUMBER\((\d+)\)` → `INT`             |
    | `VARCHAR2(n)`             | `NVARCHAR(n)`     | `VARCHAR2\((\d+)\)` → `NVARCHAR($1)`  |
    | `TO_DATE('DD/MM/YYYY')`   | `'aaaa-mm-dd'`    | regex de fecha                        |
    | `^COMMIT;`                | (se elimina)      | (se elimina)                          |
    | `FROM DUAL`               | (se elimina)      | (se elimina)                          |
    |_______________________________________________________________________________________|

## PLAN INICIAL

---------------------- PLAN INICIAL ----------------------
1. copy rev10 → create_insert.sql
2. code create_insert.sql
3. Ctrl+H con regex:
   a) TO_DATE(...)          → 'aaaa-mm-dd'
   b) NUMBER(10,2)          → DECIMAL(10,2)
   c) NUMBER(10)            → BIGINT
   d) NUMBER(n)             → INT
   e) VARCHAR2(n)           → NVARCHAR(n)
   f) ^COMMIT;              → (nada)
   g) \s*FROM DUAL          → (nada)
4. Verificar (0 TO_DATE, 0 VARCHAR2, 0 NUMBER(, 0 FROM DUAL)
5. git add + commit + push
-----------------------------------------------------------
1. copy rev10 → create_insert.sql
    Se copió el original a `db/sqlserver/create_insert.sql` 
    DE MANERA DE POWERSHELL EN VSCODE
    PS C:\Users\Ariana\proyectos\ferias-app> copy db\oracle\scrip_create_insert_rev10.txt db\sqlserver\create_insert.sql
    PS C:\Users\Ariana\proyectos\ferias-app> code db\sqlserver\create_insert.sql
    
2. code create_insert.sql
    Se entra a db/sqlserver/create_insert.sql para hacer las modificaciones 
    DE MANERA DE POWERSHELL EN VSCODE
    | PS C:\Users\Ariana\proyectos\ferias-app> code db\sqlserver\create_insert.sql
3. Ctrl+H con regex:
    En VS Code (`Ctrl + H`, modo `.*`):
    de la siguiente manera :
    -----------------------------------------------
    2 - REMPLPAZO NUMERICO
    2a.fecha DD/MM/YYYY -> 
    en VS Code (`Ctrl + H`, modo `.*`):
    en buscador: TO_DATE\('(\d{2})/(\d{2})/(\d{4})',\s*'DD/MM/YYYY'\)
    en remplazar: '$3-$2-$1';
    para presionar (Ctrl+Alt+Enter);
    -----------------------------------------------
    2b. NUMBER(10,2) → DECIMAL(10,2)
    Buscar: NUMBER\(10,2\)
    Reemplazar: DECIMAL(10,2)
    Replace All.
    -----------------------------------------------
    2c. NUMBER(10) → BIGINT (para ci y ids de persona)
    Buscar: NUMBER\(10\)
    Reemplazar: BIGINT
    Replace All.
    -----------------------------------------------
    2d. Los demás NUMBER(n) → INT
    Buscar: NUMBER\((\d+)\)
    Reemplazar: INT
    Replace All.
    -----------------------------------------------
    3 — VARCHAR2(n) → NVARCHAR(n)
    Buscar: VARCHAR2\((\d+)\)
    Reemplazar: NVARCHAR($1)
    Replace All.
    -----------------------------------------------
    4 — Limpieza de sintaxis Oracle
    4a. Quitar COMMIT;
    Buscar: ^COMMIT;
    Reemplazar: (vacío)
    Replace All.
    -----------------------------------------------
    4b. Quitar FROM DUAL
    Buscar: \s*FROM DUAL
    Reemplazar: (vacío)
    Replace All.

    -----------------------------------------------
4. Verificar (0 TO_DATE, 0 VARCHAR2, 0 NUMBER(, 0 FROM DUAL)
    DE MANERA VISUAL POR VSCODE:
    Ctrl + F → busca TO_DATE → debe dar 0 resultados.
    Busca VARCHAR2 → debe dar 0.
    Busca NUMBER( → debe dar 0.
    Busca FROM DUAL → debe dar 0.
    Busca COMMIT; → debe dar 0.
    -----------------------------------------------
    DE MANERA DE POWERSHELL EN VSCODE
    |Select-String -Path db\sqlserver\create_insert.sql -Pattern "TO_DATE|VARCHAR2|NUMBER\(|FROM DUAL|COMMIT" | Measure-Object
    -----------------------------------------------
    
5. git add + commit + push (modificar repositorio de github)
        DE MANERA DE POWERSHELL EN VSCODE
        PS C:\Users\Ariana\proyectos\ferias-app> git add db/sqlserver/create_insert.sql
        PS C:\Users\Ariana\proyectos\ferias-app> git commit -m "modulo 2:   convertir script rev10 de Oracle a T-SQL (SQL Server)"
        PS C:\Users\Ariana\proyectos\ferias-app> git push -u origin modulo-2-base-datos