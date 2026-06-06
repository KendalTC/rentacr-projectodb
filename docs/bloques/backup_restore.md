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
