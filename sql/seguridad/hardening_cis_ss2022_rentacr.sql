-- ============================================================
-- HARDENING CIS SQL Server 2022 Benchmark v1.2.1
-- Proyecto: RentaCR — IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero
-- Instancia: vm-projectdb\SQLSERVER2025
-- Fecha: Mayo 2026
-- ============================================================


-- ============================================================
-- SECCIÓN 2 — SURFACE AREA REDUCTION
-- Reducción de superficie de ataque
-- ============================================================

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

-- 2.1 Ad Hoc Distributed Queries = 0 (CIS 2.1)
-- Deshabilita consultas distribuidas ad-hoc por seguridad
EXEC sp_configure 'Ad Hoc Distributed Queries', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.2 CLR Enabled = 0 (CIS 2.2)
-- Deshabilita CLR (Common Language Runtime) — no necesario para RentaCR
EXEC sp_configure 'CLR Enabled', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.3 CLR Strict Security = 1 (CIS 2.3)
-- Requiere que todos los assemblies CLR sean firmados
EXEC sp_configure 'CLR strict security', 1;
RECONFIGURE WITH OVERRIDE;

-- 2.4 Cross DB Ownership Chaining = 0 (CIS 2.4)
-- Deshabilita el encadenamiento de propiedad entre bases de datos
EXEC sp_configure 'cross db ownership chaining', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.5 Database Mail XPs = 0 (CIS 2.5)
-- Deshabilita procedimientos extendidos de Database Mail
EXEC sp_configure 'Database Mail XPs', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.6 Ole Automation Procedures = 0 (CIS 2.6)
-- Deshabilita la creación de objetos COM desde SQL Server
EXEC sp_configure 'Ole Automation Procedures', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.7 Remote Access = 0 (CIS 2.7)
-- Deshabilita opción legacy de acceso remoto entre servidores SQL
EXEC sp_configure 'remote access', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.8 Remote Admin Connections = 0 (CIS 2.8)
-- Deshabilita conexiones remotas a la Dedicated Admin Connection
EXEC sp_configure 'remote admin connections', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.9 Scan for Startup Procs = 0 (CIS 2.9)
-- Deshabilita ejecución automática de stored procedures al iniciar
EXEC sp_configure 'scan for startup procs', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.10 xp_cmdshell = 0 (CIS 2.10)
-- Deshabilita el procedimiento que permite ejecutar comandos del OS
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE WITH OVERRIDE;

-- 2.11 Optimize for Ad Hoc Workloads = 1 (BP del curso)
-- Mejora el uso de memoria del plan cache
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE WITH OVERRIDE;

-- Verificar Sección 2
SELECT name, value_in_use
FROM sys.configurations
WHERE name IN (
    'Ad Hoc Distributed Queries',
    'CLR Enabled',
    'CLR strict security',
    'cross db ownership chaining',
    'Database Mail XPs',
    'Ole Automation Procedures',
    'remote access',
    'remote admin connections',
    'scan for startup procs',
    'xp_cmdshell',
    'optimize for ad hoc workloads'
)
ORDER BY name;


-- ============================================================
-- SECCIÓN 3 — AUTHENTICATION
-- Configuración de autenticación y cuentas
-- ============================================================

-- 3.1 Renombrar y deshabilitar SA (CIS 3.1 y 3.2)
-- SA es la primera cuenta que atacan los hackers
ALTER LOGIN [sa] WITH NAME = [sa_rentacr];
ALTER LOGIN [sa_rentacr] DISABLE;
ALTER LOGIN [sa_rentacr] WITH 
    PASSWORD = 'P@ssw0rd2025!RentaCR',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;

-- 3.2 Remover de sysadmin cuentas no autorizadas (CIS 3.12)
-- SQLWriter y Winmgmt no deben tener privilegios de sysadmin
ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\SQLWriter];
ALTER SERVER ROLE [sysadmin] DROP MEMBER [NT SERVICE\Winmgmt];

-- Verificar miembros de sysadmin
SELECT l.name, l.type_desc
FROM sys.server_role_members rm
JOIN sys.server_principals l ON rm.member_principal_id = l.principal_id
JOIN sys.server_principals r ON rm.role_principal_id = r.principal_id
WHERE r.name = 'sysadmin'
ORDER BY l.name;


-- ============================================================
-- SECCIÓN 4 — PASSWORD POLICIES
-- Políticas de contraseña para logins SQL
-- ============================================================

