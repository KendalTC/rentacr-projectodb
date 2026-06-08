-- =============================================================================
-- RentaCR_Vistas_v1.sql
-- Vistas de seguridad — 41 vistas (1 por tabla)
-- Proyecto: RentaCR | IF5100 Administración de Bases de Datos
-- Alumno: Kendall Trejos Cubero — C4K374
-- =============================================================================
-- Toda consulta a datos se hace exclusivamente a través de vistas.
-- Nunca se otorgan permisos directos sobre las tablas base.
-- =============================================================================

USE [RentaCR];
GO

-- =============================================================================
-- ESQUEMA REF
-- =============================================================================

CREATE OR ALTER VIEW [ref].[vw_Pais]
AS SELECT * FROM [ref].[Pais];
GO

CREATE OR ALTER VIEW [ref].[vw_Moneda]
AS SELECT * FROM [ref].[Moneda];
GO

CREATE OR ALTER VIEW [ref].[vw_UbicacionGeo]
AS SELECT * FROM [ref].[UbicacionGeo];
GO

CREATE OR ALTER VIEW [ref].[vw_MetaEstado]
AS SELECT * FROM [ref].[MetaEstado];
GO

CREATE OR ALTER VIEW [ref].[vw_TipoMecanismoContacto]
AS SELECT * FROM [ref].[TipoMecanismoContacto];
GO

CREATE OR ALTER VIEW [ref].[vw_TipoDireccion]
AS SELECT * FROM [ref].[TipoDireccion];
GO

CREATE OR ALTER VIEW [ref].[vw_TipoIdentificacion]
AS SELECT * FROM [ref].[TipoIdentificacion];
GO

CREATE OR ALTER VIEW [ref].[vw_MarcaTarjeta]
AS SELECT * FROM [ref].[MarcaTarjeta];
GO

CREATE OR ALTER VIEW [ref].[vw_Banco]
AS SELECT * FROM [ref].[Banco];
GO

CREATE OR ALTER VIEW [ref].[vw_Puesto]
AS SELECT * FROM [ref].[Puesto];
GO

CREATE OR ALTER VIEW [ref].[vw_TipoCambio]
AS SELECT * FROM [ref].[TipoCambio];
GO

CREATE OR ALTER VIEW [ref].[vw_Sucursal]
AS SELECT * FROM [ref].[Sucursal];
GO

-- =============================================================================
-- ESQUEMA PERSONA
-- =============================================================================

CREATE OR ALTER VIEW [persona].[vw_Persona]
AS SELECT * FROM [persona].[Persona];
GO

CREATE OR ALTER VIEW [persona].[vw_PersonaFisica]
AS SELECT * FROM [persona].[PersonaFisica];
GO

CREATE OR ALTER VIEW [persona].[vw_PersonaJuridica]
AS SELECT * FROM [persona].[PersonaJuridica];
GO

CREATE OR ALTER VIEW [persona].[vw_Cliente]
AS
    SELECT
        c.Cliente_ID, c.Persona_ID, p.TipoPersona,
        p.PrimerNombre, p.SegundoNombre, p.PrimerApellido, p.SegundoApellido,
        pf.FechaNacimiento, pf.EstadoCivil,
        pj.RazonSocial, pj.NombreComercial, pj.FechaConstitucion,
        c.FechaIngresoSistema,
        me.Descripcion AS EstadoCliente,
        me.Codigo      AS CodigoEstado
    FROM [persona].[Cliente] c
    JOIN [persona].[Persona] p ON c.Persona_ID = p.Persona_ID
    LEFT JOIN [persona].[PersonaFisica] pf ON p.Persona_ID = pf.Persona_ID
    LEFT JOIN [persona].[PersonaJuridica] pj ON p.Persona_ID = pj.Persona_ID
    JOIN [ref].[MetaEstado] me ON c.MetaEstado_ID = me.MetaEstado_ID;
GO

CREATE OR ALTER VIEW [persona].[vw_HistoricoEstadoCliente]
AS SELECT * FROM [persona].[HistoricoEstadoCliente];
GO

CREATE OR ALTER VIEW [persona].[vw_ClasificacionCliente]
AS SELECT * FROM [persona].[ClasificacionCliente];
GO

CREATE OR ALTER VIEW [persona].[vw_ClienteClasificacion]
AS SELECT * FROM [persona].[ClienteClasificacion];
GO

CREATE OR ALTER VIEW [persona].[vw_AtributoCliente]
AS SELECT * FROM [persona].[AtributoCliente];
GO

CREATE OR ALTER VIEW [persona].[vw_Identificador]
AS SELECT * FROM [persona].[Identificador];
GO

CREATE OR ALTER VIEW [persona].[vw_MecanismoContacto]
AS SELECT * FROM [persona].[MecanismoContacto];
GO

CREATE OR ALTER VIEW [persona].[vw_HistoricoEstadoContacto]
AS SELECT * FROM [persona].[HistoricoEstadoContacto];
GO

CREATE OR ALTER VIEW [persona].[vw_Direccion]
AS SELECT * FROM [persona].[Direccion];
GO

CREATE OR ALTER VIEW [persona].[vw_HistoricoEstadoDireccion]
AS SELECT * FROM [persona].[HistoricoEstadoDireccion];
GO

CREATE OR ALTER VIEW [persona].[vw_Empleado]
AS
    SELECT
        e.Empleado_ID,
        e.CodigoEmpleado,
        p.PrimerNombre, p.SegundoNombre, p.PrimerApellido, p.SegundoApellido,
        pu.Descripcion   AS Puesto,
        s.Nombre         AS Sucursal,
        e.FechaIngreso,
        e.FechaSalida,
        me.Descripcion   AS EstadoEmpleado
    FROM [persona].[Empleado] e
    JOIN [persona].[Persona] p ON e.Persona_ID = p.Persona_ID
    JOIN [ref].[Puesto] pu ON e.Puesto_ID = pu.Puesto_ID
    JOIN [ref].[Sucursal] s ON e.Sucursal_ID = s.Sucursal_ID
    JOIN [ref].[MetaEstado] me ON e.MetaEstado_ID = me.MetaEstado_ID;
