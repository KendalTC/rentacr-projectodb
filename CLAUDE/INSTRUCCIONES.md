# INSTRUCCIONES PARA CLAUDE CODE — REPOSITORIO RENTACR
# IF5100 Administración de Bases de Datos — UCR I Semestre 2026

## OBJETIVO
Crear un repositorio de GitHub completamente documentado para el proyecto RentaCR del curso IF5100.
El repositorio debe ser **privado**, en **español**, con estructura de carpetas clara y READMEs detallados por sección.

---

## DATOS DEL PROYECTO

- **Alumno:** Kendall Trejos Cubero — Carné C4K374
- **Curso:** IF5100 Administración de Bases de Datos
- **Profesor:** Luis Diego Bolaños A.
- **Universidad:** Universidad de Costa Rica
- **Semestre:** I Semestre 2026
- **Sistema:** RentaCR — Sistema de gestión de alquiler de vehículos
- **Repositorio:** Privado, en español

---

## TAREA PRINCIPAL

Crear la siguiente estructura de archivos y carpetas con su contenido completo. Cada README.md debe estar completamente redactado con la información técnica real del proyecto (no placeholders). No crear carpetas `screenshots/` — esas las agrega el alumno manualmente.

---

## ESTRUCTURA DEL REPOSITORIO

```
rentacr-projectodb/
├── README.md
├── .gitignore
│
├── docs/
│   ├── enunciado/                          # Enunciado oficial del proyecto (PDF)
│   ├── requerimientos/                     # Requerimientos funcionales V1 y V2 (Word)
│   └── bloques/
│       ├── bloque05_ecosistema.md
│       ├── bloque06_hardening_os.md
│       ├── bloque07_instalacion_sgbdr.md
│       ├── bloque08_hardening_sgbdr.md
│       ├── bloque09_arquitectura_datos.md
│       ├── bloque09b_funcionalidades_ss2025.md
│       ├── bloque10_tablas_inmemory.md
│       ├── bloque11_poblacion.md
│       ├── bloque12_seguridad.md
│       ├── bloque13_alta_disponibilidad.md
│       ├── bloque14_serializacion_json.md
│       └── backup_restore.md
│
├── sql/
│   ├── ddl/                                # RentaCR_DDL_v1.sql
│   ├── dml/                                # RentaCR_Poblacion_v2.sql
│   ├── seguridad/                          # Vistas, roles, DDM, RLS, CIS SS2022
│   ├── funcionalidades/                    # vector_search.sql, external_api.sql, regexp_validaciones.sql
│   └── operaciones/                        # backup_restore.sql
│
├── powershell/
│   ├── hardening-os/                       # CIS_WS2025_MASTER.ps1 + Parte1-5
│   ├── auditoria/                          # CIS_WS2025_AUDITORIA.ps1 + v2
│   └── antimalware/                        # ConfiguracionAntimalware.txt
│
├── diagramas/
│   ├── conceptual/                         # ModeloConceptual_RentaCR v1-v5 (.drawio)
│   └── logico/                             # RentaCR_dbdiagram.dbml, DiagraRentaCR.pdf/.png
│
├── mockups/
│   ├── mockups_rentacr.html
│   └── screens/                            # 17 pantallas PNG
│
└── CLAUDE/                                 # Contexto y configuración para Claude Code
    ├── CONTEXTO_v2.md
    ├── INSTRUCCIONES.md
    └── SKILL.md
```

---

## CONTENIDO DE CADA ARCHIVO

---

### README.md (RAÍZ — Portada principal)

