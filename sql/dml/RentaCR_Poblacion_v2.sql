-- ============================================================
-- POBLACIÓN COMPLETA — BASE DE DATOS RentaCR v2
-- IF5100 Administración de Bases de Datos — UCR I Semestre 2026
-- Alumno: Kendall Trejos Cubero
-- ============================================================
-- CORRECCIONES vs v1:
--   - ClienteClasificacion: eliminada columna Observaciones (no existe)
--   - AtributoCliente: columna NombreAtributo → TipoDato
--   - Identificador: incluye Pais_ID para pasaportes
-- ============================================================
-- IMPORTANTE: Este script NO elimina ni recrea nada.
-- Solo hace INSERTs. La BD debe estar vacía antes de ejecutar.
-- ============================================================

USE [RentaCR];
GO

SET NOCOUNT ON;
GO

-- ============================================================
-- 1. REF — CATÁLOGOS BASE
-- ============================================================

INSERT INTO [ref].[Pais] (ISOAlpha2, ISOAlpha3, NombreOficial, NombreLocal) VALUES
('CR', 'CRI', 'República de Costa Rica',    'Costa Rica'),
('US', 'USA', 'United States of America',   'Estados Unidos'),
('MX', 'MEX', 'Estados Unidos Mexicanos',   'México'),
('DE', 'DEU', 'Bundesrepublik Deutschland', 'Alemania'),
('JP', 'JPN', 'Nippon-koku',                'Japón'),
('KR', 'KOR', 'Daehan Minguk',              'Corea del Sur'),
('FR', 'FRA', 'République française',       'Francia'),
('IT', 'ITA', 'Repubblica Italiana',        'Italia'),
('SE', 'SWE', 'Konungariket Sverige',       'Suecia'),
('GB', 'GBR', 'United Kingdom',             'Reino Unido');
GO
-- Pais: CR=1, US=2, MX=3, DE=4, JP=5, KR=6, FR=7, IT=8, SE=9, GB=10

INSERT INTO [ref].[Moneda] (Codigo, NombreOficial, NombreMonedaLocal, Simbolo) VALUES
('CRC', 'Colón Costarricense', 'Colón',  '₡'),
('USD', 'United States Dollar', 'Dólar', '$'),
('EUR', 'Euro',                 'Euro',  '€');
GO
-- Moneda: CRC=1, USD=2, EUR=3

-- Provincias (Nivel 1)
INSERT INTO [ref].[UbicacionGeo] (CodigoRegion, Nivel, Valor, UbicacionGeo_ID_Padre) VALUES
('10000', 1, 'San José',    NULL),
('20000', 1, 'Alajuela',    NULL),
('30000', 1, 'Cartago',     NULL),
('40000', 1, 'Heredia',     NULL),
('50000', 1, 'Guanacaste',  NULL),
('60000', 1, 'Puntarenas',  NULL),
('70000', 1, 'Limón',       NULL);
GO
-- Provincias: SJ=1, ALJ=2, CAR=3, HER=4, GUA=5, PUN=6, LIM=7

-- Cantones (Nivel 2)
INSERT INTO [ref].[UbicacionGeo] (CodigoRegion, Nivel, Valor, UbicacionGeo_ID_Padre) VALUES
('10100', 2, 'San José (Cantón)',    1),
('10200', 2, 'Escazú',              1),
('10300', 2, 'Desamparados',        1),
('20100', 2, 'Alajuela (Cantón)',    2),
('20200', 2, 'San Ramón',           2),
('30100', 2, 'Cartago (Cantón)',     3),
('40100', 2, 'Heredia (Cantón)',     4),
('50100', 2, 'Liberia',             5),
('60100', 2, 'Puntarenas (Cantón)', 6),
('70100', 2, 'Limón (Cantón)',      7);
GO
-- Cantones: SJC=8, ESC=9, DES=10, ALJC=11, SRam=12, CARC=13, HERC=14, LIB=15, PNC=16, LIMC=17

-- Distritos (Nivel 3)
INSERT INTO [ref].[UbicacionGeo] (CodigoRegion, Nivel, Valor, UbicacionGeo_ID_Padre) VALUES
('10101', 3, 'Carmen',          8),
('10102', 3, 'Merced',          8),
('10103', 3, 'Hospital',        8),
('10201', 3, 'Escazú Centro',   9),
('10301', 3, 'Desamparados',    10),
('20101', 3, 'Alajuela Centro', 11),
('30101', 3, 'Oriental',        13),
('40101', 3, 'Heredia Centro',  14),
('50101', 3, 'Liberia Centro',  15),
('70101', 3, 'Limón Centro',    17);
GO
-- Distritos: Carmen=18, Merced=19, Hospital=20, Escazú=21, Desamp=22, Alajuela=23, Oriental=24, Heredia=25, Liberia=26, Limón=27

INSERT INTO [ref].[MetaEstado] (Entidad, Codigo, Descripcion, Activo) VALUES
('Cliente',   'ACTIVO',          'Cliente activo',                       1),  -- 1
('Cliente',   'INACTIVO',        'Cliente inactivo',                     1),  -- 2
('Cliente',   'SUSPENDIDO',      'Cliente suspendido temporalmente',      1),  -- 3
('Cliente',   'BLOQUEADO',       'Cliente bloqueado por incumplimiento',  1),  -- 4
('Empleado',  'ACTIVO',          'Empleado activo',                      1),  -- 5
('Empleado',  'INACTIVO',        'Empleado retirado',                    1),  -- 6
('Empleado',  'SUSPENDIDO',      'Empleado suspendido',                  1),  -- 7
('Contrato',  'ACTIVO',          'Contrato vigente',                     1),  -- 8
('Contrato',  'CERRADO',         'Contrato cerrado y pagado',            1),  -- 9
('Contrato',  'CANCELADO',       'Contrato cancelado',                   1),  -- 10
('Contrato',  'VENCIDO',         'Contrato vencido sin devolución',      1),  -- 11
('Contacto',  'ACTIVO',          'Mecanismo de contacto activo',         1),  -- 12
('Contacto',  'INACTIVO',        'Mecanismo de contacto inactivo',       1),  -- 13
('Direccion', 'ACTIVO',          'Dirección activa',                     1),  -- 14
('Direccion', 'INACTIVO',        'Dirección inactiva',                   1),  -- 15
('Vehiculo',  'DISPONIBLE',      'Vehículo disponible para alquiler',    1),  -- 16
('Vehiculo',  'ALQUILADO',       'Vehículo en alquiler activo',          1),  -- 17
('Vehiculo',  'MANTENIMIENTO',   'Vehículo en mantenimiento',            1),  -- 18
('Vehiculo',  'FUERADESERVICIO', 'Vehículo fuera de servicio',           1),  -- 19
('Sucursal',  'ACTIVA',          'Sucursal operativa',                   1),  -- 20
('Sucursal',  'INACTIVA',        'Sucursal cerrada',                     1);  -- 21
GO

