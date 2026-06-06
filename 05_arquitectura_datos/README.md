# Bloque 9 — Arquitectura de Datos

## Objetivo
Modelo de datos completo para el sistema RentaCR, con LUNs separados por tipo de archivo e implementación de las tres funcionalidades nuevas de SQL Server 2025.

**Valor:** 30 puntos | **Estado:** ⚠️ En proceso

---

## Modelo Lógico

| Esquema | Propósito | Tablas |
|---------|-----------|--------|
| `ref` | Catálogos y tablas de referencia | 12 |
| `persona` | Personas, clientes, empleados, contactos, direcciones | 16 |
| `vehiculo` | Flota, categorías, seguros, disponibilidad | 8 |
| `alquiler` | Contratos, devoluciones, pagos | 5 |
| **Total** | | **41** |

### Tablas por Esquema

**ref:** Pais, Moneda, UbicacionGeo, MetaEstado, TipoMecanismoContacto, TipoDireccion, TipoIdentificacion, MarcaTarjeta, Banco, Puesto, TipoCambio, Sucursal

**persona:** Persona, PersonaFisica, PersonaJuridica, Cliente, HistoricoEstadoCliente, ClasificacionCliente, ClienteClasificacion, AtributoCliente, Identificador, MecanismoContacto, HistoricoEstadoContacto, Direccion, HistoricoEstadoDireccion, Empleado, HistoricoAsignacionSucursal, HistoricoEstadoEmpleado

**vehiculo:** Marca, ModeloVehiculo, CategoriaVehiculo, Vehiculo, DocumentoSeguro, ImagenVehiculo, Tarifa, DisponibilidadVehiculo

**alquiler:** Contrato, Devolucion, FormaPago, PagoTarjeta, PagoTransferencia

### Stored Procedures

| SP | Esquema | Descripción |
|----|---------|-------------|
| sp_ValidarVehiculo | vehiculo | Valida Placa y VIN con LIKE |
| sp_ValidarContacto | persona | Valida correo y teléfono |
| sp_ValidarIdentificacion | persona | Valida cédula física |
| sp_ObtenerTipoCambioBCCR | alquiler | External API BCCR |
| sp_SerializarClientesJSON | persona | Serialización JSON clientes |

### Funciones

| Función | Esquema | Descripción |
|---------|---------|-------------|
| fn_RLS_Sucursal | alquiler | Predicado RLS para tablas normales |
| fn_RLS_Sucursal_InMemory | alquiler | Predicado RLS NATIVE_COMPILATION para In-Memory |

---

## Convenciones de Código

| Objeto | Convención | Ejemplo |
|--------|------------|---------|
| Tablas | PascalCase | Cliente |
| Vistas | vw_PascalCase | vw_Cliente |
| Stored Procedures | sp_PascalCase | sp_ObtenerClientes |
| Índices | IX_Tabla_Columna | IX_Cliente_Email |
| PK | PK_Tabla | PK_Cliente |
| FK | FK_TablaHijo_TablaPadre | FK_Cliente_Persona |

---

## Funcionalidades SQL Server 2025

### 1. Vector Data and Semantic Search

| Parámetro | Detalle |
|-----------|---------|
| Columna | vehiculo.Vehiculo.DescripcionVector |
| Tipo | VECTOR(1536) |
| Métrica | cosine |
| Función | VECTOR_DISTANCE |
| Índice DiskANN | Pendiente — limitación de build RTM-GDR |
| Estado | ⚠️ Funcional sin índice |

### 2. External API Calls

| Parámetro | Detalle |
|-----------|---------|
| Feature | sp_invoke_external_rest_endpoint |
| SP | alquiler.sp_ObtenerTipoCambioBCCR |
| API objetivo | BCCR — Tipo de cambio USD |
| Estado feature | ✅ Habilitada y funcional |
| Estado API BCCR | ⚠️ API externa devuelve HTTP 500 (servicio caído) |
| Prueba alternativa | httpbin.org — HTTP 200 ✅ |

### 3. Expresiones Regulares Avanzadas (REGEXP_LIKE)

| Parámetro | Detalle |
|-----------|---------|
| Función | REGEXP_LIKE |
| Versión instalada | 17.0.1115.1 (RTM-GDR) |
| Compatibility Level | 170 |
| Estado | ⚠️ No disponible en esta build — requiere CU posterior |
| Alternativa | Validación con LIKE implementada en los 3 SPs |