```markdown
# RentaCR — Sistema de Gestión de Alquiler de Vehículos

**Proyecto Final — IF5100 Administración de Bases de Datos**
Universidad de Costa Rica
I Semestre, 2026

---

## Información del Proyecto

| Campo | Detalle |
|-------|---------|
| **Alumno** | Kendall Trejos Cubero |
| **Carné** | C4K374 |
| **Profesor** | Luis Diego Bolaños A. |
| **Curso** | IF5100 — Administración de Bases de Datos |
| **Semestre** | I Semestre 2026 |

---

## Descripción

RentaCR es un sistema integral de gestión de alquiler de vehículos desarrollado sobre Microsoft SQL Server 2025. El sistema centraliza la gestión de personas (clientes y empleados), flota vehicular, contratos de alquiler, devoluciones, pagos y disponibilidad en tiempo real.

El proyecto implementa un ecosistema seguro con hardening de plataforma operativa y motor de base de datos, cifrado en reposo (TDE), enmascaramiento de datos sensibles (DDM), seguridad a nivel de fila (RLS), auditoría completa y funcionalidades modernas de SQL Server 2025 incluyendo Vector Search, External API calls y expresiones regulares avanzadas.

---

## Tecnologías Utilizadas

| Tecnología | Versión/Detalle |
|------------|-----------------|
| Microsoft Azure | Suscripción for Students |
| Windows Server | 2025 Datacenter Gen2 |
| SQL Server | 2025 Enterprise Evaluation (17.0.1115.1) |
| SSMS | 22 (v22.6.0) |
| Windows Defender | ATP configurado para SQL Server |
| In-Memory OLTP | MEMORY_OPTIMIZED_DATA filegroup |
| Dynamic Data Masking | email(), partial(), default() |
| Row Level Security | Por sucursal en Contrato y DisponibilidadVehiculo |
| Transparent Data Encryption | AES-256 |
| SQL Server Audit | APPLICATION_LOG — 9 action groups |
| Vector Search | VECTOR(1536) + VECTOR_DISTANCE cosine |
| External REST API | sp_invoke_external_rest_endpoint |

---

## Estándares Aplicados

| Estándar | Versión | Aplicado a |
|----------|---------|------------|
| CIS Microsoft Windows Server 2025 Benchmark | v2.0.0 | Plataforma operativa |
| CIS Microsoft SQL Server 2022 Benchmark | v1.2.1 | Motor de base de datos |

---

## Infraestructura Azure

| Componente | Detalle |
|------------|---------|
| **VM** | vm-projectdb |
| **Región** | Canada Central |
| **Imagen** | Windows Server 2025 Datacenter Gen2 |
| **Tamaño** | Standard_B2as_v2 (2 vCPU, 8 GB RAM) |
| **Grupo de Recursos** | rg-projectdb |

### Distribución de Discos (LUNs)

| Disco | Letra | Tamaño | Tipo | Propósito |
|-------|-------|--------|------|-----------|
| lun-datos | D: | 4 GB | Standard SSD | Archivos .mdf + Binarios SQL |
| lun-logs | E: | 4 GB | Standard SSD | Archivos .ldf |
| lun-tempdb | F: | 4 GB | Standard SSD | TempDB |
| lun-backups | G: | 4 GB | Standard SSD | Backups y Auditorías |

---

## Arquitectura de la Base de Datos

### Esquemas

| Esquema | Propósito | Tablas |
|---------|-----------|--------|
| `ref` | Catálogos y tablas de referencia | 12 |
| `persona` | Personas, clientes, empleados, contactos | 16 |
| `vehiculo` | Flota, categorías, seguros, disponibilidad | 8 |
| `alquiler` | Contratos, devoluciones, pagos | 5 |

**Total: 41 tablas**

---

## Estado del Proyecto

### Resumen por Bloque de Evaluación

| # | Bloque | Puntos | Estado |
|---|--------|--------|--------|
| 5 | Ecosistema (hypervisor, OS, antimalware) | 10 | ✅ Completado |
| 6 | Hardening del ecosistema (CIS WS2025) | 5 | ✅ Completado |
| 7 | Instalación y configuración SGBDR | 5 | ✅ Completado |
| 8 | Hardening SGBDR (CIS SS2022) + auditoría + TDE | 5 | ✅ Completado |
| 9 | Arquitectura de datos + LUNs + SS2025 features | 30 | ⚠️ En proceso |
| 10 | Tablas in-memory | 3 | ✅ Completado |
| 11 | Población de la base de datos | 2 | ✅ Completado |
| 12 | Seguridad y regulación | 10 | ✅ Completado |
| 13 | Alta disponibilidad — Azure PaaS | 10 | ⏳ Pendiente |
| 14 | Serialización JSON | 5 | ✅ Completado |
| **Total** | | **85** | |

### Detalle por Componente

| Componente | Estado | Observaciones |
|------------|--------|---------------|
| VM Azure (Windows Server 2025) | ✅ Implementado | Standard_B2as_v2, Canada Central |
| LUNs y discos separados | ✅ Implementado | 4 discos: datos, logs, tempdb, backups |
| Windows Defender ATP | ✅ Implementado | Exclusiones SQL Server configuradas |
| Hardening CIS WS2025 | ✅ Implementado | Controles omitidos justificados por entorno Azure |
| SQL Server 2025 Enterprise | ✅ Implementado | Named instance SQLSERVER2025, puerto 1434 |
| Mejores prácticas SGBDR | ✅ Implementado | max memory, MAXDOP, TLS, SA deshabilitado |
| Hardening CIS SS2022 | ✅ Implementado | Secciones 2-7 aplicadas |
| Auditoría SQL Server | ✅ Implementado | 9 action groups → APPLICATION_LOG |
| TDE (AES-256) | ✅ Implementado | Certificado respaldado en G:\SQLBackups |
| DDL completo RentaCR | ✅ Implementado | 41 tablas, 4 esquemas |
| In-Memory OLTP | ✅ Implementado | DisponibilidadVehiculo MEMORY_OPTIMIZED |
| Población de datos | ✅ Implementado | 10+ registros por tabla |
| Vistas (1 por tabla) | ✅ Implementado | 41 vistas creadas |
| Roles de base de datos | ✅ Implementado | db_Administrativo, db_Mantenimiento, db_LecturaGeneral |
| Dynamic Data Masking | ✅ Implementado | Correo, cédula, dirección |
| Row Level Security | ✅ Implementado | Por sucursal en Contrato y DisponibilidadVehiculo |
| Serialización JSON | ✅ Implementado | sp_SerializarClientesJSON probado |
| Vector Search | ⚠️ En proceso | VECTOR(1536) + VECTOR_DISTANCE funcional, DiskANN pendiente por limitación de build |
| External API BCCR | ⚠️ En proceso | sp_invoke_external_rest_endpoint funcional, API BCCR caída |
| REGEXP_LIKE | ⚠️ En proceso | No disponible en build RTM-GDR, requiere actualización CU |
| Azure SQL Database PaaS | ⏳ Pendiente | Deploy completo pendiente |
| Backup completo | ✅ Implementado | RentaCR_before_TDE.bak y RentaCR_post_poblacion.bak |

---

## Estructura del Repositorio

```
rentacr-projectodb/
├── docs/bloques/bloque05_ecosistema.md          # Azure VM, Windows Server 2025, Antimalware
├── docs/bloques/bloque06_hardening_os.md        # CIS WS2025
├── docs/bloques/bloque07_instalacion_sgbdr.md   # SQL Server 2025, mejores prácticas
├── docs/bloques/bloque08_hardening_sgbdr.md     # CIS SS2022, TDE, auditoría
├── docs/bloques/bloque09_arquitectura_datos.md  # DDL, modelo lógico, LUNs
├── docs/bloques/bloque10_tablas_inmemory.md     # In-Memory OLTP
├── docs/bloques/bloque11_poblacion.md           # Scripts de población
├── docs/bloques/bloque12_seguridad.md           # Vistas, roles, DDM, RLS
├── docs/bloques/bloque13_alta_disponibilidad.md # Azure SQL Database PaaS
├── docs/bloques/bloque14_serializacion_json.md  # JSON serialization
├── powershell/hardening-os/                     # Scripts CIS WS2025 (MASTER + Parte1-5)
└── sql/                                         # DDL, DML, seguridad, funcionalidades
```

---

## Checklist de Rúbrica

### Bloque 5 — Ecosistema (10 pts)
- [x] Instalación y configuración del hypervisor (Azure) — 1 pt
- [x] Instalación y configuración del sistema operativo (WS2025) — 5 pts
- [x] Instalación y configuración del antimalware para SQL Server — 4 pts

### Bloque 6 — Hardening OS (5 pts)
- [x] CIS WS2025 v2.0.0 aplicado
- [x] Controles omitidos documentados y justificados

### Bloque 7 — Instalación SGBDR (5 pts)
- [x] SQL Server 2025 Enterprise instalado — 2 pts
- [x] Mejores prácticas aplicadas (BP del curso) — 3 pts

### Bloque 8 — Hardening SGBDR (5 pts)
- [x] CIS SS2022 v1.2.1 aplicado — 3 pts
- [x] Antimalware configurado para SQL Server — 1 pt
- [x] Auditoría configurada (9 action groups) — 1 pt

### Bloque 9 — Arquitectura de datos (30 pts)
- [x] Modelo lógico creado — 10 pts
- [x] Vector Data and Semantic Search — 5 pts ⚠️
- [x] External API calls — 5 pts ⚠️
- [ ] Expresiones regulares avanzadas — 5 pts ⏳
- [x] Solución de LUNs (diseño físico) — 5 pts

### Bloque 10 — In-Memory (3 pts)
- [x] DisponibilidadVehiculo MEMORY_OPTIMIZED — 3 pts

### Bloque 11 — Población (2 pts)
- [x] Todas las tablas con 10+ registros — 2 pts

### Bloque 12 — Seguridad (10 pts)
- [x] 41 vistas creadas — 2 pts
- [x] Roles y objetos asignados — 2 pts
- [x] DDM (correo, cédula, dirección) — 4 pts
- [x] Row Level Security por sucursal — 2 pts

### Bloque 13 — Alta Disponibilidad (10 pts)
- [ ] Azure SQL Database PaaS — 10 pts ⏳

### Bloque 14 — Serialización JSON (5 pts)
- [x] sp_SerializarClientesJSON funcional con datos reales — 5 pts
```