INSERT INTO [ref].[TipoMecanismoContacto] (Codigo, Descripcion) VALUES
('Correo',       'Correo electrónico'),   -- 1
('Celular',      'Teléfono celular'),     -- 2
('TelefonoFijo', 'Teléfono fijo'),        -- 3
('WhatsApp',     'WhatsApp'),             -- 4
('Facebook',     'Facebook Messenger'),   -- 5
('Instagram',    'Instagram');            -- 6
GO

INSERT INTO [ref].[TipoDireccion] (Codigo, Descripcion) VALUES
('Residencial', 'Dirección de residencia'),           -- 1
('Laboral',     'Dirección de trabajo'),              -- 2
('Facturacion', 'Dirección de facturación'),          -- 3
('Entrega',     'Dirección de entrega del vehículo'); -- 4
GO

INSERT INTO [ref].[TipoIdentificacion] (Codigo, Descripcion) VALUES
('CedulaFisica',    'Cédula de identidad física costarricense'), -- 1
('CedulaJuridica',  'Cédula jurídica costarricense'),            -- 2
('Pasaporte',       'Pasaporte internacional'),                  -- 3
('DIMEX',           'Documento de Identidad Migratoria'),        -- 4
('LicenciaConducir','Licencia de conducir');                     -- 5
GO

INSERT INTO [ref].[MarcaTarjeta] (Codigo, Descripcion) VALUES
('VISA',       'Visa'),             -- 1
('MASTER',     'Mastercard'),       -- 2
('AMEX',       'American Express'), -- 3
('DISCOVER',   'Discover'),         -- 4
('DINERSCLUB', 'Diners Club');      -- 5
GO

INSERT INTO [ref].[Banco] (Codigo, Nombre, Pais_ID) VALUES
('BCR',      'Banco de Costa Rica',                    1),  -- 1
('BNCR',     'Banco Nacional de Costa Rica',           1),  -- 2
('BAC',      'BAC Credomatic',                         1),  -- 3
('SCOTIB',   'Scotiabank Costa Rica',                  1),  -- 4
('DAVIPL',   'Davivienda Costa Rica',                  1),  -- 5
('POPULAR',  'Banco Popular y de Desarrollo Comunal',  1),  -- 6
('LAFISE',   'Banco LAFISE',                           1),  -- 7
('PROMERICA','Banco Promerica',                        1);  -- 8
GO

INSERT INTO [ref].[Puesto] (Codigo, Descripcion) VALUES
('GERENTE',       'Gerente de Sucursal'),       -- 1
('AGENTE',        'Agente de Alquiler'),         -- 2
('MECANICO',      'Mecánico de Flota'),          -- 3
('CAJERO',        'Cajero'),                     -- 4
('SUPERVISOR',    'Supervisor Operaciones'),     -- 5
('ADMINISTRATIVO','Asistente Administrativo');   -- 6
GO

-- Sucursal requiere MetaEstado_ID=20 (Sucursal ACTIVA) y UbicacionGeo de distritos
INSERT INTO [ref].[Sucursal] (CodigoSucursal, Nombre, DireccionFisica, Telefono, CorreoElectronico, Horario, FechaApertura, UbicacionGeo_ID, MetaEstado_ID) VALUES
('SUC-SJO', 'RentaCR San José Centro',     'Av. Central, frente al Mercado Central, San José', '22221000', 'sanjose@rentacr.cr',    'L-V 7am-7pm / S-D 8am-5pm', '2010-03-15', 18, 20),  -- 1
('SUC-ESC', 'RentaCR Escazú',              'Centro Comercial Multiplaza, local 45, Escazú',    '22880200', 'escazu@rentacr.cr',     'L-D 8am-8pm',               '2013-06-01', 21, 20),  -- 2
('SUC-ALJ', 'RentaCR Aeropuerto Alajuela', 'Juan Santamaría Airport, Terminal Internacional',  '24410500', 'aeropuerto@rentacr.cr', 'L-D 5am-11pm',              '2011-01-20', 23, 20),  -- 3
('SUC-LIB', 'RentaCR Liberia',             '150m Norte del Aeropuerto Daniel Oduber, Liberia', '26656700', 'liberia@rentacr.cr',    'L-V 7am-6pm / S 8am-2pm',  '2015-08-10', 26, 20),  -- 4
('SUC-LIM', 'RentaCR Limón',               'Av. 2, diagonal al Puerto Moín, Limón',            '27980300', 'limon@rentacr.cr',      'L-V 7am-5pm',               '2018-02-28', 27, 20);  -- 5
GO

INSERT INTO [ref].[TipoCambio] (Fecha, Moneda_ID, TipoCambioCompra, TipoCambioVenta, FuenteConsulta) VALUES
('2026-04-01', 2, 515.23, 520.87, 'BCCR-WS'),  -- 1
('2026-04-15', 2, 516.10, 521.45, 'BCCR-WS'),  -- 2
('2026-05-01', 2, 517.80, 522.95, 'BCCR-WS'),  -- 3
('2026-05-10', 2, 518.25, 523.40, 'BCCR-WS'),  -- 4
('2026-05-15', 2, 517.50, 522.75, 'BCCR-WS'),  -- 5
('2026-05-20', 2, 519.00, 524.15, 'BCCR-WS');  -- 6
GO


-- ============================================================
-- 2. PERSONA
-- ============================================================

-- IDs 1-10: clientes físicos | 11-13: clientes jurídicos | 14-20: empleados
INSERT INTO [persona].[Persona] (TipoPersona, PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido) VALUES
('F', 'Carlos',    'Alberto',  'Mora',      'Jiménez'),   -- 1
('F', 'María',     'Fernanda', 'Rodríguez', 'Vargas'),    -- 2
('F', 'Luis',      'Diego',    'Quesada',   'Solís'),     -- 3
('F', 'Andrea',    NULL,       'Bermúdez',  'Castro'),    -- 4
('F', 'Roberto',   'Andrés',   'Méndez',    'Arias'),     -- 5
('F', 'Karina',    'Patricia', 'López',     'Ramírez'),   -- 6
('F', 'Diego',     NULL,       'Herrera',   'Monge'),     -- 7
('F', 'Sofía',     'Isabel',   'Jiménez',   'Salas'),     -- 8
('F', 'Alejandro', 'José',     'Vargas',    'Chacón'),    -- 9
('F', 'Paola',     'Andrea',   'Fonseca',   'Mora'),      -- 10
('J', NULL,        NULL,       NULL,        NULL),        -- 11 TechCorp
('J', NULL,        NULL,       NULL,        NULL),        -- 12 Turismo Pacífico
('J', NULL,        NULL,       NULL,        NULL),        -- 13 ExpoValle
('F', 'Laura',     'María',    'Chaves',    'Brenes'),    -- 14 Gerente SJO
('F', 'Marco',     'Antonio',  'Rojas',     'Ugalde'),    -- 15 Agente SJO
('F', 'Valeria',   NULL,       'Núñez',     'Badilla'),   -- 16 Agente ESC
('F', 'Esteban',   'Ricardo',  'Picado',    'Arce'),      -- 17 Gerente ALJ
('F', 'Natalia',   'Cristina', 'Solano',    'Vega'),      -- 18 Agente LIB
('F', 'Gerardo',   NULL,       'Campos',    'Mena'),      -- 19 Mecánico
('F', 'Daniela',   'Paola',    'Ruiz',      'Porras');    -- 20 Cajera
GO

