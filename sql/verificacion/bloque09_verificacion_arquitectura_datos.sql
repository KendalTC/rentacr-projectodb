-- =============================================================================
-- bloque09_verificacion.sql
-- Verificación Bloque 9 — Arquitectura de Datos
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Ejecutar durante la defensa para demostrar:
--   ✅ 41 tablas en 4 esquemas
--   ✅ LUNs y filegroups separados
--   ✅ 5 Stored Procedures
--   ✅ Vector Search + DiskANN
--   ✅ External API (tipo de cambio real)
--   ✅ REGEXP_LIKE (validaciones avanzadas)
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. MODELO LÓGICO — 41 tablas en 4 esquemas
-- =============================================================================
SELECT 
    s.name AS Esquema,
    COUNT(t.name) AS TotalTablas
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name <> 'dbo'
GROUP BY s.name
ORDER BY s.name;
GO

SELECT 
    s.name AS Esquema,
    t.name AS Tabla,
    p.rows AS Registros
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
WHERE s.name <> 'dbo'
ORDER BY s.name, t.name;
GO

-- =============================================================================
-- 2. LUNs Y FILEGROUPS — distribución física de archivos
-- =============================================================================
SELECT 
    fg.name AS Filegroup,
    fg.type_desc AS TipoFilegroup,
    df.name AS Archivo,
    df.physical_name AS RutaFisica,
    CAST(df.size * 8.0 / 1024 AS DECIMAL(10,2)) AS TamanioMB
FROM sys.database_files df
LEFT JOIN sys.filegroups fg ON df.data_space_id = fg.data_space_id
ORDER BY fg.name;
GO

-- =============================================================================
-- 3. STORED PROCEDURES CREADOS
-- =============================================================================
SELECT 
    s.name AS Esquema,
    p.name AS Procedimiento,
    p.create_date AS FechaCreacion
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id
ORDER BY s.name, p.name;
GO

-- =============================================================================
-- 4. VECTOR SEARCH — columna VECTOR(1536) e índice DiskANN
-- =============================================================================

-- 4.1 Verificar columna VECTOR
SELECT 
    t.name AS Tabla,
    c.name AS Columna,
    c.max_length AS MaxLength
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'vehiculo' 
AND t.name = 'Vehiculo' 
AND c.name = 'DescripcionVector';
GO

-- 4.2 Verificar índice DiskANN
SELECT 
    i.name AS Indice,
    i.type_desc AS Tipo,
    t.name AS Tabla
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'vehiculo' 
AND t.name = 'Vehiculo'
ORDER BY i.name;
GO

-- 4.3 VECTOR_DISTANCE — búsqueda semántica
DECLARE @json NVARCHAR(MAX) = '';
DECLARE @i INT = 1;
WHILE @i <= 1536
BEGIN
    SET @json = @json + '0.5';
    IF @i < 1536 SET @json = @json + ',';
    SET @i = @i + 1;
END
SET @json = '[' + @json + ']';
DECLARE @v VECTOR(1536) = @json;

SELECT TOP 5
    v.Placa,
    mv.Nombre AS Modelo,
    cv.Descripcion AS Categoria,
    VECTOR_DISTANCE('cosine', v.DescripcionVector, @v) AS Distancia
FROM [vehiculo].[Vehiculo] v
JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
WHERE v.DescripcionVector IS NOT NULL
ORDER BY Distancia ASC;
GO

-- 4.4 VECTOR_SEARCH con índice DiskANN
DECLARE @json2 NVARCHAR(MAX) = '';
DECLARE @j INT = 1;
WHILE @j <= 1536
BEGIN
    SET @json2 = @json2 + '0.5';
    IF @j < 1536 SET @json2 = @json2 + ',';
    SET @j = @j + 1;
END
SET @json2 = '[' + @json2 + ']';
DECLARE @v2 VECTOR(1536) = @json2;

SELECT TOP(5)
    s.distance AS Distancia,
    v.Placa,
    mv.Nombre AS Modelo,
    cv.Descripcion AS Categoria
FROM VECTOR_SEARCH(
    TABLE = [vehiculo].[Vehiculo] AS v,
    COLUMN = DescripcionVector,
    SIMILAR_TO = @v2,
    METRIC = 'cosine',
    TOP_N = 5
) AS s
JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
ORDER BY s.distance ASC;
GO

-- =============================================================================
-- 5. EXTERNAL API — tipo de cambio real desde exchangerate-api.com
-- =============================================================================

-- 5.1 Verificar feature habilitada
SELECT name, value_in_use AS Habilitado
FROM sys.configurations
WHERE name = 'external rest endpoint enabled';
GO

-- 5.2 Ejecutar SP de tipo de cambio
DECLARE @id INT;
EXEC [alquiler].[sp_ObtenerTipoCambioBCCR]
    @FechaConsulta = '2026-06-12',
    @TipoCambio_ID = @id OUTPUT;

SELECT @id AS TipoCambio_ID_Insertado;

SELECT TOP 5 * 
FROM [ref].[TipoCambio] 
ORDER BY TipoCambio_ID DESC;
GO

-- =============================================================================
-- 6. REGEXP_LIKE — validaciones avanzadas con expresiones regulares
-- =============================================================================

-- 6.1 Validación directa con REGEXP_LIKE
SELECT
    Identificador_ID,
    Numero,
    CASE
        WHEN REGEXP_LIKE(Numero, N'^[1-9]-[0-9]{4}-[0-9]{4}$') THEN 'VÁLIDA '
        ELSE 'INVÁLIDA '
    END AS EstadoCedula
FROM [persona].[Identificador]
WHERE TipoIdentificacion_ID = 1;
GO

-- 6.2 Validar correos con REGEXP_LIKE
SELECT
    MecanismoContacto_ID,
    Valor AS Correo,
    CASE
        WHEN REGEXP_LIKE(Valor, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'VÁLIDO '
        ELSE 'INVÁLIDO '
    END AS EstadoCorreo
FROM [persona].[MecanismoContacto]
WHERE TipoMecanismoContacto_ID = 1;
GO

-- 6.3 Probar SP de validación de placa
DECLARE @valido BIT, @mensaje NVARCHAR(200);

EXEC [vehiculo].[sp_ValidarVehiculo] 
    'ABC-123', '1HGBH41JXMN109186', 
    @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Placa ABC-123' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;

EXEC [vehiculo].[sp_ValidarVehiculo] 
    'AB-1', '1HGBH41JXMN109186', 
    @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Placa AB-1 (inválida)' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO
