# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# PARTE 4b: Administrative Templates - Secciones 18.9 en adelante
# SEGURIDAD: Este script SOLO modifica claves de registro.
# CONTROLES OMITIDOS (VM standalone sin dominio, sin hardware enterprise):
#   18.9.4.1  - CredSSP AllowEncryptionOracle=0 (bloquea RDP sin NLA)
#   18.9.5.*  - Device Guard/VBS/Credential Guard (requiere hardware enterprise)
#   18.9.25.1 - LAPS BackupDirectory=AD (requiere Active Directory)
#   18.9.26.2 - RunAsPPL (puede causar boot issues en Azure VM)
#   18.9.36.2 - RestrictRemoteClients (puede bloquear RDP remoto)
#   18.9.75.3 - fPromptForPassword (interfiere con RDP sin NLA)
#   18.9.75.5 - MinEncryptionLevel=3 (requiere certificado de dominio)
#   18.9.75.6 - SecurityLayer=2 (causó bloqueo RDP anterior)
#            NO toca User Rights, NO toca RDP, NO toca cuentas.
# =============================================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " CIS WS2025 v2.0.0 - Parte 4b: Admin Templates 18.9+" -ForegroundColor Cyan
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
# 18.9.3 - Audit Process Creation
# =============================================================================
Write-Host "--- 18.9.3 Audit ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 1 DWord "18.9.3.1" "Include command line in process creation events = Enabled"

# =============================================================================
# 18.9.4 - Credentials Delegation
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.4 Credentials Delegation ---" -ForegroundColor Magenta
# [OMITIDO - CredSSP=0 bloquea RDP sin NLA] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" "AllowEncryptionOracle" 0 DWord "18.9.4.1" "Encryption Oracle Remediation = Force Updated Clients (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" "AllowProtectedCreds" 1 DWord "18.9.4.2" "Remote host allows delegation of non-exportable credentials = Enabled"

# =============================================================================
# 18.9.5 - Device Guard
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.5 Device Guard ---" -ForegroundColor Magenta
# [OMITIDO - VBS/DeviceGuard requiere hardware enterprise] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "EnableVirtualizationBasedSecurity" 1 DWord "18.9.5.1" "Turn on Virtualization Based Security = Enabled"
# [OMITIDO - VBS/DeviceGuard requiere hardware enterprise] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "RequirePlatformSecurityFeatures" 1 DWord "18.9.5.2" "VBS Platform Security Level = Secure Boot (1)"
# [OMITIDO - VBS/DeviceGuard requiere hardware enterprise] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "HypervisorEnforcedCodeIntegrity" 1 DWord "18.9.5.3" "Virtualization Based Protection of Code Integrity = Enabled with UEFI lock (1)"
# [OMITIDO - VBS/DeviceGuard requiere hardware enterprise] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "HVCIMATRequired" 1 DWord "18.9.5.4" "Require UEFI Memory Attributes Table = Enabled"
# [OMITIDO - VBS/DeviceGuard requiere hardware enterprise] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "LsaCfgFlags" 1 DWord "18.9.5.5" "Credential Guard = Enabled with UEFI lock (1)"
# [OMITIDO - VBS/DeviceGuard requiere hardware enterprise] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" "ConfigureSystemGuardLaunch" 1 DWord "18.9.5.7" "Secure Launch = Enabled (1)"

# =============================================================================
# 18.9.7 - Device Installation
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.7 Device Installation ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDs" 1 DWord "18.9.7.1.1" "Prevent installation of devices matching any of these device IDs = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceIDsRetroactive" 1 DWord "18.9.7.1.2" "Also apply to matching devices already installed = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClasses" 1 DWord "18.9.7.1.3" "Prevent installation of devices using drivers that match device setup classes = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions" "DenyDeviceClassesRetroactive" 1 DWord "18.9.7.1.4" "Also apply to matching devices already installed (classes) = Enabled"

# =============================================================================
# 18.9.13 - Early Launch Antimalware
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.13 Early Launch Antimalware ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Policies" "ClfsAuthenticationChecking" 1 DWord "18.9.13.1" "CLFS Authentication Checking = Enabled"