INSERT INTO [persona].[PersonaFisica] (Persona_ID, FechaNacimiento, EstadoCivil) VALUES
(1,  '1985-03-12', 'Casado'),
(2,  '1990-07-24', 'Soltera'),
(3,  '1978-11-05', 'Casado'),
(4,  '1995-02-18', 'Soltera'),
(5,  '1982-09-30', 'Casado'),
(6,  '1988-04-14', 'Casada'),
(7,  '1993-12-01', 'Soltero'),
(8,  '1997-06-22', 'Soltera'),
(9,  '1975-08-17', 'Divorciado'),
(10, '1991-01-09', 'Soltera'),
(14, '1980-05-03', 'Casada'),
(15, '1992-10-15', 'Soltero'),
(16, '1994-03-28', 'Soltera'),
(17, '1977-07-11', 'Casado'),
(18, '1989-02-20', 'Casada'),
(19, '1986-11-07', 'Casado'),
(20, '1998-09-14', 'Soltera');
GO

INSERT INTO [persona].[PersonaJuridica] (Persona_ID, RazonSocial, NombreComercial, FechaConstitucion) VALUES
(11, 'TechCorp Costa Rica S.A.',             'TechCorp CR',      '2010-06-15'),
(12, 'Turismo Pacífico Aventura Ltda.',      'Turismo Pacífico', '2015-03-20'),
(13, 'Exportaciones del Valle Central S.A.', 'ExpoValle CR',     '2008-11-01');
GO

-- MetaEstado Cliente ACTIVO = 1
INSERT INTO [persona].[Cliente] (Persona_ID, FechaIngresoSistema, MetaEstado_ID) VALUES
(1,  '2020-01-15', 1),  -- Cliente_ID 1
(2,  '2019-03-22', 1),  -- 2
(3,  '2018-07-10', 1),  -- 3
(4,  '2021-11-05', 1),  -- 4
(5,  '2017-04-18', 1),  -- 5
(6,  '2022-02-28', 1),  -- 6
(7,  '2023-06-14', 1),  -- 7
(8,  '2021-09-30', 1),  -- 8
(9,  '2016-12-01', 1),  -- 9
(10, '2024-03-07', 1),  -- 10
(11, '2019-08-20', 1),  -- 11
(12, '2020-11-11', 1),  -- 12
(13, '2018-05-30', 1);  -- 13
GO

INSERT INTO [persona].[HistoricoEstadoCliente] (Cliente_ID, MetaEstado_ID, FechaCambio, RazonCambio) VALUES
(1,  1, '2020-01-15', 'Registro inicial'),
(2,  1, '2019-03-22', 'Registro inicial'),
(3,  1, '2018-07-10', 'Registro inicial'),
(4,  1, '2021-11-05', 'Registro inicial'),
(5,  1, '2017-04-18', 'Registro inicial'),
(6,  1, '2022-02-28', 'Registro inicial'),
(7,  1, '2023-06-14', 'Registro inicial'),
(8,  1, '2021-09-30', 'Registro inicial'),
(9,  1, '2016-12-01', 'Registro inicial'),
(9,  2, '2020-05-10', 'Cliente solicitó pausa temporal'),
(9,  1, '2020-09-01', 'Reactivación por solicitud del cliente'),
(10, 1, '2024-03-07', 'Registro inicial'),
(11, 1, '2019-08-20', 'Registro inicial persona jurídica'),
(12, 1, '2020-11-11', 'Registro inicial persona jurídica'),
(13, 1, '2018-05-30', 'Registro inicial persona jurídica');
GO

INSERT INTO [persona].[ClasificacionCliente] (Categoria, Codigo, Descripcion) VALUES
('Frecuencia', 'ESPORADICO', 'Alquila ocasionalmente (1-2 veces al año)'),  -- 1
('Frecuencia', 'REGULAR',    'Alquila regularmente (3-6 veces al año)'),     -- 2
('Frecuencia', 'FRECUENTE',  'Alquila frecuentemente (7+ veces al año)'),    -- 3
('Pago',       'PUNTUAL',    'Siempre paga a tiempo'),                        -- 4
('Pago',       'IRREGULAR',  'Pagos con retrasos ocasionales'),               -- 5
('Tamaño',     'MICRO',      'Empresa micro (<5 empleados)'),                 -- 6
('Tamaño',     'PEQUENA',    'Empresa pequeña (5-30 empleados)'),             -- 7
('Tamaño',     'MEDIANA',    'Empresa mediana (31-100 empleados)'),           -- 8
('Tamaño',     'GRANDE',     'Empresa grande (100+ empleados)'),              -- 9
('Riesgo',     'BAJO',       'Sin incidentes previos'),                       -- 10
('Riesgo',     'MEDIO',      'Algún incidente menor'),                        -- 11
('Riesgo',     'ALTO',       'Historial de daños o pagos tardíos');           -- 12
GO

-- CORREGIDO: sin columna Observaciones
INSERT INTO [persona].[ClienteClasificacion] (Cliente_ID, ClasificacionCliente_ID, FechaAsignacion) VALUES
(1,  3, '2020-06-01'),
(1,  4, '2020-06-01'),
(2,  2, '2019-06-01'),
(3,  3, '2019-01-01'),
(4,  1, '2022-01-01'),
(5,  2, '2018-01-01'),
(6,  1, '2022-06-01'),
(7,  1, '2023-12-01'),
(8,  2, '2022-03-01'),
(9,  3, '2017-01-01'),
(10, 1, '2024-06-01'),
(11, 8, '2020-01-01'),
(12, 7, '2021-01-01'),
(13, 8, '2019-01-01');
GO

-- CORREGIDO: columna TipoDato (no NombreAtributo)
INSERT INTO [persona].[AtributoCliente] (Cliente_ID, TipoDato, Valor) VALUES
(1,  'PreferenciaVehiculo', 'SUV'),
(1,  'IdiomaPreferido',     'Español'),
(2,  'PreferenciaVehiculo', 'Sedan'),
(3,  'PreferenciaVehiculo', 'Pickup'),
(3,  'ProgramaFidelidad',   'GOLD'),
(5,  'ProgramaFidelidad',   'SILVER'),
(9,  'ProgramaFidelidad',   'PLATINUM'),
(11, 'CuentaCorporativa',   'SI'),
(11, 'LimiteCreditoUSD',    '5000'),
(12, 'CuentaCorporativa',   'SI'),
(13, 'CuentaCorporativa',   'SI'),
(13, 'LimiteCreditoUSD',    '10000');
GO

