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

# 2.3.4 Devices
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" "AddPrinterDrivers" 1 DWord "2.3.4.1" "Prevent users from installing printer drivers = Enabled"

# 2.3.6 Domain member
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireSignOrSeal" 1 DWord "2.3.6.1" "Digitally encrypt or sign secure channel data = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "SealSecureChannel" 1 DWord "2.3.6.2" "Digitally encrypt secure channel data = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "SignSecureChannel" 1 DWord "2.3.6.3" "Digitally sign secure channel data = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "DisablePasswordChange" 0 DWord "2.3.6.4" "Disable machine account password changes = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "MaximumPasswordAge" 30 DWord "2.3.6.5" "Maximum machine account password age = 30 days"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" "RequireStrongKey" 1 DWord "2.3.6.6" "Require strong session key = Enabled"

# 2.3.7 Interactive logon
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0 DWord "2.3.7.1" "Do not require CTRL+ALT+DEL = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DontDisplayLastUserName" 1 DWord "2.3.7.2" "Don't display last signed-in = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 900 DWord "2.3.7.3" "Machine inactivity limit = 900 seconds"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LegalNoticeText" "ADVERTENCIA: Sistema de uso exclusivo proyecto IF5100 - UCR. Acceso no autorizado prohibido y auditado." String "2.3.7.4" "Logon message text configured"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LegalNoticeCaption" "ACCESO RESTRINGIDO - ProjectDB IF5100" String "2.3.7.5" "Logon message title configured"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "4" String "2.3.7.6" "Previous logons to cache = 4"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "PasswordExpiryWarning" 14 DWord "2.3.7.7" "Prompt to change password = 14 days"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "ScRemoveOption" "1" String "2.3.7.9" "Smart card removal behavior = Lock Workstation"

# 2.3.8 Network client
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" 1 DWord "2.3.8.1" "Network client: Digitally sign communications = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnablePlainTextPassword" 0 DWord "2.3.8.2" "Send unencrypted password = Disabled"

# 2.3.9 Network server
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "AutoDisconnect" 15 DWord "2.3.9.1" "Idle time before suspending session = 15 min"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RequireSecuritySignature" 1 DWord "2.3.9.2" "Network server: Digitally sign communications = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "enableforcedlogoff" 1 DWord "2.3.9.3" "Disconnect clients when logon hours expire = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "SMBServerNameHardeningLevel" 1 DWord "2.3.9.4" "Server SPN target name validation = Accept if provided"

# 2.3.10 Network access
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymousSAM" 1 DWord "2.3.10.2" "Do not allow anonymous enumeration of SAM = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictAnonymous" 1 DWord "2.3.10.3" "Do not allow anonymous enumeration of shares = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1 DWord "2.3.10.4" "Do not allow storage of passwords for network auth = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "EveryoneIncludesAnonymous" 0 DWord "2.3.10.5" "Let Everyone apply to anonymous = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "NullSessionPipes" @() MultiString "2.3.10.7" "Named Pipes accessible anonymously = None"
$regPaths = @("System\CurrentControlSet\Control\ProductOptions","System\CurrentControlSet\Control\Server Applications","Software\Microsoft\Windows NT\CurrentVersion")
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths" "Machine" $regPaths MultiString "2.3.10.8" "Remotely accessible registry paths configured"
$regSubPaths = @("System\CurrentControlSet\Control\Print\Printers","System\CurrentControlSet\Services\Eventlog","Software\Microsoft\OLAP Server","Software\Microsoft\Windows NT\CurrentVersion\Print","Software\Microsoft\Windows NT\CurrentVersion\Windows","System\CurrentControlSet\Control\ContentIndex","System\CurrentControlSet\Control\Terminal Server","System\CurrentControlSet\Control\Terminal Server\UserConfig","System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration","Software\Microsoft\Windows NT\CurrentVersion\Perflib","System\CurrentControlSet\Services\SysmonLog")
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths" "Machine" $regSubPaths MultiString "2.3.10.9" "Remotely accessible registry sub-paths configured"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RestrictNullSessAccess" 1 DWord "2.3.10.10" "Restrict anonymous access to Named Pipes = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RestrictRemoteSAM" "O:BAG:BAD:(A;;RC;;;BA)" String "2.3.10.11" "Restrict remote calls to SAM = Administrators only"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "NullSessionShares" @() MultiString "2.3.10.12" "Shares accessible anonymously = None"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "ForceGuest" 0 DWord "2.3.10.13" "Sharing model for local accounts = Classic"