-- 4.1 Aplicar política de expiración a cuentas internas (CIS 4.1)
-- Las cuentas ##MS_Policy...## deben tener expiración activa
ALTER LOGIN [##MS_PolicyEventProcessingLogin##] WITH CHECK_EXPIRATION = ON;
ALTER LOGIN [##MS_PolicyTsqlExecutionLogin##] WITH CHECK_EXPIRATION = ON;

-- Verificar política de contraseñas en todos los logins SQL
SELECT name, is_policy_checked, is_expiration_checked, is_disabled
FROM sys.sql_logins
ORDER BY name;


-- ============================================================
-- SECCIÓN 5 — AUDITING
-- Configuración de auditoría según estándares internacionales
-- ============================================================

-- 5.1 Crear Server Audit al Application Log de Windows (BP del curso)
-- Registra eventos de seguridad en el Event Log de Windows
CREATE SERVER AUDIT [Audit_RentaCR]
TO APPLICATION_LOG
WITH (
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE
);

ALTER SERVER AUDIT [Audit_RentaCR] WITH (STATE = ON);

-- 5.2 Crear Server Audit Specification con todos los grupos requeridos
-- Cubre: logins fallidos/exitosos, cambios de roles, permisos,
--        objetos, auditoría, esquemas y contraseñas (CIS 5.1-5.5)
CREATE SERVER AUDIT SPECIFICATION [AuditSpec_RentaCR]
FOR SERVER AUDIT [Audit_RentaCR]
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (AUDIT_CHANGE_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_OBJECT_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP)
WITH (STATE = ON);

-- Verificar auditoría
SELECT name, is_state_enabled FROM sys.server_audits;
SELECT audit_action_name FROM sys.server_audit_specification_details ORDER BY audit_action_name;


-- ============================================================
-- SECCIÓN 6 — APPLICATION DEVELOPMENT
-- Seguridad en desarrollo de aplicaciones
-- ============================================================

-- 6.1 CLR ya deshabilitado en sección 2
-- 6.2 CLR Strict Security ya habilitado en sección 2

-- Verificar que no existen CLR assemblies de usuario inseguros (CIS 6.2)
SELECT name, permission_set_desc
FROM sys.assemblies
WHERE is_user_defined = 1
  AND permission_set_desc != 'SAFE_ACCESS';


-- ============================================================
-- SECCIÓN 7 — ENCRYPTION
-- Configuración de cifrado
-- ============================================================

-- 7.4 Habilitar Force Encryption para comunicación TLS (CIS 7.4)
-- Obliga a que TODAS las conexiones usen TLS 1.2 o superior
-- NOTA: Requiere reinicio del servicio SQL Server después
EXEC xp_instance_regwrite 
    N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib',
    N'ForceEncryption',
    REG_DWORD,
    1;

-- NOTA: Los controles 7.1, 7.2, 7.3 y 7.5 (TDE, symmetric/asymmetric keys)
-- se aplicarán cuando se cree la base de datos RentaCR (Bloque 9)


-- ============================================================
-- CONFIGURACIONES BP ADICIONALES DEL CURSO
-- ============================================================

-- BP: Cost Threshold for Parallelism = 50
-- SQL Server usa paralelismo solo cuando costo estimado supera 50
EXEC sp_configure 'cost threshold for parallelism', 50;
RECONFIGURE WITH OVERRIDE;

-- BP: Max Degree of Parallelism = 1 (1 por cada 2 CPUs, máx 8)
-- La VM tiene 2 vCPUs, por lo tanto MAXDOP = 1
EXEC sp_configure 'max degree of parallelism', 1;
RECONFIGURE WITH OVERRIDE;

-- BP: Max Server Memory = 4096 MB
-- Dejar 4GB para el sistema operativo, 4GB para SQL Server
EXEC sp_configure 'max server memory (MB)', 4096;
RECONFIGURE WITH OVERRIDE;

-- Verificar configuración final
SELECT name, value_in_use
FROM sys.configurations
WHERE name IN (
    'max server memory (MB)',
    'max degree of parallelism',
    'cost threshold for parallelism',
    'xp_cmdshell',
    'Ole Automation Procedures',
    'optimize for ad hoc workloads',
    'remote access',
    'Ad Hoc Distributed Queries',
    'CLR Enabled',
    'CLR strict security'
)
ORDER BY name;


-- ============================================================
-- PENDIENTE — APLICAR CUANDO SE CREE LA BD RentaCR
-- ============================================================

/*
-- 7.1 Symmetric Key con AES_128 o superior (CIS 7.1)
USE [RentaCR];
CREATE SYMMETRIC KEY [SK_RentaCR]
    WITH ALGORITHM = AES_256
    ENCRYPTION BY PASSWORD = 'P@ssw0rdSymKey2025!';

-- 7.2 Asymmetric Key >= 2048 bits (CIS 7.2)
CREATE ASYMMETRIC KEY [AK_RentaCR]
    WITH ALGORITHM = RSA_2048;

-- 7.5 TDE — Transparent Data Encryption (CIS 7.5)
USE [master];
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@ssw0rdMasterKey2025!';
CREATE CERTIFICATE [Cert_TDE_RentaCR]
    WITH SUBJECT = 'TDE Certificate RentaCR';

USE [RentaCR];
CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE [Cert_TDE_RentaCR];

ALTER DATABASE [RentaCR] SET ENCRYPTION ON;
*/
