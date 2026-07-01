-- =============================================================================
-- bloque12_seguridad_vistas_roles_ddm_rls_tde.sql
-- Verificación Bloque 12 — Seguridad y Regulación
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Ejecutar durante la defensa para demostrar:
--   ✅ 41 vistas (1 por tabla)
--   ✅ 3 roles: db_Administrativo, db_Mantenimiento, db_LecturaGeneral
--   ✅ DDM en correo, cédula y dirección (con usuario sin privilegios)
--   ✅ RLS por sucursal — PolicyContratoSucursal + PolicyDisponibilidadSucursal
--   ✅ TDE AES-256 cifrado completo
--   ✅ Auditoría — 9 action groups
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. VISTAS — 41 vistas, 1 por tabla
-- =============================================================================
SELECT 
    s.name AS Esquema,
    v.name AS Vista
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id
ORDER BY s.name, v.name;
GO

SELECT COUNT(*) AS TotalVistas
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id
WHERE s.name <> 'dbo';
GO

-- =============================================================================
-- 2. ROLES DE BASE DE DATOS
-- =============================================================================
SELECT 
    name AS Rol,
    type_desc AS Tipo
FROM sys.database_principals
WHERE type = 'R' AND is_fixed_role = 0 AND name NOT IN ('public')
ORDER BY name;
GO

-- =============================================================================
-- 3. DYNAMIC DATA MASKING — correo, cédula, dirección
-- =============================================================================

-- 3.1 Ver columnas enmascaradas configuradas
SELECT 
    t.name AS Tabla,
    c.name AS Columna,
    mc.masking_function AS FuncionMascara
FROM sys.masked_columns mc
JOIN sys.tables t ON mc.object_id = t.object_id
JOIN sys.columns c ON mc.object_id = c.object_id AND mc.column_id = c.column_id;
GO

-- 3.2 Crear usuario de prueba si no existe
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'UsuarioPrueba')
BEGIN
    CREATE USER UsuarioPrueba WITHOUT LOGIN;
    GRANT SELECT ON [persona].[MecanismoContacto] TO UsuarioPrueba;
    GRANT SELECT ON [persona].[Identificador] TO UsuarioPrueba;
    GRANT SELECT ON [persona].[Direccion] TO UsuarioPrueba;
END
GO

-- 3.3 Ver datos SIN máscara (como sysadmin)
SELECT TOP 3 
    MecanismoContacto_ID,
    Valor AS Correo_REAL
FROM [persona].[MecanismoContacto]
WHERE TipoMecanismoContacto_ID = 1;

SELECT TOP 3
    Identificador_ID,
    Numero AS Cedula_REAL
FROM [persona].[Identificador]
WHERE TipoIdentificacion_ID = 1;
GO

-- 3.4 Ver datos CON máscara (como usuario sin privilegios)
EXECUTE AS USER = 'UsuarioPrueba';

SELECT TOP 3 
    MecanismoContacto_ID,
    Valor AS Correo_ENMASCARADO
FROM [persona].[MecanismoContacto]
WHERE TipoMecanismoContacto_ID = 1;

SELECT TOP 3 
    Identificador_ID,
    Numero AS Cedula_ENMASCARADA
FROM [persona].[Identificador]
WHERE TipoIdentificacion_ID = 1;

SELECT TOP 3
    Direccion_ID,
    LineaDireccion1 AS Direccion_ENMASCARADA
FROM [persona].[Direccion];

REVERT;
GO

-- =============================================================================
-- 4. ROW LEVEL SECURITY — demostrar filtrado en acción
-- =============================================================================

-- 4.1 Ver políticas activas
SELECT 
    name AS Politica,
    is_enabled AS Activa,
    type_desc AS Tipo
FROM sys.security_policies;
GO

-- 4.2 Ver tablas protegidas
SELECT 
    sp.name AS Politica,
    OBJECT_NAME(spf.target_object_id) AS TablaProtegida,
    spf.predicate_definition AS DefinicionPredicado
FROM sys.security_policies sp
JOIN sys.security_predicates spf ON sp.object_id = spf.object_id;
GO

-- 4.3 DEMOSTRACIÓN RLS EN ACCIÓN
-- PASO 1: Desactivar RLS — ver TODOS los contratos
ALTER SECURITY POLICY [alquiler].[PolicyContratoSucursal] WITH (STATE = OFF);
GO

SELECT COUNT(*) AS Contratos_SIN_RLS 
FROM [alquiler].[Contrato];
GO

-- PASO 2: Activar RLS — filtrado por predicado de sucursal
ALTER SECURITY POLICY [alquiler].[PolicyContratoSucursal] WITH (STATE = ON);
GO

SELECT COUNT(*) AS Contratos_CON_RLS 
FROM [alquiler].[Contrato];
GO

-- PASO 3: Verificar policy activa nuevamente
SELECT name AS Politica, is_enabled AS Activa
FROM sys.security_policies;
GO

-- =============================================================================
-- 5. TDE — Transparent Data Encryption AES-256
-- =============================================================================
SELECT 
    db.name AS BaseDatos,
    CASE dek.encryption_state
        WHEN 3 THEN 'Cifrado completo ✓'
        ELSE 'Otro estado'
    END AS EstadoCifrado,
    dek.key_algorithm AS Algoritmo,
    dek.key_length AS LongitudClave
FROM sys.dm_database_encryption_keys dek
JOIN sys.databases db ON dek.database_id = db.database_id
WHERE db.name = 'RentaCR';
GO

USE [master];
GO

SELECT 
    name AS Certificado,
    subject AS Descripcion,
    start_date AS FechaInicio,
    expiry_date AS FechaVencimiento
FROM sys.certificates
WHERE name = 'CertTDE_RentaCR';
GO

USE [RentaCR];
GO

-- =============================================================================
-- 6. AUDITORÍA — 9 action groups configurados
-- =============================================================================
USE [master];
GO

SELECT 
    name AS Auditoria,
    is_state_enabled AS Activa
FROM sys.server_audits;
GO

SELECT 
    sad.audit_action_name AS ActionGroup
FROM sys.server_audit_specification_details sad
JOIN sys.server_audit_specifications sas 
    ON sad.server_specification_id = sas.server_specification_id
ORDER BY sad.audit_action_name;
GO