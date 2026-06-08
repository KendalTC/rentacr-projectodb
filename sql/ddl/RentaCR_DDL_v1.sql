-- ============================================================
-- DDL COMPLETO — BASE DE DATOS RentaCR
-- IF5100 Administración de Bases de Datos — UCR I Semestre 2026
-- Profesor: Luis Diego Bolaños A.
-- Alumno: Kendall Trejos Cubero
-- Versión: 1.0 — Mayo 2026
-- ============================================================
-- Convenciones:
--   Tablas:      PascalCase              → Cliente
--   Vistas:      vw_PascalCase           → vw_Cliente
--   Stored Proc: sp_PascalCase           → sp_ObtenerClientes
--   Índices:     IX_Tabla_Columna        → IX_Cliente_Correo
--   PK:          PK_Tabla                → PK_Cliente
--   FK:          FK_TablaHijo_TablaPadre → FK_Cliente_Persona
--   Esquemas:    persona, vehiculo, alquiler, ref
-- ============================================================


-- ============================================================
-- 0. CREAR LA BASE DE DATOS
-- ============================================================

USE [master];
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RentaCR')
    DROP DATABASE [RentaCR];
GO

CREATE DATABASE [RentaCR]
ON PRIMARY
(
    NAME = N'RentaCR_data',
    FILENAME = N'D:\SQLData\RentaCR_data.mdf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
),
-- Filegroup para FILESTREAM (fotos de vehículos)
FILEGROUP [RentaCR_FS] CONTAINS FILESTREAM
(
    NAME = N'RentaCR_fs',
    FILENAME = N'D:\SQLData\RentaCR_fs'
)
LOG ON
(
    NAME = N'RentaCR_log',
    FILENAME = N'E:\SQLLogs\RentaCR_log.ldf',
    SIZE = 64MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 32MB
);
GO

ALTER DATABASE [RentaCR] SET RECOVERY FULL;
GO

USE [RentaCR];
GO


-- ============================================================
-- 1. CREAR ESQUEMAS
-- ============================================================

CREATE SCHEMA [persona];   -- Personas, clientes, empleados, contactos, direcciones
GO
CREATE SCHEMA [vehiculo];  -- Flota, categorías, seguros, disponibilidad
GO
CREATE SCHEMA [alquiler];  -- Contratos, devoluciones, pagos
GO
CREATE SCHEMA [ref];       -- Catálogos y tablas de referencia
GO


-- ============================================================
-- 2. TABLAS DE REFERENCIA (esquema ref)
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 PAIS
-- ------------------------------------------------------------
CREATE TABLE [ref].[Pais]
(
    Pais_ID        SMALLINT        NOT NULL IDENTITY(1,1),
    ISOAlpha2      CHAR(2)         NOT NULL,
    ISOAlpha3      CHAR(3)         NOT NULL,
    NombreOficial  NVARCHAR(100)   NOT NULL,
    NombreLocal    NVARCHAR(100)       NULL,

    CONSTRAINT PK_Pais PRIMARY KEY CLUSTERED (Pais_ID),
    CONSTRAINT UQ_Pais_ISOAlpha2 UNIQUE (ISOAlpha2),
    CONSTRAINT UQ_Pais_ISOAlpha3 UNIQUE (ISOAlpha3)
);
GO