-- Identificador: incluye Pais_ID para pasaportes (NULL para cédulas)
INSERT INTO [persona].[Identificador] (Persona_ID, TipoIdentificacion_ID, Numero, Pais_ID, FechaVencimiento, Activo) VALUES
(1,  1, '1-0752-0341', NULL, NULL,         1),
(2,  1, '2-0534-0892', NULL, NULL,         1),
(3,  1, '1-0891-0234', NULL, NULL,         1),
(4,  1, '3-0412-0567', NULL, NULL,         1),
(5,  1, '1-0623-0789', NULL, NULL,         1),
(6,  1, '4-0231-0456', NULL, NULL,         1),
(7,  1, '1-0945-0123', NULL, NULL,         1),
(8,  1, '2-0788-0345', NULL, NULL,         1),
(9,  1, '1-0312-0678', NULL, NULL,         1),
(10, 1, '5-0167-0234', NULL, NULL,         1),
(2,  3, 'CR123456',    1,    '2028-05-15', 1),
(9,  3, 'CR987654',    1,    '2027-11-30', 1),
(11, 2, '3-101-123456',NULL, NULL,         1),
(12, 2, '3-102-789012',NULL, NULL,         1),
(13, 2, '3-101-345678',NULL, NULL,         1),
(14, 1, '1-0456-0789', NULL, NULL,         1),
(15, 1, '2-0345-0678', NULL, NULL,         1),
(16, 1, '1-0567-0890', NULL, NULL,         1),
(17, 1, '4-0123-0456', NULL, NULL,         1),
(18, 1, '5-0234-0567', NULL, NULL,         1),
(19, 1, '1-0678-0901', NULL, NULL,         1),
(20, 1, '3-0789-0123', NULL, NULL,         1);
GO

-- MetaEstado Contacto ACTIVO = 12
INSERT INTO [persona].[MecanismoContacto] (Persona_ID, TipoMecanismoContacto_ID, Valor, CodigoArea, Prioridad, MetaEstado_ID) VALUES
(1,  1, 'carlos.mora@gmail.com',           NULL,  1, 12),
(1,  2, '88012345',                        '506', 1, 12),
(2,  1, 'mfernanda.rodriguez@hotmail.com', NULL,  1, 12),
(2,  2, '72345678',                        '506', 1, 12),
(3,  1, 'luis.quesada@empresa.cr',         NULL,  1, 12),
(3,  3, '22345678',                        '506', 2, 12),
(4,  1, 'andrea.bermudez@gmail.com',       NULL,  1, 12),
(4,  4, '89012345',                        '506', 1, 12),
(5,  1, 'roberto.mendez@outlook.com',      NULL,  1, 12),
(5,  2, '83456789',                        '506', 1, 12),
(6,  1, 'karina.lopez@gmail.com',          NULL,  1, 12),
(6,  2, '76789012',                        '506', 1, 12),
(7,  1, 'diego.herrera@gmail.com',         NULL,  1, 12),
(7,  2, '85678901',                        '506', 1, 12),
(8,  1, 'sofia.jimenez@yahoo.com',         NULL,  1, 12),
(8,  4, '84567890',                        '506', 1, 12),
(9,  1, 'alejandro.vargas@gmail.com',      NULL,  1, 12),
(9,  2, '87890123',                        '506', 1, 12),
(10, 1, 'paola.fonseca@gmail.com',         NULL,  1, 12),
(10, 2, '78901234',                        '506', 1, 12),
(11, 1, 'admin@techcorp.cr',               NULL,  1, 12),
(11, 3, '22901234',                        '506', 1, 12),
(12, 1, 'info@turismopac.cr',              NULL,  1, 12),
(13, 1, 'compras@expovalle.cr',            NULL,  1, 12),
(14, 1, 'laura.chaves@rentacr.cr',         NULL,  1, 12),
(14, 2, '88234567',                        '506', 1, 12),
(15, 1, 'marco.rojas@rentacr.cr',          NULL,  1, 12),
(16, 1, 'valeria.nunez@rentacr.cr',        NULL,  1, 12),
(17, 1, 'esteban.picado@rentacr.cr',       NULL,  1, 12),
(18, 1, 'natalia.solano@rentacr.cr',       NULL,  1, 12),
(19, 1, 'gerardo.campos@rentacr.cr',       NULL,  1, 12),
(20, 1, 'daniela.ruiz@rentacr.cr',         NULL,  1, 12);
GO

INSERT INTO [persona].[HistoricoEstadoContacto] (MecanismoContacto_ID, MetaEstado_ID, FechaCambio, RazonCambio) VALUES
(1,  12, '2020-01-15', 'Registro inicial'),
(2,  12, '2020-01-15', 'Registro inicial'),
(3,  12, '2019-03-22', 'Registro inicial'),
(4,  12, '2019-03-22', 'Registro inicial'),
(5,  12, '2018-07-10', 'Registro inicial'),
(6,  12, '2018-07-10', 'Registro inicial'),
(7,  12, '2021-11-05', 'Registro inicial'),
(8,  12, '2021-11-05', 'Registro inicial'),
(9,  12, '2017-04-18', 'Registro inicial'),
(10, 12, '2017-04-18', 'Registro inicial'),
(11, 12, '2022-02-28', 'Registro inicial'),
(12, 12, '2022-02-28', 'Registro inicial'),
(13, 12, '2023-06-14', 'Registro inicial'),
(14, 12, '2023-06-14', 'Registro inicial');
GO

-- MetaEstado Direccion ACTIVO = 14
INSERT INTO [persona].[Direccion] (Persona_ID, TipoDireccion_ID, LineaDireccion1, LineaDireccion2, Prioridad, UbicacionGeo_ID, MetaEstado_ID) VALUES
(1,  1, 'Barrio Dent, de la Clínica Bíblica 200m Norte, casa esquinera',  NULL,                                1, 18, 14),
(2,  1, 'Escazú, Trejos Montealegre, Cond. Los Pinos, apto 12B',          NULL,                                1, 21, 14),
(3,  1, 'Desamparados, San Miguel, frente a la Pulpería La Esperanza',    'Casa color verde con portón negro', 1, 22, 14),
(4,  1, 'Alajuela Centro, Calle 3, Avenida 4, casa contigua al Banco',    NULL,                                1, 23, 14),
(5,  1, 'Heredia, barrio El Carmen, 100m Sur del Parque Central',         NULL,                                1, 25, 14),
(6,  1, 'San José, Sabana Norte, Res. Los Arcos, casa 7',                 NULL,                                1, 18, 14),
(7,  1, 'Cartago Centro, Calle 4, diagonal a las Ruinas',                 NULL,                                1, 24, 14),
(8,  1, 'Escazú, Guachipelín, Cond. Montañas del Sol, apto 3A',          NULL,                                1, 21, 14),
(9,  1, 'San José, Barrio Amón, Calle 7, casa victoriana azul',           NULL,                                1, 19, 14),
(10, 1, 'Liberia, Calle Central, 50m Este del Parque Mario Cañas',        NULL,                                1, 26, 14),
(11, 2, 'San José, La Uruca, Oficentro La Sabana, Edificio 3, Piso 5',   NULL,                                1, 18, 14),
(12, 2, 'Liberia, Zona Franca Guanacaste, Bodega 12',                     NULL,                                1, 26, 14),
(13, 2, 'San José, Zapote, 200m Sur del IMAS, Edificio Valle Verde',      NULL,                                1, 19, 14),
(14, 2, 'RentaCR San José Centro, Av. Central',                           NULL,                                1, 18, 14),
(15, 2, 'RentaCR San José Centro, Av. Central',                           NULL,                                1, 18, 14),
(17, 2, 'RentaCR Aeropuerto, Alajuela',                                   NULL,                                1, 23, 14);
GO