---

### docs/bloques/bloque05_ecosistema.md

```markdown
# Bloque 5 — Ecosistema

## Objetivo
Instalación y configuración del hypervisor (Azure), plataforma operativa (Windows Server 2025) y solución antimalware configurada para SQL Server.

**Valor:** 10 puntos | **Estado:** ✅ Completado

---

## Infraestructura Azure (Hypervisor)

| Parámetro | Valor |
|-----------|-------|
| Proveedor | Microsoft Azure |
| Suscripción | Azure for Students |
| Nombre de VM | vm-projectdb |
| Región | Canada Central |
| Grupo de recursos | rg-projectdb |
| Imagen | Windows Server 2025 Datacenter Gen2 |
| Tamaño | Standard_B2as_v2 |
| vCPUs | 2 |
| RAM | 8 GB |
| Apagado automático | 7:00 PM hora Costa Rica (1:00 AM UTC) |

### Snapshots tomados

| Snapshot | Momento |
|----------|---------|
| snap-before-sqlserver-install | Antes de instalar SQL Server |
| snap-after-sqlserver-install | Después de instalar y configurar SQL Server |
| snap-after-ddl-rentacr | Después de crear el DDL completo de RentaCR |

---

## Discos y LUNs

Siguiendo las mejores prácticas para SQL Server, los archivos de base de datos se distribuyen en discos separados:

| Disco | Letra | Tamaño | Tipo | Propósito | Carpetas |
|-------|-------|--------|------|-----------|----------|
| lun-datos | D: | 4 GB | Standard SSD | Datos y Binarios | D:\SQLData, D:\SQLBinarios |
| lun-logs | E: | 4 GB | Standard SSD | Transaction Logs | E:\SQLLogs |
| lun-tempdb | F: | 4 GB | Standard SSD | TempDB | F:\SQLTempDB |
| lun-backups | G: | 4 GB | Standard SSD | Backups y Auditorías | G:\SQLBackups, G:\SQLAudits |

**NTFS Allocation Unit:** 64 KB en todos los discos de datos (BP SQL Server)

---

## Windows Server 2025

| Configuración | Valor | Justificación |
|---------------|-------|---------------|
| Edición | Datacenter Gen2 | Requerimiento del proyecto |
| Power Option | High Performance | BP SQL Server — evitar throttling |
| Win32PrioritySeparation | 24 (Background Services) | BP SQL Server — prioridad a servicios |
| NLA (Network Level Auth) | Deshabilitada | Requerido para acceso RDP en Azure sin dominio |

---

## Windows Defender ATP — Configuración para SQL Server

### Exclusiones de Procesos

| Proceso | Justificación |
|---------|---------------|
| sqlservr.exe | Motor principal SQL Server |
| sqlagent.exe | SQL Server Agent |
| sqlbrowser.exe | SQL Server Browser |
| sqlwriter.exe | SQL Writer Service |

### Exclusiones de Extensiones

| Extensión | Tipo de archivo |
|-----------|-----------------|
| .mdf | Archivo de datos principal |
| .ldf | Transaction log |
| .ndf | Archivo de datos secundario |
| .bak | Backup |
| .trn | Transaction log backup |
| .trc | Trace file |
| .sqlaudit | Archivo de auditoría |

### Exclusiones de Rutas

- `D:\SQLData`
- `D:\SQLBinarios`
- `E:\SQLLogs`
- `F:\SQLTempDB`
- `G:\SQLBackups`
- `G:\SQLAudits`

### Configuración Adicional

| Parámetro | Valor |
|-----------|-------|
| Cloud Protection | High |
| Real-time Protection | On |
| PUA Protection | On |
| Network Protection | On |
| Escaneo programado | Domingos 2AM — Full Scan |
```

