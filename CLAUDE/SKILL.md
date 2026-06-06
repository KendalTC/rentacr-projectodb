---
name: projectdb
description: Skill especializada para el proyecto IF5100 Administración de Bases de Datos, UCR I Semestre 2026, profesor Luis Diego Bolaños. Úsala para cualquier tarea relacionada con ProjectDB: diseño de modelo lógico, scripts T-SQL, hardening, seguridad, Azure, serialización JSON, Vector Search, in-memory tables, roles, vistas, RLS, Dynamic Data Masking, configuración de SQL Server 2025, o cualquier componente del proyecto. Actívala siempre que el usuario mencione ProjectDB, IF5100, el proyecto de bases de datos, o cualquiera de sus componentes técnicos.
---

# ProjectDB — IF5100 Administración de Bases de Datos
**UCR | Informática Empresarial | I Semestre 2026**
**Profesor:** Luis Diego Bolaños A.
**Alumno:** Kendall Trejos Cubero | Solo

---

## Contexto del proyecto

Crear un ecosistema completo de base de datos empresarial: infraestructura virtualizada, SQL Server 2025 Enterprise, hardening según estándares CIS, arquitectura de datos propia, seguridad avanzada y deploy en Azure PaaS.

---

## Stack tecnológico obligatorio

- **SGBDR:** SQL Server 2025 Enterprise Edition (evaluación)
- **OS:** Windows Server 2025 Datacenter
- **Hypervisor:** a definir (Hyper-V o VMware)
- **Antimalware:** Windows Defender ATP (Server 2025)
- **Nube:** Microsoft Azure SQL Database (PaaS)
- **Cifrado en tránsito:** TLS 1.2 mínimo
- **Cifrado en reposo:** TDE + Column Level Encryption
- **Hardening OS:** CIS_Microsoft_Windows_Server_2025_Benchmark_v2.0.0
- **Hardening SGBDR:** CIS_Microsoft_SQL_Server_2022_Benchmark_v1.2.1

---

## Bloques de evaluación y puntaje

| # | Bloque | Pts | Mínimo para aprobar |
|---|--------|-----|---------------------|
| 5 | Instalación ecosistema (hypervisor, OS, antimalware) | 10 | Sin estos no se aprueba nada |
| 6 | Hardening OS (CIS WS2025) | 5 | No bajar de 2 pts |
| 7 | Instalación y config SGBDR | 5 | No bajar de 2 pts |
| 8 | Hardening SGBDR (CIS SS2022) + auditoría | 5 | No bajar de 1 pt |
| 9 | Arquitectura de datos + LUNs | 30 | No bajar de 5 pts |
| 10 | Tablas in-memory | 3 | Todos o nada |
| 11 | Población (mínimo 10 registros/tabla) | 2 | Todos o nada |
| 12 | Seguridad y regulación | 10 | No bajar de 5 pts |
| 13 | Alta disponibilidad — Azure PaaS | 10 | Todos o nada |
| 14 | Serialización JSON | 5 | — |
| **Total** | | **85** | |

---

## Bloque 9 — Arquitectura de datos (el más crítico, 30 pts)

### Funcionalidades SQL Server 2025 obligatorias (3 de 3 requeridas)
1. **Vector Data and Semantic Search** (5 pts) — columnas `vector`, búsqueda semántica
2. **External API calls** (5 pts) — `sp_invoke_external_rest_endpoint`
3. **Expresiones regulares avanzadas** (5 pts) — funciones `REGEXP_*` de SS2025

### Mini-mundo: pendiente de definir y aprobar con el profesor
- Debe tener entidades con: correo, dirección, cédula (requerido para masking)
- Debe tener entidad "cliente" (requerido para serialización JSON)
- Debe justificar Row-Level Security de forma natural
- Debe justificar Vector Search de forma natural

### LUNs (5 pts)
- Diseño físico de almacenamiento basado en el hypervisor
- Separación de LUNs: datos, logs, tempdb, backups

---

## Bloque 12 — Seguridad (reglas fijas del enunciado)

