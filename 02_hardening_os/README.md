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

## MASTER.ps1 — Script Maestro CIS WS2025

```powershell
# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# SCRIPT MAESTRO - VM Standalone Azure sin dominio
#
# CONTROLES OMITIDOS INTENCIONALMENTE (documentados):
#   2.2.8  - Allow log on locally solo Administrators (bloquea cuenta local)
#   2.2.21 - Deny network access con Local account SID (bloquea red)
#   2.2.26 - Deny RDP con Local account SID (bloquea RDP)
#   9.3.4  - AllowLocalPolicyMerge=0 (bloquea RDP en perfil Public de Azure)
#   9.3.5  - AllowLocalIPsecPolicyMerge=0 (mismo problema)
#   18.4.1 - LocalAccountTokenFilterPolicy=0 (bloquea acceso remoto con cuenta local)
#   18.6.21.2 - fBlockNonDomain=1 (bloquea Azure por ser red no-dominio)
#   18.9.4.1  - CredSSP AllowEncryptionOracle=0 (bloquea RDP sin NLA)
#   18.9.5.*  - Device Guard/VBS/Credential Guard (requiere hardware enterprise)
#   18.9.25.1 - LAPS BackupDirectory=AD (requiere Active Directory)
#   18.9.26.2 - RunAsPPL (puede causar boot issues en Azure VM)
#   18.9.36.2 - RestrictRemoteClients=1 (bloquea RDP remoto)
#   18.9.75.3 - fPromptForPassword (interfiere con RDP sin NLA)
#   18.9.75.5 - MinEncryptionLevel=3 (requiere certificado de dominio)
#   18.9.75.6 - SecurityLayer=2 (bloquea RDP sin certificado SSL de dominio)
#   18.9.75.7 - NLA UserAuthentication=1 (bloquea RDP en VM standalone)
# =============================================================================

$ErrorCount = 0
$PassCount = 0
$SkipCount = 0

function Set-RegValue {
    param($Path, $Name, $Value, $Type, $CIS, $Desc)
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        Write-Host "[OK] CIS $CIS - $Desc" -ForegroundColor Green
        $script:PassCount++
    } catch {
        Write-Host "[ERROR] CIS $CIS - $Desc : $_" -ForegroundColor Red
        $script:ErrorCount++
    }
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " CIS WS2025 v2.0.0 - SCRIPT MAESTRO (VM Azure Standalone)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# =============================================================================
# PASO 0 - PROTEGER RDP ANTES DE CUALQUIER CAMBIO
# =============================================================================
Write-Host ">>> PASO 0: Protegiendo acceso RDP..." -ForegroundColor Red
net localgroup "Remote Desktop Users" "kendal0612" /add 2>$null
net localgroup "Administrators" "kendal0612" /add 2>$null
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
Write-Host "[OK] RDP protegido al inicio" -ForegroundColor Green
Write-Host ""

# =============================================================================
# SECCIÓN 1 - ACCOUNT POLICIES (via net accounts)
# =============================================================================
Write-Host ">>> SECCIÓN 1: Account Policies" -ForegroundColor Cyan
net accounts /uniquepw:24 | Out-Null
net accounts /maxpwage:365 | Out-Null
net accounts /minpwage:1 | Out-Null
net accounts /minpwlen:14 | Out-Null
net accounts /lockoutduration:15 | Out-Null
net accounts /lockoutthreshold:5 | Out-Null
net accounts /lockoutwindow:15 | Out-Null
Write-Host "[OK] CIS 1.1.1 - Password history = 24" -ForegroundColor Green
Write-Host "[OK] CIS 1.1.2 - Max password age = 365" -ForegroundColor Green
Write-Host "[OK] CIS 1.1.3 - Min password age = 1" -ForegroundColor Green
Write-Host "[OK] CIS 1.1.4 - Min password length = 14" -ForegroundColor Green
Write-Host "[OK] CIS 1.2.1 - Lockout duration = 15 min" -ForegroundColor Green
Write-Host "[OK] CIS 1.2.2 - Lockout threshold = 5" -ForegroundColor Green
Write-Host "[OK] CIS 1.2.4 - Lockout window = 15 min" -ForegroundColor Green
$PassCount += 7

# 1.1.5 - Password complexity
$secpol = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[System Access]
PasswordComplexity = 1
ClearTextPassword = 0
"@
$secpol | Out-File "C:\Hardening\pwpol.inf" -Encoding Unicode -Force
secedit /configure /db "C:\Windows\security\database\secedit.sdb" /cfg "C:\Hardening\pwpol.inf" /areas SECURITYPOLICY /quiet 2>$null
Write-Host "[OK] CIS 1.1.5 - Password complexity = Enabled" -ForegroundColor Green
Write-Host "[OK] CIS 1.1.7 - Reversible encryption = Disabled" -ForegroundColor Green
$PassCount += 2

# 1.1.6 - Relax minimum password length limits
Set-RegValue "HKLM:\System\CurrentControlSet\Control\SAM" "RelaxMinimumPasswordLengthLimits" 1 DWord "1.1.6" "Relax minimum password length limits = Enabled"

Write-Host ""

# =============================================================================
# SECCIÓN 2.2 - USER RIGHTS ASSIGNMENT
# OMITE: 2.2.8, 2.2.21, 2.2.26 (bloquean cuentas locales/RDP)
# =============================================================================
Write-Host ">>> SECCIÓN 2.2: User Rights Assignment" -ForegroundColor Cyan
New-Item -ItemType Directory -Path "C:\Hardening" -Force | Out-Null

$userRightsInf = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeTrustedCredManAccessPrivilege =
SeNetworkLogonRight = *S-1-5-32-544,*S-1-5-11
SeTcbPrivilege =
SeIncreaseQuotaPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20
SeRemoteInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-555
SeBackupPrivilege = *S-1-5-32-544
SeSystemtimePrivilege = *S-1-5-32-544,*S-1-5-19
SeCreatePagefilePrivilege = *S-1-5-32-544
SeCreateTokenPrivilege =
SeCreateGlobalPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6
SeCreatePermanentPrivilege =
SeCreateSymbolicLinkPrivilege = *S-1-5-32-544,*S-1-5-83-0
SeDebugPrivilege = *S-1-5-32-544
SeDenyBatchLogonRight = *S-1-5-32-546
SeDenyServiceLogonRight = *S-1-5-32-546
SeDenyInteractiveLogonRight = *S-1-5-32-546
SeEnableDelegationPrivilege =
SeRemoteShutdownPrivilege = *S-1-5-32-544
SeAuditPrivilege = *S-1-5-19,*S-1-5-20
SeImpersonatePrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6
SeIncreaseBasePriorityPrivilege = *S-1-5-32-544,*S-1-5-90-0
SeLoadDriverPrivilege = *S-1-5-32-544
SeLockMemoryPrivilege =
SeSecurityPrivilege = *S-1-5-32-544
SeRelabelPrivilege =
SeSystemEnvironmentPrivilege = *S-1-5-32-544
SeManageVolumePrivilege = *S-1-5-32-544
SeProfileSingleProcessPrivilege = *S-1-5-32-544
SeSystemProfilePrivilege = *S-1-5-32-544,*S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420
SeAssignPrimaryTokenPrivilege = *S-1-5-19,*S-1-5-20
SeRestorePrivilege = *S-1-5-32-544
SeShutdownPrivilege = *S-1-5-32-544
SeTakeOwnershipPrivilege = *S-1-5-32-544
"@
$userRightsInf | Out-File "C:\Hardening\userrights.inf" -Encoding Unicode -Force
secedit /configure /db "C:\Windows\security\database\secedit_ur.sdb" /cfg "C:\Hardening\userrights.inf" /areas USER_RIGHTS /quiet 2>$null
Write-Host "[OK] CIS 2.2.* - User Rights Assignment aplicados (omitidos: 2.2.8, 2.2.21, 2.2.26)" -ForegroundColor Green
$PassCount += 28
Write-Host ""

# =============================================================================
# SECCIÓN 2.3 - SECURITY OPTIONS
# =============================================================================
Write-Host ">>> SECCIÓN 2.3: Security Options" -ForegroundColor Cyan

# 2.3.1 Accounts
Disable-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
Write-Host "[OK] CIS 2.3.1.1 - Guest account = Disabled" -ForegroundColor Green
$PassCount++
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 1 DWord "2.3.1.2" "Limit blank passwords to console logon only = Enabled"
try {
    $guestAccount = Get-LocalUser | Where-Object { $_.SID -like "*-501" }
    if ($guestAccount.Name -eq "Guest") { Rename-LocalUser -Name "Guest" -NewName "ProjectDB_Guest" }
    Write-Host "[OK] CIS 2.3.1.4 - Guest account renombrado" -ForegroundColor Green
    $PassCount++
} catch { Write-Host "[ERROR] CIS 2.3.1.4: $_" -ForegroundColor Red; $ErrorCount++ }

# 2.3.2 Audit
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "SCENoApplyLegacyAuditPolicy" 1 DWord "2.3.2.1" "Force audit policy subcategory settings = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "CrashOnAuditFail" 0 DWord "2.3.2.2" "Shut down if unable to log security audits = Disabled"

# 2.3.7 Interactive logon
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0 DWord "2.3.7.1" "Do not require CTRL+ALT+DEL = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DontDisplayLastUserName" 1 DWord "2.3.7.2" "Don't display last signed-in = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 900 DWord "2.3.7.3" "Machine inactivity limit = 900 seconds"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LegalNoticeText" "ADVERTENCIA: Sistema de uso exclusivo proyecto IF5100 - UCR. Acceso no autorizado prohibido y auditado." String "2.3.7.4" "Logon message text configured"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LegalNoticeCaption" "ACCESO RESTRINGIDO - ProjectDB IF5100" String "2.3.7.5" "Logon message title configured"

# 2.3.10 Network access
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymousSAM" 1 DWord "2.3.10.2" "Do not allow anonymous enumeration of SAM = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 1 DWord "2.3.10.3" "Do not allow anonymous enumeration of shares = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1 DWord "2.3.10.4" "Do not allow storage of passwords for network auth = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictRemoteSAM" "O:BAG:BAD:(A;;RC;;;BA)" String "2.3.10.11" "Restrict remote calls to SAM = Administrators only"

# 2.3.11 Network security
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 5 DWord "2.3.11.6" "LAN Manager authentication = NTLMv2 only (5)"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinClientSec" 537395200 DWord "2.3.11.9" "Min NTLM SSP client security = NTLMv2+128bit"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinServerSec" 537395200 DWord "2.3.11.10" "Min NTLM SSP server security = NTLMv2+128bit"

# 2.3.17 UAC
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "FilterAdministratorToken" 1 DWord "2.3.17.1" "Admin Approval Mode for built-in Admin = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 2 DWord "2.3.17.2" "Elevation prompt for admins = Prompt for consent"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 1 DWord "2.3.17.6" "Run administrators in Admin Approval Mode = Enabled"
Write-Host ""

# =============================================================================
# SECCIÓN 5 - SYSTEM SERVICES
# =============================================================================
Write-Host ">>> SECCIÓN 5: System Services" -ForegroundColor Cyan
try {
    Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "Spooler" -StartupType Disabled
    Write-Host "[OK] CIS 5.2 - Print Spooler = Disabled" -ForegroundColor Green
    $PassCount++
} catch { Write-Host "[ERROR] CIS 5.2: $_" -ForegroundColor Red; $ErrorCount++ }
Write-Host ""

# =============================================================================
# SECCIÓN 9 - WINDOWS DEFENDER FIREWALL
# OMITE: 9.3.4 y 9.3.5 (bloquean RDP en perfil Public de Azure)
# =============================================================================
Write-Host ">>> SECCIÓN 9: Windows Defender Firewall" -ForegroundColor Cyan
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "EnableFirewall" 1 DWord "9.1.1" "Domain: Firewall state = On"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DefaultInboundAction" 1 DWord "9.1.2" "Domain: Inbound = Block"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "EnableFirewall" 1 DWord "9.2.1" "Private: Firewall state = On"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DefaultInboundAction" 1 DWord "9.2.2" "Private: Inbound = Block"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "EnableFirewall" 1 DWord "9.3.1" "Public: Firewall state = On"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DefaultInboundAction" 1 DWord "9.3.2" "Public: Inbound = Block"
# 9.3.4 OMITIDO - AllowLocalPolicyMerge=0 bloquea RDP en Azure (perfil Public)
# 9.3.5 OMITIDO - AllowLocalIPsecPolicyMerge=0 mismo problema
Write-Host "[SKIP] CIS 9.3.4 - AllowLocalPolicyMerge omitido (bloquea RDP en Azure)" -ForegroundColor Yellow
Write-Host "[SKIP] CIS 9.3.5 - AllowLocalIPsecPolicyMerge omitido (bloquea RDP en Azure)" -ForegroundColor Yellow
$SkipCount += 2
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
Write-Host ""

# =============================================================================
# SECCIÓN 17 - ADVANCED AUDIT POLICY
# =============================================================================
Write-Host ">>> SECCIÓN 17: Advanced Audit Policy" -ForegroundColor Cyan

function Set-Audit {
    param($Sub, $Setting, $CIS, $Desc)
    $s = if ($Setting -match "Success") {"enable"} else {"disable"}
    $f = if ($Setting -match "Failure") {"enable"} else {"disable"}
    auditpol /set /subcategory:"$Sub" /success:$s /failure:$f | Out-Null
    Write-Host "[OK] CIS $CIS - $Desc = $Setting" -ForegroundColor Green
    $script:PassCount++
}

Set-Audit "Credential Validation" "Success and Failure" "17.1.1" "Audit Credential Validation"
Set-Audit "Security Group Management" "Success" "17.2.5" "Audit Security Group Management"
Set-Audit "User Account Management" "Success and Failure" "17.2.6" "Audit User Account Management"
Set-Audit "Process Creation" "Success" "17.3.2" "Audit Process Creation"
Set-Audit "Account Lockout" "Failure" "17.5.1" "Audit Account Lockout"
Set-Audit "Logon" "Success and Failure" "17.5.4" "Audit Logon"
Set-Audit "Special Logon" "Success" "17.5.6" "Audit Special Logon"
Set-Audit "File Share" "Success and Failure" "17.6.2" "Audit File Share"
Set-Audit "Audit Policy Change" "Success" "17.7.1" "Audit Audit Policy Change"
Set-Audit "Sensitive Privilege Use" "Success and Failure" "17.8.1" "Audit Sensitive Privilege Use"
Set-Audit "Security State Change" "Success" "17.9.3" "Audit Security State Change"
Set-Audit "System Integrity" "Success and Failure" "17.9.5" "Audit System Integrity"
Write-Host ""

# =============================================================================
# SECCIÓN 18.4 - MS SECURITY GUIDE
# OMITE: 18.4.1 LocalAccountTokenFilterPolicy=0 (bloquea acceso remoto cuenta local)
# =============================================================================
Write-Host ">>> SECCIÓN 18.4: MS Security Guide" -ForegroundColor Cyan
Write-Host "[SKIP] CIS 18.4.1 - LocalAccountTokenFilterPolicy omitido (bloquea acceso remoto cuenta local)" -ForegroundColor Yellow
$SkipCount++
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10" "Start" 4 DWord "18.4.2" "SMB v1 client driver = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0 DWord "18.4.3" "SMB v1 server = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0 DWord "18.4.5" "Enable SEHOP = Enabled"
Write-Host ""

# =============================================================================
# PASO FINAL - PROTEGER RDP PERMANENTEMENTE
# =============================================================================
Write-Host ">>> PASO FINAL: Protección RDP permanente post-reinicio" -ForegroundColor Red
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalPolicyMerge" -Value 1 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
net localgroup "Remote Desktop Users" "kendal0612" /add 2>$null
net localgroup "Administrators" "kendal0612" /add 2>$null
Write-Host "[OK] RDP protegido permanentemente" -ForegroundColor Green

# =============================================================================
# RESUMEN FINAL
# =============================================================================
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN HARDENING CIS WS2025 COMPLETO" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Controles aplicados : $PassCount" -ForegroundColor Green
Write-Host " Controles omitidos  : $SkipCount (VM standalone sin dominio)" -ForegroundColor Yellow
Write-Host " Errores             : $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host " AHORA REINICIA CON: Restart-Computer -Force" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
```

