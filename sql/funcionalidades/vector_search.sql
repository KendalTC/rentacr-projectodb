-- =============================================================================
-- vector_search.sql
-- Vector Data and Semantic Search — SQL Server 2025
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Columna: vehiculo.Vehiculo.DescripcionVector VECTOR(1536)
-- Función: VECTOR_DISTANCE con métrica cosine
-- Índice DiskANN: no disponible en build 17.0.1115.1 RTM-GDR
-- Estado: FUNCIONAL sin índice
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. VERIFICAR COLUMNA VECTOR(1536)
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
-- 2. VERIFICAR VECTORES CARGADOS
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
-- 3. CARGAR VECTORES SINTÉTICOS (si están vacíos)
-- Vectores por categoría:
--   ECO/MINI  = 0.1 (bajo consumo, ciudad)
--   SEDAN     = 0.3 (confort estándar)
--   SUV       = 0.5 (terreno variado)
--   PICKUP    = 0.9 (trabajo y carga)
-- =============================================================================

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

-- =============================================================================
-- 4. CONSULTA VECTOR_DISTANCE — Búsqueda semántica de vehículos similares
-- Busca los 5 vehículos más similares a un vector de búsqueda (SUV)
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
-- 5. NOTA — Índice DiskANN
-- La sintaxis CREATE VECTOR INDEX no está disponible en build 17.0.1115.1 RTM-GDR.
-- Requiere actualización a un Cumulative Update posterior.
-- El índice DiskANN mejora el rendimiento de búsqueda pero no afecta
-- la funcionalidad de VECTOR_DISTANCE.
--
-- Sintaxis para cuando esté disponible:
-- CREATE VECTOR INDEX IX_Vehiculo_DescripcionVector
-- ON [vehiculo].[Vehiculo] (DescripcionVector)
-- WITH (METRIC = 'cosine');
-- =============================================================================