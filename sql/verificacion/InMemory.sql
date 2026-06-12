-- =============================================================================
-- bloque10_inmemory.sql
-- Tablas In-Memory — SQL Server 2025
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Tabla: vehiculo.DisponibilidadVehiculo
-- Configuración: MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA
-- Filegroup: RentaCR_MemOpt → D:\SQLData\RentaCR_MemOpt
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. VERIFICAR TABLA IN-MEMORY
-- =============================================================================
SELECT 
    t.name AS Tabla,
    t.is_memory_optimized AS EsInMemory,
    t.durability_desc AS Durabilidad,
    p.rows AS Registros
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
WHERE t.is_memory_optimized = 1;
GO

-- =============================================================================
-- 2. VERIFICAR FILEGROUP IN-MEMORY Y RUTA FÍSICA
-- =============================================================================
SELECT 
    fg.name AS Filegroup,
    fg.type_desc AS Tipo,
    df.physical_name AS RutaFisica
FROM sys.filegroups fg
JOIN sys.database_files df ON fg.data_space_id = df.data_space_id
WHERE fg.type = 'FX';
GO

-- =============================================================================
-- 3. VER DATOS EN LA TABLA IN-MEMORY
-- =============================================================================
ALTER SECURITY POLICY [vehiculo].[PolicyDisponibilidadSucursal] WITH (STATE = OFF);
GO
SELECT TOP 15
    Disponibilidad_ID,
    Vehiculo_ID,
    Sucursal_ID,
    EstadoDisponibilidad,
    FechaHoraEstado,
    Contrato_ID
FROM [vehiculo].[DisponibilidadVehiculo]
ORDER BY Disponibilidad_ID;
GO

-- =============================================================================
-- 4. DEMOSTRAR ALTA CONCURRENCIA — INSERT EN TIEMPO REAL
-- =============================================================================
INSERT INTO [vehiculo].[DisponibilidadVehiculo] 
    (Vehiculo_ID, Sucursal_ID, EstadoDisponibilidad, FechaHoraEstado, Contrato_ID)
VALUES 
    (3, 1, 'Disponible', SYSUTCDATETIME(), NULL);
GO

SELECT TOP 1 * FROM [vehiculo].[DisponibilidadVehiculo] 
ORDER BY Disponibilidad_ID DESC;
GO

ALTER SECURITY POLICY [vehiculo].[PolicyDisponibilidadSucursal] WITH (STATE = ON);
GO
-- =============================================================================
-- 5. DEFINICIÓN DDL DE LA TABLA IN-MEMORY
-- =============================================================================
/*
CREATE TABLE [vehiculo].[DisponibilidadVehiculo]
(
    Disponibilidad_ID    INT             NOT NULL IDENTITY(1,1),
    Vehiculo_ID          INT             NOT NULL,
    Sucursal_ID          INT             NOT NULL,
    EstadoDisponibilidad NVARCHAR(30)    NOT NULL,
    FechaHoraEstado      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    Contrato_ID          INT                 NULL,

    CONSTRAINT PK_DisponibilidadVehiculo PRIMARY KEY NONCLUSTERED (Disponibilidad_ID),
    CONSTRAINT CK_Disponibilidad_Estado CHECK (EstadoDisponibilidad IN ('Disponible','Alquilado','FueraDeServicio'))
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
*/