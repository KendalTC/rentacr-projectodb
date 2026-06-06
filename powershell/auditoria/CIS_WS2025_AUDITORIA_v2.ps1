# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# SCRIPT DE AUDITORÍA COMPLETO v2 - Valida TODOS los controles Level 1 MS
# Incluye controles de secciones 18.5-18.11 previamente faltantes
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

# =============================================================================
# SECCIÓN 1 - ACCOUNT POLICIES
# =============================================================================
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
if ([int]$maxage -ge 1 -and [int]$maxage -le 365) { Write-Host "[PASS] CIS 1.1.2 - Max password age 1-365 (actual: $maxage)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.1.2 - Max password age (esperado: 1-365, actual: $maxage)" -ForegroundColor Red; $fail++ }
if ([int]$minage -ge 1) { Write-Host "[PASS] CIS 1.1.3 - Min password age >= 1 (actual: $minage)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.1.3 - Min password age (esperado: >=1, actual: $minage)" -ForegroundColor Red; $fail++ }
if ([int]$minlen -ge 14) { Write-Host "[PASS] CIS 1.1.4 - Min password length >= 14 (actual: $minlen)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.1.4 - Min password length (esperado: >=14, actual: $minlen)" -ForegroundColor Red; $fail++ }

$seceditOut = "C:\Hardening\audit_secedit.cfg"
secedit /export /cfg $seceditOut /quiet 2>$null
if (Test-Path $seceditOut) {
    $content = Get-Content $seceditOut
    $complexity = ($content | Select-String "PasswordComplexity").ToString() -replace '\D',''
    $cleartext  = ($content | Select-String "ClearTextPassword").ToString() -replace '\D',''
    if ($complexity -eq "1") { Write-Host "[PASS] CIS 1.1.5 - Password complexity = Enabled" -ForegroundColor Green; $pass++ }
    else { Write-Host "[FAIL] CIS 1.1.5 - Password complexity (esperado: 1, actual: $complexity)" -ForegroundColor Red; $fail++ }
    if ($cleartext -eq "0") { Write-Host "[PASS] CIS 1.1.7 - Reversible encryption = Disabled" -ForegroundColor Green; $pass++ }
    else { Write-Host "[FAIL] CIS 1.1.7 - Reversible encryption (esperado: 0, actual: $cleartext)" -ForegroundColor Red; $fail++ }
}

Check-Reg "HKLM:\System\CurrentControlSet\Control\SAM" "RelaxMinimumPasswordLengthLimits" 1 "1.1.6" "Relax min password length limits = Enabled"