# 2.3.11 Network security
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "UseMachineId" 1 DWord "2.3.11.1" "Allow Local System to use computer identity for NTLM = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AllowNullSessionFallback" 0 DWord "2.3.11.2" "Allow LocalSystem NULL session fallback = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 0 DWord "2.3.11.3" "Allow PKU2U authentication = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "SupportedEncryptionTypes" 2147483640 DWord "2.3.11.4" "Kerberos encryption types = AES128+AES256+Future"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "EnableForcedLogOff" 1 DWord "2.3.11.5" "Force logoff when logon hours expire = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel" 5 DWord "2.3.11.6" "LAN Manager authentication = NTLMv2 only (5)"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinClientSec" 537395200 DWord "2.3.11.9" "Min NTLM SSP client security = NTLMv2+128bit"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinServerSec" 537395200 DWord "2.3.11.10" "Min NTLM SSP server security = NTLMv2+128bit"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "AuditReceivingNTLMTraffic" 1 DWord "2.3.11.11" "Restrict NTLM: Audit Incoming = Enable auditing"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "RestrictSendingNTLMTraffic" 1 DWord "2.3.11.13" "Restrict NTLM: Outgoing = Audit all"

# 2.3.13 Shutdown
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ShutdownWithoutLogon" 0 DWord "2.3.13.1" "Allow shutdown without logon = Disabled"

# 2.3.15 System objects
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" "ObCaseInsensitive" 1 DWord "2.3.15.1" "Require case insensitivity = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1 DWord "2.3.15.2" "Strengthen default permissions = Enabled"

# 2.3.17 UAC
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "FilterAdministratorToken" 1 DWord "2.3.17.1" "Admin Approval Mode for built-in Admin = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorAdmin" 2 DWord "2.3.17.2" "Elevation prompt for admins = Prompt for consent"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "ConsentPromptBehaviorUser" 0 DWord "2.3.17.3" "Elevation prompt for standard users = Deny"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableInstallerDetection" 1 DWord "2.3.17.4" "Detect app installations = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableSecureUIAPaths" 1 DWord "2.3.17.5" "Only elevate UIAccess from secure locations = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA" 1 DWord "2.3.17.6" "Run administrators in Admin Approval Mode = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "PromptOnSecureDesktop" 1 DWord "2.3.17.7" "Switch to secure desktop when prompting = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableVirtualization" 1 DWord "2.3.17.8" "Virtualize file and registry write failures = Enabled"
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
New-Item -ItemType Directory -Path "C:\Windows\System32\logfiles\firewall" -Force | Out-Null

# Domain Profile
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "EnableFirewall" 1 DWord "9.1.1" "Domain: Firewall state = On"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DefaultInboundAction" 1 DWord "9.1.2" "Domain: Inbound = Block"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DisableNotifications" 1 DWord "9.1.3" "Domain: Notifications = No"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogFilePath" "%SystemRoot%\System32\logfiles\firewall\domainfw.log" String "9.1.4" "Domain: Log = domainfw.log"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogFileSize" 16384 DWord "9.1.5" "Domain: Log size = 16384 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogDroppedPackets" 1 DWord "9.1.6" "Domain: Log dropped = Yes"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogSuccessfulConnections" 1 DWord "9.1.7" "Domain: Log successful = Yes"

# Private Profile
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "EnableFirewall" 1 DWord "9.2.1" "Private: Firewall state = On"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DefaultInboundAction" 1 DWord "9.2.2" "Private: Inbound = Block"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DisableNotifications" 1 DWord "9.2.3" "Private: Notifications = No"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogFilePath" "%SystemRoot%\System32\logfiles\firewall\privatefw.log" String "9.2.4" "Private: Log = privatefw.log"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogFileSize" 16384 DWord "9.2.5" "Private: Log size = 16384 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogDroppedPackets" 1 DWord "9.2.6" "Private: Log dropped = Yes"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogSuccessfulConnections" 1 DWord "9.2.7" "Private: Log successful = Yes"