INSERT INTO [persona].[HistoricoEstadoDireccion] (Direccion_ID, MetaEstado_ID, FechaCambio, RazonCambio) VALUES
(1,  14, '2020-01-15', 'Registro inicial'),
(2,  14, '2019-03-22', 'Registro inicial'),
(3,  14, '2018-07-10', 'Registro inicial'),
(4,  14, '2021-11-05', 'Registro inicial'),
(5,  14, '2017-04-18', 'Registro inicial'),
(6,  14, '2022-02-28', 'Registro inicial'),
(7,  14, '2023-06-14', 'Registro inicial'),
(8,  14, '2021-09-30', 'Registro inicial'),
(9,  14, '2016-12-01', 'Registro inicial'),
(10, 14, '2024-03-07', 'Registro inicial'),
(11, 14, '2019-08-20', 'Registro inicial'),
(12, 14, '2020-11-11', 'Registro inicial'),
(13, 14, '2018-05-30', 'Registro inicial');
GO

-- Puesto: GERENTE=1, AGENTE=2, MECANICO=3, CAJERO=4
-- MetaEstado Empleado ACTIVO = 5
-- Sucursal: SJO=1, ESC=2, ALJ=3, LIB=4, LIM=5
INSERT INTO [persona].[Empleado] (Persona_ID, CodigoEmpleado, Puesto_ID, FechaIngreso, FechaSalida, Sucursal_ID, MetaEstado_ID) VALUES
(14, 'EMP-001', 1, '2010-03-15', NULL, 1, 5),
(15, 'EMP-002', 2, '2015-06-01', NULL, 1, 5),
(16, 'EMP-003', 2, '2018-02-14', NULL, 2, 5),
(17, 'EMP-004', 1, '2011-01-20', NULL, 3, 5),
(18, 'EMP-005', 2, '2016-08-10', NULL, 4, 5),
(19, 'EMP-006', 3, '2013-09-01', NULL, 1, 5),
(20, 'EMP-007', 4, '2019-03-01', NULL, 1, 5);
GO
-- Empleado: Laura=1, Marco=2, Valeria=3, Esteban=4, Natalia=5, Gerardo=6, Daniela=7

INSERT INTO [persona].[HistoricoAsignacionSucursal] (Empleado_ID, Sucursal_ID, FechaInicio, FechaFin, Motivo) VALUES
(1, 1, '2010-03-15', NULL,         'Asignación inicial'),
(2, 1, '2015-06-01', NULL,         'Asignación inicial'),
(3, 2, '2018-02-14', NULL,         'Asignación inicial'),
(4, 3, '2011-01-20', NULL,         'Asignación inicial'),
(5, 1, '2014-05-01', '2016-08-10', 'Previo a traslado a Liberia'),
(5, 4, '2016-08-10', NULL,         'Traslado a Liberia'),
(6, 1, '2013-09-01', NULL,         'Asignación taller central'),
(7, 1, '2019-03-01', NULL,         'Asignación caja central');
GO

INSERT INTO [persona].[HistoricoEstadoEmpleado] (Empleado_ID, MetaEstado_ID, FechaCambio, RazonCambio) VALUES
(1, 5, '2010-03-15', 'Contratación inicial'),
(2, 5, '2015-06-01', 'Contratación inicial'),
(3, 5, '2018-02-14', 'Contratación inicial'),
(4, 5, '2011-01-20', 'Contratación inicial'),
(5, 5, '2016-08-10', 'Contratación inicial'),
(6, 5, '2013-09-01', 'Contratación inicial'),
(7, 5, '2019-03-01', 'Contratación inicial');
GO


-- ============================================================
-- 3. VEHICULO
-- ============================================================

-- Pais: DE=4, JP=5, KR=6, US=2
INSERT INTO [vehiculo].[Marca] (Nombre, Pais_ID) VALUES
('Toyota',     5),   -- 1
('Hyundai',    6),   -- 2
('Kia',        6),   -- 3
('Suzuki',     5),   -- 4
('Nissan',     5),   -- 5
('Ford',       2),   -- 6
('Chevrolet',  2),   -- 7
('Volkswagen', 4),   -- 8
('Mitsubishi', 5),   -- 9
('Honda',      5);   -- 10
GO

INSERT INTO [vehiculo].[ModeloVehiculo] (Marca_ID, Nombre) VALUES
(1, 'Yaris'),       -- 1
(1, 'Corolla'),     -- 2
(1, 'RAV4'),        -- 3
(1, 'Hilux'),       -- 4
(2, 'Accent'),      -- 5
(2, 'Tucson'),      -- 6
(3, 'Picanto'),     -- 7
(3, 'Sportage'),    -- 8
(4, 'Swift'),       -- 9
(5, 'Frontier'),    -- 10
(6, 'Explorer'),    -- 11
(7, 'TrailBlazer'), -- 12
(8, 'Tiguan'),      -- 13
(9, 'Outlander'),   -- 14
(10,'CR-V');        -- 15
GO

INSERT INTO [vehiculo].[CategoriaVehiculo] (Codigo, Descripcion, TarifaDiariaBase) VALUES
('ECO',   'Económico — sedán compacto de bajo consumo',   18000.00),  -- 1
('SEDAN', 'Sedán estándar — confort y economía',           25000.00),  -- 2
('SUV',   'SUV — terreno variado y mayor capacidad',       38000.00),  -- 3
('PICKUP','Pickup — carga y trabajo en campo',             42000.00),  -- 4
('LUX',   'Lujo — vehículo premium de alta gama',         65000.00),  -- 5
('MINI',  'Mini / City — para ciudad, bajo consumo',       15000.00);  -- 6
GO