```
- Toda consulta a tablas: SOLO por Vistas (1 vista mínimo por tabla)
- Nunca permisos directos a objetos principales
- Roles obligatorios:
    * db_Administrativo  → lectura + escritura en todos los objetos
    * db_Mantenimiento   → INSERT, SELECT, UPDATE, DELETE en tablas
    * db_LecturaGeneral  → SELECT solo en vistas
- Dynamic Data Masking obligatorio en: correo, dirección, cédula
- Row-Level Security: aplicar donde tenga sentido según el modelo
```

---

## Bloque 8 — Auditoría obligatoria

```sql
-- Patrón base para SQL Server Audit (ajustar según modelo final)
CREATE SERVER AUDIT [ProjectDB_Audit]
TO FILE (FILEPATH = 'D:\Audits\', MAXSIZE = 100MB, MAX_FILES = 10)
WITH (ON_FAILURE = CONTINUE);

CREATE DATABASE AUDIT SPECIFICATION [ProjectDB_DB_Audit]
FOR SERVER AUDIT [ProjectDB_Audit]
ADD (SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo BY public);
```

---

## Bloque 14 — Serialización JSON (patrón base)

```sql
-- Serializar todos los clientes a JSON
SELECT *
FROM vw_Cliente  -- siempre por vista
FOR JSON AUTO, ROOT('clientes');
```

---

## Mejores prácticas BP del curso (aplicar siempre)

Estas aparecen marcadas como "BP" en las presentaciones del profesor:

**Memoria y CPU:**
- `max server memory` configurado (nunca dejar en default)
- `MAXDOP` según número de cores (fórmula: min(8, #cores/2))
- `Cost threshold for parallelism` = 50

**Seguridad:**
- SA deshabilitado o renombrado
- Autenticación: Windows Authentication preferida
- `xp_cmdshell` deshabilitado
- `Ole Automation Procedures` deshabilitado
- Auditoría habilitada desde instalación

**Almacenamiento:**
- TDE habilitado
- Backups en LUN separada
- `tempdb` en LUN separada con múltiples archivos (1 por core hasta 8)

**Antimalware para SQL Server:**
- Excluir de escaneo: archivos `.mdf`, `.ldf`, `.ndf`, directorios de datos y backups
- Excluir procesos: `sqlservr.exe`, `sqlagent.exe`, `sqlbrowser.exe`

---

## Guía de trabajo por bloque

Cuando el usuario pida ayuda en un bloque específico, seguir este orden:

1. **Ecosistema/OS** → comandos PowerShell + evidencia recomendada (screenshots sugeridos)
2. **Hardening** → checklist CIS con T-SQL o PowerShell de verificación
3. **Modelo de datos** → DDL completo con esquemas, constraints, índices
4. **Funcionalidades 2025** → scripts T-SQL listos para ejecutar
5. **Seguridad** → scripts de roles, GRANT, DDM, RLS en orden correcto
6. **Azure** → pasos de deploy con Azure CLI o portal
7. **JSON** → query final con FOR JSON

---

## Convenciones de código para ProjectDB

```sql
-- Esquemas a usar (definir según mini-mundo)
-- Ejemplo: persona, ventas, producto, contabilidad, ref

-- Naming
-- Tablas:     PascalCase            → Cliente, Producto
-- Vistas:     vw_PascalCase         → vw_Cliente
-- Stored Proc: sp_PascalCase        → sp_ObtenerClientes
-- Índices:    IX_Tabla_Columna      → IX_Cliente_Email
-- PK:         PK_Tabla              → PK_Cliente
-- FK:         FK_TablaHijo_TablaPadre

-- Siempre usar esquemas explícitos
SELECT * FROM persona.Cliente;  -- no: SELECT * FROM Cliente
```

---

## Referencias clave

- CIS WS2025 Benchmark: aplicar Level 1 mínimo, Level 2 donde sea posible
- CIS SS2022 Benchmark v1.2.1: guía oficial del profesor para hardening SGBDR
- TLS 1.2: configurar via SQL Server Configuration Manager + registro de Windows
- TDE: habilitar antes de poblar datos