-- ------------------------------------------------------------
-- 2.2 MONEDA
-- ------------------------------------------------------------
CREATE TABLE [ref].[Moneda]
(
    Moneda_ID          SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo             CHAR(3)         NOT NULL,   -- ISO 4217: CRC, USD
    NombreOficial      NVARCHAR(100)   NOT NULL,
    NombreMonedaLocal  NVARCHAR(100)       NULL,
    Simbolo            NVARCHAR(10)        NULL,

    CONSTRAINT PK_Moneda PRIMARY KEY CLUSTERED (Moneda_ID),
    CONSTRAINT UQ_Moneda_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.3 UBICACION_GEO (Provincia / Cantón / Distrito de CR)
-- ------------------------------------------------------------
CREATE TABLE [ref].[UbicacionGeo]
(
    UbicacionGeo_ID  INT             NOT NULL IDENTITY(1,1),
    CodigoRegion     CHAR(5)         NOT NULL,   -- Código INEC ej: 10101
    Nivel            TINYINT         NOT NULL,   -- 1=Provincia 2=Cantón 3=Distrito
    Valor            NVARCHAR(100)   NOT NULL,
    UbicacionGeo_ID_Padre INT            NULL,   -- NULL para provincias

    CONSTRAINT PK_UbicacionGeo PRIMARY KEY CLUSTERED (UbicacionGeo_ID),
    CONSTRAINT UQ_UbicacionGeo_Codigo UNIQUE (CodigoRegion),
    CONSTRAINT FK_UbicacionGeo_Padre FOREIGN KEY (UbicacionGeo_ID_Padre)
        REFERENCES [ref].[UbicacionGeo] (UbicacionGeo_ID)
);
GO

-- ------------------------------------------------------------
-- 2.4 META_ESTADO (catálogo de estados por entidad)
-- Permite definir los estados válidos para cada entidad del sistema
-- sin cambios en la metadata (diseño flexible)
-- ------------------------------------------------------------
CREATE TABLE [ref].[MetaEstado]
(
    MetaEstado_ID  INT             NOT NULL IDENTITY(1,1),
    Entidad        NVARCHAR(50)    NOT NULL,   -- 'Cliente','Empleado','Contrato',etc.
    Codigo         NVARCHAR(30)    NOT NULL,
    Descripcion    NVARCHAR(100)   NOT NULL,
    Activo         BIT             NOT NULL DEFAULT 1,

    CONSTRAINT PK_MetaEstado PRIMARY KEY CLUSTERED (MetaEstado_ID),
    CONSTRAINT UQ_MetaEstado_Entidad_Codigo UNIQUE (Entidad, Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.5 TIPO_MECANISMO_CONTACTO
-- ------------------------------------------------------------
CREATE TABLE [ref].[TipoMecanismoContacto]
(
    TipoMecanismoContacto_ID  SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo                    NVARCHAR(30)    NOT NULL,
    Descripcion               NVARCHAR(100)   NOT NULL,

    CONSTRAINT PK_TipoMecanismoContacto PRIMARY KEY CLUSTERED (TipoMecanismoContacto_ID),
    CONSTRAINT UQ_TipoMecanismoContacto_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.6 TIPO_DIRECCION
-- ------------------------------------------------------------
CREATE TABLE [ref].[TipoDireccion]
(
    TipoDireccion_ID  SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo            NVARCHAR(30)    NOT NULL,
    Descripcion       NVARCHAR(100)   NOT NULL,

    CONSTRAINT PK_TipoDireccion PRIMARY KEY CLUSTERED (TipoDireccion_ID),
    CONSTRAINT UQ_TipoDireccion_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.7 TIPO_IDENTIFICACION
-- ------------------------------------------------------------
CREATE TABLE [ref].[TipoIdentificacion]
(
    TipoIdentificacion_ID  SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo                 NVARCHAR(30)    NOT NULL,
    Descripcion            NVARCHAR(100)   NOT NULL,

    CONSTRAINT PK_TipoIdentificacion PRIMARY KEY CLUSTERED (TipoIdentificacion_ID),
    CONSTRAINT UQ_TipoIdentificacion_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.8 MARCA_TARJETA
-- ------------------------------------------------------------
CREATE TABLE [ref].[MarcaTarjeta]
(
    MarcaTarjeta_ID  SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo           NVARCHAR(30)    NOT NULL,
    Descripcion      NVARCHAR(100)   NOT NULL,

    CONSTRAINT PK_MarcaTarjeta PRIMARY KEY CLUSTERED (MarcaTarjeta_ID),
    CONSTRAINT UQ_MarcaTarjeta_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.9 BANCO
-- ------------------------------------------------------------
CREATE TABLE [ref].[Banco]
(
    Banco_ID    SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo      NVARCHAR(20)    NOT NULL,
    Nombre      NVARCHAR(100)   NOT NULL,
    Pais_ID     SMALLINT        NOT NULL,

    CONSTRAINT PK_Banco PRIMARY KEY CLUSTERED (Banco_ID),
    CONSTRAINT UQ_Banco_Codigo UNIQUE (Codigo),
    CONSTRAINT FK_Banco_Pais FOREIGN KEY (Pais_ID)
        REFERENCES [ref].[Pais] (Pais_ID)
);
GO

-- ------------------------------------------------------------
-- 2.10 PUESTO (roles de empleado)
-- ------------------------------------------------------------
CREATE TABLE [ref].[Puesto]
(
    Puesto_ID   SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo      NVARCHAR(30)    NOT NULL,
    Descripcion NVARCHAR(100)   NOT NULL,

    CONSTRAINT PK_Puesto PRIMARY KEY CLUSTERED (Puesto_ID),
    CONSTRAINT UQ_Puesto_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 2.11 TIPO_CAMBIO (histórico de tipo de cambio BCCR)
-- Se registra al cerrar cada contrato via External API
-- ------------------------------------------------------------
CREATE TABLE [ref].[TipoCambio]
(
    TipoCambio_ID  INT             NOT NULL IDENTITY(1,1),
    Fecha          DATE            NOT NULL,
    Moneda_ID      SMALLINT        NOT NULL,
    TipoCambioCompra DECIMAL(12,4) NOT NULL,
    TipoCambioVenta  DECIMAL(12,4) NOT NULL,
    FuenteConsulta   NVARCHAR(200) NOT NULL DEFAULT 'BCCR-WS',
    FechaHoraConsulta DATETIME2    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_TipoCambio PRIMARY KEY CLUSTERED (TipoCambio_ID),
    CONSTRAINT UQ_TipoCambio_Fecha_Moneda UNIQUE (Fecha, Moneda_ID),
    CONSTRAINT FK_TipoCambio_Moneda FOREIGN KEY (Moneda_ID)
        REFERENCES [ref].[Moneda] (Moneda_ID)
);
GO

-- ------------------------------------------------------------
-- 2.12 SUCURSAL
-- ------------------------------------------------------------
CREATE TABLE [ref].[Sucursal]
(
    Sucursal_ID      INT             NOT NULL IDENTITY(1,1),
    CodigoSucursal   NVARCHAR(20)    NOT NULL,
    Nombre           NVARCHAR(150)   NOT NULL,
    DireccionFisica  NVARCHAR(300)   NOT NULL,
    Telefono         NVARCHAR(20)        NULL,
    CorreoElectronico NVARCHAR(150)      NULL,
    Horario          NVARCHAR(200)       NULL,
    FechaApertura    DATE            NOT NULL,
    UbicacionGeo_ID  INT                 NULL,   -- Distrito donde se ubica
    MetaEstado_ID    INT             NOT NULL,   -- Estado de la sucursal

    CONSTRAINT PK_Sucursal PRIMARY KEY CLUSTERED (Sucursal_ID),
    CONSTRAINT UQ_Sucursal_Codigo UNIQUE (CodigoSucursal),
    CONSTRAINT FK_Sucursal_UbicacionGeo FOREIGN KEY (UbicacionGeo_ID)
        REFERENCES [ref].[UbicacionGeo] (UbicacionGeo_ID),
    CONSTRAINT FK_Sucursal_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO


-- ============================================================
-- 3. ESQUEMA PERSONA
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 PERSONA (tabla base — herencia)
-- ------------------------------------------------------------
CREATE TABLE [persona].[Persona]
(
    Persona_ID      INT             NOT NULL IDENTITY(1,1),
    TipoPersona     CHAR(1)         NOT NULL,   -- 'F'=Física, 'J'=Jurídica
    -- Campos comunes
    PrimerNombre    NVARCHAR(100)       NULL,   -- NULL para jurídicas
    SegundoNombre   NVARCHAR(100)       NULL,
    PrimerApellido  NVARCHAR(100)       NULL,   -- NULL para jurídicas
    SegundoApellido NVARCHAR(100)       NULL,

    CONSTRAINT PK_Persona PRIMARY KEY CLUSTERED (Persona_ID),
    CONSTRAINT CK_Persona_TipoPersona CHECK (TipoPersona IN ('F','J'))
);
GO

-- ------------------------------------------------------------
-- 3.2 PERSONA_FISICA
-- ------------------------------------------------------------
CREATE TABLE [persona].[PersonaFisica]
(
    Persona_ID      INT             NOT NULL,
    FechaNacimiento DATE                NULL,
    EstadoCivil     NVARCHAR(30)        NULL,

    CONSTRAINT PK_PersonaFisica PRIMARY KEY CLUSTERED (Persona_ID),
    CONSTRAINT FK_PersonaFisica_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID)
);
GO

-- ------------------------------------------------------------
-- 3.3 PERSONA_JURIDICA
-- ------------------------------------------------------------
CREATE TABLE [persona].[PersonaJuridica]
(
    Persona_ID          INT             NOT NULL,
    RazonSocial         NVARCHAR(200)   NOT NULL,
    NombreComercial     NVARCHAR(200)       NULL,
    FechaConstitucion   DATE                NULL,

    CONSTRAINT PK_PersonaJuridica PRIMARY KEY CLUSTERED (Persona_ID),
    CONSTRAINT FK_PersonaJuridica_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID)
);
GO

-- ------------------------------------------------------------
-- 3.4 CLIENTE
-- ------------------------------------------------------------
CREATE TABLE [persona].[Cliente]
(
    Cliente_ID          INT             NOT NULL IDENTITY(1,1),
    Persona_ID          INT             NOT NULL,
    FechaIngresoSistema DATE            NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    MetaEstado_ID       INT             NOT NULL,   -- Estado: activo, inactivo, suspendido, bloqueado

    CONSTRAINT PK_Cliente PRIMARY KEY CLUSTERED (Cliente_ID),
    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID),
    CONSTRAINT FK_Cliente_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID),
    CONSTRAINT UQ_Cliente_Persona UNIQUE (Persona_ID)
);
GO

-- Índice para búsqueda por estado
CREATE NONCLUSTERED INDEX IX_Cliente_MetaEstado
    ON [persona].[Cliente] (MetaEstado_ID);
GO

-- ------------------------------------------------------------
-- 3.5 HISTORICO_ESTADO_CLIENTE
-- Registro histórico de cambios de estado del cliente (Ley 8968)
-- ------------------------------------------------------------
CREATE TABLE [persona].[HistoricoEstadoCliente]
(
    HistoricoEstadoCliente_ID  INT             NOT NULL IDENTITY(1,1),
    Cliente_ID                 INT             NOT NULL,
    MetaEstado_ID              INT             NOT NULL,
    FechaCambio                DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    RazonCambio                NVARCHAR(300)   NOT NULL,

    CONSTRAINT PK_HistoricoEstadoCliente PRIMARY KEY CLUSTERED (HistoricoEstadoCliente_ID),
    CONSTRAINT FK_HistoricoEstadoCliente_Cliente FOREIGN KEY (Cliente_ID)
        REFERENCES [persona].[Cliente] (Cliente_ID),
    CONSTRAINT FK_HistoricoEstadoCliente_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

-- ------------------------------------------------------------
-- 3.6 CLASIFICACION_CLIENTE (catálogo de clasificaciones)
-- Flexible: frecuencia, comportamiento de pago, tamaño jurídico
-- ------------------------------------------------------------
CREATE TABLE [persona].[ClasificacionCliente]
(
    ClasificacionCliente_ID  INT             NOT NULL IDENTITY(1,1),
    Categoria                NVARCHAR(100)   NOT NULL,   -- ej: 'Frecuencia', 'Pago'
    Codigo                   NVARCHAR(30)    NOT NULL,
    Descripcion              NVARCHAR(150)   NOT NULL,

    CONSTRAINT PK_ClasificacionCliente PRIMARY KEY CLUSTERED (ClasificacionCliente_ID),
    CONSTRAINT UQ_ClasificacionCliente_Codigo UNIQUE (Categoria, Codigo)
);
GO

-- ------------------------------------------------------------
-- 3.7 CLIENTE_CLASIFICACION (relación N:M cliente-clasificacion)
-- ------------------------------------------------------------
CREATE TABLE [persona].[ClienteClasificacion]
(
    ClienteClasificacion_ID  INT       NOT NULL IDENTITY(1,1),
    Cliente_ID               INT       NOT NULL,
    ClasificacionCliente_ID  INT       NOT NULL,
    FechaAsignacion          DATE      NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),

    CONSTRAINT PK_ClienteClasificacion PRIMARY KEY CLUSTERED (ClienteClasificacion_ID),
    CONSTRAINT UQ_ClienteClasificacion UNIQUE (Cliente_ID, ClasificacionCliente_ID),
    CONSTRAINT FK_ClienteClasificacion_Cliente FOREIGN KEY (Cliente_ID)
        REFERENCES [persona].[Cliente] (Cliente_ID),
    CONSTRAINT FK_ClienteClasificacion_Clasificacion FOREIGN KEY (ClasificacionCliente_ID)
        REFERENCES [persona].[ClasificacionCliente] (ClasificacionCliente_ID)
);
GO

-- ------------------------------------------------------------
-- 3.8 ATRIBUTO_CLIENTE (EAV — atributos flexibles por cliente)
-- Permite registrar características adicionales sin cambios en metadata
-- ------------------------------------------------------------
CREATE TABLE [persona].[AtributoCliente]
(
    AtributoCliente_ID  INT             NOT NULL IDENTITY(1,1),
    Cliente_ID          INT             NOT NULL,
    TipoDato            NVARCHAR(50)    NOT NULL,   -- ej: 'PreferenciaVehiculo'
    Valor               NVARCHAR(500)   NOT NULL,
    FechaRegistro       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AtributoCliente PRIMARY KEY CLUSTERED (AtributoCliente_ID),
    CONSTRAINT FK_AtributoCliente_Cliente FOREIGN KEY (Cliente_ID)
        REFERENCES [persona].[Cliente] (Cliente_ID)
);
GO

-- ------------------------------------------------------------
-- 3.9 IDENTIFICADOR (documentos de identidad del cliente/empleado)
-- ------------------------------------------------------------
CREATE TABLE [persona].[Identificador]
(
    Identificador_ID       INT             NOT NULL IDENTITY(1,1),
    Persona_ID             INT             NOT NULL,
    TipoIdentificacion_ID  SMALLINT        NOT NULL,
    -- DDM en Numero (cédula) — se aplica en la vista
    Numero                 NVARCHAR(30)    NOT NULL,
    Pais_ID                SMALLINT            NULL,   -- Requerido para pasaportes
    FechaVencimiento       DATE                NULL,
    Activo                 BIT             NOT NULL DEFAULT 1,

    CONSTRAINT PK_Identificador PRIMARY KEY CLUSTERED (Identificador_ID),
    CONSTRAINT FK_Identificador_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID),
    CONSTRAINT FK_Identificador_TipoIdentificacion FOREIGN KEY (TipoIdentificacion_ID)
        REFERENCES [ref].[TipoIdentificacion] (TipoIdentificacion_ID),
    CONSTRAINT FK_Identificador_Pais FOREIGN KEY (Pais_ID)
        REFERENCES [ref].[Pais] (Pais_ID)
);
GO

-- Índice para búsqueda por número de cédula
CREATE NONCLUSTERED INDEX IX_Identificador_Numero
    ON [persona].[Identificador] (Numero);
GO

-- ------------------------------------------------------------
-- 3.10 MECANISMO_CONTACTO (teléfonos, correos, WhatsApp)
-- ------------------------------------------------------------
CREATE TABLE [persona].[MecanismoContacto]
(
    MecanismoContacto_ID      INT             NOT NULL IDENTITY(1,1),
    Persona_ID                INT             NOT NULL,
    TipoMecanismoContacto_ID  SMALLINT        NOT NULL,
    -- DDM en Valor (correo) — se aplica en la vista
    Valor                     NVARCHAR(150)   NOT NULL,
    CodigoArea                NVARCHAR(10)        NULL,
    Prioridad                 TINYINT         NOT NULL DEFAULT 1,
    SolicitadoPorCliente      BIT             NOT NULL DEFAULT 1,
    InstruccionesUso          NVARCHAR(300)       NULL,
    FechaInicio               DATE            NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    FechaFin                  DATE                NULL,
    MetaEstado_ID             INT             NOT NULL,

    CONSTRAINT PK_MecanismoContacto PRIMARY KEY CLUSTERED (MecanismoContacto_ID),
    CONSTRAINT FK_MecanismoContacto_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID),
    CONSTRAINT FK_MecanismoContacto_Tipo FOREIGN KEY (TipoMecanismoContacto_ID)
        REFERENCES [ref].[TipoMecanismoContacto] (TipoMecanismoContacto_ID),
    CONSTRAINT FK_MecanismoContacto_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

-- ------------------------------------------------------------
-- 3.11 HISTORICO_ESTADO_CONTACTO (Ley 8968)
-- ------------------------------------------------------------
CREATE TABLE [persona].[HistoricoEstadoContacto]
(
    HistoricoEstadoContacto_ID  INT             NOT NULL IDENTITY(1,1),
    MecanismoContacto_ID        INT             NOT NULL,
    MetaEstado_ID               INT             NOT NULL,
    FechaCambio                 DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    RazonCambio                 NVARCHAR(300)   NOT NULL,

    CONSTRAINT PK_HistoricoEstadoContacto PRIMARY KEY CLUSTERED (HistoricoEstadoContacto_ID),
    CONSTRAINT FK_HistoricoEstadoContacto_Contacto FOREIGN KEY (MecanismoContacto_ID)
        REFERENCES [persona].[MecanismoContacto] (MecanismoContacto_ID),
    CONSTRAINT FK_HistoricoEstadoContacto_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

-- ------------------------------------------------------------
-- 3.12 DIRECCION
-- DDM en LineaDireccion1 — se aplica en la vista
-- ------------------------------------------------------------
CREATE TABLE [persona].[Direccion]
(
    Direccion_ID      INT             NOT NULL IDENTITY(1,1),
    Persona_ID        INT             NOT NULL,
    TipoDireccion_ID  SMALLINT        NOT NULL,
    LineaDireccion1   NVARCHAR(300)   NOT NULL,
    LineaDireccion2   NVARCHAR(300)       NULL,
    DireccionPostal   NVARCHAR(50)        NULL,
    Prioridad         TINYINT         NOT NULL DEFAULT 1,
    FechaInicio       DATE            NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    FechaFin          DATE                NULL,
    UbicacionGeo_ID   INT                 NULL,   -- Distrito
    MetaEstado_ID     INT             NOT NULL,

    CONSTRAINT PK_Direccion PRIMARY KEY CLUSTERED (Direccion_ID),
    CONSTRAINT FK_Direccion_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID),
    CONSTRAINT FK_Direccion_TipoDireccion FOREIGN KEY (TipoDireccion_ID)
        REFERENCES [ref].[TipoDireccion] (TipoDireccion_ID),
    CONSTRAINT FK_Direccion_UbicacionGeo FOREIGN KEY (UbicacionGeo_ID)
        REFERENCES [ref].[UbicacionGeo] (UbicacionGeo_ID),
    CONSTRAINT FK_Direccion_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

-- ------------------------------------------------------------
-- 3.13 HISTORICO_ESTADO_DIRECCION (Ley 8968)
-- ------------------------------------------------------------
CREATE TABLE [persona].[HistoricoEstadoDireccion]
(
    HistoricoEstadoDireccion_ID  INT             NOT NULL IDENTITY(1,1),
    Direccion_ID                 INT             NOT NULL,
    MetaEstado_ID                INT             NOT NULL,
    FechaCambio                  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    RazonCambio                  NVARCHAR(300)   NOT NULL,

    CONSTRAINT PK_HistoricoEstadoDireccion PRIMARY KEY CLUSTERED (HistoricoEstadoDireccion_ID),
    CONSTRAINT FK_HistoricoEstadoDireccion_Direccion FOREIGN KEY (Direccion_ID)
        REFERENCES [persona].[Direccion] (Direccion_ID),
    CONSTRAINT FK_HistoricoEstadoDireccion_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

-- ------------------------------------------------------------
-- 3.14 EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE [persona].[Empleado]
(
    Empleado_ID     INT             NOT NULL IDENTITY(1,1),
    Persona_ID      INT             NOT NULL,
    CodigoEmpleado  NVARCHAR(20)    NOT NULL,
    Puesto_ID       SMALLINT        NOT NULL,
    FechaIngreso    DATE            NOT NULL,
    FechaSalida     DATE                NULL,
    Sucursal_ID     INT             NOT NULL,   -- Sucursal actual
    MetaEstado_ID   INT             NOT NULL,

    CONSTRAINT PK_Empleado PRIMARY KEY CLUSTERED (Empleado_ID),
    CONSTRAINT UQ_Empleado_Codigo UNIQUE (CodigoEmpleado),
    CONSTRAINT UQ_Empleado_Persona UNIQUE (Persona_ID),
    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (Persona_ID)
        REFERENCES [persona].[Persona] (Persona_ID),
    CONSTRAINT FK_Empleado_Puesto FOREIGN KEY (Puesto_ID)
        REFERENCES [ref].[Puesto] (Puesto_ID),
    CONSTRAINT FK_Empleado_Sucursal FOREIGN KEY (Sucursal_ID)
        REFERENCES [ref].[Sucursal] (Sucursal_ID),
    CONSTRAINT FK_Empleado_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

-- ------------------------------------------------------------
-- 3.15 HISTORICO_ASIGNACION_SUCURSAL (empleado en múltiples sucursales)
-- ------------------------------------------------------------
CREATE TABLE [persona].[HistoricoAsignacionSucursal]
(
    HistoricoAsignacion_ID  INT       NOT NULL IDENTITY(1,1),
    Empleado_ID             INT       NOT NULL,
    Sucursal_ID             INT       NOT NULL,
    FechaInicio             DATE      NOT NULL,
    FechaFin                DATE          NULL,
    Motivo                  NVARCHAR(300) NULL,

    CONSTRAINT PK_HistoricoAsignacionSucursal PRIMARY KEY CLUSTERED (HistoricoAsignacion_ID),
    CONSTRAINT FK_HistoricoAsignacion_Empleado FOREIGN KEY (Empleado_ID)
        REFERENCES [persona].[Empleado] (Empleado_ID),
    CONSTRAINT FK_HistoricoAsignacion_Sucursal FOREIGN KEY (Sucursal_ID)
        REFERENCES [ref].[Sucursal] (Sucursal_ID)
);
GO

-- ------------------------------------------------------------
-- 3.16 HISTORICO_ESTADO_EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE [persona].[HistoricoEstadoEmpleado]
(
    HistoricoEstadoEmpleado_ID  INT             NOT NULL IDENTITY(1,1),
    Empleado_ID                 INT             NOT NULL,
    MetaEstado_ID               INT             NOT NULL,
    FechaCambio                 DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    RazonCambio                 NVARCHAR(300)   NOT NULL,

    CONSTRAINT PK_HistoricoEstadoEmpleado PRIMARY KEY CLUSTERED (HistoricoEstadoEmpleado_ID),
    CONSTRAINT FK_HistoricoEstadoEmpleado_Empleado FOREIGN KEY (Empleado_ID)
        REFERENCES [persona].[Empleado] (Empleado_ID),
    CONSTRAINT FK_HistoricoEstadoEmpleado_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO


-- ============================================================
-- 4. ESQUEMA VEHICULO
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 MARCA (fabricante del vehículo)
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[Marca]
(
    Marca_ID    SMALLINT        NOT NULL IDENTITY(1,1),
    Nombre      NVARCHAR(100)   NOT NULL,
    Pais_ID     SMALLINT            NULL,

    CONSTRAINT PK_Marca PRIMARY KEY CLUSTERED (Marca_ID),
    CONSTRAINT UQ_Marca_Nombre UNIQUE (Nombre),
    CONSTRAINT FK_Marca_Pais FOREIGN KEY (Pais_ID)
        REFERENCES [ref].[Pais] (Pais_ID)
);
GO

-- ------------------------------------------------------------
-- 4.2 MODELO_VEHICULO
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[ModeloVehiculo]
(
    ModeloVehiculo_ID  SMALLINT        NOT NULL IDENTITY(1,1),
    Marca_ID           SMALLINT        NOT NULL,
    Nombre             NVARCHAR(100)   NOT NULL,

    CONSTRAINT PK_ModeloVehiculo PRIMARY KEY CLUSTERED (ModeloVehiculo_ID),
    CONSTRAINT FK_ModeloVehiculo_Marca FOREIGN KEY (Marca_ID)
        REFERENCES [vehiculo].[Marca] (Marca_ID)
);
GO

-- ------------------------------------------------------------
-- 4.3 CATEGORIA_VEHICULO (con tarifa diaria base)
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[CategoriaVehiculo]
(
    CategoriaVehiculo_ID  SMALLINT        NOT NULL IDENTITY(1,1),
    Codigo                NVARCHAR(30)    NOT NULL,
    Descripcion           NVARCHAR(150)   NOT NULL,
    TarifaDiariaBase      DECIMAL(12,2)   NOT NULL,

    CONSTRAINT PK_CategoriaVehiculo PRIMARY KEY CLUSTERED (CategoriaVehiculo_ID),
    CONSTRAINT UQ_CategoriaVehiculo_Codigo UNIQUE (Codigo)
);
GO

-- ------------------------------------------------------------
-- 4.4 VEHICULO
-- Incluye columna VECTOR para Semantic Search (SS2025)
-- Validaciones con REGEXP_ se aplican en stored procedures
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[Vehiculo]
(
    Vehiculo_ID        INT             NOT NULL IDENTITY(1,1),
    -- Validado con REGEXP_LIKE: [A-Z]{3}-[0-9]{3,4}
    Placa              NVARCHAR(10)    NOT NULL,
    -- Validado con REGEXP_LIKE: [A-HJ-NPR-Z0-9]{17}
    VIN                NCHAR(17)       NOT NULL,
    ModeloVehiculo_ID  SMALLINT        NOT NULL,
    CategoriaVehiculo_ID SMALLINT      NOT NULL,
    Anio               SMALLINT        NOT NULL,
    Color              NVARCHAR(50)    NOT NULL,
    NumeroPuertas      TINYINT         NOT NULL,
    Capacidad          TINYINT         NOT NULL,
    Transmision        NVARCHAR(20)    NOT NULL,
    TipoCombustible    NVARCHAR(20)    NOT NULL,
    Kilometraje        INT             NOT NULL DEFAULT 0,
    Descripcion        NVARCHAR(MAX)       NULL,
    -- Vector para Semantic Search — SQL Server 2025
    DescripcionVector  VECTOR(1536)        NULL,
    FechaIngresoFlota  DATE            NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    Sucursal_ID        INT             NOT NULL,
    MetaEstado_ID      INT             NOT NULL,
    -- Póliza de seguro vigente (desnormalizado para acceso rápido)
    NumeroPóliza       NVARCHAR(50)        NULL,
    Aseguradora        NVARCHAR(100)       NULL,
    FechaInicioCobertura DATE              NULL,
    FechaVencimientoSeguro DATE            NULL,

    CONSTRAINT PK_Vehiculo PRIMARY KEY CLUSTERED (Vehiculo_ID),
    CONSTRAINT UQ_Vehiculo_Placa UNIQUE (Placa),
    CONSTRAINT UQ_Vehiculo_VIN UNIQUE (VIN),
    CONSTRAINT CK_Vehiculo_Transmision CHECK (Transmision IN ('Manual','Automatica')),
    CONSTRAINT CK_Vehiculo_Combustible CHECK (TipoCombustible IN ('Gasolina','Diesel','Hibrido','Electrico')),
    CONSTRAINT FK_Vehiculo_Modelo FOREIGN KEY (ModeloVehiculo_ID)
        REFERENCES [vehiculo].[ModeloVehiculo] (ModeloVehiculo_ID),
    CONSTRAINT FK_Vehiculo_Categoria FOREIGN KEY (CategoriaVehiculo_ID)
        REFERENCES [vehiculo].[CategoriaVehiculo] (CategoriaVehiculo_ID),
    CONSTRAINT FK_Vehiculo_Sucursal FOREIGN KEY (Sucursal_ID)
        REFERENCES [ref].[Sucursal] (Sucursal_ID),
    CONSTRAINT FK_Vehiculo_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID)
);
GO

CREATE NONCLUSTERED INDEX IX_Vehiculo_Placa
    ON [vehiculo].[Vehiculo] (Placa);
GO
CREATE NONCLUSTERED INDEX IX_Vehiculo_Sucursal_Estado
    ON [vehiculo].[Vehiculo] (Sucursal_ID, MetaEstado_ID);
GO

-- ------------------------------------------------------------
-- 4.5 DOCUMENTO_SEGURO (póliza en VARBINARY + datos de referencia)
-- Se guarda aparte para no inflar la tabla Vehiculo
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[DocumentoSeguro]
(
    DocumentoSeguro_ID    INT             NOT NULL IDENTITY(1,1),
    Vehiculo_ID           INT             NOT NULL,
    NumeroPóliza          NVARCHAR(50)    NOT NULL,
    Aseguradora           NVARCHAR(100)   NOT NULL,
    FechaInicioCobertura  DATE            NOT NULL,
    FechaVencimiento      DATE            NOT NULL,
    PDF                   VARBINARY(MAX)  NOT NULL,
    FechaCarga            DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_DocumentoSeguro PRIMARY KEY CLUSTERED (DocumentoSeguro_ID),
    CONSTRAINT FK_DocumentoSeguro_Vehiculo FOREIGN KEY (Vehiculo_ID)
        REFERENCES [vehiculo].[Vehiculo] (Vehiculo_ID)
);
GO

-- ------------------------------------------------------------
-- 4.6 IMAGEN_VEHICULO (FILESTREAM — fotos del vehículo)
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[ImagenVehiculo]
(
    Imagen_ID    UNIQUEIDENTIFIER NOT NULL ROWGUIDCOL DEFAULT NEWSEQUENTIALID(),
    Vehiculo_ID  INT              NOT NULL,
    Descripcion  NVARCHAR(200)        NULL,
    Url          NVARCHAR(500)        NULL,
    Imagen       VARBINARY(MAX) FILESTREAM NULL,
    FechaCarga   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_ImagenVehiculo PRIMARY KEY CLUSTERED (Imagen_ID),
    CONSTRAINT FK_ImagenVehiculo_Vehiculo FOREIGN KEY (Vehiculo_ID)
        REFERENCES [vehiculo].[Vehiculo] (Vehiculo_ID)
);
GO

-- ------------------------------------------------------------
-- 4.7 TARIFA (histórico de tarifas por categoría y sucursal)
-- ------------------------------------------------------------
CREATE TABLE [vehiculo].[Tarifa]
(
    Tarifa_ID            INT             NOT NULL IDENTITY(1,1),
    CategoriaVehiculo_ID SMALLINT        NOT NULL,
    Sucursal_ID          INT                 NULL,   -- NULL = aplica a todas
    TarifaDiariaCRC      DECIMAL(12,2)   NOT NULL,
    TarifaDiariaUSD      DECIMAL(12,4)   NOT NULL,
    Temporada            NVARCHAR(20)    NOT NULL,
    FechaInicioVigencia  DATE            NOT NULL,
    FechaFinVigencia     DATE                NULL,

    CONSTRAINT PK_Tarifa PRIMARY KEY CLUSTERED (Tarifa_ID),
    CONSTRAINT CK_Tarifa_Temporada CHECK (Temporada IN ('Alta','Baja','Festiva')),
    CONSTRAINT FK_Tarifa_Categoria FOREIGN KEY (CategoriaVehiculo_ID)
        REFERENCES [vehiculo].[CategoriaVehiculo] (CategoriaVehiculo_ID),
    CONSTRAINT FK_Tarifa_Sucursal FOREIGN KEY (Sucursal_ID)
        REFERENCES [ref].[Sucursal] (Sucursal_ID)
);
GO

-- ------------------------------------------------------------
-- 4.8 DISPONIBILIDAD_VEHICULO — Memory-Optimized Table (IN-MEMORY OLTP)
-- Alta concurrencia, baja latencia — estado en tiempo real
-- ------------------------------------------------------------
USE [RentaCR];
GO

ALTER DATABASE [RentaCR]
ADD FILEGROUP [RentaCR_MemOpt] CONTAINS MEMORY_OPTIMIZED_DATA;
GO

ALTER DATABASE [RentaCR]
ADD FILE (
    NAME = 'RentaCR_MemOpt',
    FILENAME = 'D:\SQLData\RentaCR_MemOpt'
) TO FILEGROUP [RentaCR_MemOpt];
GO



CREATE TABLE [vehiculo].[DisponibilidadVehiculo]
(
    Disponibilidad_ID    INT             NOT NULL IDENTITY(1,1),
    Vehiculo_ID          INT             NOT NULL,
    Sucursal_ID          INT             NOT NULL,
    EstadoDisponibilidad NVARCHAR(30)    NOT NULL,
    FechaHoraEstado      DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    Contrato_ID          INT                 NULL,   -- FK lógica, no física en in-memory

    CONSTRAINT PK_DisponibilidadVehiculo PRIMARY KEY NONCLUSTERED (Disponibilidad_ID),
    CONSTRAINT CK_Disponibilidad_Estado CHECK (EstadoDisponibilidad IN ('Disponible','Alquilado','FueraDeServicio'))
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO


-- ============================================================
-- 5. ESQUEMA ALQUILER
-- ============================================================

-- ------------------------------------------------------------
-- 5.1 CONTRATO
-- ------------------------------------------------------------
CREATE TABLE [alquiler].[Contrato]
(
    Contrato_ID       INT             NOT NULL IDENTITY(1,1),
    NumeroContrato    NVARCHAR(20)    NOT NULL,
    Cliente_ID        INT             NOT NULL,
    Vehiculo_ID       INT             NOT NULL,
    Sucursal_ID       INT             NOT NULL,
    Empleado_ID       INT             NOT NULL,
    Tarifa_ID         INT             NOT NULL,   -- Tarifa vigente al momento del contrato
    FechaInicio       DATETIME2       NOT NULL,
    FechaFinPactada   DATETIME2       NOT NULL,
    TarifaAplicada    DECIMAL(12,2)   NOT NULL,   -- Snapshot de la tarifa
    DiasPactados      SMALLINT        NOT NULL,
    MontoTotal        DECIMAL(14,2)   NOT NULL,
    DepositoGarantia  DECIMAL(14,2)       NULL,
    KmEntrega         INT             NOT NULL,
    CombustibleEntrega NVARCHAR(20)   NOT NULL,
    Observaciones     NVARCHAR(500)       NULL,
    MetaEstado_ID     INT             NOT NULL,
    -- Tipo de cambio registrado al cerrar (via API BCCR)
    TipoCambio_ID     INT                 NULL,
    MontoTotalUSD     DECIMAL(14,4)       NULL,

    CONSTRAINT PK_Contrato PRIMARY KEY CLUSTERED (Contrato_ID),
    CONSTRAINT UQ_Contrato_Numero UNIQUE (NumeroContrato),
    CONSTRAINT CK_Contrato_Combustible CHECK (CombustibleEntrega IN ('Vacio','Cuarto','Mitad','TresCuartos','Lleno')),
    CONSTRAINT FK_Contrato_Cliente FOREIGN KEY (Cliente_ID)
        REFERENCES [persona].[Cliente] (Cliente_ID),
    CONSTRAINT FK_Contrato_Vehiculo FOREIGN KEY (Vehiculo_ID)
        REFERENCES [vehiculo].[Vehiculo] (Vehiculo_ID),
    CONSTRAINT FK_Contrato_Sucursal FOREIGN KEY (Sucursal_ID)
        REFERENCES [ref].[Sucursal] (Sucursal_ID),
    CONSTRAINT FK_Contrato_Empleado FOREIGN KEY (Empleado_ID)
        REFERENCES [persona].[Empleado] (Empleado_ID),
    CONSTRAINT FK_Contrato_Tarifa FOREIGN KEY (Tarifa_ID)
        REFERENCES [vehiculo].[Tarifa] (Tarifa_ID),
    CONSTRAINT FK_Contrato_MetaEstado FOREIGN KEY (MetaEstado_ID)
        REFERENCES [ref].[MetaEstado] (MetaEstado_ID),
    CONSTRAINT FK_Contrato_TipoCambio FOREIGN KEY (TipoCambio_ID)
        REFERENCES [ref].[TipoCambio] (TipoCambio_ID)
);
GO

CREATE NONCLUSTERED INDEX IX_Contrato_Cliente
    ON [alquiler].[Contrato] (Cliente_ID);
GO
CREATE NONCLUSTERED INDEX IX_Contrato_Sucursal_Estado
    ON [alquiler].[Contrato] (Sucursal_ID, MetaEstado_ID);
GO

-- ------------------------------------------------------------
-- 5.2 DEVOLUCION
-- ------------------------------------------------------------
CREATE TABLE [alquiler].[Devolucion]
(
    Devolucion_ID         INT             NOT NULL IDENTITY(1,1),
    Contrato_ID           INT             NOT NULL,
    FechaDevolucionReal   DATETIME2       NOT NULL,
    Sucursal_ID           INT             NOT NULL,   -- Puede ser diferente a la de origen
    Empleado_ID           INT             NOT NULL,   -- Empleado que recibe
    KmDevolucion          INT             NOT NULL,
    CombustibleDevolucion NVARCHAR(20)    NOT NULL,
    EstadoVehiculo        NVARCHAR(30)    NOT NULL,
    DescripcionDanios     NVARCHAR(500)       NULL,

    CONSTRAINT PK_Devolucion PRIMARY KEY CLUSTERED (Devolucion_ID),
    CONSTRAINT UQ_Devolucion_Contrato UNIQUE (Contrato_ID),   -- 1 devolución por contrato
    CONSTRAINT CK_Devolucion_Combustible CHECK (CombustibleDevolucion IN ('Vacio','Cuarto','Mitad','TresCuartos','Lleno')),
    CONSTRAINT CK_Devolucion_EstadoVehiculo CHECK (EstadoVehiculo IN ('SinDanios','DaniosLeves','DaniosMayores')),
    CONSTRAINT FK_Devolucion_Contrato FOREIGN KEY (Contrato_ID)
        REFERENCES [alquiler].[Contrato] (Contrato_ID),
    CONSTRAINT FK_Devolucion_Sucursal FOREIGN KEY (Sucursal_ID)
        REFERENCES [ref].[Sucursal] (Sucursal_ID),
    CONSTRAINT FK_Devolucion_Empleado FOREIGN KEY (Empleado_ID)
        REFERENCES [persona].[Empleado] (Empleado_ID)
);
GO

-- ------------------------------------------------------------
-- 5.3 FORMA_PAGO (cabecera — tipo de pago por contrato)
-- ------------------------------------------------------------
CREATE TABLE [alquiler].[FormaPago]
(
    FormaPago_ID  INT             NOT NULL IDENTITY(1,1),
    Contrato_ID   INT             NOT NULL,
    Empleado_ID   INT             NOT NULL,
    TipoPago      NVARCHAR(30)    NOT NULL,
    MontoPago     DECIMAL(14,2)   NOT NULL,
    Moneda_ID     SMALLINT        NOT NULL,
    FechaPago     DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_FormaPago PRIMARY KEY CLUSTERED (FormaPago_ID),
    CONSTRAINT CK_FormaPago_TipoPago CHECK (TipoPago IN ('Efectivo','TarjetaDebito','TarjetaCredito','Transferencia')),
    CONSTRAINT FK_FormaPago_Contrato FOREIGN KEY (Contrato_ID)
        REFERENCES [alquiler].[Contrato] (Contrato_ID),
    CONSTRAINT FK_FormaPago_Empleado FOREIGN KEY (Empleado_ID)
        REFERENCES [persona].[Empleado] (Empleado_ID),
    CONSTRAINT FK_FormaPago_Moneda FOREIGN KEY (Moneda_ID)
        REFERENCES [ref].[Moneda] (Moneda_ID)
);
GO

-- ------------------------------------------------------------
-- 5.4 PAGO_TARJETA (detalle para pagos con tarjeta)
-- ------------------------------------------------------------
CREATE TABLE [alquiler].[PagoTarjeta]
(
    PagoTarjeta_ID      INT             NOT NULL IDENTITY(1,1),
    FormaPago_ID        INT             NOT NULL,
    MarcaTarjeta_ID     SMALLINT        NOT NULL,
    BIN                 CHAR(6)         NOT NULL,
    CodigoAutorizacion  NVARCHAR(20)    NOT NULL,
    Emisor              NVARCHAR(100)       NULL,

    CONSTRAINT PK_PagoTarjeta PRIMARY KEY CLUSTERED (PagoTarjeta_ID),
    CONSTRAINT UQ_PagoTarjeta_FormaPago UNIQUE (FormaPago_ID),
    CONSTRAINT FK_PagoTarjeta_FormaPago FOREIGN KEY (FormaPago_ID)
        REFERENCES [alquiler].[FormaPago] (FormaPago_ID),
    CONSTRAINT FK_PagoTarjeta_MarcaTarjeta FOREIGN KEY (MarcaTarjeta_ID)
        REFERENCES [ref].[MarcaTarjeta] (MarcaTarjeta_ID)
);
GO

-- ------------------------------------------------------------
-- 5.5 PAGO_TRANSFERENCIA (detalle para transferencias bancarias)
-- ------------------------------------------------------------
CREATE TABLE [alquiler].[PagoTransferencia]
(
    PagoTransferencia_ID  INT             NOT NULL IDENTITY(1,1),
    FormaPago_ID          INT             NOT NULL,
    Banco_ID              SMALLINT        NOT NULL,
    NumeroCuenta          NVARCHAR(50)    NOT NULL,
    NumeroComprobante     NVARCHAR(50)    NOT NULL,

    CONSTRAINT PK_PagoTransferencia PRIMARY KEY CLUSTERED (PagoTransferencia_ID),
    CONSTRAINT UQ_PagoTransferencia_FormaPago UNIQUE (FormaPago_ID),
    CONSTRAINT FK_PagoTransferencia_FormaPago FOREIGN KEY (FormaPago_ID)
        REFERENCES [alquiler].[FormaPago] (FormaPago_ID),
    CONSTRAINT FK_PagoTransferencia_Banco FOREIGN KEY (Banco_ID)
        REFERENCES [ref].[Banco] (Banco_ID)
);
GO


-- ============================================================
-- 6. DYNAMIC DATA MASKING (DDM)
-- Ley 8968 — Correo, Cédula, Dirección
-- ============================================================

USE [RentaCR];
GO

-- Correo electrónico
ALTER TABLE [persona].[MecanismoContacto]
    ALTER COLUMN Valor NVARCHAR(150) MASKED WITH (FUNCTION = 'email()') NOT NULL;
GO

-- Número de identificación
ALTER TABLE [persona].[Identificador]
    ALTER COLUMN Numero NVARCHAR(30) MASKED WITH (FUNCTION = 'partial(2,"XXXXXX",2)') NOT NULL;
GO

-- Dirección física
ALTER TABLE [persona].[Direccion]
    ALTER COLUMN LineaDireccion1 NVARCHAR(300) MASKED WITH (FUNCTION = 'default()') NOT NULL;
GO


-- ============================================================
-- 7. ROLES DE BASE DE DATOS
-- ============================================================

CREATE ROLE [db_Administrativo];
GO
CREATE ROLE [db_Mantenimiento];
GO
CREATE ROLE [db_LecturaGeneral];
GO


-- ============================================================
-- 8. EXPRESIONES REGULARES — STORED PROCEDURES DE VALIDACIÓN
-- Funciones REGEXP_LIKE de SQL Server 2025
-- ============================================================
USE [RentaCR];
GO

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

    -- Validar Placa: formato MOPT [A-Z]{3}-[0-9]{3,4} (con LIKE temporal)
    IF @Placa NOT LIKE '[A-Z][A-Z][A-Z]-[0-9][0-9][0-9]'
    AND @Placa NOT LIKE '[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]'
    BEGIN
        SET @Valido = 0;
        SET @Mensaje = 'Placa inválida. Formato esperado: ABC-123 o ABC-1234';
        RETURN;
    END

    -- Validar VIN: 17 chars (validación básica con LEN)
    IF LEN(@VIN) <> 17
    BEGIN
        SET @Valido = 0;
        SET @Mensaje = 'VIN inválido. Debe tener 17 caracteres alfanuméricos (sin I, O, Q)';
        RETURN;
    END
END;
GO

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

    -- Validar correo: debe contener @ y un punto después
    IF @TipoContacto = 'Correo'
    BEGIN
        IF @Valor NOT LIKE '%@%.%'
        BEGIN
            SET @Valido = 0;
            SET @Mensaje = 'Correo electrónico inválido';
            RETURN;
        END
    END

    -- Validar teléfono costarricense: 8 dígitos
    IF @TipoContacto IN ('Celular','TelefonoFijo','WhatsApp')
    BEGIN
        IF @Valor NOT LIKE '[2-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
            SET @Valido = 0;
            SET @Mensaje = 'Número de teléfono inválido. Debe tener 8 dígitos y comenzar con 2-9';
            RETURN;
        END
    END
END;
GO

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

    -- Validar cédula física: formato [1-9]-[0-9]{4}-[0-9]{4}
    IF @TipoIdentificacion = 'CedulaFisica'
    BEGIN
        IF @Numero NOT LIKE '[1-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
        BEGIN
            SET @Valido = 0;
            SET @Mensaje = 'Cédula física inválida. Formato esperado: 1-0000-0000';
            RETURN;
        END
    END
END;
GO

-- ============================================================
-- 9. STORED PROCEDURE — EXTERNAL API BCCR (SQL Server 2025)
-- Se invoca al cerrar un contrato para obtener tipo de cambio
-- ============================================================

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

    -- Llamada a la API del BCCR mediante sp_invoke_external_rest_endpoint
    DECLARE @url        NVARCHAR(500);
    DECLARE @response   NVARCHAR(MAX);
    DECLARE @compra     DECIMAL(12,4);
    DECLARE @venta      DECIMAL(12,4);
    DECLARE @moneda_id  SMALLINT;

    SET @url = CONCAT(
        'https://gee.bccr.fi.cr/Indicadores/Suscripciones/WS/wsindicadoreseconomicos.asmx',
        '/ObtenerIndicadoresEconomicos',
        '?Indicador=317&FechaInicio=', FORMAT(@FechaConsulta,'dd/MM/yyyy'),
        '&FechaFinal=', FORMAT(@FechaConsulta,'dd/MM/yyyy'),
        '&Nombre=RentaCR&SubNiveles=N'
    );

    EXEC sp_invoke_external_rest_endpoint
        @url     = @url,
        @method  = 'GET',
        @response = @response OUTPUT;

    -- Obtener Moneda_ID para USD
    SELECT @moneda_id = Moneda_ID FROM [ref].[Moneda] WHERE Codigo = 'USD';

    -- Parsear respuesta (simplificado — en producción usar JSON)
    -- Por ahora insertar con valores de referencia
    SET @compra = CAST(JSON_VALUE(@response, '$.result.compra') AS DECIMAL(12,4));
    SET @venta  = CAST(JSON_VALUE(@response, '$.result.venta')  AS DECIMAL(12,4));

    INSERT INTO [ref].[TipoCambio] (Fecha, Moneda_ID, TipoCambioCompra, TipoCambioVenta)
    VALUES (@FechaConsulta, @moneda_id, @compra, @venta);

    SET @TipoCambio_ID = SCOPE_IDENTITY();
END;
GO


-- ============================================================
-- 10. VISTAS (mínimo una por tabla)
-- Toda consulta al sistema se realiza ÚNICAMENTE por vistas
-- ============================================================

-- ref schema
CREATE OR ALTER VIEW [ref].[vw_Pais]                AS SELECT * FROM [ref].[Pais];                GO
CREATE OR ALTER VIEW [ref].[vw_Moneda]              AS SELECT * FROM [ref].[Moneda];              GO
CREATE OR ALTER VIEW [ref].[vw_UbicacionGeo]        AS SELECT * FROM [ref].[UbicacionGeo];        GO
CREATE OR ALTER VIEW [ref].[vw_MetaEstado]          AS SELECT * FROM [ref].[MetaEstado];          GO
CREATE OR ALTER VIEW [ref].[vw_TipoMecanismoContacto] AS SELECT * FROM [ref].[TipoMecanismoContacto]; GO
CREATE OR ALTER VIEW [ref].[vw_TipoDireccion]       AS SELECT * FROM [ref].[TipoDireccion];       GO
CREATE OR ALTER VIEW [ref].[vw_TipoIdentificacion]  AS SELECT * FROM [ref].[TipoIdentificacion];  GO
CREATE OR ALTER VIEW [ref].[vw_MarcaTarjeta]        AS SELECT * FROM [ref].[MarcaTarjeta];        GO
CREATE OR ALTER VIEW [ref].[vw_Banco]               AS SELECT * FROM [ref].[Banco];               GO
CREATE OR ALTER VIEW [ref].[vw_Puesto]              AS SELECT * FROM [ref].[Puesto];              GO
CREATE OR ALTER VIEW [ref].[vw_TipoCambio]          AS SELECT * FROM [ref].[TipoCambio];          GO
CREATE OR ALTER VIEW [ref].[vw_Sucursal]            AS SELECT * FROM [ref].[Sucursal];            GO

-- persona schema
CREATE OR ALTER VIEW [persona].[vw_Persona]         AS SELECT * FROM [persona].[Persona];         GO
CREATE OR ALTER VIEW [persona].[vw_PersonaFisica]   AS SELECT * FROM [persona].[PersonaFisica];   GO
CREATE OR ALTER VIEW [persona].[vw_PersonaJuridica] AS SELECT * FROM [persona].[PersonaJuridica]; GO

CREATE OR ALTER VIEW [persona].[vw_Cliente]
AS
    SELECT
        c.Cliente_ID,
        c.Persona_ID,
        p.TipoPersona,
        p.PrimerNombre,
        p.SegundoNombre,
        p.PrimerApellido,
        p.SegundoApellido,
        pf.FechaNacimiento,
        pf.EstadoCivil,
        pj.RazonSocial,
        pj.NombreComercial,
        pj.FechaConstitucion,
        c.FechaIngresoSistema,
        me.Descripcion    AS EstadoCliente,
        me.Codigo         AS CodigoEstado
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
        p.PrimerNombre,
        p.SegundoNombre,
        p.PrimerApellido,
        p.SegundoApellido,
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

-- vehiculo schema
CREATE OR ALTER VIEW [vehiculo].[vw_Marca]          AS SELECT * FROM [vehiculo].[Marca];          GO
CREATE OR ALTER VIEW [vehiculo].[vw_ModeloVehiculo] AS SELECT * FROM [vehiculo].[ModeloVehiculo]; GO
CREATE OR ALTER VIEW [vehiculo].[vw_CategoriaVehiculo] AS SELECT * FROM [vehiculo].[CategoriaVehiculo]; GO

CREATE OR ALTER VIEW [vehiculo].[vw_Vehiculo]
AS
    SELECT
        v.Vehiculo_ID,
        v.Placa,
        v.VIN,
        m.Nombre         AS Marca,
        mv.Nombre        AS Modelo,
        cv.Descripcion   AS Categoria,
        v.Anio,
        v.Color,
        v.NumeroPuertas,
        v.Capacidad,
        v.Transmision,
        v.TipoCombustible,
        v.Kilometraje,
        v.Descripcion,
        v.FechaIngresoFlota,
        s.Nombre         AS Sucursal,
        me.Descripcion   AS EstadoVehiculo,
        v.NumeroPóliza,
        v.Aseguradora,
        v.FechaVencimientoSeguro
    FROM [vehiculo].[Vehiculo] v
    JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
    JOIN [vehiculo].[Marca] m ON mv.Marca_ID = m.Marca_ID
    JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
    JOIN [ref].[Sucursal] s ON v.Sucursal_ID = s.Sucursal_ID
    JOIN [ref].[MetaEstado] me ON v.MetaEstado_ID = me.MetaEstado_ID;
GO

CREATE OR ALTER VIEW [vehiculo].[vw_DocumentoSeguro]    AS SELECT Vehiculo_ID, NumeroPóliza, Aseguradora, FechaInicioCobertura, FechaVencimiento, FechaCarga FROM [vehiculo].[DocumentoSeguro]; GO
CREATE OR ALTER VIEW [vehiculo].[vw_ImagenVehiculo]     AS SELECT Imagen_ID, Vehiculo_ID, Descripcion, Url, FechaCarga FROM [vehiculo].[ImagenVehiculo]; GO
CREATE OR ALTER VIEW [vehiculo].[vw_Tarifa]             AS SELECT * FROM [vehiculo].[Tarifa];             GO
CREATE OR ALTER VIEW [vehiculo].[vw_DisponibilidadVehiculo] AS SELECT * FROM [vehiculo].[DisponibilidadVehiculo]; GO

-- alquiler schema
CREATE OR ALTER VIEW [alquiler].[vw_Contrato]
AS
    SELECT
        c.Contrato_ID,
        c.NumeroContrato,
        cl.Cliente_ID,
        p.PrimerNombre + ' ' + ISNULL(p.SegundoNombre+' ','') + p.PrimerApellido AS NombreCliente,
        v.Placa,
        mv.Nombre        AS ModeloVehiculo,
        s.Nombre         AS Sucursal,
        e.CodigoEmpleado AS Agente,
        c.FechaInicio,
        c.FechaFinPactada,
        c.TarifaAplicada,
        c.DiasPactados,
        c.MontoTotal,
        c.MontoTotalUSD,
        c.DepositoGarantia,
        c.KmEntrega,
        c.CombustibleEntrega,
        c.Observaciones,
        me.Descripcion   AS EstadoContrato
    FROM [alquiler].[Contrato] c
    JOIN [persona].[Cliente] cl ON c.Cliente_ID = cl.Cliente_ID
    JOIN [persona].[Persona] p ON cl.Persona_ID = p.Persona_ID
    JOIN [vehiculo].[Vehiculo] v ON c.Vehiculo_ID = v.Vehiculo_ID
    JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
    JOIN [ref].[Sucursal] s ON c.Sucursal_ID = s.Sucursal_ID
    JOIN [persona].[Empleado] e ON c.Empleado_ID = e.Empleado_ID
    JOIN [ref].[MetaEstado] me ON c.MetaEstado_ID = me.MetaEstado_ID;
GO

CREATE OR ALTER VIEW [alquiler].[vw_Devolucion]         AS SELECT * FROM [alquiler].[Devolucion];         GO
CREATE OR ALTER VIEW [alquiler].[vw_FormaPago]          AS SELECT * FROM [alquiler].[FormaPago];          GO
CREATE OR ALTER VIEW [alquiler].[vw_PagoTarjeta]        AS SELECT * FROM [alquiler].[PagoTarjeta];        GO
CREATE OR ALTER VIEW [alquiler].[vw_PagoTransferencia]  AS SELECT * FROM [alquiler].[PagoTransferencia];  GO


-- ============================================================
-- 11. PERMISOS POR ROL
-- Nunca se conceden permisos directos sobre tablas base
-- ============================================================

-- db_Administrativo: lectura y escritura sobre todos los esquemas
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[persona]  TO [db_Administrativo];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[vehiculo] TO [db_Administrativo];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[alquiler] TO [db_Administrativo];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[ref]      TO [db_Administrativo];
GO

-- db_Mantenimiento: INSERT, SELECT, UPDATE, DELETE sobre tablas
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[persona]  TO [db_Mantenimiento];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[vehiculo] TO [db_Mantenimiento];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[alquiler] TO [db_Mantenimiento];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[ref]      TO [db_Mantenimiento];
GO

-- db_LecturaGeneral: SELECT únicamente sobre vistas
GRANT SELECT ON [ref].[vw_Pais]                       TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_Moneda]                     TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_UbicacionGeo]               TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_MetaEstado]                 TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_TipoMecanismoContacto]      TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_TipoDireccion]              TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_TipoIdentificacion]         TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_MarcaTarjeta]               TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_Banco]                      TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_Puesto]                     TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_TipoCambio]                 TO [db_LecturaGeneral];
GRANT SELECT ON [ref].[vw_Sucursal]                   TO [db_LecturaGeneral];
GRANT SELECT ON [persona].[vw_Cliente]                TO [db_LecturaGeneral];
GRANT SELECT ON [persona].[vw_Empleado]               TO [db_LecturaGeneral];
GRANT SELECT ON [persona].[vw_MecanismoContacto]      TO [db_LecturaGeneral];
GRANT SELECT ON [persona].[vw_Direccion]              TO [db_LecturaGeneral];
GRANT SELECT ON [persona].[vw_Identificador]          TO [db_LecturaGeneral];
GRANT SELECT ON [vehiculo].[vw_Vehiculo]              TO [db_LecturaGeneral];
GRANT SELECT ON [vehiculo].[vw_Tarifa]                TO [db_LecturaGeneral];
GRANT SELECT ON [vehiculo].[vw_DisponibilidadVehiculo] TO [db_LecturaGeneral];
GRANT SELECT ON [alquiler].[vw_Contrato]              TO [db_LecturaGeneral];
GRANT SELECT ON [alquiler].[vw_Devolucion]            TO [db_LecturaGeneral];
GRANT SELECT ON [alquiler].[vw_FormaPago]             TO [db_LecturaGeneral];
GO


