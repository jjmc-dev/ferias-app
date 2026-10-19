#!/bin/bash
set -euo pipefail

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

echo "Comprobando conexión con SQL Server..."

until "$SQLCMD" \
    -S sqlserver \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C -b \
    -Q "SELECT 1" \
    -o /dev/null; do
    echo "Esperando a SQL Server..."
    sleep 5
done

echo "SQL Server disponible."

echo "Comprobando base de datos ferias..."

"$SQLCMD" \
    -S sqlserver \
    -U sa \
    -P "$MSSQL_SA_PASSWORD" \
    -C -b \
    -Q "IF DB_ID(N'ferias') IS NULL CREATE DATABASE [ferias];"

echo "Base de datos ferias preparada."

echo "Inicialización terminada correctamente."