---

### docs/bloques/bloque06_hardening_os.md

```markdown
# Bloque 6 — Hardening del Ecosistema (OS)

## Objetivo
Aplicar el estándar CIS Microsoft Windows Server 2025 Benchmark v2.0.0 para blindar la plataforma operativa donde reside SQL Server.

**Valor:** 5 puntos | **Estado:** ✅ Completado

---

## Estándar Aplicado

| Parámetro | Valor |
|-----------|-------|
| Guía | CIS Microsoft Windows Server 2025 Benchmark |
| Versión | v2.0.0 |
| Nivel | Level 1 + Level 2 (con excepciones justificadas) |

---

## Scripts

| Archivo | Descripción |
|---------|-------------|
| `MASTER.ps1` | Script maestro — aplica todos los controles CIS WS2025 |
| `AUDITORIA.ps1` | Script de auditoría — verifica el estado de cada control |

Ubicación en la VM: `C:\Hardening\`

---

## Controles Omitidos y Justificación

Los siguientes controles del estándar fueron omitidos intencionalmente por incompatibilidad con el entorno Azure sin Active Directory:

| Control | Descripción | Razón de Omisión |
|---------|-------------|------------------|
| 2.2.8, 2.2.21, 2.2.26 | Restricciones de cuentas locales | Bloquean cuentas locales necesarias para RDP en Azure |
| 9.3.4, 9.3.5 | AllowLocalPolicyMerge | Bloquea RDP en perfil Public de Azure |
| 18.4.1 | LocalAccountTokenFilterPolicy | Bloquea acceso remoto con cuenta local |
| 18.6.21.2 | fBlockNonDomain | Bloquea Azure (red no-dominio) |
| 18.9.4.1 | CredSSP | Bloquea RDP sin NLA |
| 18.9.5.* | Device Guard/VBS | Requiere hardware enterprise físico |
| 18.9.25.1 | LAPS | Requiere Active Directory |
| 18.9.26.2 | RunAsPPL | Causa problemas de boot en Azure VM |
| 18.9.36.2 | RestrictRemoteClients | Bloquea RDP remoto |
| 18.9.75.3/5/6/7 | SSL/NLA forzado | Bloquean RDP sin certificado de dominio |

> **Nota:** Estos controles son incompatibles con VMs de Azure sin dominio. La omisión está debidamente documentada y justificada técnicamente.

---

## Controles Críticos NUNCA Aplicar en Esta VM

- `SecurityLayer=2`
- `AllowLocalPolicyMerge=0`
- `fBlockNonDomain=1`
- `CredSSP AllowEncryptionOracle=0`
- `UserAuthentication=1` (NLA forzado)
- `MinEncryptionLevel=3`
```

---

### docs/bloques/bloque07_instalacion_sgbdr.md