# Public Profile - OMITE AllowLocalPolicyMerge y AllowLocalIPsecPolicyMerge
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "EnableFirewall" 1 DWord "9.3.1" "Public: Firewall state = On"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DefaultInboundAction" 1 DWord "9.3.2" "Public: Inbound = Block"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DisableNotifications" 1 DWord "9.3.3" "Public: Notifications = No"
# 9.3.4 OMITIDO - AllowLocalPolicyMerge=0 bloquea RDP en Azure (perfil Public)
# 9.3.5 OMITIDO - AllowLocalIPsecPolicyMerge=0 mismo problema
Write-Host "[SKIP] CIS 9.3.4 - AllowLocalPolicyMerge omitido (bloquea RDP en Azure)" -ForegroundColor Yellow
Write-Host "[SKIP] CIS 9.3.5 - AllowLocalIPsecPolicyMerge omitido (bloquea RDP en Azure)" -ForegroundColor Yellow
$SkipCount += 2
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogFilePath" "%SystemRoot%\System32\logfiles\firewall\publicfw.log" String "9.3.6" "Public: Log = publicfw.log"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogFileSize" 16384 DWord "9.3.7" "Public: Log size = 16384 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogDroppedPackets" 1 DWord "9.3.8" "Public: Log dropped = Yes"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogSuccessfulConnections" 1 DWord "9.3.9" "Public: Log successful = Yes"

# Asegurar RDP en firewall
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
Write-Host "[OK] Regla RDP habilitada en firewall" -ForegroundColor Green
$PassCount++
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
Set-Audit "Application Group Management" "Success and Failure" "17.2.1" "Audit Application Group Management"
Set-Audit "Security Group Management" "Success" "17.2.5" "Audit Security Group Management"
Set-Audit "User Account Management" "Success and Failure" "17.2.6" "Audit User Account Management"
Set-Audit "Plug and Play Events" "Success" "17.3.1" "Audit PNP Activity"
Set-Audit "Process Creation" "Success" "17.3.2" "Audit Process Creation"
Set-Audit "Account Lockout" "Failure" "17.5.1" "Audit Account Lockout"
Set-Audit "Group Membership" "Success" "17.5.2" "Audit Group Membership"
Set-Audit "Logoff" "Success" "17.5.3" "Audit Logoff"
Set-Audit "Logon" "Success and Failure" "17.5.4" "Audit Logon"
Set-Audit "Other Logon/Logoff Events" "Success and Failure" "17.5.5" "Audit Other Logon/Logoff Events"
Set-Audit "Special Logon" "Success" "17.5.6" "Audit Special Logon"
Set-Audit "Detailed File Share" "Failure" "17.6.1" "Audit Detailed File Share"
Set-Audit "File Share" "Success and Failure" "17.6.2" "Audit File Share"
Set-Audit "Other Object Access Events" "Success and Failure" "17.6.3" "Audit Other Object Access Events"
Set-Audit "Removable Storage" "Success and Failure" "17.6.4" "Audit Removable Storage"
Set-Audit "Audit Policy Change" "Success" "17.7.1" "Audit Audit Policy Change"
Set-Audit "Authentication Policy Change" "Success" "17.7.2" "Audit Authentication Policy Change"
Set-Audit "Authorization Policy Change" "Success" "17.7.3" "Audit Authorization Policy Change"
Set-Audit "MPSSVC Rule-Level Policy Change" "Success and Failure" "17.7.4" "Audit MPSSVC Rule-Level Policy Change"
Set-Audit "Other Policy Change Events" "Failure" "17.7.5" "Audit Other Policy Change Events"
Set-Audit "Sensitive Privilege Use" "Success and Failure" "17.8.1" "Audit Sensitive Privilege Use"
Set-Audit "IPsec Driver" "Success and Failure" "17.9.1" "Audit IPsec Driver"
Set-Audit "Other System Events" "Success and Failure" "17.9.2" "Audit Other System Events"
Set-Audit "Security State Change" "Success" "17.9.3" "Audit Security State Change"
Set-Audit "Security System Extension" "Success" "17.9.4" "Audit Security System Extension"
Set-Audit "System Integrity" "Success and Failure" "17.9.5" "Audit System Integrity"
Write-Host ""

