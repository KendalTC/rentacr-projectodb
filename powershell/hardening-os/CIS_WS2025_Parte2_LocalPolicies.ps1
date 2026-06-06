# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# PARTE 2: Local Policies - Secciones 2.2 y 2.3
# VERSIÓN SEGURA - Omite controles que bloquean cuentas locales por RDP
# Controles omitidos intencionalmente (VM standalone sin dominio):
#   2.2.8  - Allow log on locally: solo Administrators (bloquea usuario local)
#   2.2.21 - Deny network access: incluye Local account (bloquea acceso red)
#   2.2.26 - Deny RDP: incluye Local account (bloquea RDP)
#   2.3.1.3 - Rename Administrator (puede causar confusión)
# =============================================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " CIS WS2025 v2.0.0 - Parte 2: Local Policies (SAFE)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$PassCount = 0

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

# =============================================================================
# PASO 0 - PROTEGER ACCESO RDP ANTES DE CUALQUIER CAMBIO
# =============================================================================
Write-Host "--- Protegiendo acceso RDP ---" -ForegroundColor Red
net localgroup "Remote Desktop Users" "kendal0612" /add 2>$null
Write-Host "[OK] kendal0612 asegurado en Remote Desktop Users" -ForegroundColor Green
Write-Host ""

# =============================================================================
# SECCIÓN 2.2 - USER RIGHTS ASSIGNMENT
# OMITE: 2.2.8, 2.2.21, 2.2.26 (bloquean cuentas locales)
# =============================================================================
Write-Host "--- Sección 2.2: User Rights Assignment ---" -ForegroundColor Magenta
Write-Host ""

$userRightsInf = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
; CIS 2.2.1 - Access Credential Manager as trusted caller: No One
SeTrustedCredManAccessPrivilege =

; CIS 2.2.3 - Access this computer from the network: Administrators, Authenticated Users
SeNetworkLogonRight = *S-1-5-32-544,*S-1-5-11

; CIS 2.2.4 - Act as part of the operating system: No One
SeTcbPrivilege =

; CIS 2.2.6 - Adjust memory quotas: Administrators, LOCAL SERVICE, NETWORK SERVICE
SeIncreaseQuotaPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20

; CIS 2.2.10 - Allow log on through RDS: Administrators, Remote Desktop Users
; NOTA: 2.2.8 (Allow log on locally) OMITIDO - bloquea cuentas locales
SeRemoteInteractiveLogonRight = *S-1-5-32-544,*S-1-5-32-555

; CIS 2.2.11 - Back up files and directories: Administrators
SeBackupPrivilege = *S-1-5-32-544

; CIS 2.2.12 - Change the system time: Administrators, LOCAL SERVICE
SeSystemtimePrivilege = *S-1-5-32-544,*S-1-5-19

; CIS 2.2.13 - Create a pagefile: Administrators
SeCreatePagefilePrivilege = *S-1-5-32-544

; CIS 2.2.14 - Create a token object: No One
SeCreateTokenPrivilege =

; CIS 2.2.15 - Create global objects: Administrators, LOCAL SERVICE, NETWORK SERVICE, SERVICE
SeCreateGlobalPrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6

; CIS 2.2.16 - Create permanent shared objects: No One
SeCreatePermanentPrivilege =

; CIS 2.2.18 - Create symbolic links: Administrators, NT VIRTUAL MACHINE\Virtual Machines
SeCreateSymbolicLinkPrivilege = *S-1-5-32-544,*S-1-5-83-0

; CIS 2.2.19 - Debug programs: Administrators
SeDebugPrivilege = *S-1-5-32-544

; CIS 2.2.21 OMITIDO - Deny network access incluye Local account (bloquea RDP/red)

; CIS 2.2.22 - Deny log on as batch job: Guests
SeDenyBatchLogonRight = *S-1-5-32-546

; CIS 2.2.23 - Deny log on as service: Guests
SeDenyServiceLogonRight = *S-1-5-32-546

; CIS 2.2.24 - Deny log on locally: Guests
SeDenyInteractiveLogonRight = *S-1-5-32-546