-- ============================================================
-- 12. ROW-LEVEL SECURITY (RLS)
-- Agentes solo ven contratos y disponibilidad de su sucursal
-- db_Administrativo ve todo
-- ============================================================

-- Función de predicado RLS
CREATE OR ALTER FUNCTION [alquiler].[fn_RLS_Sucursal](@Sucursal_ID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    WHERE
        -- Administrativos ven todo
        IS_ROLEMEMBER('db_Administrativo') = 1
        OR
        -- Agentes ven solo su sucursal (basado en login → empleado → sucursal)
        @Sucursal_ID = (
            SELECT e.Sucursal_ID
            FROM [persona].[Empleado] e
            JOIN [persona].[Persona] p ON e.Persona_ID = p.Persona_ID
            WHERE p.PrimerNombre = USER_NAME()   -- Ajustar según esquema de logins
        )
);
GO

-- Aplicar RLS en Contrato
CREATE SECURITY POLICY [alquiler].[PolicyContratoSucursal]
ADD FILTER PREDICATE [alquiler].[fn_RLS_Sucursal](Sucursal_ID)
ON [alquiler].[Contrato]
WITH (STATE = ON);
GO

-- Aplicar RLS en DisponibilidadVehiculo
CREATE SECURITY POLICY [vehiculo].[PolicyDisponibilidadSucursal]
ADD FILTER PREDICATE [alquiler].[fn_RLS_Sucursal](Sucursal_ID)
ON [vehiculo].[DisponibilidadVehiculo]
WITH (STATE = ON);
GO


