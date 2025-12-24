#!/bin/bash

DB_SERVER=${DB_SERVER:-db}
DB_NAME=${DB_NAME:-170171}
DB_USER=${DB_USER:-sa}
DB_PASSWORD=${DB_PASSWORD:-Lekovitobilje22!}
TIMEOUT=${TIMEOUT:-300}
START_TIME=$(date +%s)

echo "Waiting for SQL Server to be available at $DB_SERVER..."

until /opt/mssql-tools/bin/sqlcmd -S $DB_SERVER -U $DB_USER -P $DB_PASSWORD -Q "SELECT 1" &> /dev/null
do
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

  if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
    echo "SQL Server is still unavailable after $((TIMEOUT / 60)) minutes. Exiting."
    exit 1
  fi

  echo "SQL Server is unavailable - sleeping"
  sleep 5
done

echo "SQL Server is up - executing command"

echo "Waiting for database $DB_NAME to be restored..."

START_TIME=$(date +%s)
until /opt/mssql-tools/bin/sqlcmd -S $DB_SERVER -U $DB_USER -P $DB_PASSWORD -Q "SELECT name FROM sys.databases WHERE name = '$DB_NAME'" | grep -q $DB_NAME
do
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

  if [ $ELAPSED_TIME -ge $TIMEOUT ]; then
    echo "Database $DB_NAME is not restored after $((TIMEOUT / 60)) minutes. Exiting."
    exit 1
  fi

  echo "Database $DB_NAME is not restored yet - sleeping"
  sleep 5
done

echo "Database $DB_NAME is restored - starting webapi"

exec dotnet API.dll
