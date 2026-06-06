# Bloque 13 — Alta Disponibilidad y la Nube

## Objetivo
Deploy completo de la base de datos RentaCR (metadatos y datos) a Azure SQL Database PaaS, configurado según mejores prácticas.

**Valor:** 10 puntos | **Estado:** ⏳ Pendiente

---

## Plan de Implementación

| Paso | Descripción | Estado |
|------|-------------|--------|
| 1 | Crear Azure SQL Server (servidor lógico) | ⏳ Pendiente |
| 2 | Crear Azure SQL Database | ⏳ Pendiente |
| 3 | Configurar firewall y acceso | ⏳ Pendiente |
| 4 | Migrar esquema (DDL) | ⏳ Pendiente |
| 5 | Migrar datos (población) | ⏳ Pendiente |
| 6 | Verificar integridad | ⏳ Pendiente |
| 7 | Configurar BPs en PaaS | ⏳ Pendiente |

---

## Consideraciones Técnicas

- La BD tiene TDE activo — Azure SQL Database soporta TDE nativo
- La tabla in-memory (DisponibilidadVehiculo) puede requerir ajustes en PaaS
- Los SPs con sp_invoke_external_rest_endpoint funcionan en Azure SQL Database
- El certificado TDE debe migrarse correctamente
