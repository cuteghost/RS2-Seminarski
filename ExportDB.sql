-- Get the default backup directory and create the backup
DECLARE @BackupPath NVARCHAR(500);
DECLARE @FileName NVARCHAR(500);

-- Get default backup directory
SET @BackupPath = '/var/opt/mssql/backup/'

-- Build full file path
SET @FileName = @BackupPath + '\170171_' + CONVERT(VARCHAR(20), GETDATE(), 112) + '.bak';

-- Execute backup
BACKUP DATABASE [170171]
TO DISK = @FileName
WITH FORMAT, 
     INIT, 
     NAME = N'170171-Full Database Backup', 
     SKIP, 
     NOREWIND, 
     NOUNLOAD, 
     COMPRESSION,
     STATS = 10;

-- Show completion message
PRINT 'Backup completed successfully to: ' + @FileName;