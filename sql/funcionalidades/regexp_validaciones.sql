-- =============================================================================
-- regexp_validaciones.sql
-- Expresiones Regulares Avanzadas — SQL Server 2025
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Función: REGEXP_LIKE (disponible en SQL Server 2025)
-- Estado: FUNCIONAL ✅
-- Validaciones implementadas:
--   - Placa vehicular MOPT: ^[A-Z]{3}-[0-9]{3,4}$
--   - VIN: ^[A-HJ-NPR-Z0-9]{17}$
--   - Correo electrónico: ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$
--   - Teléfono costarricense: ^[2-9][0-9]{7}$
--   - Cédula física CR: ^[1-9]-[0-9]{4}-[0-9]{4}$
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- 1. STORED PROCEDURE — Validar Vehículo (Placa y VIN)
-- =============================================================================
CREATE OR ALTER PROCEDURE [vehiculo].[sp_ValidarVehiculo]
    @Placa   NVARCHAR(10),
    @VIN     NCHAR(17),
    @Valido  BIT OUTPUT,
    @Mensaje NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Valido = 1;
    SET @Mensaje = 'OK';

    -- Validar Placa: formato MOPT ^[A-Z]{3}-[0-9]{3,4}$
    IF NOT REGEXP_LIKE(@Placa, N'^[A-Z]{3}-[0-9]{3,4}$')
    BEGIN
        SET @Valido = 0;
        SET @Mensaje = 'Placa inválida. Formato esperado: ABC-123 o ABC-1234';
        RETURN;
    END

    -- Validar VIN: 17 chars alfanuméricos sin I, O, Q
    IF NOT REGEXP_LIKE(@VIN, N'^[A-HJ-NPR-Z0-9]{17}$')
    BEGIN
        SET @Valido = 0;
        SET @Mensaje = 'VIN inválido. Debe tener 17 caracteres alfanuméricos (sin I, O, Q)';
        RETURN;
    END
END;
GO

-- =============================================================================
-- 2. STORED PROCEDURE — Validar Contacto (correo y teléfono)
-- =============================================================================
CREATE OR ALTER PROCEDURE [persona].[sp_ValidarContacto]
    @TipoContacto NVARCHAR(30),
    @Valor        NVARCHAR(150),
    @Valido       BIT OUTPUT,
    @Mensaje      NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Valido = 1;
    SET @Mensaje = 'OK';

    -- Validar correo electrónico
    IF @TipoContacto = 'Correo'
    BEGIN
        IF NOT REGEXP_LIKE(@Valor, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        BEGIN
            SET @Valido = 0;
            SET @Mensaje = 'Correo electrónico inválido';
            RETURN;
        END
    END

    -- Validar teléfono costarricense: 8 dígitos comenzando con 2-9
    IF @TipoContacto IN ('Celular','TelefonoFijo','WhatsApp')
    BEGIN
        IF NOT REGEXP_LIKE(@Valor, N'^[2-9][0-9]{7}$')
        BEGIN
            SET @Valido = 0;
            SET @Mensaje = 'Número de teléfono inválido. Debe tener 8 dígitos y comenzar con 2-9';
            RETURN;
        END
    END
END;
GO

-- =============================================================================
-- 3. STORED PROCEDURE — Validar Identificación (cédula física)
-- =============================================================================
CREATE OR ALTER PROCEDURE [persona].[sp_ValidarIdentificacion]
    @TipoIdentificacion NVARCHAR(30),
    @Numero             NVARCHAR(30),
    @Valido             BIT OUTPUT,
    @Mensaje            NVARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Valido = 1;
    SET @Mensaje = 'OK';

    -- Validar cédula física costarricense: 1-0000-0000
    IF @TipoIdentificacion = 'CedulaFisica'
    BEGIN
        IF NOT REGEXP_LIKE(@Numero, N'^[1-9]-[0-9]{4}-[0-9]{4}$')
        BEGIN
            SET @Valido = 0;
            SET @Mensaje = 'Cédula física inválida. Formato esperado: 1-0000-0000';
            RETURN;
        END
    END
END;
GO

-- =============================================================================
-- 4. PRUEBAS DE VALIDACIÓN
-- =============================================================================

-- Prueba 1: Placa y VIN válidos
DECLARE @valido BIT, @mensaje NVARCHAR(200);
EXEC [vehiculo].[sp_ValidarVehiculo] 'ABC-123', '1HGBH41JXMN109186', @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Placa ABC-123 / VIN válido' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO

-- Prueba 2: Placa inválida
DECLARE @valido BIT, @mensaje NVARCHAR(200);
EXEC [vehiculo].[sp_ValidarVehiculo] 'AB-123', '1HGBH41JXMN109186', @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Placa AB-123 (inválida)' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO

-- Prueba 3: Correo válido
DECLARE @valido BIT, @mensaje NVARCHAR(200);
EXEC [persona].[sp_ValidarContacto] 'Correo', 'carlos.mora@gmail.com', @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Correo válido' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO

-- Prueba 4: Correo inválido
DECLARE @valido BIT, @mensaje NVARCHAR(200);
EXEC [persona].[sp_ValidarContacto] 'Correo', 'correo-invalido', @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Correo inválido' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO

-- Prueba 5: Cédula válida
DECLARE @valido BIT, @mensaje NVARCHAR(200);
EXEC [persona].[sp_ValidarIdentificacion] 'CedulaFisica', '1-0752-0341', @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Cédula válida' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO

-- Prueba 6: Cédula inválida
DECLARE @valido BIT, @mensaje NVARCHAR(200);
EXEC [persona].[sp_ValidarIdentificacion] 'CedulaFisica', '12345678', @valido OUTPUT, @mensaje OUTPUT;
SELECT 'Cédula inválida' AS Prueba, @valido AS Valido, @mensaje AS Mensaje;
GO

-- =============================================================================
-- 5. VALIDACIÓN MASIVA — todos los identificadores de la BD
-- =============================================================================
SELECT
    i.Identificador_ID,
    i.Numero,
    ti.Codigo AS TipoIdentificacion,
    CASE
        WHEN ti.Codigo = 'CedulaFisica' AND REGEXP_LIKE(i.Numero, N'^[1-9]-[0-9]{4}-[0-9]{4}$') THEN 'VALIDA'
        WHEN ti.Codigo = 'CedulaJuridica' AND REGEXP_LIKE(i.Numero, N'^[0-9]-[0-9]{3}-[0-9]{6}$') THEN 'VALIDA'
        WHEN ti.Codigo = 'Pasaporte' AND REGEXP_LIKE(i.Numero, N'^[A-Z]{1,2}[0-9]{6,9}$') THEN 'VALIDO'
        ELSE 'REVISAR'
    END AS EstadoValidacion
FROM [persona].[Identificador] i
JOIN [ref].[TipoIdentificacion] ti ON i.TipoIdentificacion_ID = ti.TipoIdentificacion_ID
ORDER BY ti.Codigo, i.Identificador_ID;
GO

-- =============================================================================
-- 6. VALIDACIÓN MASIVA — correos de la BD
-- =============================================================================
SELECT
    mc.MecanismoContacto_ID,
    mc.Valor AS Correo,
    CASE
        WHEN REGEXP_LIKE(mc.Valor, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        THEN 'VALIDO'
        ELSE 'INVALIDO'
    END AS EstadoValidacion
FROM [persona].[MecanismoContacto] mc
WHERE mc.TipoMecanismoContacto_ID = 1  -- Solo correos
ORDER BY mc.MecanismoContacto_ID;
GO