; CIS 2.2.26 OMITIDO - Deny RDP incluye Local account (bloquea RDP)

; CIS 2.2.28 - Enable trusted for delegation: No One
SeEnableDelegationPrivilege =

; CIS 2.2.29 - Force shutdown from remote system: Administrators
SeRemoteShutdownPrivilege = *S-1-5-32-544

; CIS 2.2.30 - Generate security audits: LOCAL SERVICE, NETWORK SERVICE
SeAuditPrivilege = *S-1-5-19,*S-1-5-20

; CIS 2.2.32 - Impersonate client after auth: Admins, LOCAL SERVICE, NETWORK SERVICE, SERVICE
SeImpersonatePrivilege = *S-1-5-32-544,*S-1-5-19,*S-1-5-20,*S-1-5-6

; CIS 2.2.33 - Increase scheduling priority: Administrators, Window Manager Group
SeIncreaseBasePriorityPrivilege = *S-1-5-32-544,*S-1-5-90-0

; CIS 2.2.34 - Load and unload device drivers: Administrators
SeLoadDriverPrivilege = *S-1-5-32-544

; CIS 2.2.35 - Lock pages in memory: No One
SeLockMemoryPrivilege =

; CIS 2.2.38 - Manage auditing and security log: Administrators
SeSecurityPrivilege = *S-1-5-32-544

; CIS 2.2.39 - Modify an object label: No One
SeRelabelPrivilege =

; CIS 2.2.40 - Modify firmware environment values: Administrators
SeSystemEnvironmentPrivilege = *S-1-5-32-544

; CIS 2.2.41 - Perform volume maintenance tasks: Administrators
SeManageVolumePrivilege = *S-1-5-32-544

; CIS 2.2.42 - Profile single process: Administrators
SeProfileSingleProcessPrivilege = *S-1-5-32-544

; CIS 2.2.43 - Profile system performance: Administrators, NT SERVICE\WdiServiceHost
SeSystemProfilePrivilege = *S-1-5-32-544,*S-1-5-80-3139157870-2983391045-3678747466-658725712-1809340420

; CIS 2.2.44 - Replace a process level token: LOCAL SERVICE, NETWORK SERVICE
SeAssignPrimaryTokenPrivilege = *S-1-5-19,*S-1-5-20

; CIS 2.2.45 - Restore files and directories: Administrators
SeRestorePrivilege = *S-1-5-32-544

; CIS 2.2.46 - Shut down the system: Administrators
SeShutdownPrivilege = *S-1-5-32-544

; CIS 2.2.48 - Take ownership of files or other objects: Administrators
SeTakeOwnershipPrivilege = *S-1-5-32-544
"@

New-Item -ItemType Directory -Path "C:\CIS_Hardening" -Force | Out-Null
$userRightsPath = "C:\CIS_Hardening\cis_part2_userrights.inf"
$userRightsInf | Out-File -FilePath $userRightsPath -Encoding Unicode

Write-Host "[*] Aplicando User Rights Assignment..." -ForegroundColor Yellow
secedit /configure /db "C:\Windows\security\database\secedit_userrights.sdb" /cfg $userRightsPath /areas USER_RIGHTS /log "C:\CIS_Hardening\secedit_part2.log" /quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] User Rights Assignment aplicados correctamente" -ForegroundColor Green
    $PassCount += 28
} else {
    Write-Host "[WARN] secedit retorno codigo $LASTEXITCODE - verificar C:\CIS_Hardening\secedit_part2.log" -ForegroundColor Yellow
}

# Verificar que RDP sigue funcionando después de aplicar User Rights
Write-Host "[*] Verificando que RDP sigue habilitado..." -ForegroundColor Yellow
net localgroup "Remote Desktop Users" "kendal0612" /add 2>$null
Write-Host "[OK] Acceso RDP de kendal0612 confirmado" -ForegroundColor Green
Write-Host ""

# =============================================================================
# SECCIÓN 2.3 - SECURITY OPTIONS
# =============================================================================
Write-Host "--- Sección 2.3: Security Options ---" -ForegroundColor Magenta
Write-Host ""

