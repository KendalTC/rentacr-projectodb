-- =============================================================================
-- bloque14_verificacion.sql
-- Verificación Bloque 14 — Serialización JSON
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Ejecutar durante la defensa para demostrar:
--   ✅ sp_SerializarClientesJSON funcional
--   ✅ JSON anidado: clientes → contactos, direcciones, identificaciones
--   ✅ 13 clientes serializados (10 físicos + 3 jurídicos)
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. VERIFICAR SP EXISTE
-- =============================================================================
SELECT 
    s.name AS Esquema,
    p.name AS Procedimiento,
    p.create_date AS FechaCreacion
FROM sys.procedures p
JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE p.name = 'sp_SerializarClientesJSON';
GO

-- =============================================================================
-- 2. EJECUTAR SERIALIZACIÓN — output JSON completo
-- =============================================================================
EXEC [persona].[sp_SerializarClientesJSON];
GO

-- =============================================================================
-- 3. VERIFICAR ESTRUCTURA DEL JSON (primeros 2 clientes)
-- =============================================================================
DECLARE @json NVARCHAR(MAX);

SELECT @json = (
    SELECT TOP 2
        c.Cliente_ID,
        p.TipoPersona,
        p.PrimerNombre,
        p.PrimerApellido,
        me.Descripcion AS EstadoCliente,
        (
            SELECT 
                mc.TipoMecanismoContacto_ID,
                mc.Valor,
                mc.Prioridad,
                mc.CodigoArea
            FROM [persona].[MecanismoContacto] mc
            WHERE mc.Persona_ID = p.Persona_ID
            FOR JSON PATH
        ) AS Contactos,
        (
            SELECT 
                d.TipoDireccion_ID,
                d.LineaDireccion1,
                d.Prioridad
            FROM [persona].[Direccion] d
            WHERE d.Persona_ID = p.Persona_ID
            FOR JSON PATH
        ) AS Direcciones,
        (
            SELECT 
                i.TipoIdentificacion_ID,
                i.Numero,
                i.FechaVencimiento
            FROM [persona].[Identificador] i
            WHERE i.Persona_ID = p.Persona_ID
            FOR JSON PATH
        ) AS Identificaciones
    FROM [persona].[Cliente] c
    JOIN [persona].[Persona] p ON c.Persona_ID = p.Persona_ID
    JOIN [ref].[MetaEstado] me ON c.MetaEstado_ID = me.MetaEstado_ID
    FOR JSON PATH, ROOT('clientes')
);

SELECT @json AS JSON_Preview;
GO

-- =============================================================================
-- 4. CONTAR CLIENTES SERIALIZADOS
-- =============================================================================
SELECT 
    COUNT(*) AS TotalClientes,
    SUM(CASE WHEN p.TipoPersona = 'F' THEN 1 ELSE 0 END) AS ClientesFisicos,
    SUM(CASE WHEN p.TipoPersona = 'J' THEN 1 ELSE 0 END) AS ClientesJuridicos
FROM [persona].[Cliente] c
JOIN [persona].[Persona] p ON c.Persona_ID = p.Persona_ID;
GO