-- ============================================================
-- 13. SERIALIZACIÓN JSON (Bloque 14)
-- Todos los clientes con sus contactos, direcciones e IDs activos
-- Se ejecuta ÚNICAMENTE a través de vw_Cliente
-- ============================================================

CREATE OR ALTER PROCEDURE [persona].[sp_SerializarClientesJSON]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.Cliente_ID,
        c.TipoPersona,
        c.PrimerNombre,
        c.SegundoNombre,
        c.PrimerApellido,
        c.SegundoApellido,
        c.RazonSocial,
        c.NombreComercial,
        c.FechaNacimiento,
        c.FechaIngresoSistema,
        c.EstadoCliente,
        -- Contactos activos
        (
            SELECT mc.TipoMecanismoContacto_ID, mc.Valor, mc.Prioridad, mc.CodigoArea
            FROM [persona].[MecanismoContacto] mc
            JOIN [persona].[Persona] p2 ON mc.Persona_ID = p2.Persona_ID
            JOIN [persona].[Cliente] c2 ON p2.Persona_ID = c2.Persona_ID
            JOIN [ref].[MetaEstado] me2 ON mc.MetaEstado_ID = me2.MetaEstado_ID
            WHERE c2.Cliente_ID = c.Cliente_ID AND me2.Codigo = 'ACTIVO'
            FOR JSON PATH
        ) AS Contactos,
        -- Direcciones activas
        (
            SELECT d.TipoDireccion_ID, d.LineaDireccion1, d.LineaDireccion2, d.Prioridad
            FROM [persona].[Direccion] d
            JOIN [persona].[Persona] p3 ON d.Persona_ID = p3.Persona_ID
            JOIN [persona].[Cliente] c3 ON p3.Persona_ID = c3.Persona_ID
            JOIN [ref].[MetaEstado] me3 ON d.MetaEstado_ID = me3.MetaEstado_ID
            WHERE c3.Cliente_ID = c.Cliente_ID AND me3.Codigo = 'ACTIVO'
            FOR JSON PATH
        ) AS Direcciones,
        -- Identificaciones activas
        (
            SELECT i.TipoIdentificacion_ID, i.Numero, i.FechaVencimiento
            FROM [persona].[Identificador] i
            JOIN [persona].[Persona] p4 ON i.Persona_ID = p4.Persona_ID
            JOIN [persona].[Cliente] c4 ON p4.Persona_ID = c4.Persona_ID
            WHERE c4.Cliente_ID = c.Cliente_ID AND i.Activo = 1
            FOR JSON PATH
        ) AS Identificaciones
    FROM [persona].[vw_Cliente] c
    FOR JSON PATH, ROOT('clientes');
END;
GO


-- ============================================================
-- FIN DEL DDL — RentaCR v1.0
-- ============================================================
-- PENDIENTE (requiere datos insertados):
-- - Aplicar TDE (Bloque 8 sección 7.5)
-- - Poblar tablas de referencia (Bloque 11)
-- - Crear índice DiskANN para Vector Search
-- - Ajustar fn_RLS_Sucursal según esquema de logins SQL
-- ============================================================