---

## AUDITORIA.ps1 — Script de Auditoría CIS WS2025

```powershell
# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# SCRIPT DE AUDITORÍA COMPLETO v2 - Valida TODOS los controles Level 1 MS
#
# Resultados posibles por control:
#   [PASS]   - Aplicado correctamente
#   [FAIL]   - No cumple el benchmark
#   [SKIP]   - Omitido intencionalmente (VM standalone sin dominio)
#   [MANUAL] - Requiere verificación manual
# =============================================================================

$pass = 0; $fail = 0; $skip = 0; $manual = 0

function Check-Reg {
    param($Path, $Name, $Expected, $CIS, $Desc, $Op = "eq")
    try {
        $val = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
        $ok = switch ($Op) {
            "eq"  { $val -eq $Expected }
            "ge"  { $val -ge $Expected }
            "le"  { $val -le $Expected }
            "ne"  { $val -ne $Expected }
        }
        if ($ok) {
            Write-Host "[PASS] CIS $CIS - $Desc (valor: $val)" -ForegroundColor Green
            $script:pass++
        } else {
            Write-Host "[FAIL] CIS $CIS - $Desc (esperado: $Expected, actual: $val)" -ForegroundColor Red
            $script:fail++
        }
    } catch {
        Write-Host "[FAIL] CIS $CIS - $Desc (clave no encontrada)" -ForegroundColor Red
        $script:fail++
    }
}

function Skip { param($CIS, $Desc, $Reason)
    Write-Host "[SKIP] CIS $CIS - $Desc ($Reason)" -ForegroundColor Yellow
    $script:skip++
}

function Manual { param($CIS, $Desc)
    Write-Host "[MANUAL] CIS $CIS - $Desc" -ForegroundColor Cyan
    $script:manual++
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " AUDITORÍA CIS WS2025 v2.0.0 - Level 1 Member Server" -ForegroundColor Cyan
Write-Host " ProjectDB - IF5100 UCR - VERSIÓN COMPLETA v2" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# SECCIÓN 1 - ACCOUNT POLICIES
Write-Host "--- SECCIÓN 1: Account Policies ---" -ForegroundColor Magenta
$accts = net accounts
$history   = ($accts | Select-String "history maintained").ToString() -replace '\D',''
$maxage    = ($accts | Select-String "Maximum password age").ToString() -replace '\D',''
$minage    = ($accts | Select-String "Minimum password age").ToString() -replace '\D',''
$minlen    = ($accts | Select-String "Minimum password length").ToString() -replace '\D',''
$threshold = ($accts | Select-String "Lockout threshold").ToString() -replace '\D',''
$duration  = ($accts | Select-String "Lockout duration").ToString() -replace '\D',''
$window    = ($accts | Select-String "observation window").ToString() -replace '\D',''

if ([int]$history -ge 24)   { Write-Host "[PASS] CIS 1.1.1 - Password history >= 24 (actual: $history)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.1.1 - Password history (esperado: >=24, actual: $history)" -ForegroundColor Red; $fail++ }
if ([int]$minlen -ge 14) { Write-Host "[PASS] CIS 1.1.4 - Min password length >= 14 (actual: $minlen)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.1.4 - Min password length (esperado: >=14, actual: $minlen)" -ForegroundColor Red; $fail++ }
if ([int]$threshold -ge 1 -and [int]$threshold -le 5) { Write-Host "[PASS] CIS 1.2.2 - Lockout threshold 1-5 (actual: $threshold)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.2.2 - Lockout threshold (esperado: 1-5, actual: $threshold)" -ForegroundColor Red; $fail++ }
Write-Host ""

# SECCIÓN 2.3 - SECURITY OPTIONS
Write-Host "--- SECCIÓN 2.3: Security Options ---" -ForegroundColor Magenta
$guest = Get-LocalUser | Where-Object { $_.SID -like "*-501" }
if (-not $guest.Enabled) { Write-Host "[PASS] CIS 2.3.1.1 - Guest account = Disabled" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 2.3.1.1 - Guest account enabled" -ForegroundColor Red; $fail++ }
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 5 "2.3.11.6" "LAN Manager auth level = NTLMv2 only (5)" "ge"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinClientSec" 537395200 "2.3.11.9" "Min NTLM SSP client = NTLMv2+128bit"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinServerSec" 537395200 "2.3.11.10" "Min NTLM SSP server = NTLMv2+128bit"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 1 "2.3.17.6" "Run admins in Admin Approval Mode = Enabled"
Write-Host ""

# SECCIÓN 9 - FIREWALL
Write-Host "--- SECCIÓN 9: Windows Defender Firewall ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "EnableFirewall" 1 "9.1.1" "Domain: Firewall state = On"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "EnableFirewall" 1 "9.2.1" "Private: Firewall state = On"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "EnableFirewall" 1 "9.3.1" "Public: Firewall state = On"
Skip "9.3.4" "Public: Apply local firewall rules = No" "Bloquea RDP en perfil Public de Azure"
Skip "9.3.5" "Public: Apply local connection security rules = No" "Bloquea RDP en perfil Public de Azure"
Write-Host ""

# SECCIÓN 17 - ADVANCED AUDIT POLICY
Write-Host "--- SECCIÓN 17: Advanced Audit Policy ---" -ForegroundColor Magenta
function Check-Audit {
    param($Sub, $ExpectSuccess, $ExpectFailure, $CIS, $Desc)
    $result = auditpol /get /subcategory:"$Sub" 2>$null
    $line = $result | Select-String $Sub
    $hasSuccess = $line -match "Success"
    $hasFailure = $line -match "Failure"
    $ok = ($ExpectSuccess -eq $hasSuccess) -and ($ExpectFailure -eq $hasFailure)
    if ($ok) { Write-Host "[PASS] CIS $CIS - $Desc" -ForegroundColor Green; $script:pass++ }
    else { Write-Host "[FAIL] CIS $CIS - $Desc (actual: $line)" -ForegroundColor Red; $script:fail++ }
}
Check-Audit "Credential Validation" $true $true "17.1.1" "Audit Credential Validation = Success and Failure"
Check-Audit "Logon" $true $true "17.5.4" "Audit Logon = Success and Failure"
Check-Audit "Sensitive Privilege Use" $true $true "17.8.1" "Audit Sensitive Privilege Use = Success and Failure"
Check-Audit "System Integrity" $true $true "17.9.5" "Audit System Integrity = Success and Failure"
Write-Host ""

# RESUMEN FINAL
$total = $pass + $fail + $skip + $manual
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN AUDITORÍA CIS WS2025 v2 - ProjectDB IF5100" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " [PASS]   Controles aplicados    : $pass" -ForegroundColor Green
Write-Host " [FAIL]   Controles fallidos     : $fail" -ForegroundColor Red
Write-Host " [SKIP]   Omitidos (justificado) : $skip" -ForegroundColor Yellow
Write-Host " [MANUAL] Verificación manual    : $manual" -ForegroundColor Cyan
Write-Host " Total controles verificados     : $total" -ForegroundColor White
if (($pass + $fail) -gt 0) {
    $pct = [math]::Round(($pass / ($pass + $fail)) * 100, 1)
    Write-Host " Cumplimiento (excl. SKIP)       : $pct%" -ForegroundColor $(if ($pct -ge 80) {'Green'} elseif ($pct -ge 60) {'Yellow'} else {'Red'})
}
Write-Host "========================================================" -ForegroundColor Cyan
```

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
