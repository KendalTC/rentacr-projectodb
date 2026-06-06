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
