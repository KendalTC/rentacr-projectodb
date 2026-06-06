# CONTEXTO PROJECTDB IF5100 — UCR I Semestre 2026
# Pega esto al inicio del nuevo chat para continuar sin perder contexto
# Última actualización: Mayo 2026

## PROYECTO
**Curso:** IF5100 Administración de Bases de Datos — UCR
**Profesor:** Luis Diego Bolaños A.
**Alumno:** Kendall Trejos Cubero (solo)
**Sistema:** RentaCR — Sistema de gestión de alquiler de vehículos

---

## VM AZURE — ESTADO ACTUAL

- **Nombre:** vm-projectdb
- **Región:** Canada Central
- **Imagen:** Windows Server 2025 Datacenter - Gen2
- **Tamaño:** Standard_B2as_v2 (2 vCPU, 8 GB RAM) — ~$67.74/mes
- **Usuario:** kendal0612
- **Grupo de recursos:** rg-projectdb
- **Apagado automático:** 7:00 PM hora Costa Rica (1:00 AM UTC)
- **Suscripción:** Azure for Students

### ACCESO RDP
- Usar `.\kendal0612` como usuario
- NLA está DESHABILITADA — es intencional
- Si se pierde acceso: Azure Portal → Run Command → RunPowerShellScript

### DISCOS (LUNs reales en Azure — Canada Central)
| Disco | Letra | Tamaño | Tipo | Propósito |
|-------|-------|--------|------|-----------|
| lun-datos | D: | 4 GB | Standard SSD | Archivos .mdf |
| lun-logs | E: | 4 GB | Standard SSD | Archivos .ldf |
| lun-tempdb | F: | 4 GB | Standard SSD | TempDB |
| lun-backups | G: | 4 GB | Standard SSD | Backups y Audits |

### CARPETAS SQL SERVER
```
D:\SQLBinarios\Instance   — Binarios SQL Server
D:\SQLBinarios\Shared     — Shared features
D:\SQLBinarios\Shared86   — Shared features x86
D:\SQLData                — Archivos .mdf
E:\SQLLogs                — Archivos .ldf
F:\SQLTempDB              — TempDB
G:\SQLBackups             — Backups
G:\SQLAudits              — Auditorías
```

### SNAPSHOTS TOMADOS
- `snap-before-sqlserver-install` — antes de instalar SQL Server
- `snap-after-sqlserver-install` — después de instalar y configurar SQL Server
- `snap-after-ddl-rentacr` — después de crear el DDL completo de RentaCR

---

## BLOQUES DE EVALUACIÓN

| Bloque | Descripción | Pts | Estado |
|--------|-------------|-----|--------|
| 5 | Ecosistema (hypervisor, OS, antimalware) | 10 | ✅ Completo |
| 6 | Hardening OS (CIS WS2025) | 5 | ✅ Completo |
| 7 | Instalación y config SGBDR | 5 | ✅ Completo |
| 8 | Hardening SGBDR (CIS SS2022) + auditoría | 5 | ⚠️ Parcial (falta TDE) |
| 9 | Arquitectura de datos + LUNs | 30 | ⚠️ Parcial (Vector Search, API, RegEx pendientes de prueba) |
| 10 | Tablas in-memory | 3 | ✅ Completo |
| 11 | Población (mínimo 10 registros/tabla) | 2 | ⏳ Pendiente |
| 12 | Seguridad y regulación | 10 | ⚠️ Parcial (falta TDE) |
| 13 | Alta disponibilidad — Azure PaaS | 10 | ⏳ Pendiente |
| 14 | Serialización JSON | 5 | ⚠️ Parcial (falta prueba con datos) |

---

## ESTADO ACTUAL POR BLOQUE

### ✅ COMPLETADO

**Bloque 5 — Ecosistema:**
- Windows Server 2025 Datacenter instalado y configurado
- Windows Defender configurado con mejores prácticas para SQL Server
  - Exclusiones de procesos: sqlservr.exe, sqlagent.exe, sqlbrowser.exe, sqlwriter.exe
  - Exclusiones de extensiones: .mdf, .ldf, .ndf, .bak, .trn, .trc, .sqlaudit
  - Cloud protection: High, Real-time: On, PUA: On, Network Protection: On
  - Escaneo programado: Domingos 2AM Full Scan
- Exclusiones de rutas: D:\SQLData, D:\SQLBinarios, E:\SQLLogs, F:\SQLTempDB, G:\SQLBackups, G:\SQLAudits

**Bloque 6 — Hardening OS:**
- CIS WS2025 v2.0.0 aplicado completamente
- Script maestro: `C:\Hardening\MASTER.ps1`
- Script auditoría: `C:\Hardening\AUDITORIA.ps1`

**Bloque 7 — Instalación y configuración SGBDR:**
- SQL Server 2025 Enterprise Evaluation instalado
- Instancia: SQLSERVER2025 (named instance)
- Puerto TCP: 1434 (cambiado desde 1433)
- Force Encryption TLS habilitado
- SA renombrado a sa_rentacr y deshabilitado
- SSMS 22 (v22.6.0) instalado — reemplazó al SSMS 20

