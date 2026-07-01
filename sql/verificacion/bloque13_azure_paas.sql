-- Verificación Bloque 13 — Azure SQL Database PaaS
-- Ejecutar conectado a sql-rentacr-paas.database.windows.net

-- 1. Verificar esquemas
SELECT name FROM sys.schemas WHERE name IN ('alquiler','persona','ref','vehiculo');

-- 2. Verificar tablas (debe ser 41)
SELECT COUNT(*) AS TotalTablas FROM sys.tables;

-- 3. Verificar vistas (debe ser 41)
SELECT COUNT(*) AS TotalVistas FROM sys.views;

-- 4. Verificar SPs
SELECT s.name AS Esquema, p.name AS SP
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id
ORDER BY s.name, p.name;

-- 5. Verificar roles
SELECT name AS Rol FROM sys.database_principals
WHERE type = 'R' AND is_fixed_role = 0 AND name NOT IN ('public');

-- 6. Verificar DDM
SELECT t.name AS Tabla, c.name AS Columna, mc.masking_function
FROM sys.masked_columns mc
JOIN sys.tables t ON mc.object_id = t.object_id
JOIN sys.columns c ON mc.object_id = c.object_id AND mc.column_id = c.column_id;

-- 7. Verificar RLS
SELECT name AS Politica, is_enabled AS Activa FROM sys.security_policies;

-- 8. Conteo de registros por tabla
SELECT s.name AS Esquema, t.name AS Tabla, p.rows AS Registros
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
WHERE s.name <> 'dbo'
ORDER BY s.name, t.name;

-- 9. TDE (Azure lo gestiona automáticamente)
SELECT db.name, dek.encryption_state, dek.key_algorithm, dek.key_length
FROM sys.dm_database_encryption_keys dek
JOIN sys.databases db ON dek.database_id = db.database_id;