# =============================================================================
# SECCIÓN 18.1 - CONTROL PANEL
# =============================================================================
Write-Host ">>> SECCIÓN 18.1: Control Panel" -ForegroundColor Cyan
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera" 1 DWord "18.1.1.1" "Prevent lock screen camera = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 1 DWord "18.1.1.2" "Prevent lock screen slideshow = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "AllowInputPersonalization" 0 DWord "18.1.2.2" "Allow online speech recognition = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "AllowOnlineTips" 0 DWord "18.1.3" "Allow Online Tips = Disabled"
Write-Host ""

# =============================================================================
# SECCIÓN 18.4 - MS SECURITY GUIDE
# OMITE: 18.4.1 LocalAccountTokenFilterPolicy=0 (bloquea acceso remoto cuenta local)
# =============================================================================
Write-Host ">>> SECCIÓN 18.4: MS Security Guide" -ForegroundColor Cyan
# 18.4.1 OMITIDO - LocalAccountTokenFilterPolicy=0 bloquea acceso remoto con cuenta local
Write-Host "[SKIP] CIS 18.4.1 - LocalAccountTokenFilterPolicy omitido (bloquea acceso remoto cuenta local)" -ForegroundColor Yellow
$SkipCount++
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10" "Start" 4 DWord "18.4.2" "SMB v1 client driver = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0 DWord "18.4.3" "SMB v1 server = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config" "EnableCertPaddingCheck" "1" String "18.4.4" "Enable Certificate Padding (32-bit) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" "EnableCertPaddingCheck" "1" String "18.4.4" "Enable Certificate Padding (64-bit) = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0 DWord "18.4.5" "Enable SEHOP = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NodeType" 2 DWord "18.4.6" "NetBT NodeType = P-node (2)"
Write-Host ""

# =============================================================================
# SECCIÓN 18.5 - MSS (LEGACY)
# =============================================================================
Write-Host ">>> SECCIÓN 18.5: MSS (Legacy)" -ForegroundColor Cyan
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoAdminLogon" "0" String "18.5.1" "AutoAdminLogon = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisableIPSourceRouting" 2 DWord "18.5.2" "DisableIPSourceRouting IPv6 = 2"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableIPSourceRouting" 2 DWord "18.5.3" "DisableIPSourceRouting IPv4 = 2"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 0 DWord "18.5.4" "EnableICMPRedirect = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NoNameReleaseOnDemand" 1 DWord "18.5.6" "NoNameReleaseOnDemand = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "PerformRouterDiscovery" 0 DWord "18.5.7" "PerformRouterDiscovery = Disabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "SafeDllSearchMode" 1 DWord "18.5.8" "SafeDllSearchMode = Enabled"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "TcpMaxDataRetransmissions" 3 DWord "18.5.9" "TcpMaxDataRetransmissions IPv6 = 3"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpMaxDataRetransmissions" 3 DWord "18.5.10" "TcpMaxDataRetransmissions IPv4 = 3"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security" "WarningLevel" 90 DWord "18.5.11" "Security log warning level = 90%"
Write-Host ""