**BPs aplicadas post-instalación:**
```sql
max server memory (MB) = 4096
max degree of parallelism = 1
cost threshold for parallelism = 50
optimize for ad hoc workloads = 1
xp_cmdshell = 0
Ole Automation Procedures = 0
remote access = 0
```

**BPs aplicadas en Windows:**
- Power Option = High Performance
- Win32PrioritySeparation = 24 (Background Services)
- NTFS Allocation Unit = 64KB en todos los discos de datos

**Bloque 10 — Tablas In-Memory:**
- DisponibilidadVehiculo creada como MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA
- Filegroup MEMORY_OPTIMIZED_DATA creado en D:\SQLData
- Función RLS nativa con NATIVE_COMPILATION aplicada

### ⚠️ PARCIAL

**Bloque 8 — Hardening CIS SS2022:**
Controles aplicados:
- Sección 2: Surface Area Reduction completa (remote access=0, xp_cmdshell=0, Ole Automation=0, Ad Hoc=0, CLR=0, CLR strict security=1, cross db ownership=0, scan startup procs=0, Database Mail=0, remote admin=0)
- Sección 3: SA renombrado (sa_rentacr), deshabilitado, policy ON. Removidos de sysadmin: NT SERVICE\SQLWriter, NT SERVICE\Winmgmt
- Sección 4: CHECK_EXPIRATION=ON en ##MS_PolicyEventProcessingLogin## y ##MS_PolicyTsqlExecutionLogin##
- Sección 5: Audit_RentaCR al APPLICATION_LOG con 9 action groups: FAILED_LOGIN_GROUP, SUCCESSFUL_LOGIN_GROUP, AUDIT_CHANGE_GROUP, SERVER_ROLE_MEMBER_CHANGE_GROUP, SERVER_OBJECT_CHANGE_GROUP, SCHEMA_OBJECT_CHANGE_GROUP, DATABASE_ROLE_MEMBER_CHANGE_GROUP, LOGIN_CHANGE_PASSWORD_GROUP, SERVER_PERMISSION_CHANGE_GROUP
- Sección 6: CLR strict security=1, sin assemblies de usuario inseguros
- Sección 7.4: Force Encryption habilitado vía registro

**PENDIENTE Bloque 8:**
- TDE (Sección 7.5) — se aplica después de poblar RentaCR

**Bloque 9 — Arquitectura de datos:**
- DDL completo ejecutado en la VM
- REGEXP_LIKE: requiere probar en RentaCR con CL 170 usando SSMS 22
  - Tu BD RentaCR ya tiene compatibility_level = 170
  - Probar: `USE [RentaCR]; SELECT REGEXP_LIKE('ABC-123', '^[A-Z]{3}-[0-9]{3}$');`
  - Si funciona → actualizar los 3 stored procedures de validación
- Vector Search: columna VECTOR(1536) creada, falta índice DiskANN + consulta VECTOR_DISTANCE (requiere datos)
- External API BCCR: SP creado, falta prueba real (requiere datos)

**Bloque 12 — Seguridad:**
- 41 vistas creadas ✅
- Roles db_Administrativo, db_Mantenimiento, db_LecturaGeneral con GRANTs ✅
- DDM en correo (email()), cédula (partial(2,"XXXXXX",2)), dirección (default()) ✅
- RLS por sucursal en Contrato y DisponibilidadVehiculo ✅
- TDE pendiente ⏳

**Bloque 14 — JSON:**
- SP sp_SerializarClientesJSON creado con FOR JSON PATH anidado ✅
- Prueba con datos reales pendiente ⏳

### ⏳ PENDIENTE (en orden de prioridad)

1. **Probar REGEXP_LIKE en RentaCR con SSMS 22** — puede que ya funcione con CL 170
2. **Poblar todas las tablas** — mínimo 10 registros cada una (Bloque 11)
3. **TDE** — después de poblar RentaCR
4. **Índice DiskANN + VECTOR_DISTANCE** — después de poblar Vehiculo
5. **Prueba External API BCCR** — después de poblar datos
6. **Prueba JSON** — después de poblar clientes
7. **Azure SQL Database PaaS** — Bloque 13 (todos o nada, 10 pts)

---

## BASE DE DATOS RentaCR

### Esquemas
- `persona` — Personas, clientes, empleados, contactos, direcciones
- `vehiculo` — Flota, categorías, seguros, disponibilidad
- `alquiler` — Contratos, devoluciones, pagos
- `ref` — Catálogos y tablas de referencia

### Tablas principales (30+)
**ref:** Pais, Moneda, UbicacionGeo, MetaEstado, TipoMecanismoContacto, TipoDireccion, TipoIdentificacion, MarcaTarjeta, Banco, Puesto, TipoCambio, Sucursal

**persona:** Persona, PersonaFisica, PersonaJuridica, Cliente, HistoricoEstadoCliente, ClasificacionCliente, ClienteClasificacion, AtributoCliente, Identificador, MecanismoContacto, HistoricoEstadoContacto, Direccion, HistoricoEstadoDireccion, Empleado, HistoricoAsignacionSucursal, HistoricoEstadoEmpleado

