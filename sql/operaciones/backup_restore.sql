-- =============================================================================
-- backup_restore.sql
-- Scripts de Backup y Restauración — RentaCR
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Backups disponibles en G:\SQLBackups\:
--   RentaCR_before_TDE.bak     — Backup previo a TDE (26/05/2026)
--   RentaCR_post_poblacion.bak — Backup con datos y TDE activo (26/05/2026)
-- Certificado TDE:
--   CertTDE_RentaCR.cer + .pvk — Requerido para restaurar en otro servidor
-- =============================================================================

USE [master];
GO

-- =============================================================================
-- 1. BACKUP COMPLETO
-- =============================================================================
BACKUP DATABASE [RentaCR]
TO DISK = N'G:\SQLBackups\RentaCR_backup_completo.bak'
WITH FORMAT,
     COMPRESSION,
     NAME = N'RentaCR — Backup completo',
     DESCRIPTION = N'Backup completo RentaCR con TDE. IF5100 Junio 2026.';
GO

-- =============================================================================
-- 2. VERIFICAR INTEGRIDAD DEL BACKUP
-- =============================================================================
RESTORE VERIFYONLY
FROM DISK = N'G:\SQLBackups\RentaCR_backup_completo.bak';
GO

-- =============================================================================
-- 3. VER CONTENIDO DEL BACKUP
-- =============================================================================
RESTORE HEADERONLY
FROM DISK = N'G:\SQLBackups\RentaCR_backup_completo.bak';
GO

-- =============================================================================
-- 4. VER ARCHIVOS DENTRO DEL BACKUP
-- =============================================================================
RESTORE FILELISTONLY
FROM DISK = N'G:\SQLBackups\RentaCR_post_poblacion.bak';
GO

-- =============================================================================
-- 5. VERIFICAR BACKUPS EXISTENTES
-- =============================================================================
SELECT 
    bs.database_name AS BaseDatos,
    bs.backup_start_date AS FechaInicio,
    bs.backup_finish_date AS FechaFin,
    CAST(bs.backup_size / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS TamanioMB,
    bs.type AS TipoBackup,
    bmf.physical_device_name AS Archivo
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'RentaCR'
ORDER BY bs.backup_start_date DESC;
GO

-- =============================================================================
-- 6. NOTA — RESTAURACIÓN CON TDE
-- Para restaurar en otro servidor se requiere:
--   1. Restaurar el certificado TDE:
--      CREATE CERTIFICATE CertTDE_RentaCR
--          FROM FILE = 'G:\SQLBackups\CertTDE_RentaCR.cer'
--          WITH PRIVATE KEY (
--              FILE = 'G:\SQLBackups\CertTDE_RentaCR.pvk',
--              DECRYPTION BY PASSWORD = 'RentaCR_Cert_2026!Backup#'
--          );
--   2. Luego restaurar la base de datos normalmente:
--      RESTORE DATABASE [RentaCR]
--          FROM DISK = N'G:\SQLBackups\RentaCR_post_poblacion.bak'
--          WITH RECOVERY;
-- =============================================================================