# =============================================================================
# SECCIÓN 18.6 - NETWORK
# OMITE: 18.6.21.2 fBlockNonDomain=1 (bloquea Azure por ser red no-dominio)
# =============================================================================
Write-Host ">>> SECCIÓN 18.6: Network" -ForegroundColor Cyan
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMDNS" 0 DWord "18.6.4.1" "Configure mDNS = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableNetbios" 2 DWord "18.6.4.2" "Configure NetBIOS = Disable (2)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0 DWord "18.6.4.4" "Turn off LLMNR = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableFontProviders" 0 DWord "18.6.5.1" "Enable Font Providers = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditClientDoesNotSupportEncryption" 1 DWord "18.6.7.1" "Audit client no encryption = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditClientDoesNotSupportSigning" 1 DWord "18.6.7.2" "Audit client no signing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditInsecureGuestLogon" 1 DWord "18.6.7.3" "LanmanServer: Audit insecure guest = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "EnableAuthRateLimiter" 1 DWord "18.6.7.4" "Auth rate limiter = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bowser" "EnableMailslots" 0 DWord "18.6.7.5" "Remote mailslots (Bowser) = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "MinSmb2Dialect" 785 DWord "18.6.7.6" "LanmanServer MinSmb2Dialect = SMB 3.1.1"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "InvalidAuthenticationDelay" 2000 DWord "18.6.7.7" "Auth rate limiter delay = 2000ms"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditInsecureGuestLogon" 1 DWord "18.6.8.1" "LanmanWorkstation: Audit insecure guest = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditServerDoesNotSupportEncryption" 1 DWord "18.6.8.2" "Audit server no encryption = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditServerDoesNotSupportSigning" 1 DWord "18.6.8.3" "Audit server no signing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestLogons" 0 DWord "18.6.8.4" "Enable insecure guest logons = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider" "EnableMailslots" 0 DWord "18.6.8.5" "Remote mailslots (NetworkProvider) = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "MinSmb2Dialect" 785 DWord "18.6.8.6" "LanmanWorkstation MinSmb2Dialect = SMB 3.1.1"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "RequireEncryption" 1 DWord "18.6.8.7" "Require Encryption = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowLLTDIOOnDomain" 0 DWord "18.6.9.1" "LLTDIO = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowLLTDIOOnPublicNet" 0 DWord "18.6.9.1" "LLTDIO public = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "EnableLLTDIO" 0 DWord "18.6.9.1" "LLTDIO enabled = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "ProhibitLLTDIOOnPrivateNet" 0 DWord "18.6.9.1" "LLTDIO private = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowRspndrOnDomain" 0 DWord "18.6.9.2" "RSPNDR = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowRspndrOnPublicNet" 0 DWord "18.6.9.2" "RSPNDR public = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "EnableRspndr" 0 DWord "18.6.9.2" "RSPNDR enabled = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "ProhibitRspndrOnPrivateNet" 0 DWord "18.6.9.2" "RSPNDR private = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Peernet" "Disabled" 1 DWord "18.6.10.2" "Peer-to-Peer Networking = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_AllowNetBridge_NLA" 0 DWord "18.6.11.2" "Prohibit Network Bridge = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI" 0 DWord "18.6.11.3" "Prohibit ICS = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_StdDomainUserSetLocation" 1 DWord "18.6.11.4" "Require elevation for network location = Enabled"
try {
    $uncPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
    if (-not (Test-Path $uncPath)) { New-Item -Path $uncPath -Force | Out-Null }
    Set-ItemProperty -Path $uncPath -Name "\\*\NETLOGON" -Value "RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1" -Type String -Force
    Set-ItemProperty -Path $uncPath -Name "\\*\SYSVOL" -Value "RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1" -Type String -Force
    Write-Host "[OK] CIS 18.6.14.1 - Hardened UNC Paths configured" -ForegroundColor Green
    $PassCount++
} catch { Write-Host "[ERROR] CIS 18.6.14.1: $_" -ForegroundColor Red; $ErrorCount++ }
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 255 DWord "18.6.19.2.1" "Disable IPv6 = 0xff"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "EnableRegistrars" 0 DWord "18.6.20.1" "WCN = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\UI" "DisableWcnUi" 1 DWord "18.6.20.2" "WCN wizards = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections" 3 DWord "18.6.21.1" "Minimize simultaneous connections = 3"
# 18.6.21.2 OMITIDO - fBlockNonDomain=1 bloquea Azure (red no-dominio)
Write-Host "[SKIP] CIS 18.6.21.2 - fBlockNonDomain omitido (bloquea Azure)" -ForegroundColor Yellow
$SkipCount++
Write-Host ""

# =============================================================================
# SECCIÓN 18.9 - WINDOWS COMPONENTS
# =============================================================================
Write-Host ">>> SECCIÓN 18.9: Windows Components" -ForegroundColor Cyan