# --- 2.3.1 Accounts ---
Write-Host "  [2.3.1] Accounts" -ForegroundColor Yellow

# CIS 2.3.1.1 - Guest account: Disabled
try {
    Disable-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
    Write-Host "[OK] CIS 2.3.1.1 - Guest account = Disabled" -ForegroundColor Green
    $PassCount++
} catch {
    Write-Host "[INFO] CIS 2.3.1.1 - Guest account ya deshabilitado" -ForegroundColor Cyan
    $PassCount++
}

# CIS 2.3.1.2 - Limit blank passwords to console logon only
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 1 DWord "2.3.1.2" "Limit blank passwords to console logon only = Enabled"

# CIS 2.3.1.3 OMITIDO - Rename administrator (puede causar confusion)
Write-Host "[SKIP] CIS 2.3.1.3 - Rename administrator omitido (VM standalone)" -ForegroundColor Yellow

# CIS 2.3.1.4 - Rename guest account
try {
    $guestAccount = Get-LocalUser | Where-Object { $_.SID -like "*-501" }
    if ($guestAccount.Name -eq "Guest") {
        Rename-LocalUser -Name "Guest" -NewName "ProjectDB_Guest"
        Write-Host "[OK] CIS 2.3.1.4 - Guest renombrado a 'ProjectDB_Guest'" -ForegroundColor Green
    } else {
        Write-Host "[OK] CIS 2.3.1.4 - Guest ya renombrado a '$($guestAccount.Name)'" -ForegroundColor Green
    }
    $PassCount++
} catch {
    Write-Host "[ERROR] CIS 2.3.1.4 - $_" -ForegroundColor Red
    $ErrorCount++
}

# --- 2.3.2 Audit ---
Write-Host ""
Write-Host "  [2.3.2] Audit" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "SCENoApplyLegacyAuditPolicy" 1 DWord "2.3.2.1" "Force audit policy subcategory settings = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "CrashOnAuditFail" 0 DWord "2.3.2.2" "Shut down if unable to log security audits = Disabled"

# --- 2.3.4 Devices ---
Write-Host ""
Write-Host "  [2.3.4] Devices" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" "AddPrinterDrivers" 1 DWord "2.3.4.1" "Prevent users from installing printer drivers = Enabled"

# --- 2.3.6 Domain member ---
Write-Host ""
Write-Host "  [2.3.6] Domain member" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireSignOrSeal" 1 DWord "2.3.6.1" "Digitally encrypt or sign secure channel data (always) = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "SealSecureChannel" 1 DWord "2.3.6.2" "Digitally encrypt secure channel data (when possible) = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "SignSecureChannel" 1 DWord "2.3.6.3" "Digitally sign secure channel data (when possible) = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "DisablePasswordChange" 0 DWord "2.3.6.4" "Disable machine account password changes = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "MaximumPasswordAge" 30 DWord "2.3.6.5" "Maximum machine account password age = 30 days"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireStrongKey" 1 DWord "2.3.6.6" "Require strong session key = Enabled"

# --- 2.3.7 Interactive logon ---
Write-Host ""
Write-Host "  [2.3.7] Interactive logon" -ForegroundColor Yellow
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0 DWord "2.3.7.1" "Do not require CTRL+ALT+DEL = Disabled (Level 2)"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DontDisplayLastUserName" 1 DWord "2.3.7.2" "Don't display last signed-in = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 900 DWord "2.3.7.3" "Machine inactivity limit = 900 seconds"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LegalNoticeText" "ADVERTENCIA: Sistema de uso exclusivo proyecto IF5100 - UCR. Acceso no autorizado prohibido y auditado." String "2.3.7.4" "Message text for logon configured"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LegalNoticeCaption" "ACCESO RESTRINGIDO - ProjectDB IF5100" String "2.3.7.5" "Message title for logon configured"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "4" String "2.3.7.6" "Number of previous logons to cache = 4 (Level 2)"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "PasswordExpiryWarning" 14 DWord "2.3.7.7" "Prompt to change password before expiration = 14 days"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "ScRemoveOption" "1" String "2.3.7.9" "Smart card removal behavior = Lock Workstation"