-- MetaEstado: DISPONIBLE=16, ALQUILADO=17, MANTENIMIENTO=18, FUERADESERVICIO=19
-- Sucursal: SJO=1, ESC=2, ALJ=3, LIB=4, LIM=5
INSERT INTO [vehiculo].[Vehiculo] (Placa, VIN, ModeloVehiculo_ID, CategoriaVehiculo_ID, Anio, Color, NumeroPuertas, Capacidad, Transmision, TipoCombustible, Kilometraje, Descripcion, DescripcionVector, FechaIngresoFlota, Sucursal_ID, MetaEstado_ID, NumeroPóliza, Aseguradora, FechaInicioCobertura, FechaVencimientoSeguro) VALUES
('ABC-123', '1HGBH41JXMN109186', 1,  1, 2022, 'Blanco',   4, 5, 'Automatica', 'Gasolina', 35200, 'Toyota Yaris 2022, económico y eficiente para ciudad.',                NULL, '2022-03-10', 1, 16, 'POL-2022-001', 'INS Costa Rica', '2022-03-10', '2026-03-10'),  -- 1
('DEF-456', '2T1BURHE0JC037958', 2,  2, 2023, 'Gris',     4, 5, 'Automatica', 'Gasolina', 22100, 'Toyota Corolla 2023, sedán familiar con excelente equipamiento.',      NULL, '2023-01-15', 1, 16, 'POL-2023-002', 'INS Costa Rica', '2023-01-15', '2027-01-15'),  -- 2
('GHI-789', '5TDKK3DC0FS559201', 3,  3, 2023, 'Plateado', 4, 7, 'Automatica', 'Gasolina', 18500, 'Toyota RAV4 2023, SUV familiar tracción 4x2.',                         NULL, '2023-04-20', 1, 16, 'POL-2023-003', 'Sagicor CR',     '2023-04-20', '2027-04-20'),  -- 3
('JKL-012', '3D7KS28C36G246281', 4,  4, 2021, 'Negro',    4, 5, 'Manual',    'Diesel',   62300, 'Toyota Hilux 2021 Diesel, pickup doble cabina.',                        NULL, '2021-06-01', 2, 16, 'POL-2021-004', 'INS Costa Rica', '2021-06-01', '2025-06-01'),  -- 4
('MNO-345', 'KMHCT4AE5GU272478', 5,  1, 2022, 'Rojo',     4, 5, 'Manual',    'Gasolina', 41800, 'Hyundai Accent 2022, económico de bajo consumo.',                       NULL, '2022-08-15', 2, 16, 'POL-2022-005', 'Sagicor CR',     '2022-08-15', '2026-08-15'),  -- 5
('PQR-678', 'KM8JUCAC4JU716425', 6,  3, 2024, 'Azul',     4, 5, 'Automatica', 'Gasolina',  9800, 'Hyundai Tucson 2024, SUV moderno con cámara 360°.',                    NULL, '2024-02-28', 3, 16, 'POL-2024-006', 'INS Costa Rica', '2024-02-28', '2028-02-28'),  -- 6
('STU-901', 'KNADM4A37G6594361', 7,  6, 2023, 'Amarillo', 4, 4, 'Manual',    'Gasolina', 28600, 'Kia Picanto 2023, city car ultra económico.',                           NULL, '2023-07-10', 3, 16, 'POL-2023-007', 'Sagicor CR',     '2023-07-10', '2027-07-10'),  -- 7
('VWX-234', 'KNDPB3A24G7812345', 8,  3, 2022, 'Verde',    4, 5, 'Automatica', 'Gasolina', 33400, 'Kia Sportage 2022, SUV compacta con diseño moderno.',                   NULL, '2022-10-05', 3, 17, 'POL-2022-008', 'INS Costa Rica', '2022-10-05', '2026-10-05'),  -- 8
('YZA-567', 'JS2RC41S0K4300412', 9,  1, 2021, 'Blanco',   4, 5, 'Manual',    'Gasolina', 55700, 'Suzuki Swift 2021, económico confiable.',                               NULL, '2021-11-20', 4, 16, 'POL-2021-009', 'INS Costa Rica', '2021-11-20', '2025-11-20'),  -- 9
('BCD-890', '1N4AL3AP7JC231456', 10, 4, 2022, 'Gris',     4, 5, 'Manual',    'Diesel',   47200, 'Nissan Frontier 2022 Diesel, pickup de trabajo.',                       NULL, '2022-05-12', 4, 16, 'POL-2022-010', 'Sagicor CR',     '2022-05-12', '2026-05-12'),  -- 10
('EFG-123', '1FMHK7D8XBGA12345', 11, 3, 2023, 'Negro',    4, 7, 'Automatica', 'Gasolina', 15300, 'Ford Explorer 2023, SUV grande 7 puestos.',                             NULL, '2023-09-01', 1, 16, 'POL-2023-011', 'INS Costa Rica', '2023-09-01', '2027-09-01'),  -- 11
('HIJ-456', '2GNFLNE38D6236789', 12, 3, 2021, 'Plateado', 4, 7, 'Automatica', 'Gasolina', 58900, 'Chevrolet TrailBlazer 2021, SUV 7 puestos.',                            NULL, '2021-03-15', 5, 16, 'POL-2021-012', 'INS Costa Rica', '2021-03-15', '2025-03-15'),  -- 12
('KLM-789', 'WVGBV7AX5DW534123', 13, 3, 2024, 'Blanco',   4, 5, 'Automatica', 'Gasolina',  4200, 'Volkswagen Tiguan 2024, SUV premium europeo.',                          NULL, '2024-05-01', 2, 16, 'POL-2024-013', 'Sagicor CR',     '2024-05-01', '2028-05-01'),  -- 13
('NOP-012', 'JA4AP4AU9HZ056789', 14, 3, 2022, 'Rojo',     4, 7, 'Automatica', 'Gasolina', 39100, 'Mitsubishi Outlander 2022, SUV familiar 7 puestos 4x4.',               NULL, '2022-07-20', 4, 18, 'POL-2022-014', 'INS Costa Rica', '2022-07-20', '2026-07-20'),  -- 14
('QRS-345', '19XFC2F77KE234567', 15, 3, 2023, 'Azul',     4, 5, 'Automatica', 'Gasolina', 21700, 'Honda CR-V 2023, SUV japonesa eficiente y cómoda.',                     NULL, '2023-06-10', 3, 16, 'POL-2023-015', 'Sagicor CR',     '2023-06-10', '2027-06-10');  -- 15
GO

INSERT INTO [vehiculo].[DocumentoSeguro] (Vehiculo_ID, NumeroPóliza, Aseguradora, FechaInicioCobertura, FechaVencimiento, PDF) VALUES
(1,  'POL-2022-001', 'INS Costa Rica', '2022-03-10', '2026-03-10', 0x255044462D312E34),
(2,  'POL-2023-002', 'INS Costa Rica', '2023-01-15', '2027-01-15', 0x255044462D312E34),
(3,  'POL-2023-003', 'Sagicor CR',     '2023-04-20', '2027-04-20', 0x255044462D312E34),
(4,  'POL-2021-004', 'INS Costa Rica', '2021-06-01', '2025-06-01', 0x255044462D312E34),
(5,  'POL-2022-005', 'Sagicor CR',     '2022-08-15', '2026-08-15', 0x255044462D312E34),
(6,  'POL-2024-006', 'INS Costa Rica', '2024-02-28', '2028-02-28', 0x255044462D312E34),
(7,  'POL-2023-007', 'Sagicor CR',     '2023-07-10', '2027-07-10', 0x255044462D312E34),
(8,  'POL-2022-008', 'INS Costa Rica', '2022-10-05', '2026-10-05', 0x255044462D312E34),
(9,  'POL-2021-009', 'INS Costa Rica', '2021-11-20', '2025-11-20', 0x255044462D312E34),
(10, 'POL-2022-010', 'Sagicor CR',     '2022-05-12', '2026-05-12', 0x255044462D312E34);
GO