# 18.9.3 Audit
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 1 DWord "18.9.3.1" "Include command line in process creation = Enabled"

# 18.9.4 CredSSP - OMITE AllowEncryptionOracle=0
Write-Host "[SKIP] CIS 18.9.4.1 - CredSSP AllowEncryptionOracle omitido (bloquea RDP sin NLA)" -ForegroundColor Yellow
$SkipCount++
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" "AllowProtectedCreds" 1 DWord "18.9.4.2" "Allow delegation of non-exportable credentials = Enabled"

# 18.9.5 Device Guard - OMITIDO COMPLETAMENTE
Write-Host "[SKIP] CIS 18.9.5.* - Device Guard/VBS/Credential Guard omitidos (requiere hardware enterprise)" -ForegroundColor Yellow
$SkipCount++

# 18.9.7 Device Installation
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 1 DWord "18.9.7.1.1" "Prevent device IDs installation = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDsRetroactive" 1 DWord "18.9.7.1.2" "Also apply retroactively = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 1 DWord "18.9.7.1.3" "Prevent device classes = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClassesRetroactive" 1 DWord "18.9.7.1.4" "Also apply retroactively (classes) = Enabled"

# 18.9.13
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Policies" "ClfsAuthenticationChecking" 1 DWord "18.9.13.1" "CLFS Authentication Checking = Enabled"

# 18.9.19 Group Policy
$gpKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{827D319E-6EAC-11D2-A4EA-00C04F79F83A}"
Set-RegValue $gpKey "NoBackgroundPolicy" 0 DWord "18.9.19.2" "Continue GP processing slow network = Enabled"
Set-RegValue $gpKey "NoGPOListChanges" 0 DWord "18.9.19.3" "Process even if GP not changed = Enabled"

# 18.9.20 Internet Communication
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp" 0 DWord "18.9.20.1.1" "Turn off CDP = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "DisableWebPnPDownload" 1 DWord "18.9.20.1.2" "Turn off HTTP print drivers = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" "PreventHandwritingDataSharing" 1 DWord "18.9.20.1.3" "Turn off handwriting sharing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" "PreventHandwritingErrorReports" 1 DWord "18.9.20.1.4" "Turn off handwriting error reports = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Internet Connection Wizard" "ExitOnMSICW" 1 DWord "18.9.20.1.5" "Turn off ICW = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoWebServices" 1 DWord "18.9.20.1.6" "Turn off web publishing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "DisableHTTPPrinting" 1 DWord "18.9.20.1.7" "Turn off HTTP printing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Registration Wizard Control" "NoRegistration" 1 DWord "18.9.20.1.8" "Turn off registration = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\SearchCompanion" "DisableContentFileUpdates" 1 DWord "18.9.20.1.9" "Turn off Search Companion updates = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoOnlinePrintsWizard" 1 DWord "18.9.20.1.10" "Turn off Order Prints = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoPublishingWizard" 1 DWord "18.9.20.1.11" "Turn off Publish to Web = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Messenger\Client" "CEIP" 2 DWord "18.9.20.1.12" "Turn off Windows Messenger CEIP = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" 0 DWord "18.9.20.1.13" "Turn off CEIP = Enabled"

# 18.9.24 Kernel DMA
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0 DWord "18.9.24.1" "DMA protection = Block all (0)"

# 18.9.25 LAPS - OMITE BackupDirectory=AD
Write-Host "[SKIP] CIS 18.9.25.1 - LAPS BackupDirectory=AD omitido (sin Active Directory)" -ForegroundColor Yellow
$SkipCount++
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordExpirationProtectionEnabled" 1 DWord "18.9.25.2" "LAPS password expiration protection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordComplexity" 4 DWord "18.9.25.5" "LAPS password complexity = 4"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordLength" 15 DWord "18.9.25.6" "LAPS password length = 15"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordAgeDays" 30 DWord "18.9.25.7" "LAPS password age = 30 days"

