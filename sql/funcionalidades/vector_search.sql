-- =============================================================================
-- vector_search.sql
-- Vector Data and Semantic Search — SQL Server 2025
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Columna: vehiculo.Vehiculo.DescripcionVector VECTOR(1536)
-- Índice:  DiskANN (IX_Vehiculo_DescripcionVector) — FUNCIONAL ✅
-- Funciones: VECTOR_DISTANCE + VECTOR_SEARCH
-- Estado: COMPLETAMENTE FUNCIONAL ✅
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. HABILITAR PREVIEW FEATURES (requerido para VECTOR_SEARCH + DiskANN)
-- =============================================================================
ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

-- =============================================================================
-- 2. VERIFICAR COLUMNA VECTOR(1536)
-- =============================================================================
SELECT 
    t.name AS Tabla,
    c.name AS Columna,
    c.max_length AS MaxLength
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'vehiculo' AND t.name = 'Vehiculo' AND c.name = 'DescripcionVector';
GO

-- =============================================================================
-- 3. VERIFICAR ÍNDICE DISKANN
-- =============================================================================
SELECT 
    i.name AS Indice,
    i.type_desc AS Tipo,
    t.name AS Tabla
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'vehiculo' AND t.name = 'Vehiculo'
ORDER BY i.name;
GO

-- =============================================================================
-- 4. CREAR ÍNDICE DISKANN (si no existe)
-- =============================================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE object_id = OBJECT_ID('vehiculo.Vehiculo') 
    AND name = 'IX_Vehiculo_DescripcionVector'
)
BEGIN
    CREATE VECTOR INDEX IX_Vehiculo_DescripcionVector
    ON [vehiculo].[Vehiculo] (DescripcionVector)
    WITH (METRIC = 'cosine', TYPE = 'diskann');
END
GO

-- =============================================================================
-- 5. VERIFICAR VECTORES CARGADOS
-- =============================================================================
SELECT 
    v.Vehiculo_ID,
    v.Placa,
    cv.Descripcion AS Categoria,
    CASE WHEN v.DescripcionVector IS NULL THEN 'Sin vector' ELSE 'Con vector ✓' END AS EstadoVector
FROM [vehiculo].[Vehiculo] v
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
ORDER BY v.Vehiculo_ID;
GO

-- =============================================================================
-- 6. CARGAR VECTORES SINTÉTICOS (ejecutar si columna está vacía)
-- Vectores por categoría semántica:
--   ECO/MINI  = 0.1 (bajo consumo, ciudad)
--   SEDAN     = 0.3 (confort estándar)
--   SUV       = 0.5 (terreno variado, familiar)
--   PICKUP    = 0.9 (trabajo, carga, campo)
-- =============================================================================
-- Eliminar índice antes de actualizar vectores
DROP INDEX IF EXISTS IX_Vehiculo_DescripcionVector ON [vehiculo].[Vehiculo];
GO


-- ECO y MINI
DECLARE @jsonEco NVARCHAR(MAX) = '';
DECLARE @i INT = 1;
WHILE @i <= 1536
BEGIN
    SET @jsonEco = @jsonEco + '0.1';
    IF @i < 1536 SET @jsonEco = @jsonEco + ',';
    SET @i = @i + 1;
END
SET @jsonEco = '[' + @jsonEco + ']';
UPDATE [vehiculo].[Vehiculo]
SET DescripcionVector = CAST(@jsonEco AS VECTOR(1536))
WHERE CategoriaVehiculo_ID IN (1, 6);
GO

-- SEDAN
DECLARE @jsonSedan NVARCHAR(MAX) = '';
DECLARE @i INT = 1;
WHILE @i <= 1536
BEGIN
    SET @jsonSedan = @jsonSedan + '0.3';
    IF @i < 1536 SET @jsonSedan = @jsonSedan + ',';
    SET @i = @i + 1;
END
SET @jsonSedan = '[' + @jsonSedan + ']';
UPDATE [vehiculo].[Vehiculo]
SET DescripcionVector = CAST(@jsonSedan AS VECTOR(1536))
WHERE CategoriaVehiculo_ID = 2;
GO

-- SUV
DECLARE @jsonSuv NVARCHAR(MAX) = '';
DECLARE @i INT = 1;
WHILE @i <= 1536
BEGIN
    SET @jsonSuv = @jsonSuv + '0.5';
    IF @i < 1536 SET @jsonSuv = @jsonSuv + ',';
    SET @i = @i + 1;
END
SET @jsonSuv = '[' + @jsonSuv + ']';
UPDATE [vehiculo].[Vehiculo]
SET DescripcionVector = CAST(@jsonSuv AS VECTOR(1536))
WHERE CategoriaVehiculo_ID = 3;
GO

-- PICKUP
DECLARE @jsonPickup NVARCHAR(MAX) = '';
DECLARE @i INT = 1;
WHILE @i <= 1536
BEGIN
    SET @jsonPickup = @jsonPickup + '0.9';
    IF @i < 1536 SET @jsonPickup = @jsonPickup + ',';
    SET @i = @i + 1;
END
SET @jsonPickup = '[' + @jsonPickup + ']';
UPDATE [vehiculo].[Vehiculo]
SET DescripcionVector = CAST(@jsonPickup AS VECTOR(1536))
WHERE CategoriaVehiculo_ID = 4;
GO


-- Recrear índice DiskANN
CREATE VECTOR INDEX IX_Vehiculo_DescripcionVector
ON [vehiculo].[Vehiculo] (DescripcionVector)
WITH (METRIC = 'cosine', TYPE = 'diskann');
GO
-- =============================================================================
-- 7. VECTOR_DISTANCE — Búsqueda exacta de similitud semántica
-- Busca los 5 vehículos más similares a un perfil SUV
-- =============================================================================
DECLARE @json NVARCHAR(MAX) = '';
DECLARE @i INT = 1;
WHILE @i <= 1536
BEGIN
    SET @json = @json + '0.5';
    IF @i < 1536 SET @json = @json + ',';
    SET @i = @i + 1;
END
SET @json = '[' + @json + ']';
DECLARE @vectorBusqueda VECTOR(1536) = @json;

SELECT TOP 5
    v.Placa,
    mv.Nombre AS Modelo,
    cv.Descripcion AS Categoria,
    VECTOR_DISTANCE('cosine', v.DescripcionVector, @vectorBusqueda) AS Distancia
FROM [vehiculo].[Vehiculo] v
JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
WHERE v.DescripcionVector IS NOT NULL
ORDER BY Distancia ASC;
GO

-- =============================================================================
-- 8. VECTOR_SEARCH — Búsqueda aproximada con índice DiskANN
-- Más eficiente para grandes volúmenes de datos
-- =============================================================================
DECLARE @json2 NVARCHAR(MAX) = '';
DECLARE @j INT = 1;
WHILE @j <= 1536
BEGIN
    SET @json2 = @json2 + '0.5';
    IF @j < 1536 SET @json2 = @json2 + ',';
    SET @j = @j + 1;
END
SET @json2 = '[' + @json2 + ']';
DECLARE @v VECTOR(1536) = @json2;

SELECT TOP(5)
    s.distance AS Distancia,
    v.Placa,
    mv.Nombre AS Modelo,
    cv.Descripcion AS Categoria
FROM VECTOR_SEARCH(
    TABLE = [vehiculo].[Vehiculo] AS v,
    COLUMN = DescripcionVector,
    SIMILAR_TO = @v,
    METRIC = 'cosine',
    TOP_N = 5
) AS s
JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
ORDER BY s.distance ASC;
GO