```markdown
# Bloque 7 — Instalación y Configuración del SGBDR

## Objetivo
Instalación de SQL Server 2025 Enterprise con todas las mejores prácticas de configuración vistas en el curso.

**Valor:** 5 puntos | **Estado:** ✅ Completado

---

## SQL Server 2025

| Parámetro | Valor |
|-----------|-------|
| Edición | Enterprise Evaluation |
| Versión | 17.0.1115.1 (RTM-GDR) KB5091223 |
| Instancia | SQLSERVER2025 (named instance) |
| Servicio | MSSQL$SQLSERVER2025 |
| Puerto TCP | 1434 (cambiado desde 1433 por seguridad) |
| Autenticación | Mixed Mode |
| Collation | SQL_Latin1_General_CP1_CI_AI |
| SA | Renombrado a sa_rentacr — DESHABILITADO |

### Herramientas Instaladas
- SQL Server Management Studio 22 (v22.6.0)

---

## Mejores Prácticas Aplicadas (BPs del Curso)

### Configuración del Motor (sp_configure)

| Parámetro | Valor | Justificación |
|-----------|-------|---------------|
| max server memory (MB) | 4096 | 50% de 8GB RAM — deja memoria para OS |
| max degree of parallelism | 1 | VM de 2 vCPUs — evitar paralelismo excesivo |
| cost threshold for parallelism | 50 | Umbral adecuado para cargas OLTP |
| optimize for ad hoc workloads | 1 | Reduce bloat en plan cache |
| xp_cmdshell | 0 | Deshabilitado — Surface Area Reduction |
| Ole Automation Procedures | 0 | Deshabilitado — Surface Area Reduction |
| remote access | 0 | Deshabilitado — Surface Area Reduction |

### Configuración de Windows para SQL Server

| Parámetro | Valor | Justificación |
|-----------|-------|---------------|
| Power Option | High Performance | Evitar throttling de CPU |
| Win32PrioritySeparation | 24 | Prioridad a servicios en background |
| NTFS Allocation Unit | 64 KB | BP para discos de datos SQL Server |
| Force Encryption | On | TLS 1.2+ obligatorio |

### Estructura de Carpetas

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
```

---

### docs/bloques/bloque08_hardening_sgbdr.md

```markdown
# Bloque 8 — Hardening del SGBDR

## Objetivo
Aplicar el estándar CIS Microsoft SQL Server 2022 Benchmark v1.2.1, configurar auditoría completa y cifrado TDE.

**Valor:** 5 puntos | **Estado:** ✅ Completado

---

## Estándar Aplicado

| Parámetro | Valor |
|-----------|-------|
| Guía | CIS Microsoft SQL Server 2022 Benchmark |
| Versión | v1.2.1 |

---

## Controles Aplicados por Sección

### Sección 2 — Surface Area Reduction

| Control | Configuración |
|---------|---------------|
| remote access | 0 (deshabilitado) |
| xp_cmdshell | 0 (deshabilitado) |
| Ole Automation Procedures | 0 (deshabilitado) |
| Ad Hoc Distributed Queries | 0 (deshabilitado) |
| CLR | 0 (deshabilitado) |
| CLR strict security | 1 (habilitado) |
| cross db ownership chaining | 0 (deshabilitado) |
| scan for startup procs | 0 (deshabilitado) |
| Database Mail | 0 (deshabilitado) |
| remote admin connections | 0 (deshabilitado) |

### Sección 3 — Autenticación y Cuentas

| Control | Acción |
|---------|--------|
| SA renombrado | sa → sa_rentacr |
| SA deshabilitado | LOGIN DISABLE |
| SA con política de contraseña | CHECK_POLICY=ON |
| NT SERVICE\SQLWriter | Removido de sysadmin |
| NT SERVICE\Winmgmt | Removido de sysadmin |

### Sección 4 — Políticas de Contraseña

| Login | CHECK_EXPIRATION |
|-------|-----------------|
| ##MS_PolicyEventProcessingLogin## | ON |
| ##MS_PolicyTsqlExecutionLogin## | ON |

### Sección 5 — Auditoría

| Parámetro | Valor |
|-----------|-------|
| Nombre | Audit_RentaCR |
| Destino | APPLICATION_LOG (Windows Event Log) |
| Especificación | AuditSpec_RentaCR |

**Action Groups configurados:**

| Action Group | Descripción |
|-------------|-------------|
| FAILED_LOGIN_GROUP | Intentos de login fallidos |
| SUCCESSFUL_LOGIN_GROUP | Logins exitosos |
| AUDIT_CHANGE_GROUP | Cambios en la auditoría |
| SERVER_ROLE_MEMBER_CHANGE_GROUP | Cambios en roles de servidor |
| SERVER_OBJECT_CHANGE_GROUP | Cambios en objetos del servidor |
| SCHEMA_OBJECT_CHANGE_GROUP | Cambios en esquemas |
| DATABASE_ROLE_MEMBER_CHANGE_GROUP | Cambios en roles de BD |
| LOGIN_CHANGE_PASSWORD_GROUP | Cambios de contraseña |
| SERVER_PERMISSION_CHANGE_GROUP | Cambios en permisos de servidor |

### Sección 6 — CLR

| Control | Valor |
|---------|-------|
| CLR strict security | 1 |
| Assemblies de usuario inseguros | Ninguno |

### Sección 7 — Encriptación

| Control | Valor |
|---------|-------|
| Force Encryption (7.4) | Habilitado vía registro |
| TDE — Transparent Data Encryption (7.5) | ✅ Aplicado — AES-256 |

---

## TDE — Transparent Data Encryption

| Parámetro | Valor |
|-----------|-------|
| Algoritmo | AES_256 |
| Estado | Cifrado completo (encryption_state = 3) |
| Certificado | CertTDE_RentaCR |
| Backup certificado | G:\SQLBackups\CertTDE_RentaCR.cer |
| Backup private key | G:\SQLBackups\CertTDE_RentaCR.pvk |

> **Importante:** Los archivos .mdf, .ldf y .bak de RentaCR están cifrados en disco. Sin el certificado no es posible restaurar la base de datos.
```