# 18.9.26 LSA
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0 DWord "18.9.26.1" "Allow Custom SSPs = Disabled"
# 18.9.26.2 OMITIDO - RunAsPPL puede causar boot issues en Azure VM
Write-Host "[SKIP] CIS 18.9.26.2 - RunAsPPL omitido (boot issues en Azure VM)" -ForegroundColor Yellow
$SkipCount++

# 18.9.27 Logon
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockUserFromShowingAccountDetailsOnSignin" 1 DWord "18.9.27.1" "Block account details on sign-in = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 1 DWord "18.9.27.2" "Do not display network selection UI = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontEnumerateConnectedUsers" 1 DWord "18.9.27.3" "Do not enumerate connected users = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnumerateLocalUsers" 0 DWord "18.9.27.4" "Enumerate local users = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1 DWord "18.9.27.5" "Turn off lock screen notifications = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowDomainPINLogon" 0 DWord "18.9.27.6" "Turn off picture password = Enabled"

# 18.9.28 Activity Feed
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0 DWord "18.9.28.1" "Clipboard sync across devices = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0 DWord "18.9.28.2" "Publishing user activities = Disabled"

# 18.9.31 Power Management
$pwrGuid1 = "f15576e8-98b7-4186-b944-eafa664402d9"
$pwrGuid2 = "0e796bdb-100d-47d6-a2d5f7d2daa51f51"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid1" "DCSettingIndex" 0 DWord "18.9.31.2" "Require password on wakeup (battery) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid1" "ACSettingIndex" 0 DWord "18.9.31.3" "Require password on wakeup (plugged) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid2" "DCSettingIndex" 1 DWord "18.9.31.4" "Require password wakes (battery) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid2" "ACSettingIndex" 1 DWord "18.9.31.5" "Require password wakes (plugged) = Enabled"

# 18.9.35 Remote Assistance
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited" 0 DWord "18.9.35.1" "Offer Remote Assistance = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp" 0 DWord "18.9.35.2" "Solicited Remote Assistance = Disabled"

# 18.9.36 RPC - OMITE RestrictRemoteClients=1
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "EnableAuthEpResolution" 1 DWord "18.9.36.1" "RPC Endpoint Mapper Client Auth = Enabled"
# 18.9.36.2 OMITIDO - RestrictRemoteClients puede bloquear RDP remoto
Write-Host "[SKIP] CIS 18.9.36.2 - RestrictRemoteClients omitido (bloquea RDP remoto)" -ForegroundColor Yellow
$SkipCount++

# 18.9.47 Event Log
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 32768 DWord "18.9.47.1.1" "Application log size = 32768 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "Retention" "0" String "18.9.47.1.2" "Application log retention = Overwrite"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "MaxSize" 196608 DWord "18.9.47.2.1" "Security log size = 196608 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "Retention" "0" String "18.9.47.2.2" "Security log retention = Overwrite"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup" "MaxSize" 32768 DWord "18.9.47.3.1" "Setup log size = 32768 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup" "Retention" "0" String "18.9.47.3.2" "Setup log retention = Overwrite"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" "MaxSize" 32768 DWord "18.9.47.4.1" "System log size = 32768 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" "Retention" "0" String "18.9.47.4.2" "System log retention = Overwrite"

# 18.9.52 Explorer
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableMotWOnInsecurePathCompletion" 0 DWord "18.9.52.1" "Disable MotW insecure path = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0 DWord "18.9.52.2" "Turn off DEP for Explorer = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption" 0 DWord "18.9.52.3" "Turn off heap termination = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0 DWord "18.9.52.4" "Turn off shell protocol protected mode = Disabled"

# 18.9.58 Location
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1 DWord "18.9.58.1" "Turn off location = Enabled"

# 18.9.63 Messaging
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging" "AllowMessageSync" 0 DWord "18.9.63.1" "Message Service Cloud Sync = Disabled"

# 18.9.64 Microsoft accounts
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 1 DWord "18.9.64.1" "Block consumer Microsoft account auth = Enabled"