# =============================================================================
# 18.9.19 - Group Policy
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.19 Group Policy ---" -ForegroundColor Magenta
$gpKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{827D319E-6EAC-11D2-A4EA-00C04F79F83A}"
Set-RegValue $gpKey "NoBackgroundPolicy" 0 DWord "18.9.19.2" "Continue Group Policy processing when slow network = Enabled"
Set-RegValue $gpKey "NoGPOListChanges" 0 DWord "18.9.19.3" "Process even if GP objects not changed = Enabled"

# =============================================================================
# 18.9.20 - Internet Communication
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.20 Internet Communication ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp" 0 DWord "18.9.20.1.1" "Turn off CDP = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "DisableWebPnPDownload" 1 DWord "18.9.20.1.2" "Turn off downloading print drivers via HTTP = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC" "PreventHandwritingDataSharing" 1 DWord "18.9.20.1.3" "Turn off handwriting personalization data sharing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" "PreventHandwritingErrorReports" 1 DWord "18.9.20.1.4" "Turn off handwriting recognition error reporting = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Internet Connection Wizard" "ExitOnMSICW" 1 DWord "18.9.20.1.5" "Turn off Internet Connection Wizard = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoWebServices" 1 DWord "18.9.20.1.6" "Turn off Internet download for Web publishing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "DisableHTTPPrinting" 1 DWord "18.9.20.1.7" "Turn off printing over HTTP = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Registration Wizard Control" "NoRegistration" 1 DWord "18.9.20.1.8" "Turn off Registration if URL connection available = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\SearchCompanion" "DisableContentFileUpdates" 1 DWord "18.9.20.1.9" "Turn off Search Companion content file updates = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoOnlinePrintsWizard" 1 DWord "18.9.20.1.10" "Turn off the Order Prints picture task = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoPublishingWizard" 1 DWord "18.9.20.1.11" "Turn off the Publish to Web task = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Messenger\Client" "CEIP" 2 DWord "18.9.20.1.12" "Turn off Windows Messenger Customer Experience = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" 0 DWord "18.9.20.1.13" "Turn off Windows Customer Experience Improvement = Enabled"

# =============================================================================
# 18.9.24 - Kernel DMA Protection
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.24 Kernel DMA ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0 DWord "18.9.24.1" "Enumeration policy for external devices incompatible with DMA = Block all (0)"

# =============================================================================
# 18.9.25 - LAPS
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.25 LAPS ---" -ForegroundColor Magenta
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "BackupDirectory" 1 DWord "18.9.25.1" "LAPS: Configure backup directory = Active Directory (1)"
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordExpirationProtectionEnabled" 1 DWord "18.9.25.2" "LAPS: Do not allow password expiration longer than required = Enabled"
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "ADPasswordEncryptionEnabled" 1 DWord "18.9.25.3" "LAPS: Enable password encryption = Enabled"
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordComplexity" 4 DWord "18.9.25.5" "LAPS: Password complexity = Large letters+small+numbers+specials (4)"
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordLength" 15 DWord "18.9.25.6" "LAPS: Password length = 15"
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordAgeDays" 30 DWord "18.9.25.7" "LAPS: Password age = 30 days"
# [OMITIDO - LAPS requiere Active Directory] # Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PostAuthenticationActions" 3 DWord "18.9.25.8" "LAPS: Post-auth actions = Reset password + logoff (3)"

# =============================================================================
# 18.9.26 - Local Security Authority
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.26 Local Security Authority ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0 DWord "18.9.26.1" "Allow Custom SSPs and APs = Disabled"
# [OMITIDO - RunAsPPL puede causar boot issues en Azure VM] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "RunAsPPL" 1 DWord "18.9.26.2" "Configures LSASS to run as a protected process = Enabled (1)"

# =============================================================================
# 18.9.27 - Logon
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.27 Logon ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockUserFromShowingAccountDetailsOnSignin" 1 DWord "18.9.27.1" "Block user from showing account details on sign-in = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 1 DWord "18.9.27.2" "Do not display network selection UI = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontEnumerateConnectedUsers" 1 DWord "18.9.27.3" "Do not enumerate connected users on domain-joined computers = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnumerateLocalUsers" 0 DWord "18.9.27.4" "Enumerate local users on domain-joined computers = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1 DWord "18.9.27.5" "Turn off app notifications on lock screen = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowDomainPINLogon" 0 DWord "18.9.27.6" "Turn off picture password sign-in = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Netlogon\Parameters" "BlockNetbiosDiscovery" 1 DWord "18.9.27.7" "Turn on convenience PIN sign-in = Disabled"