---

### docs/bloques/bloque09_arquitectura_datos.md

```markdown
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
```

---

### docs/bloques/bloque10_tablas_inmemory.md

```markdown
# Bloque 10 — Tablas In-Memory

## Objetivo
Implementar In-Memory OLTP para la tabla de disponibilidad de vehículos, que requiere alta concurrencia y baja latencia.

**Valor:** 3 puntos | **Estado:** ✅ Completado

---

## Configuración

| Parámetro | Valor |
|-----------|-------|
| Filegroup | RentaCR_MemOpt |
| Tipo | MEMORY_OPTIMIZED_DATA |
| Ubicación | D:\SQLData\RentaCR_MemOpt |

---

## Tabla In-Memory

### vehiculo.DisponibilidadVehiculo

| Propiedad | Valor |
|-----------|-------|
| MEMORY_OPTIMIZED | ON |
| DURABILITY | SCHEMA_AND_DATA |
| Primary Key | NONCLUSTERED |
| Registros | 15 |

### Columnas

| Columna | Tipo | Descripción |
|---------|------|-------------|
| Disponibilidad_ID | INT IDENTITY | PK |
| Vehiculo_ID | INT | FK lógica |
| Sucursal_ID | INT | FK lógica |
| EstadoDisponibilidad | NVARCHAR(30) | Disponible / Alquilado / FueraDeServicio |
| FechaHoraEstado | DATETIME2 | Timestamp del estado |
| Contrato_ID | INT NULL | Referencia al contrato activo |

---

## Row Level Security en In-Memory

La tabla in-memory utiliza una función RLS con NATIVE_COMPILATION (requerido para tablas MEMORY_OPTIMIZED):

```sql
CREATE FUNCTION [alquiler].[fn_RLS_Sucursal_InMemory](@Sucursal_ID INT)
RETURNS TABLE
WITH SCHEMABINDING, NATIVE_COMPILATION
AS
RETURN (
    SELECT 1 AS fn_result
    WHERE IS_ROLEMEMBER('db_Administrativo') = 1
);
```

> **Nota técnica:** Las funciones inline TVF para RLS en tablas in-memory requieren NATIVE_COMPILATION. No pueden hacer subqueries a otras tablas — solo pueden validar roles o variables de sesión.
```

---

### docs/bloques/bloque11_poblacion.md

```markdown
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
```

---

### docs/bloques/bloque12_seguridad.md