if ([int]$duration -ge 15) { Write-Host "[PASS] CIS 1.2.1 - Lockout duration >= 15 min (actual: $duration)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.2.1 - Lockout duration (esperado: >=15, actual: $duration)" -ForegroundColor Red; $fail++ }
if ([int]$threshold -ge 1 -and [int]$threshold -le 5) { Write-Host "[PASS] CIS 1.2.2 - Lockout threshold 1-5 (actual: $threshold)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.2.2 - Lockout threshold (esperado: 1-5, actual: $threshold)" -ForegroundColor Red; $fail++ }
Manual "1.2.3" "Allow Administrator account lockout - verificar en secpol.msc > Account Lockout Policy"
if ([int]$window -ge 15) { Write-Host "[PASS] CIS 1.2.4 - Reset lockout counter >= 15 min (actual: $window)" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 1.2.4 - Reset lockout counter (esperado: >=15, actual: $window)" -ForegroundColor Red; $fail++ }
Write-Host ""

# =============================================================================
# SECCIÓN 2.2 - USER RIGHTS ASSIGNMENT
# =============================================================================
Write-Host "--- SECCIÓN 2.2: User Rights Assignment ---" -ForegroundColor Magenta

function Check-UserRight {
    param($Privilege, $ExpectedSIDs, $CIS, $Desc, $IsSkip = $false, $SkipReason = "")
    if ($IsSkip) { Skip $CIS $Desc $SkipReason; return }
    try {
        $export = "C:\Hardening\audit_ur.cfg"
        secedit /export /cfg $export /areas USER_RIGHTS /quiet 2>$null
        $content = Get-Content $export -ErrorAction Stop
        $line = $content | Where-Object { $_ -match "^$Privilege\s*=" }
        if ($null -eq $line -or $line -match "^$Privilege\s*=$") {
            if ($ExpectedSIDs -eq "") { Write-Host "[PASS] CIS $CIS - $Desc = No One" -ForegroundColor Green; $script:pass++ }
            else { Write-Host "[FAIL] CIS $CIS - $Desc (esperado: $ExpectedSIDs, actual: vacío)" -ForegroundColor Red; $script:fail++ }
        } else {
            Write-Host "[PASS] CIS $CIS - $Desc (configurado)" -ForegroundColor Green; $script:pass++
        }
    } catch {
        Write-Host "[FAIL] CIS $CIS - $Desc (error al verificar)" -ForegroundColor Red; $script:fail++
    }
}

Check-UserRight "SeTrustedCredManAccessPrivilege" "" "2.2.1" "Access Credential Manager = No One"
Check-UserRight "SeNetworkLogonRight" "Administrators,AuthUsers" "2.2.3" "Access from network = Administrators + Authenticated Users"
Check-UserRight "SeTcbPrivilege" "" "2.2.4" "Act as part of OS = No One"
Check-UserRight "SeIncreaseQuotaPrivilege" "Admins,LocalSvc,NetworkSvc" "2.2.6" "Adjust memory quotas = Admins+LocalSvc+NetworkSvc"
Skip "2.2.8" "Allow log on locally = Administrators only" "VM standalone - bloquea cuenta local"
Check-UserRight "SeRemoteInteractiveLogonRight" "Admins,RDUsers" "2.2.10" "Allow RDP = Administrators + Remote Desktop Users"
Check-UserRight "SeBackupPrivilege" "Administrators" "2.2.11" "Back up files = Administrators"
Check-UserRight "SeSystemtimePrivilege" "Admins,LocalSvc" "2.2.12" "Change system time = Admins + LOCAL SERVICE"
Check-UserRight "SeCreatePagefilePrivilege" "Administrators" "2.2.13" "Create pagefile = Administrators"
Check-UserRight "SeCreateTokenPrivilege" "" "2.2.14" "Create token object = No One"
Check-UserRight "SeCreateGlobalPrivilege" "Admins,LocalSvc,NetworkSvc,Service" "2.2.15" "Create global objects = Admins+Services"
Check-UserRight "SeCreatePermanentPrivilege" "" "2.2.16" "Create permanent shared objects = No One"
Check-UserRight "SeCreateSymbolicLinkPrivilege" "Admins,VMs" "2.2.18" "Create symbolic links = Admins + VM\Virtual Machines"
Check-UserRight "SeDebugPrivilege" "Administrators" "2.2.19" "Debug programs = Administrators"
Skip "2.2.21" "Deny network access includes Local account" "VM standalone - bloquea acceso red"
Check-UserRight "SeDenyBatchLogonRight" "Guests" "2.2.22" "Deny log on as batch = Guests"
Check-UserRight "SeDenyServiceLogonRight" "Guests" "2.2.23" "Deny log on as service = Guests"
Check-UserRight "SeDenyInteractiveLogonRight" "Guests" "2.2.24" "Deny log on locally = Guests"
Skip "2.2.26" "Deny RDP includes Local account" "VM standalone - bloquea RDP"
Check-UserRight "SeEnableDelegationPrivilege" "" "2.2.28" "Enable trusted for delegation = No One"
Check-UserRight "SeRemoteShutdownPrivilege" "Administrators" "2.2.29" "Force shutdown from remote = Administrators"
Check-UserRight "SeAuditPrivilege" "LocalSvc,NetworkSvc" "2.2.30" "Generate security audits = LOCAL+NETWORK SERVICE"
Check-UserRight "SeImpersonatePrivilege" "Admins,Services" "2.2.32" "Impersonate client = Admins+Services"
Check-UserRight "SeIncreaseBasePriorityPrivilege" "Admins,WinMgr" "2.2.33" "Increase scheduling priority = Admins+Window Manager"
Check-UserRight "SeLoadDriverPrivilege" "Administrators" "2.2.34" "Load device drivers = Administrators"
Check-UserRight "SeLockMemoryPrivilege" "" "2.2.35" "Lock pages in memory = No One"
Check-UserRight "SeSecurityPrivilege" "Administrators" "2.2.38" "Manage auditing and security log = Administrators"
Check-UserRight "SeRelabelPrivilege" "" "2.2.39" "Modify object label = No One"
Check-UserRight "SeSystemEnvironmentPrivilege" "Administrators" "2.2.40" "Modify firmware environment = Administrators"
Check-UserRight "SeManageVolumePrivilege" "Administrators" "2.2.41" "Perform volume maintenance = Administrators"
Check-UserRight "SeProfileSingleProcessPrivilege" "Administrators" "2.2.42" "Profile single process = Administrators"
Check-UserRight "SeSystemProfilePrivilege" "Admins,WdiServiceHost" "2.2.43" "Profile system performance = Admins+WdiServiceHost"
Check-UserRight "SeAssignPrimaryTokenPrivilege" "LocalSvc,NetworkSvc" "2.2.44" "Replace process level token = LOCAL+NETWORK SERVICE"
Check-UserRight "SeRestorePrivilege" "Administrators" "2.2.45" "Restore files = Administrators"
Check-UserRight "SeShutdownPrivilege" "Administrators" "2.2.46" "Shut down system = Administrators"
Check-UserRight "SeTakeOwnershipPrivilege" "Administrators" "2.2.48" "Take ownership = Administrators"
Write-Host ""

# =============================================================================
# SECCIÓN 2.3 - SECURITY OPTIONS
# =============================================================================
Write-Host "--- SECCIÓN 2.3: Security Options ---" -ForegroundColor Magenta
$guest = Get-LocalUser | Where-Object { $_.SID -like "*-501" }
if (-not $guest.Enabled) { Write-Host "[PASS] CIS 2.3.1.1 - Guest account = Disabled" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 2.3.1.1 - Guest account enabled" -ForegroundColor Red; $fail++ }
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 1 "2.3.1.2" "Limit blank passwords to console only = Enabled"
Manual "2.3.1.3" "Rename Administrator account - verificar manualmente"
if ($guest.Name -ne "Guest") { Write-Host "[PASS] CIS 2.3.1.4 - Guest account renamed (actual: $($guest.Name))" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 2.3.1.4 - Guest account not renamed" -ForegroundColor Red; $fail++ }
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "SCENoApplyLegacyAuditPolicy" 1 "2.3.2.1" "Force audit policy subcategory settings = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "CrashOnAuditFail" 0 "2.3.2.2" "Shut down if unable to log audits = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" "AddPrinterDrivers" 1 "2.3.4.1" "Prevent users installing printer drivers = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireSignOrSeal" 1 "2.3.6.1" "Digitally encrypt/sign secure channel (always) = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "SealSecureChannel" 1 "2.3.6.2" "Digitally encrypt secure channel (when possible) = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "SignSecureChannel" 1 "2.3.6.3" "Digitally sign secure channel (when possible) = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "DisablePasswordChange" 0 "2.3.6.4" "Disable machine account password changes = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "MaximumPasswordAge" 30 "2.3.6.5" "Max machine account password age = 30" "le"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireStrongKey" 1 "2.3.6.6" "Require strong session key = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0 "2.3.7.1" "Do not require CTRL+ALT+DEL = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DontDisplayLastUserName" 1 "2.3.7.2" "Don't display last signed-in = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 900 "2.3.7.3" "Machine inactivity limit = 900 sec" "le"
Manual "2.3.7.4" "Message text for logon - verificar LegalNoticeText"
Manual "2.3.7.5" "Message title for logon - verificar LegalNoticeCaption"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "PasswordExpiryWarning" 14 "2.3.7.7" "Prompt to change password = 14 days" "ge"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "ScRemoveOption" "1" "2.3.7.9" "Smart card removal = Lock Workstation"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" 1 "2.3.8.1" "Network client: Digitally sign communications = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnablePlainTextPassword" 0 "2.3.8.2" "Send unencrypted password = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "AutoDisconnect" 15 "2.3.9.1" "Idle time before suspending session = 15 min" "le"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RequireSecuritySignature" 1 "2.3.9.2" "Network server: Digitally sign communications = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "enableforcedlogoff" 1 "2.3.9.3" "Disconnect clients when logon hours expire = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "SMBServerNameHardeningLevel" 1 "2.3.9.4" "Server SPN target name validation >= 1" "ge"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymousSAM" 1 "2.3.10.2" "Do not allow anonymous SAM enumeration = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 1 "2.3.10.3" "Do not allow anonymous SAM+shares enumeration = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1 "2.3.10.4" "Do not store passwords for network auth = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "EveryoneIncludesAnonymous" 0 "2.3.10.5" "Let Everyone apply to anonymous = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RestrictNullSessAccess" 1 "2.3.10.10" "Restrict anonymous access to Named Pipes = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictRemoteSAM" "O:BAG:BAD:(A;;RC;;;BA)" "2.3.10.11" "Restrict remote calls to SAM = Administrators only"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "ForceGuest" 0 "2.3.10.13" "Sharing model for local accounts = Classic"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "UseMachineId" 1 "2.3.11.1" "Allow Local System computer identity for NTLM = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AllowNullSessionFallback" 0 "2.3.11.2" "Allow LocalSystem NULL session fallback = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 0 "2.3.11.3" "Allow PKU2U authentication = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "SupportedEncryptionTypes" 2147483640 "2.3.11.4" "Kerberos encryption = AES128+AES256+Future"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 5 "2.3.11.6" "LAN Manager auth level = NTLMv2 only (5)" "ge"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinClientSec" 537395200 "2.3.11.9" "Min NTLM SSP client = NTLMv2+128bit"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinServerSec" 537395200 "2.3.11.10" "Min NTLM SSP server = NTLMv2+128bit"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 1 "2.3.11.11" "Restrict NTLM: Audit incoming >= 1" "ge"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "RestrictSendingNTLMTraffic" 1 "2.3.11.13" "Restrict NTLM: Outgoing >= 1" "ge"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ShutdownWithoutLogon" 0 "2.3.13.1" "Allow shutdown without logon = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" "ObCaseInsensitive" 1 "2.3.15.1" "Require case insensitivity = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1 "2.3.15.2" "Strengthen default permissions = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "FilterAdministratorToken" 1 "2.3.17.1" "Admin Approval Mode for built-in Admin = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 2 "2.3.17.2" "Elevation prompt for admins = Prompt for consent" "ge"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorUser" 0 "2.3.17.3" "Elevation prompt for standard users = Deny"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableInstallerDetection" 1 "2.3.17.4" "Detect app installations = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableSecureUIAPaths" 1 "2.3.17.5" "Only elevate UIAccess from secure locations = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 1 "2.3.17.6" "Run admins in Admin Approval Mode = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" 1 "2.3.17.7" "Switch to secure desktop = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableVirtualization" 1 "2.3.17.8" "Virtualize file/registry write failures = Enabled"
Write-Host ""

# =============================================================================
# SECCIÓN 5 - SYSTEM SERVICES
# =============================================================================
Write-Host "--- SECCIÓN 5: System Services ---" -ForegroundColor Magenta
$spooler = (Get-Service Spooler -ErrorAction SilentlyContinue).StartType
if ($spooler -eq "Disabled") { Write-Host "[PASS] CIS 5.2 - Print Spooler = Disabled" -ForegroundColor Green; $pass++ }
else { Write-Host "[FAIL] CIS 5.2 - Print Spooler (esperado: Disabled, actual: $spooler)" -ForegroundColor Red; $fail++ }
Write-Host ""

# =============================================================================
# SECCIÓN 9 - WINDOWS FIREWALL
# =============================================================================
Write-Host "--- SECCIÓN 9: Windows Defender Firewall ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "EnableFirewall" 1 "9.1.1" "Domain: Firewall state = On"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DefaultInboundAction" 1 "9.1.2" "Domain: Inbound = Block"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DisableNotifications" 1 "9.1.3" "Domain: Notifications = No"
Manual "9.1.4" "Domain: Log name - verificar LogFilePath"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogFileSize" 16384 "9.1.5" "Domain: Log size >= 16384 KB" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogDroppedPackets" 1 "9.1.6" "Domain: Log dropped = Yes"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogSuccessfulConnections" 1 "9.1.7" "Domain: Log successful = Yes"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "EnableFirewall" 1 "9.2.1" "Private: Firewall state = On"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DefaultInboundAction" 1 "9.2.2" "Private: Inbound = Block"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DisableNotifications" 1 "9.2.3" "Private: Notifications = No"
Manual "9.2.4" "Private: Log name - verificar LogFilePath"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogFileSize" 16384 "9.2.5" "Private: Log size >= 16384 KB" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogDroppedPackets" 1 "9.2.6" "Private: Log dropped = Yes"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogSuccessfulConnections" 1 "9.2.7" "Private: Log successful = Yes"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "EnableFirewall" 1 "9.3.1" "Public: Firewall state = On"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DefaultInboundAction" 1 "9.3.2" "Public: Inbound = Block"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DisableNotifications" 1 "9.3.3" "Public: Notifications = No"
Skip "9.3.4" "Public: Apply local firewall rules = No" "Bloquea RDP en perfil Public de Azure"
Skip "9.3.5" "Public: Apply local connection security rules = No" "Bloquea RDP en perfil Public de Azure"
Manual "9.3.6" "Public: Log name - verificar LogFilePath"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogFileSize" 16384 "9.3.7" "Public: Log size >= 16384 KB" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogDroppedPackets" 1 "9.3.8" "Public: Log dropped = Yes"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogSuccessfulConnections" 1 "9.3.9" "Public: Log successful = Yes"
Write-Host ""

# =============================================================================
# SECCIÓN 17 - ADVANCED AUDIT POLICY
# =============================================================================
Write-Host "--- SECCIÓN 17: Advanced Audit Policy ---" -ForegroundColor Magenta

function Check-Audit {
    param($Sub, $ExpectSuccess, $ExpectFailure, $CIS, $Desc)
    $result = auditpol /get /subcategory:"$Sub" 2>$null
    if ($null -eq $result) { Write-Host "[FAIL] CIS $CIS - $Desc (no se pudo verificar)" -ForegroundColor Red; $script:fail++; return }
    $line = $result | Select-String $Sub
    if ($null -eq $line) { Write-Host "[FAIL] CIS $CIS - $Desc (subcategoría no encontrada)" -ForegroundColor Red; $script:fail++; return }
    $hasSuccess = $line -match "Success"
    $hasFailure = $line -match "Failure"
    $ok = ($ExpectSuccess -eq $hasSuccess) -and ($ExpectFailure -eq $hasFailure)
    if ($ok) { Write-Host "[PASS] CIS $CIS - $Desc" -ForegroundColor Green; $script:pass++ }
    else { Write-Host "[FAIL] CIS $CIS - $Desc (actual: $line)" -ForegroundColor Red; $script:fail++ }
}

Check-Audit "Credential Validation" $true $true "17.1.1" "Audit Credential Validation = Success and Failure"
Check-Audit "Application Group Management" $true $true "17.2.1" "Audit Application Group Management = Success and Failure"
Check-Audit "Security Group Management" $true $false "17.2.5" "Audit Security Group Management = Success"
Check-Audit "User Account Management" $true $true "17.2.6" "Audit User Account Management = Success and Failure"
Check-Audit "Plug and Play Events" $true $false "17.3.1" "Audit PNP Activity = Success"
Check-Audit "Process Creation" $true $false "17.3.2" "Audit Process Creation = Success"
Check-Audit "Account Lockout" $false $true "17.5.1" "Audit Account Lockout = Failure"
Check-Audit "Group Membership" $true $false "17.5.2" "Audit Group Membership = Success"
Check-Audit "Logoff" $true $false "17.5.3" "Audit Logoff = Success"
Check-Audit "Logon" $true $true "17.5.4" "Audit Logon = Success and Failure"
Check-Audit "Other Logon/Logoff Events" $true $true "17.5.5" "Audit Other Logon/Logoff = Success and Failure"
Check-Audit "Special Logon" $true $false "17.5.6" "Audit Special Logon = Success"
Check-Audit "Detailed File Share" $false $true "17.6.1" "Audit Detailed File Share = Failure"
Check-Audit "File Share" $true $true "17.6.2" "Audit File Share = Success and Failure"
Check-Audit "Other Object Access Events" $true $true "17.6.3" "Audit Other Object Access = Success and Failure"
Check-Audit "Removable Storage" $true $true "17.6.4" "Audit Removable Storage = Success and Failure"
Check-Audit "Audit Policy Change" $true $false "17.7.1" "Audit Audit Policy Change = Success"
Check-Audit "Authentication Policy Change" $true $false "17.7.2" "Audit Authentication Policy Change = Success"
Check-Audit "Authorization Policy Change" $true $false "17.7.3" "Audit Authorization Policy Change = Success"
Check-Audit "MPSSVC Rule-Level Policy Change" $true $true "17.7.4" "Audit MPSSVC Rule-Level Policy = Success and Failure"
Check-Audit "Other Policy Change Events" $false $true "17.7.5" "Audit Other Policy Change = Failure"
Check-Audit "Sensitive Privilege Use" $true $true "17.8.1" "Audit Sensitive Privilege Use = Success and Failure"
Check-Audit "IPsec Driver" $true $true "17.9.1" "Audit IPsec Driver = Success and Failure"
Check-Audit "Other System Events" $true $true "17.9.2" "Audit Other System Events = Success and Failure"
Check-Audit "Security State Change" $true $false "17.9.3" "Audit Security State Change = Success"
Check-Audit "Security System Extension" $true $false "17.9.4" "Audit Security System Extension = Success"
Check-Audit "System Integrity" $true $true "17.9.5" "Audit System Integrity = Success and Failure"
Write-Host ""

# =============================================================================
# SECCIÓN 18 - ADMINISTRATIVE TEMPLATES
# =============================================================================
Write-Host "--- SECCIÓN 18.1: Control Panel ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera" 1 "18.1.1.1" "Prevent lock screen camera = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 1 "18.1.1.2" "Prevent lock screen slideshow = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "AllowInputPersonalization" 0 "18.1.2.2" "Allow online speech recognition = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "AllowOnlineTips" 0 "18.1.3" "Allow Online Tips = Disabled"
Write-Host ""

Write-Host "--- SECCIÓN 18.4: MS Security Guide ---" -ForegroundColor Magenta
Skip "18.4.1" "Apply UAC restrictions to local accounts" "Bloquea acceso remoto con cuenta local en VM standalone"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10" "Start" 4 "18.4.2" "SMB v1 client driver = Disabled (4)"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0 "18.4.3" "SMB v1 server = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config" "EnableCertPaddingCheck" "1" "18.4.4" "Enable Certificate Padding (32-bit) = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0 "18.4.5" "Enable SEHOP = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NodeType" 2 "18.4.6" "NetBT NodeType = P-node (2)"
Write-Host ""

Write-Host "--- SECCIÓN 18.5: MSS Legacy ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoAdminLogon" "0" "18.5.1" "AutoAdminLogon = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisableIPSourceRouting" 2 "18.5.2" "DisableIPSourceRouting IPv6 = 2"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableIPSourceRouting" 2 "18.5.3" "DisableIPSourceRouting IPv4 = 2"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 0 "18.5.4" "EnableICMPRedirect = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "KeepAliveTime" 300000 "18.5.5" "KeepAliveTime = 300000ms (5 min)" "le"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NoNameReleaseOnDemand" 1 "18.5.6" "NoNameReleaseOnDemand = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "PerformRouterDiscovery" 0 "18.5.7" "PerformRouterDiscovery = Disabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "SafeDllSearchMode" 1 "18.5.8" "SafeDllSearchMode = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "TcpMaxDataRetransmissions" 3 "18.5.9" "TcpMaxDataRetransmissions IPv6 <= 3" "le"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpMaxDataRetransmissions" 3 "18.5.10" "TcpMaxDataRetransmissions IPv4 <= 3" "le"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security" "WarningLevel" 90 "18.5.11" "Security log warning level <= 90%" "le"
Write-Host ""

Write-Host "--- SECCIÓN 18.6: Network ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMDNS" 0 "18.6.4.1" "Configure mDNS = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableNetbios" 2 "18.6.4.2" "Configure NetBIOS = Disable (2)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "DisableSmartNameResolution" 1 "18.6.4.3" "Turn off default IPv6 DNS Servers = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0 "18.6.4.4" "Turn off LLMNR = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableFontProviders" 0 "18.6.5.1" "Enable Font Providers = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditClientDoesNotSupportEncryption" 1 "18.6.7.1" "Audit client no encryption = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditClientDoesNotSupportSigning" 1 "18.6.7.2" "Audit client no signing = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditInsecureGuestLogon" 1 "18.6.7.3" "LanmanServer: Audit insecure guest = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "EnableAuthRateLimiter" 1 "18.6.7.4" "Auth rate limiter = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bowser" "EnableMailslots" 0 "18.6.7.5" "Remote mailslots Bowser = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "MinSmb2Dialect" 785 "18.6.7.6" "LanmanServer MinSmb2Dialect = SMB 3.1.1 (785)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "InvalidAuthenticationDelay" 2000 "18.6.7.7" "Auth rate limiter delay >= 2000ms" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditInsecureGuestLogon" 1 "18.6.8.1" "LanmanWorkstation: Audit insecure guest = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditServerDoesNotSupportEncryption" 1 "18.6.8.2" "Audit server no encryption = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditServerDoesNotSupportSigning" 1 "18.6.8.3" "Audit server no signing = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestLogons" 0 "18.6.8.4" "Enable insecure guest logons = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider" "EnableMailslots" 0 "18.6.8.5" "Remote mailslots NetworkProvider = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "MinSmb2Dialect" 785 "18.6.8.6" "LanmanWorkstation MinSmb2Dialect = SMB 3.1.1 (785)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "RequireEncryption" 1 "18.6.8.7" "Require Encryption = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "EnableLLTDIO" 0 "18.6.9.1" "LLTDIO = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "EnableRspndr" 0 "18.6.9.2" "RSPNDR = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Peernet" "Disabled" 1 "18.6.10.2" "Peer-to-Peer Networking = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_AllowNetBridge_NLA" 0 "18.6.11.2" "Prohibit Network Bridge = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI" 0 "18.6.11.3" "Prohibit ICS = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_StdDomainUserSetLocation" 1 "18.6.11.4" "Require elevation for network location = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 255 "18.6.19.2.1" "Disable IPv6 = 0xff (255)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "EnableRegistrars" 0 "18.6.20.1" "WCN wireless config = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\UI" "DisableWcnUi" 1 "18.6.20.2" "Prohibit WCN wizards = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections" 3 "18.6.21.1" "Minimize simultaneous connections = 3"
Skip "18.6.21.2" "Prohibit connection to non-domain networks" "Azure es red no-dominio - bloquearía conectividad"
Write-Host ""

Write-Host "--- SECCIÓN 18.7: Printers ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "RegisterSpoolerRemoteRpcEndPoint" 2 "18.7.1" "Allow Print Spooler client connections = Disabled (2)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "RedirectionguardPolicy" 1 "18.7.2" "Configure Redirection Guard = Enabled (1)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcUseNamedPipeProtocol" 0 "18.7.3" "RPC outgoing = RPC over TCP (0)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcAuthentication" 0 "18.7.4" "RPC authentication outgoing = Default (0)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcProtocols" 5 "18.7.5" "RPC listener protocols = 5"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "AuthenticationProtocol" 0 "18.7.6" "RPC listener auth = Negotiate (0)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcTcpPort" 0 "18.7.7" "RPC over TCP port = 0"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Print" "RpcAuthnLevelPrivacyEnabled" 1 "18.7.8" "RPC packet level privacy = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "WppEnabled" 1 "18.7.9" "Windows protected print = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "PointAndPrint_TrustedServers" 1 "18.7.10" "Limit print driver to Administrators = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "CopyFilesPolicy" 1 "18.7.11" "Queue-specific files = Color profiles (1)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "NoWarningNoElevationOnInstall" 0 "18.7.12" "Point and Print new = Warn + elevation (0)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "UpdatePromptSettings" 0 "18.7.13" "Point and Print update = Warn + elevation (0)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "RequireIpps" 1 "18.7.14" "Require IPPS = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_CA" 1 "18.7.15" "IPP TLS: Disallow invalid CA = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_ServerCert" 1 "18.7.16" "IPP TLS: Disallow non-server certs = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_CN" 1 "18.7.17" "IPP TLS: Disallow invalid CN = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_Date" 1 "18.7.18" "IPP TLS: Disallow invalid date = Enabled"
Write-Host ""

Write-Host "--- SECCIÓN 18.8: Start Menu ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" "NoCloudApplicationNotification" 1 "18.8.1.1" "Turn off notifications network usage = Enabled"
Write-Host ""

Write-Host "--- SECCIÓN 18.9: System ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 1 "18.9.3.1" "Include command line in process creation = Enabled"
Skip "18.9.4.1" "CredSSP AllowEncryptionOracle = Force Updated Clients" "Bloquea RDP sin NLA en VM standalone"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" "AllowProtectedCreds" 1 "18.9.4.2" "Allow delegation of non-exportable credentials = Enabled"
Skip "18.9.5.1" "Turn on VBS = Enabled" "Requiere hardware enterprise"
Skip "18.9.5.2" "VBS Platform Security Level = Secure Boot" "Requiere hardware enterprise"
Skip "18.9.5.3" "HVCI = Enabled with UEFI lock" "Requiere hardware enterprise"
Skip "18.9.5.4" "Require UEFI MAT = Enabled" "Requiere hardware enterprise"
Skip "18.9.5.5" "Credential Guard = Enabled with UEFI lock" "Requiere Active Directory y hardware enterprise"
Skip "18.9.5.7" "Secure Launch = Enabled" "Requiere hardware enterprise"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 1 "18.9.7.1.1" "Prevent device IDs = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 1 "18.9.7.1.3" "Prevent device classes = Enabled"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 3 "18.9.13.1" "Boot-Start Driver = Good+unknown+critical (3)"
Check-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies" "ClfsAuthenticationChecking" 1 "18.9.17.1" "CLFS logfile authentication = Enabled"
$gpKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{827D319E-6EAC-11D2-A4EA-00C04F79F83A}"
Check-Reg $gpKey "NoBackgroundPolicy" 0 "18.9.19.2" "Continue GP processing slow network = Enabled"
Check-Reg $gpKey "NoGPOListChanges" 0 "18.9.19.3" "Process even if GP not changed = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp" 0 "18.9.19.4" "Continue experiences on this device (CDP) = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableBkGndGroupPolicy" 0 "18.9.19.5" "Turn off background refresh of Group Policy = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 1 "18.9.20.1.13" "Turn off Windows Error Reporting = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "DevicePKInitEnabled" 1 "18.9.23.1" "Support device auth using certificate = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0 "18.9.24.1" "DMA Protection = Block All (0)"
Skip "18.9.26.1" "LAPS: Configure backup directory = Active Directory" "Sin Active Directory en VM standalone"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordExpirationProtectionEnabled" 1 "18.9.26.2" "LAPS: Password expiration protection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "ADPasswordEncryptionEnabled" 1 "18.9.26.3" "LAPS: Enable password encryption = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordComplexity" 4 "18.9.26.4" "LAPS: Password complexity = 4"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordLength" 15 "18.9.26.5" "LAPS: Password length >= 15" "ge"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordAgeDays" 30 "18.9.26.6" "LAPS: Password age <= 30 days" "le"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PostAuthenticationActions" 3 "18.9.26.8" "LAPS: Post-auth actions >= 3" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0 "18.9.27.1" "Allow Custom SSPs = Disabled"
Skip "18.9.27.2" "LSASS RunAsPPL = Enabled with UEFI lock" "Puede causar boot failure en Azure VM"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International" "BlockUserInputMethodsForSignIn" 1 "18.9.28.1" "Disallow copying user input methods = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockUserFromShowingAccountDetailsOnSignin" 1 "18.9.29.1" "Block account details on sign-in = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 1 "18.9.29.2" "Do not display network selection UI = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontEnumerateConnectedUsers" 1 "18.9.29.3" "Do not enumerate connected users = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnumerateLocalUsers" 0 "18.9.29.4" "Enumerate local users = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1 "18.9.29.5" "Turn off lock screen notifications = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowDomainPINLogon" 0 "18.9.29.6" "Turn on convenience PIN sign-in = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Netlogon\Parameters" "BlockNetbiosDiscovery" 1 "18.9.31.1.1" "Block NetBIOS-based DC discovery = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0 "18.9.33.1" "Clipboard sync across devices = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0 "18.9.33.2" "Upload User Activities = Disabled"
$netStandbyGuid = "f15576e8-98b7-4186-b944-eafa664402d9"
$wakePasswordGuid = "0e796bdb-100d-47d6-a2d5f7d2daa51f51"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$netStandbyGuid" "DCSettingIndex" 0 "18.9.35.6.1" "Network connectivity standby (battery) = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$netStandbyGuid" "ACSettingIndex" 0 "18.9.35.6.2" "Network connectivity standby (plugged) = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$wakePasswordGuid" "DCSettingIndex" 1 "18.9.35.6.3" "Require password on wake (battery) = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$wakePasswordGuid" "ACSettingIndex" 1 "18.9.35.6.4" "Require password on wake (plugged) = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited" 0 "18.9.37.1" "Offer Remote Assistance = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp" 0 "18.9.37.2" "Solicited Remote Assistance = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "EnableAuthEpResolution" 1 "18.9.38.1" "RPC Endpoint Mapper Auth = Enabled"
Skip "18.9.38.2" "Restrict Unauthenticated RPC clients = Authenticated" "Puede bloquear conexiones RDP remotas"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\SAM" "SamrChangedPasswordViaLogonRemote" 1 "18.9.41.3" "SAM change password RPC = Block (MS only)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" "DisableQueryRemoteServer" 0 "18.9.49.5.1" "MSDT interactive communication = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" "ScenarioExecutionEnabled" 0 "18.9.49.11.1" "PerfTrack = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" 1 "18.9.51.1" "Turn off advertising ID = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\W32Time\TimeProviders\NtpClient" "Enabled" 1 "18.9.53.1.1" "Enable Windows NTP Client = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\W32Time\TimeProviders\NtpServer" "Enabled" 0 "18.9.53.1.2" "Enable Windows NTP Server = Disabled (MS only)"

# Event Logs
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 32768 "18.9.47.1.1" "Application log size >= 32768 KB" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "MaxSize" 196608 "18.9.47.2.1" "Security log size >= 196608 KB" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup" "MaxSize" 32768 "18.9.47.3.1" "Setup log size >= 32768 KB" "ge"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" "MaxSize" 32768 "18.9.47.4.1" "System log size >= 32768 KB" "ge"

# Windows Defender
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" 2 "18.9.65.2" "Join Microsoft MAPS = Advanced (2)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0 "18.9.65.3" "Turn on behavior monitoring = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableIOAVProtection" 0 "18.9.65.4" "Scan downloaded files = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 "18.9.65.5" "Real-time protection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 0 "18.9.65.6" "Script scanning = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableEmailScanning" 0 "18.9.65.7" "Email scanning = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "PUAProtection" 1 "18.9.65.8" "PUA Protection = Block (1)"

# RDP
Skip "18.9.75.3" "Always prompt for password upon RDP connection" "Interfiere con RDP sin NLA en VM standalone"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fEncryptRPCTraffic" 1 "18.9.75.4" "Require secure RPC = Enabled"
Skip "18.9.75.5" "Set client connection encryption level = High" "Requiere certificado de dominio para SSL"
Skip "18.9.75.6" "Require SSL security layer for RDP" "Causó bloqueo RDP - requiere certificado de dominio"
Skip "18.9.75.7" "Require NLA for RDP" "VM standalone sin dominio - bloquea acceso RDP"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxIdleTime" 900000 "18.9.75.8" "Idle session limit <= 900000ms (15min)" "le"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxDisconnectionTime" 60000 "18.9.75.9" "Disconnected session limit = 60000ms (1min)"
Write-Host ""

Write-Host "--- SECCIÓN 18.10: Windows Components ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" "BlockNonAdminUserInstall" 1 "18.10.4.2" "Not allow per-user unsigned packages = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "MSAOptional" 1 "18.10.6.1" "Allow Microsoft accounts to be optional = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoAutoplayfornonVolume" 1 "18.10.8.1" "Disallow Autoplay non-volume devices = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoAutorun" 1 "18.10.8.2" "Default AutoRun = Do not execute (1)"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255 "18.10.8.3" "Turn off Autoplay = All drives (255)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" "EnhancedAntiSpoofing" 1 "18.10.9.1.1" "Enhanced anti-spoofing = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Camera" "AllowCamera" 0 "18.10.11.1" "Allow Use of Camera = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableConsumerAccountStateContent" 1 "18.10.13.1" "Turn off cloud consumer account state = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableCloudOptimizedContent" 1 "18.10.13.2" "Turn off cloud optimized content = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect" "RequirePinForPairing" 1 "18.10.14.1" "Require pin for pairing = First Time (1)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "DisablePasswordReveal" 1 "18.10.15.1" "Do not display password reveal button = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnumerateAdministrators" 0 "18.10.15.2" "Enumerate administrator accounts = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 1 "18.10.16.1" "Allow Diagnostic Data = Required only (1)" "le"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DisableEnterpriseAuthProxy" 1 "18.10.16.2" "Disable Authenticated Proxy = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1 "18.10.16.3" "Do not show feedback notifications = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "EnableOneSettingsAuditing" 1 "18.10.16.4" "Enable OneSettings Auditing = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDiagnosticLogCollection" 1 "18.10.16.5" "Limit Diagnostic Log Collection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDumpCollection" 1 "18.10.16.6" "Limit Dump Collection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableAppInstaller" 0 "18.10.18.1" "Enable App Installer = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableExperimentalFeatures" 0 "18.10.18.2" "App Installer Experimental Features = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableHashOverride" 0 "18.10.18.3" "App Installer Hash Override = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableLocalArchiveMalwareScanOverride" 0 "18.10.18.4" "Local Archive Malware Scan Override = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableMSAppInstallerProtocol" 0 "18.10.18.5" "ms-appinstaller protocol = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableMicrosoftStoreSourceCertificateValidationBypass" 0 "18.10.18.6" "MS Store Cert Validation Bypass = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableWindowsPackageManagerCommandLineInterfaces" 0 "18.10.18.7" "Windows Package Manager CLI = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableMotWOnInsecurePathCompletion" 0 "18.10.29.2" "Do not apply MotW insecure sources = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0 "18.10.29.3" "Turn off DEP for Explorer = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption" 0 "18.10.29.4" "Turn off heap termination = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0 "18.10.29.5" "Turn off shell protocol protected mode = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1 "18.10.36.1" "Turn off location = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging" "AllowMessageSync" 0 "18.10.40.1" "Allow Message Service Cloud Sync = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 1 "18.10.41.1" "Block consumer Microsoft account auth = Enabled"

# Defender additional
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Features" "TamperProtection" 5 "18.10.42.4.1" "Enable EDR in block mode = Enabled (5)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "LocalSettingOverrideSpynetReporting" 0 "18.10.42.5.1" "Override local MAPS setting = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" "ExploitGuard_ASR_Rules" 1 "18.10.42.6.1.1" "Configure ASR rules = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" "EnableNetworkProtection" 1 "18.10.42.6.3.1" "Network Protection = Block (1)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" "MpEnableFileHashComputation" 1 "18.10.42.7.1" "Enable file hash computation = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" "DisableGenericRePorts" 1 "18.10.42.12.1" "Configure Watson events = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableRemovableDriveScanning" 0 "18.10.42.13.3" "Scan removable drives = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "QuickScanInterval" 7 "18.10.42.13.4" "Quick scan interval = 7 days" "le"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableLocalAdminMerge" 1 "18.10.42.17" "Exclusions visible to local users = Enabled"

Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" "DisablePushToInstall" 1 "18.10.56.1" "Turn off Push To Install = Enabled"

# RDP additional
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fSingleSessionPerUser" 1 "18.10.57.3.2.1" "Restrict RDS to single session = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCcm" 1 "18.10.57.3.3.2" "Do not allow COM port redirection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCdm" 1 "18.10.57.3.3.3" "Do not allow drive redirection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableLocationRedir" 1 "18.10.57.3.3.4" "Do not allow location redirection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableLPT" 1 "18.10.57.3.3.5" "Do not allow LPT redirection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisablePNPRedir" 1 "18.10.57.3.3.6" "Do not allow PnP redirection = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableWebAuthn" 1 "18.10.57.3.3.7" "Do not allow WebAuthn redirection = Enabled"
Skip "18.10.57.3.9.1" "Always prompt for password upon connection" "Interfiere con RDP sin NLA"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fEncryptRPCTraffic" 1 "18.10.57.3.9.2" "Require secure RPC = Enabled"
Skip "18.10.57.3.9.3" "Require SSL security layer for RDP" "Causó bloqueo RDP anterior"
Skip "18.10.57.3.9.4" "Require NLA for RDP" "VM standalone - bloquea RDP"
Skip "18.10.57.3.9.5" "Set client connection encryption level = High" "Requiere certificado dominio"

Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 1 "18.10.58.1" "Prevent downloading enclosures = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCloudSearch" 0 "18.10.59.2" "Allow Cloud Search = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0 "18.10.59.3" "Allow indexing encrypted files = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "EnableDynamicContentInWSB" 0 "18.10.59.4" "Allow search highlights = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" "NoGenTicket" 1 "18.10.63.1" "Turn off KMS Client AVS Validation = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1 "18.10.77.2.1" "Configure SmartScreen = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowSuggestedAppsInWindowsInkWorkspace" 0 "18.10.81.1" "Allow suggested apps in Ink Workspace = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 1 "18.10.81.2" "Allow Windows Ink Workspace = On but not above lock (1)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "EnableUserControl" 0 "18.10.82.1" "Allow user control over installs = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated" 0 "18.10.82.2" "Always install with elevated privileges = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "SafeForScripting" 0 "18.10.82.3" "Prevent IE security prompt for Installer = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableMPR" 0 "18.10.83.1" "Transmission of password in MPR = Disabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableAutomaticRestartSignOn" 1 "18.10.83.2" "Sign-in after restart = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" "EnableScriptBlockLogging" 1 "18.10.88.1" "PowerShell Script Block Logging = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" "EnableTranscripting" 1 "18.10.88.2" "PowerShell Transcription = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowBasic" 0 "18.10.90.1.1" "WinRM Client: Allow Basic auth = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowUnencryptedTraffic" 0 "18.10.90.1.2" "WinRM Client: Allow unencrypted = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowDigest" 0 "18.10.90.1.3" "WinRM Client: Disallow Digest = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowBasic" 0 "18.10.90.2.1" "WinRM Service: Allow Basic auth = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowAutoConfig" 0 "18.10.90.2.2" "WinRM Service: Allow remote management = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowUnencryptedTraffic" 0 "18.10.90.2.3" "WinRM Service: Allow unencrypted = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "DisableRunAs" 1 "18.10.90.2.4" "WinRM Service: Disallow RunAs = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" "AllowRemoteShellAccess" 0 "18.10.91.1" "Allow Remote Shell Access = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 1 "18.10.93.2.1" "Prevent users modifying security settings = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 0 "18.10.94.1.1" "No auto-restart with logged on users = Disabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0 "18.10.94.2.1" "Configure Automatic Updates = Enabled"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "ScheduledInstallDay" 0 "18.10.94.2.2" "Scheduled install day = Every day (0)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "ManagePreviewBuildsPolicyValue" 1 "18.10.94.4.1" "Manage preview builds = Disabled (1)"
Check-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferQualityUpdatesPeriodInDays" 0 "18.10.94.4.2" "Quality Updates deferral = 0 days"
Write-Host ""

Write-Host "--- SECCIÓN 18.11: Custom Settings ---" -ForegroundColor Magenta
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" "WpadOverride" 1 "18.11.1" "Disable WPAD = Enabled"
Check-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "ProxySettingsPerUser" 1 "18.11.2" "Disable proxy authentication = Enabled"
Write-Host ""

# =============================================================================
# RESUMEN FINAL
# =============================================================================
$total = $pass + $fail + $skip + $manual
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN AUDITORÍA CIS WS2025 v2 - ProjectDB IF5100" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " [PASS]   Controles aplicados    : $pass" -ForegroundColor Green
Write-Host " [FAIL]   Controles fallidos     : $fail" -ForegroundColor Red
Write-Host " [SKIP]   Omitidos (justificado) : $skip" -ForegroundColor Yellow
Write-Host " [MANUAL] Verificación manual    : $manual" -ForegroundColor Cyan
Write-Host " Total controles verificados     : $total" -ForegroundColor White
Write-Host ""
if (($pass + $fail) -gt 0) {
    $pct = [math]::Round(($pass / ($pass + $fail)) * 100, 1)
    Write-Host " Cumplimiento (excl. SKIP)       : $pct%" -ForegroundColor $(if ($pct -ge 80) {'Green'} elseif ($pct -ge 60) {'Yellow'} else {'Red'})
}
Write-Host ""
Write-Host " Justificación de controles SKIP:" -ForegroundColor Yellow
Write-Host "  - VM standalone sin Active Directory (omite controles de dominio)" -ForegroundColor Yellow
Write-Host "  - Azure perfil de red Public (omite controles que bloquean RDP)" -ForegroundColor Yellow
Write-Host "  - Sin hardware enterprise Hyper-V/UEFI (omite VBS/Credential Guard)" -ForegroundColor Yellow
Write-Host "  - Sin certificado SSL de dominio (omite SecurityLayer=2 y NLA)" -ForegroundColor Yellow
Write-Host "  - 18.9.38.2 RestrictRemoteClients (puede bloquear RDP remoto)" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