INSERT INTO [vehiculo].[Tarifa] (CategoriaVehiculo_ID, Sucursal_ID, TarifaDiariaCRC, TarifaDiariaUSD, Temporada, FechaInicioVigencia, FechaFinVigencia) VALUES
(1, NULL, 18000.00, 34.8600, 'Baja',  '2025-01-01', '2025-11-30'),   -- 1
(1, NULL, 22000.00, 42.6000, 'Alta',  '2025-12-01', '2026-04-30'),   -- 2
(2, NULL, 25000.00, 48.4300, 'Baja',  '2025-01-01', '2025-11-30'),   -- 3
(2, NULL, 30000.00, 58.1200, 'Alta',  '2025-12-01', '2026-04-30'),   -- 4
(3, NULL, 38000.00, 73.6000, 'Baja',  '2025-01-01', '2025-11-30'),   -- 5
(3, NULL, 45000.00, 87.1400, 'Alta',  '2025-12-01', '2026-04-30'),   -- 6
(4, NULL, 42000.00, 81.3700, 'Baja',  '2025-01-01', '2025-11-30'),   -- 7
(4, NULL, 50000.00, 96.8600, 'Alta',  '2025-12-01', '2026-04-30'),   -- 8
(6, NULL, 15000.00, 29.0500, 'Baja',  '2025-01-01', '2025-11-30'),   -- 9
(6, NULL, 18000.00, 34.8600, 'Alta',  '2025-12-01', '2026-04-30'),   -- 10
(1, NULL, 19000.00, 36.7900, 'Baja',  '2026-05-01', NULL),           -- 11
(2, NULL, 27000.00, 52.3000, 'Baja',  '2026-05-01', NULL),           -- 12
(3, NULL, 40000.00, 77.5400, 'Baja',  '2026-05-01', NULL),           -- 13
(4, NULL, 44000.00, 85.3100, 'Baja',  '2026-05-01', NULL),           -- 14
(6, NULL, 16000.00, 31.0200, 'Baja',  '2026-05-01', NULL);           -- 15
GO

-- Tabla IN-MEMORY
-- Vehiculo 8 (Kia Sportage) = Alquilado, resto Disponible
-- Vehiculo 14 (Outlander) = FueraDeServicio
INSERT INTO [vehiculo].[DisponibilidadVehiculo] (Vehiculo_ID, Sucursal_ID, EstadoDisponibilidad, FechaHoraEstado, Contrato_ID) VALUES
(1,  1, 'Disponible',      '2026-05-01 08:00:00', NULL),
(2,  1, 'Disponible',      '2026-05-01 08:00:00', NULL),
(3,  1, 'Disponible',      '2026-05-10 08:00:00', NULL),
(4,  2, 'Disponible',      '2026-05-01 08:00:00', NULL),
(5,  2, 'Disponible',      '2026-05-01 08:00:00', NULL),
(6,  3, 'Disponible',      '2026-05-01 08:00:00', NULL),
(7,  3, 'Disponible',      '2026-05-01 08:00:00', NULL),
(8,  3, 'Alquilado',       '2026-05-18 09:30:00', NULL),
(9,  4, 'Disponible',      '2026-05-01 08:00:00', NULL),
(10, 4, 'Disponible',      '2026-05-01 08:00:00', NULL),
(11, 1, 'Disponible',      '2026-05-01 08:00:00', NULL),
(12, 5, 'Disponible',      '2026-05-01 08:00:00', NULL),
(13, 2, 'Disponible',      '2026-05-01 08:00:00', NULL),
(14, 4, 'FueraDeServicio', '2026-05-05 10:00:00', NULL),
(15, 3, 'Disponible',      '2026-05-01 08:00:00', NULL);
GO


-- ============================================================
-- 4. ALQUILER
-- ============================================================

-- Contrato:
-- Tarifa 2026 vigentes: ECO=11, SEDAN=12, SUV=13, PICKUP=14, MINI=15
-- MetaEstado: ACTIVO=8, CERRADO=9
-- Contratos 1-13: CERRADOS | 14-15: ACTIVOS
INSERT INTO [alquiler].[Contrato] (NumeroContrato, Cliente_ID, Vehiculo_ID, Sucursal_ID, Empleado_ID, Tarifa_ID, FechaInicio, FechaFinPactada, TarifaAplicada, DiasPactados, MontoTotal, DepositoGarantia, KmEntrega, CombustibleEntrega, Observaciones, MetaEstado_ID, TipoCambio_ID, MontoTotalUSD) VALUES
('RCRSJO-2026-001', 3,  2,  1, 2, 12, '2026-01-10 08:00', '2026-01-17 08:00', 27000.00, 7,  189000.00, 50000.00, 22100, 'Lleno',       'Viaje de trabajo a Guanacaste',          9, 3,  365.77),  -- 1
('RCRSJO-2026-002', 9,  3,  1, 2, 13, '2026-01-20 09:00', '2026-01-27 09:00', 40000.00, 7,  280000.00, 80000.00, 18500, 'Lleno',       'Turismo familiar — playas del Pacífico',  9, 3,  541.85),  -- 2
('RCRSJO-2026-003', 11, 11, 1, 1, 13, '2026-02-03 07:30', '2026-02-10 07:30', 40000.00, 7,  280000.00, 80000.00, 15300, 'Lleno',       'Cuenta corporativa TechCorp',            9, 3,  541.85),  -- 3
('RCRESC-2026-001', 5,  4,  2, 3, 14, '2026-02-14 10:00', '2026-02-21 10:00', 44000.00, 7,  308000.00, 90000.00, 62300, 'TresCuartos', 'Traslado de equipos zona sur',           9, 3,  596.13),  -- 4
('RCRALJ-2026-001', 2,  6,  3, 4, 13, '2026-02-20 06:00', '2026-02-27 06:00', 40000.00, 7,  280000.00, 80000.00,  9800, 'Lleno',       'Ingresa por aeropuerto',                 9, 3,  541.85),  -- 5
('RCRSJO-2026-004', 1,  1,  1, 2, 11, '2026-03-05 08:00', '2026-03-10 08:00', 19000.00, 5,   95000.00, 30000.00, 35200, 'Lleno',       'Uso personal, cliente frecuente',        9, 3,  183.89),  -- 6
('RCRSJO-2026-005', 12, 11, 1, 2, 13, '2026-03-15 08:00', '2026-03-22 08:00', 40000.00, 7,  280000.00, 80000.00, 15300, 'Lleno',       'Turismo Pacífico — traslado turistas',   9, 4,  541.18),  -- 7
('RCRALJ-2026-002', 4,  7,  3, 4, 15, '2026-03-25 09:00', '2026-03-30 09:00', 16000.00, 5,   80000.00, 25000.00, 28600, 'Lleno',       'Primera vez alquilando',                 9, 4,  154.62),  -- 8
('RCRLIB-2026-001', 6,  9,  4, 5, 11, '2026-04-01 07:00', '2026-04-08 07:00', 19000.00, 7,  133000.00, 35000.00, 55700, 'Mitad',       'Turismo Guanacaste',                     9, 5,  257.27),  -- 9
('RCRLIB-2026-002', 13, 10, 4, 5, 14, '2026-04-10 08:00', '2026-04-17 08:00', 44000.00, 7,  308000.00, 90000.00, 47200, 'Lleno',       'ExpoValle — transporte carga liviana',   9, 5,  595.48),  -- 10
('RCRSJO-2026-006', 7,  2,  1, 2, 12, '2026-04-20 10:00', '2026-04-25 10:00', 27000.00, 5,  135000.00, 40000.00, 22100, 'Lleno',       'Viaje Semana Santa zona atlántica',      9, 5,  261.00),  -- 11
('RCRALJ-2026-003', 8,  15, 3, 4, 13, '2026-05-01 08:00', '2026-05-08 08:00', 40000.00, 7,  280000.00, 80000.00, 21700, 'Lleno',       'Vacaciones con familia',                 9, 6,  534.76),  -- 12
('RCRESC-2026-002', 5,  13, 2, 3, 12, '2026-05-10 09:00', '2026-05-17 09:00', 40000.00, 7,  280000.00, 80000.00,  4200, 'Lleno',       'Segunda vez — cliente regular',          9, 6,  534.76),  -- 13
('RCRSJO-2026-007', 9,  3,  1, 2, 13, '2026-05-15 07:00', '2026-05-22 07:00', 40000.00, 7,  280000.00, 80000.00, 18500, 'Lleno',       'Viaje Nicoya, segundo contrato del año', 8, NULL, NULL),  -- 14
('RCRALJ-2026-004', 4,  8,  3, 4, 13, '2026-05-18 09:30', '2026-05-25 09:30', 40000.00, 7,  280000.00, 80000.00, 33400, 'Lleno',       'Contrato activo — Kia Sportage',         8, NULL, NULL);  -- 15
GO