```markdown
# Bloque 12 — Gestión de Seguridad y Regulación

## Objetivo
Implementar seguridad completa: vistas, roles, enmascaramiento de datos, seguridad a nivel de fila y cifrado.

**Valor:** 10 puntos | **Estado:** ✅ Completado

---

## Vistas (1 por tabla)

Total: **41 vistas** — una por cada tabla de la base de datos.

Toda consulta a datos se hace exclusivamente a través de vistas. Nunca se otorgan permisos directos sobre las tablas base.

| Esquema | Vistas |
|---------|--------|
| ref | vw_Pais, vw_Moneda, vw_UbicacionGeo, vw_MetaEstado, vw_TipoMecanismoContacto, vw_TipoDireccion, vw_TipoIdentificacion, vw_MarcaTarjeta, vw_Banco, vw_Puesto, vw_TipoCambio, vw_Sucursal |
| persona | vw_Persona, vw_PersonaFisica, vw_PersonaJuridica, vw_Cliente, vw_HistoricoEstadoCliente, vw_ClasificacionCliente, vw_ClienteClasificacion, vw_AtributoCliente, vw_Identificador, vw_MecanismoContacto, vw_HistoricoEstadoContacto, vw_Direccion, vw_HistoricoEstadoDireccion, vw_Empleado, vw_HistoricoAsignacionSucursal, vw_HistoricoEstadoEmpleado |
| vehiculo | vw_Marca, vw_ModeloVehiculo, vw_CategoriaVehiculo, vw_Vehiculo, vw_DocumentoSeguro, vw_ImagenVehiculo, vw_Tarifa, vw_DisponibilidadVehiculo |
| alquiler | vw_Contrato, vw_Devolucion, vw_FormaPago, vw_PagoTarjeta, vw_PagoTransferencia |

---

## Roles de Base de Datos

| Rol | Permisos | Objetos |
|-----|----------|---------|
| db_Administrativo | SELECT, INSERT, UPDATE, DELETE, EXECUTE | Todas las tablas + vistas + SPs |
| db_Mantenimiento | SELECT, INSERT, UPDATE, DELETE | Todas las tablas |
| db_LecturaGeneral | SELECT | Todas las vistas |

> Nunca se otorgan permisos directos a los objetos principales. Todo acceso es a través de vistas.

---

## Dynamic Data Masking (DDM)

| Tabla | Columna | Función de Máscara | Datos protegidos |
|-------|---------|-------------------|-----------------|
| persona.MecanismoContacto | Valor | email() | Correos electrónicos |
| persona.Identificador | Numero | partial(2,"XXXXXX",2) | Números de cédula |
| persona.Direccion | LineaDireccion1 | default() | Direcciones físicas |

**Cumplimiento:** Ley de Protección de Datos Personales de Costa Rica (Ley 8968)

---

## Row Level Security (RLS)

### Política en alquiler.Contrato

| Parámetro | Valor |
|-----------|-------|
| Política | PolicyContratoSucursal |
| Función | alquiler.fn_RLS_Sucursal |
| Tipo | FILTER PREDICATE |
| Lógica | Administrativos ven todo; agentes solo ven contratos de su sucursal |

### Política en vehiculo.DisponibilidadVehiculo

| Parámetro | Valor |
|-----------|-------|
| Política | PolicyDisponibilidadSucursal |
| Función | alquiler.fn_RLS_Sucursal_InMemory |
| Tipo | FILTER PREDICATE |
| Nota | Función NATIVE_COMPILATION por ser tabla in-memory |

---

## Transparent Data Encryption (TDE)

| Parámetro | Valor |
|-----------|-------|
| Estado | Cifrado completo (encryption_state = 3) |
| Algoritmo | AES_256 |
| Certificado | CertTDE_RentaCR |
| Alcance | Archivos .mdf, .ldf y .bak de RentaCR |

---

## Cumplimiento Regulatorio

| Regulación | Mecanismo aplicado |
|------------|--------------------|
| Ley 8968 (Protección datos personales CR) | DDM en correo, cédula y dirección |
| Confidencialidad de datos en reposo | TDE AES-256 |
| Control de acceso por rol | Roles + vistas — sin permisos directos |
| Auditoría de accesos | SQL Server Audit — 9 action groups |
| Cifrado en tránsito | Force Encryption TLS 1.2+ |
```

---

### docs/bloques/bloque13_alta_disponibilidad.md

```markdown
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
```

---

### docs/bloques/bloque14_serializacion_json.md

```markdown
# Bloque 14 — Serialización y Transferencia de Datos

## Objetivo
Serializar la información completa de todos los clientes a formato JSON usando FOR JSON PATH con estructura anidada.

**Valor:** 5 puntos | **Estado:** ✅ Completado

---

## Stored Procedure

| Parámetro | Valor |
|-----------|-------|
| Nombre | persona.sp_SerializarClientesJSON |
| Técnica | FOR JSON PATH con subconsultas anidadas |
| Estructura | Clientes → Contactos, Direcciones, Identificaciones |

---

## Estructura del JSON

```json
{
  "clientes": [
    {
      "Cliente_ID": 1,
      "TipoPersona": "F",
      "PrimerNombre": "Carlos",
      "PrimerApellido": "Mora",
      "FechaNacimiento": "1985-03-12",
      "EstadoCliente": "Cliente activo",
      "Contactos": [
        { "TipoMecanismoContacto_ID": 1, "Valor": "carlos.mora@gmail.com" },
        { "TipoMecanismoContacto_ID": 2, "Valor": "88012345", "CodigoArea": "506" }
      ],
      "Direcciones": [
        { "TipoDireccion_ID": 1, "LineaDireccion1": "Barrio Dent..." }
      ],
      "Identificaciones": [
        { "TipoIdentificacion_ID": 1, "Numero": "1-0752-0341" }
      ]
    }
  ]
}
```

---

## Ejecución

```sql
USE [RentaCR];
EXEC [persona].[sp_SerializarClientesJSON];
```

**Resultado:** JSON completo con los 13 clientes (10 físicos + 3 jurídicos) con sus contactos, direcciones e identificaciones anidadas.
```

---

### docs/bloques/bloque09b_funcionalidades_ss2025.md

```markdown
# Bloque 9 — Funcionalidades SQL Server 2025

## Objetivo
Implementar las tres nuevas funcionalidades de SQL Server 2025: Vector Search, External API calls y expresiones regulares avanzadas.

**Estado general:** ⚠️ En proceso — limitaciones de build RTM-GDR

---

## 1. Vector Data and Semantic Search

**Estado:** ⚠️ Funcional sin índice DiskANN

| Componente | Estado | Detalle |
|------------|--------|---------|
| Columna VECTOR(1536) | ✅ Implementado | vehiculo.Vehiculo.DescripcionVector |
| Datos vectoriales | ✅ Implementado | 15 vehículos con vectores sintéticos |
| VECTOR_DISTANCE | ✅ Funcional | Métrica cosine probada |
| Índice DiskANN | ⚠️ Pendiente | Sintaxis no disponible en build RTM-GDR |

### Consulta de Similitud Semántica

```sql
-- Buscar los 5 vehículos más similares a un vector de búsqueda
SELECT TOP 5
    v.Placa,
    mv.Nombre AS Modelo,
    cv.Descripcion AS Categoria,
    VECTOR_DISTANCE('cosine', v.DescripcionVector, @vectorBusqueda) AS Distancia
