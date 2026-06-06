# Bloque 11 — Población de la Base de Datos

## Objetivo
Poblar todas las tablas con un mínimo de 10 registros cada una, usando datos coherentes para un sistema de renta de vehículos costarricense.

**Valor:** 2 puntos | **Estado:** ✅ Completado

---

## Conteo de Registros por Tabla

| Esquema | Tabla | Registros |
|---------|-------|-----------|
| alquiler | Contrato | 15 |
| alquiler | Devolucion | 13 |
| alquiler | FormaPago | 13 |
| alquiler | PagoTarjeta | 7 |
| alquiler | PagoTransferencia | 4 |
| persona | AtributoCliente | 12 |
| persona | ClasificacionCliente | 12 |
| persona | Cliente | 13 |
| persona | ClienteClasificacion | 14 |
| persona | Direccion | 16 |
| persona | Empleado | 7 |
| persona | HistoricoAsignacionSucursal | 8 |
| persona | HistoricoEstadoCliente | 15 |
| persona | HistoricoEstadoContacto | 14 |
| persona | HistoricoEstadoDireccion | 13 |
| persona | HistoricoEstadoEmpleado | 7 |
| persona | Identificador | 22 |
| persona | MecanismoContacto | 32 |
| persona | Persona | 20 |
| persona | PersonaFisica | 17 |
| persona | PersonaJuridica | 3 |
| ref | Banco | 8 |
| ref | MarcaTarjeta | 5 |
| ref | MetaEstado | 21 |
| ref | Moneda | 3 |
| ref | Pais | 10 |
| ref | Puesto | 6 |
| ref | Sucursal | 5 |
| ref | TipoCambio | 6 |
| ref | TipoDireccion | 4 |
| ref | TipoIdentificacion | 5 |
| ref | TipoMecanismoContacto | 6 |
| ref | UbicacionGeo | 27 |
| vehiculo | CategoriaVehiculo | 6 |
| vehiculo | DisponibilidadVehiculo | 15 |
| vehiculo | DocumentoSeguro | 10 |
| vehiculo | Marca | 10 |
| vehiculo | ModeloVehiculo | 15 |
| vehiculo | Tarifa | 15 |
| vehiculo | Vehiculo | 15 |

---

## Datos de Prueba

- **Sucursales:** 5 (San José, Escazú, Aeropuerto Alajuela, Liberia, Limón)
- **Clientes:** 10 físicos + 3 jurídicos
- **Empleados:** 7 (gerentes, agentes, mecánico, cajera)
- **Vehículos:** 15 (Toyota, Hyundai, Kia, Suzuki, Nissan, Ford, Chevrolet, VW, Mitsubishi, Honda)
- **Contratos:** 15 (13 cerrados + 2 activos)
- **Tipos de pago:** Efectivo, TarjetaDebito, TarjetaCredito, Transferencia