-- Actualizar Contrato_ID en DisponibilidadVehiculo para Kia Sportage alquilado
UPDATE [vehiculo].[DisponibilidadVehiculo]
SET Contrato_ID = 15
WHERE Vehiculo_ID = 8 AND EstadoDisponibilidad = 'Alquilado';
GO

INSERT INTO [alquiler].[Devolucion] (Contrato_ID, FechaDevolucionReal, Sucursal_ID, Empleado_ID, KmDevolucion, CombustibleDevolucion, EstadoVehiculo, DescripcionDanios) VALUES
(1,  '2026-01-17 09:15', 1, 2, 22950, 'Lleno',       'SinDanios',   NULL),
(2,  '2026-01-27 10:30', 1, 2, 20200, 'Lleno',       'SinDanios',   NULL),
(3,  '2026-02-10 08:00', 1, 1, 16800, 'Lleno',       'SinDanios',   NULL),
(4,  '2026-02-21 11:00', 2, 3, 64100, 'Cuarto',      'DaniosLeves', 'Rayón leve en guardafango trasero derecho'),
(5,  '2026-02-27 07:30', 3, 4, 11500, 'Lleno',       'SinDanios',   NULL),
(6,  '2026-03-10 09:00', 1, 2, 35980, 'Lleno',       'SinDanios',   NULL),
(7,  '2026-03-22 08:30', 1, 2, 17100, 'TresCuartos', 'SinDanios',   NULL),
(8,  '2026-03-30 09:45', 3, 4, 29300, 'Mitad',       'SinDanios',   NULL),
(9,  '2026-04-08 07:30', 4, 5, 57100, 'Cuarto',      'SinDanios',   NULL),
(10, '2026-04-17 08:15', 4, 5, 48900, 'Lleno',       'SinDanios',   NULL),
(11, '2026-04-25 10:30', 1, 2, 23400, 'TresCuartos', 'SinDanios',   NULL),
(12, '2026-05-08 09:00', 3, 4, 23400, 'Lleno',       'SinDanios',   NULL),
(13, '2026-05-17 10:00', 2, 3,  6800, 'Lleno',       'SinDanios',   NULL);
GO

INSERT INTO [alquiler].[FormaPago] (Contrato_ID, Empleado_ID, TipoPago, MontoPago, Moneda_ID, FechaPago) VALUES
(1,  2, 'TarjetaCredito', 189000.00, 1, '2026-01-10 08:30'),
(2,  2, 'TarjetaCredito', 280000.00, 1, '2026-01-20 09:30'),
(3,  1, 'Transferencia',  280000.00, 1, '2026-02-03 08:00'),
(4,  3, 'TarjetaDebito',  308000.00, 1, '2026-02-14 10:30'),
(5,  4, 'TarjetaCredito', 280000.00, 1, '2026-02-20 06:30'),
(6,  2, 'Efectivo',        95000.00, 1, '2026-03-05 08:30'),
(7,  2, 'Transferencia',  280000.00, 1, '2026-03-15 08:30'),
(8,  4, 'TarjetaCredito',  80000.00, 1, '2026-03-25 09:30'),
(9,  5, 'Efectivo',       133000.00, 1, '2026-04-01 07:30'),
(10, 5, 'Transferencia',  308000.00, 1, '2026-04-10 08:30'),
(11, 2, 'TarjetaCredito', 135000.00, 1, '2026-04-20 10:30'),
(12, 4, 'TarjetaCredito', 280000.00, 1, '2026-05-01 08:30'),
(13, 3, 'Transferencia',  280000.00, 1, '2026-05-10 09:30');
GO

-- FormaPago tarjeta: IDs 1,2,4,5,8,11,12
INSERT INTO [alquiler].[PagoTarjeta] (FormaPago_ID, MarcaTarjeta_ID, BIN, CodigoAutorizacion, Emisor) VALUES
(1,  1, '426734', 'AUTH-8821-A', 'BAC Credomatic'),
(2,  2, '545301', 'AUTH-9034-B', 'Banco Nacional'),
(4,  1, '411234', 'AUTH-7712-C', 'Banco de Costa Rica'),
(5,  3, '378282', 'AUTH-5523-D', 'American Express CR'),
(8,  2, '510510', 'AUTH-6645-E', 'Banco Popular'),
(11, 1, '426700', 'AUTH-3389-F', 'BAC Credomatic'),
(12, 1, '423456', 'AUTH-2278-G', 'Scotiabank CR');
GO

-- FormaPago transferencia: IDs 3,7,10,13
INSERT INTO [alquiler].[PagoTransferencia] (FormaPago_ID, Banco_ID, NumeroCuenta, NumeroComprobante) VALUES
(3,  3, 'CR21015201001026284066', 'COMP-20260203-001'),
(7,  1, 'CR05015201001026284067', 'COMP-20260315-007'),
(10, 2, 'CR18015201001026284068', 'COMP-20260410-010'),
(13, 3, 'CR21015201001026284069', 'COMP-20260510-013');
GO


-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
SELECT
    s.name  AS Esquema,
    t.name  AS Tabla,
    p.rows  AS Registros
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
WHERE s.name <> 'dbo'
ORDER BY s.name, t.name;
GO
-- ============================================================
-- FIN POBLACIÓN RentaCR v2
-- ============================================================