**vehiculo:** Marca, ModeloVehiculo, CategoriaVehiculo, Vehiculo (con VECTOR(1536)), DocumentoSeguro, ImagenVehiculo (FILESTREAM), Tarifa, DisponibilidadVehiculo (IN-MEMORY)

**alquiler:** Contrato, Devolucion, FormaPago, PagoTarjeta, PagoTransferencia

### Stored Procedures
- `vehiculo.sp_ValidarVehiculo` — valida Placa y VIN con LIKE (temporal hasta confirmar REGEXP)
- `persona.sp_ValidarContacto` — valida correo y teléfono
- `persona.sp_ValidarIdentificacion` — valida cédula física
- `alquiler.sp_ObtenerTipoCambioBCCR` — External API BCCR
- `persona.sp_SerializarClientesJSON` — serialización JSON clientes
- `alquiler.fn_RLS_Sucursal` — función RLS para tablas normales
- `alquiler.fn_RLS_Sucursal_InMemory` — función RLS NATIVE_COMPILATION para In-Memory

### Seguridad implementada
- DDM: MecanismoContacto.Valor (email()), Identificador.Numero (partial), Direccion.LineaDireccion1 (default())
- RLS: PolicyContratoSucursal en alquiler.Contrato, PolicyDisponibilidadSucursal en vehiculo.DisponibilidadVehiculo
- Roles: db_Administrativo, db_Mantenimiento, db_LecturaGeneral
- 41 vistas — toda consulta solo por vistas

---

## SQL SERVER — CONFIGURACIÓN ACTUAL

```
Instancia:    MSSQL$SQLSERVER2025
Puerto TCP:   1434
Collation:    SQL_Latin1_General_CP1_CI_AI
Edición:      Enterprise Evaluation (180 días)
Versión:      17.0.1000.7 (RTM)
Auth:         Mixed Mode
SA:           Renombrado a sa_rentacr — DESHABILITADO
```

### Auditoría activa
- Audit_RentaCR → APPLICATION_LOG de Windows
- AuditSpec_RentaCR → 9 action groups

---

## ARCHIVOS GENERADOS

```
hardening_cis_ss2022_rentacr.sql  — Script completo hardening CIS SS2022
RentaCR_DDL_v1.sql                — DDL completo de la base de datos
RentaCR_Vistas_v1.sql             — Script de vistas corregido
RentaCR_dbdiagram.dbml            — Modelo para dbdiagram.io
C:\Hardening\MASTER.ps1           — Script maestro hardening CIS WS2025
C:\Hardening\AUDITORIA.ps1        — Script auditoría CIS WS2025
```

---

## HARDENING CIS WS2025 — CONTROLES OMITIDOS (justificados)

| Control | Razón |
|---------|-------|
| 2.2.8, 2.2.21, 2.2.26 | Bloquean cuentas locales/RDP |
| 9.3.4, 9.3.5 | AllowLocalPolicyMerge=0 bloquea RDP en perfil Public de Azure |
| 18.4.1 | LocalAccountTokenFilterPolicy=0 bloquea acceso remoto cuenta local |
| 18.6.21.2 | fBlockNonDomain=1 bloquea Azure (red no-dominio) |
| 18.9.4.1 | CredSSP=0 bloquea RDP sin NLA |
| 18.9.5.* | Device Guard/VBS requiere hardware enterprise |
| 18.9.25.1 | LAPS requiere Active Directory |
| 18.9.26.2 | RunAsPPL causa boot issues en Azure VM |
| 18.9.36.2 | RestrictRemoteClients bloquea RDP remoto |
| 18.9.75.3/5/6/7 | SSL/NLA bloquean RDP sin certificado de dominio |

**NUNCA aplicar en esta VM:**
- SecurityLayer=2, AllowLocalPolicyMerge=0, fBlockNonDomain=1
- CredSSP AllowEncryptionOracle=0, UserAuthentication=1 (NLA), MinEncryptionLevel=3

---

## CONVENCIONES DE CÓDIGO

```sql
-- Tablas:      PascalCase          → Cliente
-- Vistas:      vw_PascalCase       → vw_Cliente
-- Stored Proc: sp_PascalCase       → sp_ObtenerClientes
-- Índices:     IX_Tabla_Columna    → IX_Cliente_Email
-- PK:          PK_Tabla            → PK_Cliente
-- FK:          FK_TablaHijo_TablaPadre
-- Esquemas explícitos siempre: SELECT * FROM persona.Cliente
```

---

## PRÓXIMAS TAREAS (en orden)

1. Abrir SSMS 22 y probar REGEXP_LIKE en RentaCR con CL 170
2. Si funciona → actualizar los 3 SPs de validación con REGEXP_LIKE real
3. Poblar todas las tablas (mínimo 10 registros c/u)
4. Aplicar TDE sobre RentaCR
5. Crear índice DiskANN + consulta VECTOR_DISTANCE en Vehiculo
6. Probar External API BCCR (sp_ObtenerTipoCambioBCCR)
7. Probar serialización JSON (sp_SerializarClientesJSON)
8. Deploy Azure SQL Database PaaS (Bloque 13)