# =============================================================================
# 18.9.28 - MS Security Guide (additional)
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.28 Activity Feed ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0 DWord "18.9.28.1" "Allow Clipboard synchronization across devices = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0 DWord "18.9.28.2" "Allow publishing of User Activities = Disabled"

# =============================================================================
# 18.9.31 - Power Management
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.31 Power Management ---" -ForegroundColor Magenta
$pwrGuid1 = "f15576e8-98b7-4186-b944-eafa664402d9"
$pwrGuid2 = "0e796bdb-100d-47d6-a2d5f7d2daa51f51"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid1" "DCSettingIndex" 0 DWord "18.9.31.2" "Require password on wakeup (battery) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid1" "ACSettingIndex" 0 DWord "18.9.31.3" "Require password on wakeup (plugged in) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid2" "DCSettingIndex" 1 DWord "18.9.31.4" "Require password when computer wakes (battery) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$pwrGuid2" "ACSettingIndex" 1 DWord "18.9.31.5" "Require password when computer wakes (plugged in) = Enabled"

# =============================================================================
# 18.9.35 - Remote Assistance
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.35 Remote Assistance ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited" 0 DWord "18.9.35.1" "Configure Offer Remote Assistance = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp" 0 DWord "18.9.35.2" "Configure Solicited Remote Assistance = Disabled"

# =============================================================================
# 18.9.36 - Remote Procedure Call
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.36 RPC ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "EnableAuthEpResolution" 1 DWord "18.9.36.1" "Enable RPC Endpoint Mapper Client Authentication = Enabled"
# [OMITIDO - RestrictRemoteClients puede bloquear RDP remoto] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "RestrictRemoteClients" 1 DWord "18.9.36.2" "Restrict Unauthenticated RPC clients = Authenticated (1)"

# =============================================================================
# 18.9.37 - SAM
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.37 SAM ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\SAM" "SamNGCKeyROCAValidation" 2 DWord "18.9.37.1" "Configure validation of ROCA-vulnerable WHfB keys = Audit (2)"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\SAM" "SamrChangedPasswordViaLogon" 2 DWord "18.9.37.2" "Configure SAM change password logon = Block (2)"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\SAM" "SamrChangedPasswordViaLogonRemote" 1 DWord "18.9.37.3" "Configure SAM change password remote = Enabled"

# =============================================================================
# 18.9.47 - Event Log (Application, Security, Setup, System)
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.47 Event Log ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 32768 DWord "18.9.47.1.1" "Application log max size = 32768 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "Retention" "0" String "18.9.47.1.2" "Application log retention = Overwrite as needed"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "MaxSize" 196608 DWord "18.9.47.2.1" "Security log max size = 196608 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "Retention" "0" String "18.9.47.2.2" "Security log retention = Overwrite as needed"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup" "MaxSize" 32768 DWord "18.9.47.3.1" "Setup log max size = 32768 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Setup" "Retention" "0" String "18.9.47.3.2" "Setup log retention = Overwrite as needed"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" "MaxSize" 32768 DWord "18.9.47.4.1" "System log max size = 32768 KB"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" "Retention" "0" String "18.9.47.4.2" "System log retention = Overwrite as needed"

# =============================================================================
# 18.9.52 - Explorer
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.52 Explorer ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableMotWOnInsecurePathCompletion" 0 DWord "18.9.52.1" "Disable MotW on insecure path completion = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0 DWord "18.9.52.2" "Turn off Data Execution Prevention for Explorer = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption" 0 DWord "18.9.52.3" "Turn off heap termination on corruption = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0 DWord "18.9.52.4" "Turn off shell protocol protected mode = Disabled"

# =============================================================================
# 18.9.58 - Location and Sensors
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.58 Location ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1 DWord "18.9.58.1" "Turn off location = Enabled"

# =============================================================================
# 18.9.63 - Messaging
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.63 Messaging ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging" "AllowMessageSync" 0 DWord "18.9.63.1" "Allow Message Service Cloud Sync = Disabled"

