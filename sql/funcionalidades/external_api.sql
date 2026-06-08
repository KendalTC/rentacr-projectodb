USE [RentaCR];
GO

CREATE OR ALTER PROCEDURE [alquiler].[sp_ObtenerTipoCambioBCCR]
    @FechaConsulta DATE,
    @TipoCambio_ID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si ya existe el tipo de cambio para esa fecha
    IF EXISTS (
        SELECT 1 FROM [ref].[TipoCambio] tc
        JOIN [ref].[Moneda] m ON tc.Moneda_ID = m.Moneda_ID
        WHERE tc.Fecha = @FechaConsulta AND m.Codigo = 'USD'
    )
    BEGIN
        SELECT @TipoCambio_ID = tc.TipoCambio_ID
        FROM [ref].[TipoCambio] tc
        JOIN [ref].[Moneda] m ON tc.Moneda_ID = m.Moneda_ID
        WHERE tc.Fecha = @FechaConsulta AND m.Codigo = 'USD';
        RETURN;
    END

    DECLARE @url        NVARCHAR(500);
    DECLARE @response   NVARCHAR(MAX);
    DECLARE @compra     DECIMAL(12,4);
    DECLARE @venta      DECIMAL(12,4);
    DECLARE @moneda_id  SMALLINT;

    -- API alternativa: exchangerate-api.com (BCCR bloquea IPs de Azure)
    SET @url = 'https://api.exchangerate-api.com/v4/latest/USD';

    EXEC sp_invoke_external_rest_endpoint
        @url     = @url,
        @method  = 'GET',
        @response = @response OUTPUT;

    -- Obtener Moneda_ID para USD
    SELECT @moneda_id = Moneda_ID FROM [ref].[Moneda] WHERE Codigo = 'USD';

    -- Parsear CRC desde el JSON de respuesta
    SET @compra = CAST(JSON_VALUE(@response, '$.result.rates.CRC') AS DECIMAL(12,4));
    SET @venta  = CAST(@compra * 1.01 AS DECIMAL(12,4)); -- venta = compra + 1%

    INSERT INTO [ref].[TipoCambio] (Fecha, Moneda_ID, TipoCambioCompra, TipoCambioVenta, FuenteConsulta)
    VALUES (@FechaConsulta, @moneda_id, @compra, @venta, 'ExchangeRate-API');

    SET @TipoCambio_ID = SCOPE_IDENTITY();
END;
GO

-- Probar el SP
DECLARE @id INT;

EXEC [alquiler].[sp_ObtenerTipoCambioBCCR]
    @FechaConsulta = '2026-06-08',
    @TipoCambio_ID = @id OUTPUT;

SELECT @id AS TipoCambio_ID_Insertado;

-- Verificar el registro insertado
SELECT * FROM [ref].[TipoCambio] WHERE TipoCambio_ID = @id;
GO