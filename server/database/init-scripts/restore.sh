#!/bin/bash

# Wait for the SQL Server to come up
sleep 30s

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P Lekovitobilje22! -Q "
RESTORE DATABASE [170171] 
FROM DISK = '/var/opt/mssql/backup/Database.bak' 
WITH MOVE '170171' TO '/var/opt/mssql/data/170171.mdf', 
MOVE '170171_log' TO '/var/opt/mssql/data/170171_log.ldf';
"