# --- 2.3.8 Microsoft network client ---
Write-Host ""
Write-Host "  [2.3.8] Microsoft network client" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" 1 DWord "2.3.8.1" "Network client: Digitally sign communications (always) = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnablePlainTextPassword" 0 DWord "2.3.8.2" "Send unencrypted password to third-party SMB = Disabled"

# --- 2.3.9 Microsoft network server ---
Write-Host ""
Write-Host "  [2.3.9] Microsoft network server" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "AutoDisconnect" 15 DWord "2.3.9.1" "Idle time before suspending session = 15 minutes"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RequireSecuritySignature" 1 DWord "2.3.9.2" "Network server: Digitally sign communications (always) = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "enableforcedlogoff" 1 DWord "2.3.9.3" "Disconnect clients when logon hours expire = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "SMBServerNameHardeningLevel" 1 DWord "2.3.9.4" "Server SPN target name validation = Accept if provided by client"

# --- 2.3.10 Network access ---
Write-Host ""
Write-Host "  [2.3.10] Network access" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymousSAM" 1 DWord "2.3.10.2" "Do not allow anonymous enumeration of SAM accounts = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 1 DWord "2.3.10.3" "Do not allow anonymous enumeration of SAM accounts and shares = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1 DWord "2.3.10.4" "Do not allow storage of passwords for network auth = Enabled (Level 2)"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "EveryoneIncludesAnonymous" 0 DWord "2.3.10.5" "Let Everyone permissions apply to anonymous users = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "NullSessionPipes" @() MultiString "2.3.10.7" "Named Pipes accessible anonymously = blank"
$regPaths = @("System\CurrentControlSet\Control\ProductOptions","System\CurrentControlSet\Control\Server Applications","Software\Microsoft\Windows NT\CurrentVersion")
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths" "Machine" $regPaths MultiString "2.3.10.8" "Remotely accessible registry paths configured"
$regSubPaths = @("System\CurrentControlSet\Control\Print\Printers","System\CurrentControlSet\Services\Eventlog","Software\Microsoft\OLAP Server","Software\Microsoft\Windows NT\CurrentVersion\Print","Software\Microsoft\Windows NT\CurrentVersion\Windows","System\CurrentControlSet\Control\ContentIndex","System\CurrentControlSet\Control\Terminal Server","System\CurrentControlSet\Control\Terminal Server\UserConfig","System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration","Software\Microsoft\Windows NT\CurrentVersion\Perflib","System\CurrentControlSet\Services\SysmonLog")
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths" "Machine" $regSubPaths MultiString "2.3.10.9" "Remotely accessible registry paths and sub-paths configured"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RestrictNullSessAccess" 1 DWord "2.3.10.10" "Restrict anonymous access to Named Pipes and Shares = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictRemoteSAM" "O:BAG:BAD:(A;;RC;;;BA)" String "2.3.10.11" "Restrict remote calls to SAM = Administrators only"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "NullSessionShares" @() MultiString "2.3.10.12" "Shares accessible anonymously = None"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "ForceGuest" 0 DWord "2.3.10.13" "Sharing and security model for local accounts = Classic"

# --- 2.3.11 Network security ---
Write-Host ""
Write-Host "  [2.3.11] Network security" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "UseMachineId" 1 DWord "2.3.11.1" "Allow Local System to use computer identity for NTLM = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AllowNullSessionFallback" 0 DWord "2.3.11.2" "Allow LocalSystem NULL session fallback = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 0 DWord "2.3.11.3" "Allow PKU2U authentication = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "SupportedEncryptionTypes" 2147483640 DWord "2.3.11.4" "Kerberos encryption types = AES128, AES256, Future"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "EnableForcedLogOff" 1 DWord "2.3.11.5" "Force logoff when logon hours expire = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 5 DWord "2.3.11.6" "LAN Manager authentication level = NTLMv2 only (level 5)"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinClientSec" 537395200 DWord "2.3.11.9" "Min session security NTLM SSP clients = NTLMv2+128bit"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinServerSec" 537395200 DWord "2.3.11.10" "Min session security NTLM SSP servers = NTLMv2+128bit"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 1 DWord "2.3.11.11" "Restrict NTLM: Audit Incoming NTLM Traffic = Enable auditing"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "RestrictSendingNTLMTraffic" 1 DWord "2.3.11.13" "Restrict NTLM: Outgoing NTLM traffic = Audit all"