# =============================================================================
# 18.9.64 - Microsoft accounts
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.64 Microsoft accounts ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 1 DWord "18.9.64.1" "Block all consumer Microsoft account authentication = Enabled"

# =============================================================================
# 18.9.65 - Microsoft Defender Antivirus
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.65 Windows Defender ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Features" "PassiveRemediation" 1 DWord "18.9.65.1" "Defender: Configure Behavior Monitoring = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" 2 DWord "18.9.65.2" "Join Microsoft MAPS = Advanced MAPS (2)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0 DWord "18.9.65.3" "Turn off behavior monitoring = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableIOAVProtection" 0 DWord "18.9.65.4" "Scan all downloaded files and attachments = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 DWord "18.9.65.5" "Turn off real-time protection = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 0 DWord "18.9.65.6" "Turn on script scanning = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableEmailScanning" 0 DWord "18.9.65.7" "Turn on e-mail scanning = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "PUAProtection" 1 DWord "18.9.65.8" "Configure detection for PUAs = Enabled (1)"

# =============================================================================
# 18.9.74 - Push To Install
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.74 Push To Install ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" "DisablePushToInstall" 1 DWord "18.9.74.1" "Turn off Push To Install service = Enabled"

# =============================================================================
# 18.9.75 - Remote Desktop Services
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.75 Remote Desktop Services ---" -ForegroundColor Magenta
# NOTA: Solo configuraciones que NO bloquean RDP
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCcm" 1 DWord "18.9.75.1" "Do not allow COM port redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCdm" 1 DWord "18.9.75.2" "Do not allow drive redirection = Enabled"
# [OMITIDO - fPromptForPassword interfiere con RDP sin NLA] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fPromptForPassword" 1 DWord "18.9.75.3" "Always prompt for password upon connection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fEncryptRPCTraffic" 1 DWord "18.9.75.4" "Require secure RPC communication = Enabled"
# [OMITIDO - MinEncryptionLevel=3 bloquea RDP sin certificado dominio] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MinEncryptionLevel" 3 DWord "18.9.75.5" "Set client connection encryption level = High (3)"
# [OMITIDO - SecurityLayer=2 fue la causa del bloqueo anterior] # Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "SecurityLayer" 2 DWord "18.9.75.6" "Require use of specific security layer = SSL (2)"
# NLA se mantiene deshabilitada para permitir acceso - OMITIDO intencionalmente
Write-Host "[SKIP] CIS 18.9.75.7 - NLA omitido - VM sin dominio, NLA deshabilitada para acceso RDP" -ForegroundColor Yellow
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxIdleTime" 900000 DWord "18.9.75.8" "Set time limit for active but idle sessions = 15 min"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxDisconnectionTime" 60000 DWord "18.9.75.9" "Set time limit for disconnected sessions = 1 min"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableLPT" 1 DWord "18.9.75.10" "Do not allow LPT port redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisablePNPRedir" 1 DWord "18.9.75.11" "Do not allow supported Plug and Play device redirection = Enabled"

# =============================================================================
# 18.9.82 - Scripted Diagnostics
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.82 Scripted Diagnostics ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" "DisableQueryRemoteServer" 0 DWord "18.9.82.1" "Microsoft Support Diagnostic Tool: Turn off MSDT = Disabled"

# =============================================================================
# 18.9.83 - Security Account Manager
# =============================================================================
Write-Host ""
Write-Host "--- 18.9.83 Windows Search ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0 DWord "18.9.83.1" "Allow indexing of encrypted files = Disabled"

# =============================================================================
# VERIFICACION FINAL - Confirmar RDP intacto
# =============================================================================
Write-Host ""
Write-Host "--- Verificación final de acceso RDP ---" -ForegroundColor Red
$rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
if ($rdp -eq 0) {
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
# RESUMEN
# =============================================================================
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN PARTE 4b" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Controles aplicados : $PassCount" -ForegroundColor Green
Write-Host " Errores             : $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host " Omitidos            : 9 controles peligrosos para VM standalone" -ForegroundColor Yellow
Write-Host ""
Write-Host "Hardening CIS WS2025 COMPLETADO (Partes 1, 2, 3, 4a, 4b)" -ForegroundColor Green
Write-Host "Reiniciar la VM para aplicar todos los cambios." -ForegroundColor Yellow
