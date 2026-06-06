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