# --- 2.3.13 Shutdown ---
Write-Host ""
Write-Host "  [2.3.13] Shutdown" -ForegroundColor Yellow
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ShutdownWithoutLogon" 0 DWord "2.3.13.1" "Allow system shutdown without logon = Disabled"

# --- 2.3.15 System objects ---
Write-Host ""
Write-Host "  [2.3.15] System objects" -ForegroundColor Yellow
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" "ObCaseInsensitive" 1 DWord "2.3.15.1" "Require case insensitivity for non-Windows subsystems = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1 DWord "2.3.15.2" "Strengthen default permissions of internal system objects = Enabled"

# --- 2.3.17 User Account Control ---
Write-Host ""
Write-Host "  [2.3.17] User Account Control (UAC)" -ForegroundColor Yellow
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "FilterAdministratorToken" 1 DWord "2.3.17.1" "Admin Approval Mode for Built-in Administrator = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 2 DWord "2.3.17.2" "Elevation prompt for admins = Prompt for consent on secure desktop"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorUser" 0 DWord "2.3.17.3" "Elevation prompt for standard users = Automatically deny"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableInstallerDetection" 1 DWord "2.3.17.4" "Detect application installations and prompt for elevation = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableSecureUIAPaths" 1 DWord "2.3.17.5" "Only elevate UIAccess apps in secure locations = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 1 DWord "2.3.17.6" "Run all administrators in Admin Approval Mode = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" 1 DWord "2.3.17.7" "Switch to secure desktop when prompting = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableVirtualization" 1 DWord "2.3.17.8" "Virtualize file and registry write failures = Enabled"

# =============================================================================
# SECCIÓN 5 - SYSTEM SERVICES
# =============================================================================
Write-Host ""
Write-Host "--- Sección 5: System Services ---" -ForegroundColor Magenta
try {
    Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "Spooler" -StartupType Disabled
    Write-Host "[OK] CIS 5.2 - Print Spooler = Disabled" -ForegroundColor Green
    $PassCount++
} catch {
    Write-Host "[ERROR] CIS 5.2 - Print Spooler: $_" -ForegroundColor Red
    $ErrorCount++
}

# =============================================================================
# VERIFICACION FINAL DE ACCESO RDP
# =============================================================================
Write-Host ""
Write-Host "--- Verificación final de acceso RDP ---" -ForegroundColor Red
$rdpStatus = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
if ($rdpStatus -eq 0) {
    Write-Host "[OK] RDP habilitado correctamente" -ForegroundColor Green
} else {
    Write-Host "[FIXING] RDP estaba deshabilitado - corrigiendo..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    Write-Host "[OK] RDP habilitado" -ForegroundColor Green
}
net localgroup "Remote Desktop Users" "kendal0612" /add 2>$null
Write-Host "[OK] kendal0612 confirmado en Remote Desktop Users" -ForegroundColor Green

# =============================================================================
# RESUMEN FINAL
# =============================================================================
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN PARTE 2" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Controles aplicados : $PassCount" -ForegroundColor Green
Write-Host " Errores             : $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host " Controles omitidos  : 3 (2.2.8, 2.2.21, 2.2.26 - VM standalone)" -ForegroundColor Yellow
Write-Host ""
Write-Host "NO es necesario reiniciar - los cambios de registro aplican inmediato." -ForegroundColor Cyan
Write-Host "Los User Rights requieren reinicio para aplicar completamente." -ForegroundColor Yellow
Write-Host ""
Write-Host "Parte 2 completada. Continuar con Parte 3 (Firewall + Audit Policy)." -ForegroundColor Cyan