GO

CREATE OR ALTER VIEW [persona].[vw_HistoricoAsignacionSucursal]
AS SELECT * FROM [persona].[HistoricoAsignacionSucursal];
GO

CREATE OR ALTER VIEW [persona].[vw_HistoricoEstadoEmpleado]
AS SELECT * FROM [persona].[HistoricoEstadoEmpleado];
GO

-- =============================================================================
-- ESQUEMA VEHICULO
-- =============================================================================

CREATE OR ALTER VIEW [vehiculo].[vw_Marca]
AS SELECT * FROM [vehiculo].[Marca];
GO

CREATE OR ALTER VIEW [vehiculo].[vw_ModeloVehiculo]
AS SELECT * FROM [vehiculo].[ModeloVehiculo];
GO

CREATE OR ALTER VIEW [vehiculo].[vw_CategoriaVehiculo]
AS SELECT * FROM [vehiculo].[CategoriaVehiculo];
GO

CREATE OR ALTER VIEW [vehiculo].[vw_Vehiculo]
AS
    SELECT
        v.Vehiculo_ID, v.Placa, v.VIN,
        m.Nombre       AS Marca,
        mv.Nombre      AS Modelo,
        cv.Descripcion AS Categoria,
        v.Anio, v.Color, v.NumeroPuertas, v.Capacidad,
        v.Transmision, v.TipoCombustible, v.Kilometraje,
        v.Descripcion, v.FechaIngresoFlota,
        s.Nombre       AS Sucursal,
        me.Descripcion AS EstadoVehiculo,
        v.NumeroPóliza, v.Aseguradora, v.FechaVencimientoSeguro
    FROM [vehiculo].[Vehiculo] v
    JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
    JOIN [vehiculo].[Marca] m ON mv.Marca_ID = m.Marca_ID
    JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
    JOIN [ref].[Sucursal] s ON v.Sucursal_ID = s.Sucursal_ID
    JOIN [ref].[MetaEstado] me ON v.MetaEstado_ID = me.MetaEstado_ID;
GO

CREATE OR ALTER VIEW [vehiculo].[vw_DocumentoSeguro]
AS SELECT Vehiculo_ID, NumeroPóliza, Aseguradora, FechaInicioCobertura, FechaVencimiento, FechaCarga
   FROM [vehiculo].[DocumentoSeguro];
GO

CREATE OR ALTER VIEW [vehiculo].[vw_ImagenVehiculo]
AS SELECT Imagen_ID, Vehiculo_ID, Descripcion, Url, FechaCarga
   FROM [vehiculo].[ImagenVehiculo];
GO

CREATE OR ALTER VIEW [vehiculo].[vw_Tarifa]
AS SELECT * FROM [vehiculo].[Tarifa];
GO

CREATE OR ALTER VIEW [vehiculo].[vw_DisponibilidadVehiculo]
AS SELECT * FROM [vehiculo].[DisponibilidadVehiculo];
GO

-- =============================================================================
-- ESQUEMA ALQUILER
-- =============================================================================

CREATE OR ALTER VIEW [alquiler].[vw_Contrato]
AS
    SELECT
        c.Contrato_ID, c.NumeroContrato, cl.Cliente_ID,
        p.PrimerNombre + ' ' + ISNULL(p.SegundoNombre + ' ', '') + p.PrimerApellido AS NombreCliente,
        v.Placa, mv.Nombre AS ModeloVehiculo,
        s.Nombre AS Sucursal, e.CodigoEmpleado AS Agente,
        c.FechaInicio, c.FechaFinPactada, c.TarifaAplicada,
        c.DiasPactados, c.MontoTotal, c.MontoTotalUSD,
        c.DepositoGarantia, c.KmEntrega, c.CombustibleEntrega,
        c.Observaciones, me.Descripcion AS EstadoContrato
    FROM [alquiler].[Contrato] c
    JOIN [persona].[Cliente] cl ON c.Cliente_ID = cl.Cliente_ID
    JOIN [persona].[Persona] p ON cl.Persona_ID = p.Persona_ID
    JOIN [vehiculo].[Vehiculo] v ON c.Vehiculo_ID = v.Vehiculo_ID
    JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
    JOIN [ref].[Sucursal] s ON c.Sucursal_ID = s.Sucursal_ID
    JOIN [persona].[Empleado] e ON c.Empleado_ID = e.Empleado_ID
    JOIN [ref].[MetaEstado] me ON c.MetaEstado_ID = me.MetaEstado_ID;
GO

CREATE OR ALTER VIEW [alquiler].[vw_Devolucion]
AS SELECT * FROM [alquiler].[Devolucion];
GO

CREATE OR ALTER VIEW [alquiler].[vw_FormaPago]
AS SELECT * FROM [alquiler].[FormaPago];
GO

CREATE OR ALTER VIEW [alquiler].[vw_PagoTarjeta]
AS SELECT * FROM [alquiler].[PagoTarjeta];
GO

CREATE OR ALTER VIEW [alquiler].[vw_PagoTransferencia]
AS SELECT * FROM [alquiler].[PagoTransferencia];
GO

-- =============================================================================
-- VERIFICACION — debe mostrar 41 vistas
-- =============================================================================
SELECT s.name AS Esquema, v.name AS Vista
FROM sys.views v
JOIN sys.schemas s ON v.schema_id = s.schema_id
ORDER BY s.name, v.name;
GO