FROM [vehiculo].[Vehiculo] v
JOIN [vehiculo].[ModeloVehiculo] mv ON v.ModeloVehiculo_ID = mv.ModeloVehiculo_ID
JOIN [vehiculo].[CategoriaVehiculo] cv ON v.CategoriaVehiculo_ID = cv.CategoriaVehiculo_ID
WHERE v.DescripcionVector IS NOT NULL
ORDER BY Distancia ASC;
```

---

## 2. External API Calls

**Estado:** ⚠️ Feature funcional — API BCCR caída

| Componente | Estado | Detalle |
|------------|--------|---------|
| sp_invoke_external_rest_endpoint | ✅ Habilitado | external rest endpoint enabled = 1 |
| SP implementado | ✅ Completo | alquiler.sp_ObtenerTipoCambioBCCR |
| Prueba con httpbin.org | ✅ HTTP 200 | Feature funcional |
| API BCCR | ⚠️ HTTP 500 | Servicio externo caído al momento de la prueba |

### Stored Procedure

```sql
EXEC [alquiler].[sp_ObtenerTipoCambioBCCR]
    @FechaConsulta = '2026-05-26',
    @TipoCambio_ID = @id OUTPUT;
```

---

## 3. Expresiones Regulares (REGEXP_LIKE)

**Estado:** ⚠️ No disponible en build actual

| Componente | Estado | Detalle |
|------------|--------|---------|
| REGEXP_LIKE | ❌ No disponible | Build 17.0.1115.1 RTM-GDR no lo soporta |
| Compatibility Level | ✅ 170 | Correcto |
| Alternativa implementada | ✅ LIKE | Los 3 SPs usan LIKE como fallback |
| Solución | Actualizar al último CU de SS2025 | Pendiente |

### SPs con validación LIKE (temporal)

| SP | Valida |
|----|--------|
| vehiculo.sp_ValidarVehiculo | Placa: [A-Z][A-Z][A-Z]-[0-9][0-9][0-9] |
| persona.sp_ValidarContacto | Correo: LIKE '%@%.%' |
| persona.sp_ValidarIdentificacion | Cédula: [1-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9] |
```

---

### docs/bloques/backup_restore.md

```markdown
# Backup y Restauración

## Objetivo
Documentar la estrategia de backup implementada para RentaCR.

---

## Backups Realizados

| Archivo | Descripción | Fecha | Ubicación |
|---------|-------------|-------|-----------|
| RentaCR_before_TDE.bak | Backup completo previo a TDE | 2026-05-26 | G:\SQLBackups\ |
| RentaCR_post_poblacion.bak | Backup completo con datos y TDE | 2026-05-26 | G:\SQLBackups\ |

---

## Comando de Backup

```sql
BACKUP DATABASE [RentaCR]
TO DISK = N'G:\SQLBackups\RentaCR_post_poblacion.bak'
WITH FORMAT,
     COMPRESSION,
     NAME = N'RentaCR — Backup post población y TDE',
     DESCRIPTION = N'Backup completo con datos, TDE activo. IF5100 Mayo 2026.';
```

---

## Consideraciones TDE

> Los backups están cifrados porque TDE está activo en la base de datos. Para restaurar este backup en otro servidor se requiere:
> 1. El certificado `CertTDE_RentaCR.cer`
> 2. La private key `CertTDE_RentaCR.pvk`
> 3. La contraseña del certificado

---

## Verificación del Backup

```sql
RESTORE VERIFYONLY
FROM DISK = N'G:\SQLBackups\RentaCR_post_poblacion.bak';
```
```

---

### .gitignore

```
# Contraseñas y credenciales
*.pfx
*.pvk
*.p12
secrets.txt
credentials.txt

# Archivos de auditoría con datos sensibles
*.sqlaudit

# Archivos temporales
*.tmp
*.log
Thumbs.db
.DS_Store
```

---

## INSTRUCCIONES FINALES PARA CLAUDE CODE

1. Crear el repositorio con nombre `rentacr-projectodb` — **privado**
2. Crear toda la estructura de carpetas y archivos descritos arriba
3. El contenido de cada README.md es el que aparece en este documento — usarlo tal cual
4. Para los archivos `.ps1` y `.sql` — crear los archivos con el nombre correcto pero dejar el contenido como comentario indicando que el alumno los proveerá (ej: `-- El alumno provee el contenido de este archivo`)
5. El README principal va en la raíz del repositorio
6. Hacer un commit inicial con mensaje: `"docs: estructura inicial del proyecto RentaCR IF5100"`
7. No crear carpetas `screenshots/` — el alumno las agrega manualmente