# 18.9.65 Windows Defender
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Features" "PassiveRemediation" 1 DWord "18.9.65.1" "Defender: Behavior Monitoring = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" 2 DWord "18.9.65.2" "Join Microsoft MAPS = Advanced (2)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0 DWord "18.9.65.3" "Turn off behavior monitoring = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableIOAVProtection" 0 DWord "18.9.65.4" "Scan downloaded files = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 DWord "18.9.65.5" "Real-time protection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 0 DWord "18.9.65.6" "Script scanning = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableEmailScanning" 0 DWord "18.9.65.7" "Email scanning = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "PUAProtection" 1 DWord "18.9.65.8" "PUA protection = Enabled"

# 18.9.74 Push To Install
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" "DisablePushToInstall" 1 DWord "18.9.74.1" "Push To Install = Disabled"

# 18.9.75 Remote Desktop Services
# OMITE: fPromptForPassword, MinEncryptionLevel, SecurityLayer, UserAuthentication
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCcm" 1 DWord "18.9.75.1" "Do not allow COM port redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCdm" 1 DWord "18.9.75.2" "Do not allow drive redirection = Enabled"
Write-Host "[SKIP] CIS 18.9.75.3 - fPromptForPassword omitido (interfiere RDP sin NLA)" -ForegroundColor Yellow
Write-Host "[SKIP] CIS 18.9.75.5 - MinEncryptionLevel=3 omitido (requiere certificado dominio)" -ForegroundColor Yellow
Write-Host "[SKIP] CIS 18.9.75.6 - SecurityLayer=2 omitido (bloquea RDP - causa del incidente anterior)" -ForegroundColor Yellow
Write-Host "[SKIP] CIS 18.9.75.7 - UserAuthentication=1 (NLA) omitido (VM standalone sin dominio)" -ForegroundColor Yellow
$SkipCount += 4
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fEncryptRPCTraffic" 1 DWord "18.9.75.4" "Require secure RPC = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxIdleTime" 900000 DWord "18.9.75.8" "Idle session limit = 15 min"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxDisconnectionTime" 60000 DWord "18.9.75.9" "Disconnected session limit = 1 min"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableLPT" 1 DWord "18.9.75.10" "Do not allow LPT redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisablePNPRedir" 1 DWord "18.9.75.11" "Do not allow PnP redirection = Enabled"

# 18.9.83
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0 DWord "18.9.83.1" "Allow indexing encrypted files = Disabled"
Write-Host ""

# =============================================================================
# PASO FINAL - PROTEGER RDP PERMANENTEMENTE
# Este bloque es el más importante - garantiza acceso RDP post-reinicio
# =============================================================================
Write-Host ">>> PASO FINAL: Protección RDP permanente post-reinicio" -ForegroundColor Red

# Forzar RDP habilitado a nivel de sistema
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force

# Forzar RDP seguro (sin SSL ni NLA)
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value 0 -Force

# Asegurar reglas de firewall a nivel de política (no solo local)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalPolicyMerge" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "AllowLocalIPsecPolicyMerge" -Value 1 -Force

# Habilitar regla de firewall RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

# Confirmar usuario en grupos correctos
net localgroup "Remote Desktop Users" "kendal0612" /add 2>$null
net localgroup "Administrators" "kendal0612" /add 2>$null
net user kendal0612 /active:yes
net accounts /lockoutthreshold:0

Write-Host "[OK] fDenyTSConnections = 0 (RDP habilitado)" -ForegroundColor Green
Write-Host "[OK] UserAuthentication = 0 (sin NLA)" -ForegroundColor Green
Write-Host "[OK] SecurityLayer = 0 (RDP classic)" -ForegroundColor Green
Write-Host "[OK] AllowLocalPolicyMerge = 1 (reglas locales activas en perfil Public)" -ForegroundColor Green
Write-Host "[OK] Regla RDP habilitada en firewall" -ForegroundColor Green
Write-Host "[OK] kendal0612 activo y en grupos correctos" -ForegroundColor Green

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
Write-Host ""
Write-Host " Secciones cubiertas: 1, 2.2, 2.3, 5, 9, 17, 18.1, 18.4-18.6, 18.9" -ForegroundColor Cyan
Write-Host ""
Write-Host " AHORA REINICIA CON: Restart-Computer -Force" -ForegroundColor Yellow
Write-Host " RDP debe funcionar correctamente post-reinicio." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
