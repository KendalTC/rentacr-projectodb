# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# PARTE 5: Controles faltantes de la sección 18
#
# SEGURIDAD: Este script SOLO modifica claves de registro.
#            NO toca User Rights, NO toca RDP, NO toca cuentas.
#
# CONTROLES OMITIDOS INTENCIONALMENTE (documentados al final):
#   18.9.4.1   - CredSSP (bloquea RDP sin NLA)
#   18.9.5.*   - Device Guard/VBS (requiere hardware enterprise)
#   18.9.26.1  - LAPS BackupDirectory=AD (requiere Active Directory)
#   18.9.27.2  - LSASS RunAsPPL (boot issues en Azure VM)
#   18.10.57.3.9.1 - Always prompt for password (interfiere RDP sin NLA)
#   18.10.57.3.9.3 - SecurityLayer=SSL (causó bloqueo RDP anterior)
#   18.10.57.3.9.4 - NLA (bloquea RDP en VM standalone)
#   18.10.57.3.9.5 - MinEncryptionLevel=High (requiere certificado dominio)
# =============================================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " CIS WS2025 v2.0.0 - Parte 5: Controles Faltantes" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

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

function Skip-Control {
    param($CIS, $Desc, $Reason)
    Write-Host "[SKIP] CIS $CIS - $Desc ($Reason)" -ForegroundColor Yellow
    $script:SkipCount++
}

# =============================================================================
# 18.5.5 - KeepAliveTime
# =============================================================================
Write-Host "--- 18.5 MSS (Legacy) ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "KeepAliveTime" 300000 DWord "18.5.5" "MSS: KeepAliveTime = 300000ms (5 min)"
Write-Host ""

# =============================================================================
# 18.6.4.3 - Turn off default IPv6 DNS Servers
# =============================================================================
Write-Host "--- 18.6.4 DNS Client ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "DisableSmartNameResolution" 1 DWord "18.6.4.3" "Turn off default IPv6 DNS Servers = Enabled"
Write-Host ""

# =============================================================================
# 18.6.20 - Windows Connect Now
# =============================================================================
Write-Host "--- 18.6.20 Windows Connect Now ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "EnableRegistrars" 0 DWord "18.6.20.1" "WCN wireless config = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableUPnPRegistrar" 0 DWord "18.6.20.1" "WCN UPnP Registrar = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableInBand802DOT11Registrar" 0 DWord "18.6.20.1" "WCN InBand 802.11 = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableFlashConfigRegistrar" 0 DWord "18.6.20.1" "WCN Flash Config = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableWPDRegistrar" 0 DWord "18.6.20.1" "WCN WPD Registrar = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\UI" "DisableWcnUi" 1 DWord "18.6.20.2" "Prohibit WCN wizards = Enabled"
Write-Host ""

# =============================================================================
# 18.6.21.1 - Minimize simultaneous connections
# =============================================================================
Write-Host "--- 18.6.21 Windows Connection Manager ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections" 3 DWord "18.6.21.1" "Minimize simultaneous connections = 3 (Ethernet over WiFi)"
# 18.6.21.2 OMITIDO - fBlockNonDomain bloquea Azure
Skip-Control "18.6.21.2" "Prohibit non-domain network connection" "Azure es red no-dominio - bloquearía RDP"
Write-Host ""

# =============================================================================
# 18.7 - PRINTERS
# =============================================================================
Write-Host "--- 18.7 Printers ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "RegisterSpoolerRemoteRpcEndPoint" 2 DWord "18.7.1" "Allow Print Spooler to accept client connections = Disabled (2)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "RedirectionguardPolicy" 1 DWord "18.7.2" "Configure Redirection Guard = Enabled (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcUseNamedPipeProtocol" 0 DWord "18.7.3" "RPC outgoing connections = RPC over TCP (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcAuthentication" 0 DWord "18.7.4" "RPC authentication for outgoing = Default (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "ForceKerberosForRpc" 0 DWord "18.7.5" "RPC listener protocols = RPC over TCP (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcProtocols" 5 DWord "18.7.5" "RPC listener protocols value = 5"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "AuthenticationProtocol" 0 DWord "18.7.6" "RPC listener auth = Negotiate (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" "RpcTcpPort" 0 DWord "18.7.7" "RPC over TCP port = 0"
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Print" "RpcAuthnLevelPrivacyEnabled" 1 DWord "18.7.8" "RPC packet level privacy = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "WppEnabled" 1 DWord "18.7.9" "Windows protected print = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "PointAndPrint_TrustedServers" 1 DWord "18.7.10" "Limit print driver install to Administrators = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" "CopyFilesPolicy" 1 DWord "18.7.11" "Queue-specific files = Color profiles only (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "NoWarningNoElevationOnInstall" 0 DWord "18.7.12" "Point and Print new connection = Warn + elevation prompt (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "UpdatePromptSettings" 0 DWord "18.7.13" "Point and Print update = Warn + elevation prompt (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "RequireIpps" 1 DWord "18.7.14" "Require IPPS for IPP printers = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_CA" 1 DWord "18.7.15" "IPP TLS: Disallow invalid CA = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_ServerCert" 1 DWord "18.7.16" "IPP TLS: Disallow non-server certs = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_CN" 1 DWord "18.7.17" "IPP TLS: Disallow invalid CN = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\IPP" "TLSValidationMode_Date" 1 DWord "18.7.18" "IPP TLS: Disallow invalid date = Enabled"
Write-Host ""

# =============================================================================
# 18.8 - START MENU AND TASKBAR
# =============================================================================
Write-Host "--- 18.8 Start Menu and Taskbar ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" "NoCloudApplicationNotification" 1 DWord "18.8.1.1" "Turn off notifications network usage = Enabled"
Write-Host ""

# =============================================================================
# 18.9.13 - Early Launch Antimalware
# =============================================================================
Write-Host "--- 18.9.13 Early Launch Antimalware ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 3 DWord "18.9.13.1" "Boot-Start Driver = Good, unknown and bad but critical (3)"
Write-Host ""

# =============================================================================
# 18.9.17 - Filesystem / CLFS
# =============================================================================
Write-Host "--- 18.9.17 Filesystem ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Policies" "ClfsAuthenticationChecking" 1 DWord "18.9.17.1" "Enable CLFS logfile authentication = Enabled"
Write-Host ""

# =============================================================================
# 18.9.19 - Group Policy (additional)
# =============================================================================
Write-Host "--- 18.9.19 Group Policy ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableCdp" 0 DWord "18.9.19.4" "Continue experiences on this device (CDP) = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableBkGndGroupPolicy" 0 DWord "18.9.19.5" "Turn off background refresh of Group Policy = Disabled"
Write-Host ""

# =============================================================================
# 18.9.20.1.13 - Turn off Windows Error Reporting
# =============================================================================
Write-Host "--- 18.9.20 Internet Communication (adicional) ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 1 DWord "18.9.20.1.13" "Turn off Windows Error Reporting = Enabled"
Write-Host ""

# =============================================================================
# 18.9.23 - Kerberos
# =============================================================================
Write-Host "--- 18.9.23 Kerberos ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "DevicePKInitEnabled" 1 DWord "18.9.23.1" "Support device authentication using certificate = Enabled: Automatic"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "DevicePKInitBehavior" 0 DWord "18.9.23.1" "Device PKInit Behavior = Automatic (0)"
Write-Host ""

# =============================================================================
# 18.9.24 - Kernel DMA Protection
# =============================================================================
Write-Host "--- 18.9.24 Kernel DMA Protection ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0 DWord "18.9.24.1" "DMA Protection = Block All (0)"
Write-Host ""

# =============================================================================
# 18.9.26 - LAPS (additional controls)
# =============================================================================
Write-Host "--- 18.9.26 LAPS ---" -ForegroundColor Magenta
Skip-Control "18.9.26.1" "LAPS: Configure backup directory = Active Directory" "Requiere Active Directory - VM standalone"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordExpirationProtectionEnabled" 1 DWord "18.9.26.2" "LAPS: Password expiration protection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "ADPasswordEncryptionEnabled" 1 DWord "18.9.26.3" "LAPS: Enable password encryption = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordComplexity" 4 DWord "18.9.26.4" "LAPS: Password complexity = Large+Small+Numbers+Specials (4)"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordLength" 15 DWord "18.9.26.5" "LAPS: Password length = 15"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PasswordAgeDays" 30 DWord "18.9.26.6" "LAPS: Password age = 30 days"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PostAuthenticationResetDelay" 8 DWord "18.9.26.7" "LAPS: Post-auth grace period = 8 hours"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS" "PostAuthenticationActions" 3 DWord "18.9.26.8" "LAPS: Post-auth actions = Reset password + logoff (3)"
Write-Host ""

# =============================================================================
# 18.9.27 - Local Security Authority (additional)
# =============================================================================
Write-Host "--- 18.9.27 Local Security Authority ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCustomSSPsAPs" 0 DWord "18.9.27.1" "Allow Custom SSPs = Disabled"
Skip-Control "18.9.27.2" "LSASS RunAsPPL = Enabled with UEFI lock" "Puede causar boot failure en Azure VM"
Write-Host ""

# =============================================================================
# 18.9.28 - Locale Services
# =============================================================================
Write-Host "--- 18.9.28 Locale Services ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International" "BlockUserInputMethodsForSignIn" 1 DWord "18.9.28.1" "Disallow copying of user input methods to system account = Enabled"
Write-Host ""

# =============================================================================
# 18.9.29.6 - Turn on convenience PIN sign-in
# =============================================================================
Write-Host "--- 18.9.29 Logon (adicional) ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowDomainPINLogon" 0 DWord "18.9.29.6" "Turn on convenience PIN sign-in = Disabled"
Write-Host ""

# =============================================================================
# 18.9.31.1.1 - Block NetBIOS-based discovery
# =============================================================================
Write-Host "--- 18.9.31 Net Logon ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Netlogon\Parameters" "BlockNetbiosDiscovery" 1 DWord "18.9.31.1.1" "Block NetBIOS-based discovery for DC location = Enabled"
Write-Host ""

# =============================================================================
# 18.9.33 - OS Policies
# =============================================================================
Write-Host "--- 18.9.33 OS Policies ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0 DWord "18.9.33.1" "Allow Clipboard sync across devices = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0 DWord "18.9.33.2" "Allow upload of User Activities = Disabled"
Write-Host ""

# =============================================================================
# 18.9.35 - Power Management / Sleep Settings
# =============================================================================
Write-Host "--- 18.9.35 Power Management ---" -ForegroundColor Magenta
$netStandbyGuid = "f15576e8-98b7-4186-b944-eafa664402d9"
$wakePasswordGuid = "0e796bdb-100d-47d6-a2d5f7d2daa51f51"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$netStandbyGuid" "DCSettingIndex" 0 DWord "18.9.35.6.1" "Network connectivity during standby (battery) = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$netStandbyGuid" "ACSettingIndex" 0 DWord "18.9.35.6.2" "Network connectivity during standby (plugged) = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$wakePasswordGuid" "DCSettingIndex" 1 DWord "18.9.35.6.3" "Require password on wake (battery) = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$wakePasswordGuid" "ACSettingIndex" 1 DWord "18.9.35.6.4" "Require password on wake (plugged) = Enabled"
Write-Host ""

# =============================================================================
# 18.9.41.3 - SAM change password RPC (MS only)
# =============================================================================
Write-Host "--- 18.9.41 Security Account Manager ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\SAM" "SamrChangedPasswordViaLogonRemote" 1 DWord "18.9.41.3" "SAM change password RPC = Block all (MS only)"
Write-Host ""

# =============================================================================
# 18.9.49 - Troubleshooting and Diagnostics
# =============================================================================
Write-Host "--- 18.9.49 Troubleshooting ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy" "DisableQueryRemoteServer" 0 DWord "18.9.49.5.1" "MSDT interactive communication = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WDI\{9c5a40da-b965-4fc3-8781-88dd50a6299d}" "ScenarioExecutionEnabled" 0 DWord "18.9.49.11.1" "Enable/Disable PerfTrack = Disabled"
Write-Host ""

# =============================================================================
# 18.9.51 - User Profiles
# =============================================================================
Write-Host "--- 18.9.51 User Profiles ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" 1 DWord "18.9.51.1" "Turn off the advertising ID = Enabled"
Write-Host ""

# =============================================================================
# 18.9.53 - Windows Time Service
# =============================================================================
Write-Host "--- 18.9.53 Windows Time Service ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\W32Time\TimeProviders\NtpClient" "Enabled" 1 DWord "18.9.53.1.1" "Enable Windows NTP Client = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\W32Time\TimeProviders\NtpServer" "Enabled" 0 DWord "18.9.53.1.2" "Enable Windows NTP Server = Disabled (MS only)"
Write-Host ""

# =============================================================================
# 18.10.4 - App Package Deployment
# =============================================================================
Write-Host "--- 18.10.4 App Package Deployment ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" "RestrictAppToSystemVolume" 0 DWord "18.10.4.1" "Allow app data between users = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Appx" "BlockNonAdminUserInstall" 1 DWord "18.10.4.2" "Not allow per-user unsigned packages = Enabled"
Write-Host ""

# =============================================================================
# 18.10.6.1 - Allow Microsoft accounts to be optional
# =============================================================================
Write-Host "--- 18.10.6 App Runtime ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "MSAOptional" 1 DWord "18.10.6.1" "Allow Microsoft accounts to be optional = Enabled"
Write-Host ""

# =============================================================================
# 18.10.8 - AutoPlay Policies
# =============================================================================
Write-Host "--- 18.10.8 AutoPlay ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoAutoplayfornonVolume" 1 DWord "18.10.8.1" "Disallow Autoplay for non-volume devices = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoAutorun" 1 DWord "18.10.8.2" "Default AutoRun behavior = Do not execute (1)"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 255 DWord "18.10.8.3" "Turn off Autoplay = All drives (255)"
Write-Host ""

# =============================================================================
# 18.10.9.1.1 - Enhanced anti-spoofing
# =============================================================================
Write-Host "--- 18.10.9 Biometrics ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" "EnhancedAntiSpoofing" 1 DWord "18.10.9.1.1" "Configure enhanced anti-spoofing = Enabled"
Write-Host ""

# =============================================================================
# 18.10.11.1 - Allow Use of Camera
# =============================================================================
Write-Host "--- 18.10.11 Camera ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Camera" "AllowCamera" 0 DWord "18.10.11.1" "Allow Use of Camera = Disabled"
Write-Host ""

# =============================================================================
# 18.10.13 - Cloud Content
# =============================================================================
Write-Host "--- 18.10.13 Cloud Content ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableConsumerAccountStateContent" 1 DWord "18.10.13.1" "Turn off cloud consumer account state content = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableCloudOptimizedContent" 1 DWord "18.10.13.2" "Turn off cloud optimized content = Enabled"
Write-Host ""

# =============================================================================
# 18.10.14.1 - Require pin for pairing
# =============================================================================
Write-Host "--- 18.10.14 Connect ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Connect" "RequirePinForPairing" 1 DWord "18.10.14.1" "Require pin for pairing = First Time (1)"
Write-Host ""

# =============================================================================
# 18.10.15 - Credential User Interface
# =============================================================================
Write-Host "--- 18.10.15 Credential UI ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "DisablePasswordReveal" 1 DWord "18.10.15.1" "Do not display password reveal button = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnumerateAdministrators" 0 DWord "18.10.15.2" "Enumerate administrator accounts on elevation = Disabled"
Write-Host ""

# =============================================================================
# 18.10.16 - Data Collection and Preview Builds
# =============================================================================
Write-Host "--- 18.10.16 Data Collection ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 1 DWord "18.10.16.1" "Allow Diagnostic Data = Required only (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DisableEnterpriseAuthProxy" 1 DWord "18.10.16.2" "Disable Authenticated Proxy = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1 DWord "18.10.16.3" "Do not show feedback notifications = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "EnableOneSettingsAuditing" 1 DWord "18.10.16.4" "Enable OneSettings Auditing = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDiagnosticLogCollection" 1 DWord "18.10.16.5" "Limit Diagnostic Log Collection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDumpCollection" 1 DWord "18.10.16.6" "Limit Dump Collection = Enabled"
Write-Host ""

# =============================================================================
# 18.10.18 - Desktop App Installer (winget)
# =============================================================================
Write-Host "--- 18.10.18 Desktop App Installer ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableAppInstaller" 0 DWord "18.10.18.1" "Enable App Installer = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableExperimentalFeatures" 0 DWord "18.10.18.2" "Enable App Installer Experimental Features = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableHashOverride" 0 DWord "18.10.18.3" "Enable App Installer Hash Override = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableLocalArchiveMalwareScanOverride" 0 DWord "18.10.18.4" "Enable Local Archive Malware Scan Override = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableMSAppInstallerProtocol" 0 DWord "18.10.18.5" "Enable ms-appinstaller protocol = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableMicrosoftStoreSourceCertificateValidationBypass" 0 DWord "18.10.18.6" "Enable MS Store Source Cert Validation Bypass = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller" "EnableWindowsPackageManagerCommandLineInterfaces" 0 DWord "18.10.18.7" "Enable Windows Package Manager CLI = Disabled"
Write-Host ""

# =============================================================================
# 18.10.29 - File Explorer (additional)
# =============================================================================
Write-Host "--- 18.10.29 File Explorer ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableMotWOnInsecurePathCompletion" 0 DWord "18.10.29.2" "Do not apply MotW from insecure sources = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0 DWord "18.10.29.3" "Turn off DEP for Explorer = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoHeapTerminationOnCorruption" 0 DWord "18.10.29.4" "Turn off heap termination on corruption = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0 DWord "18.10.29.5" "Turn off shell protocol protected mode = Disabled"
Write-Host ""

# =============================================================================
# 18.10.36.1 - Turn off location
# =============================================================================
Write-Host "--- 18.10.36 Location ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1 DWord "18.10.36.1" "Turn off location = Enabled"
Write-Host ""

# =============================================================================
# 18.10.40.1 - Messaging
# =============================================================================
Write-Host "--- 18.10.40 Messaging ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Messaging" "AllowMessageSync" 0 DWord "18.10.40.1" "Allow Message Service Cloud Sync = Disabled"
Write-Host ""

# =============================================================================
# 18.10.41.1 - Microsoft account
# =============================================================================
Write-Host "--- 18.10.41 Microsoft Account ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" "DisableUserAuth" 1 DWord "18.10.41.1" "Block all consumer Microsoft account auth = Enabled"
Write-Host ""

# =============================================================================
# 18.10.42 - Windows Defender (additional missing controls)
# =============================================================================
Write-Host "--- 18.10.42 Windows Defender ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Features" "TamperProtection" 5 DWord "18.10.42.4.1" "Enable EDR in block mode = Enabled (5)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "LocalSettingOverrideSpynetReporting" 0 DWord "18.10.42.5.1" "Override local setting for MAPS = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" "SpynetReporting" 2 DWord "18.10.42.5.2" "Join Microsoft MAPS = Advanced (2)"
# ASR Rules
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR" "ExploitGuard_ASR_Rules" 1 DWord "18.10.42.6.1.1" "Configure ASR rules = Enabled"
# ASR Rule States - configure common rules as Block (1)
$asrRules = @{
    "56a863a9-875e-4185-98a7-b882c64b5ce5" = 1  # Block abuse of exploited vulnerable signed drivers
    "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c" = 1  # Block Adobe Reader from creating child processes
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a" = 1  # Block all Office applications from creating child processes
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b0" = 1  # Block credential stealing from LSASS
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550" = 1  # Block executable content from email/webmail
    "01443614-cd74-433a-b99e-2ecdc07bfc25" = 1  # Block untrusted and unsigned processes from USB
    "5beb7efe-fd9a-4556-801d-275e5ffc04cc" = 1  # Block execution of potentially obfuscated scripts
    "d3e037e1-3eb8-44c8-a917-57927947596d" = 1  # Block JavaScript/VBScript from launching executables
    "3b576869-a4ec-4529-8536-b80a7769e899" = 1  # Block Office apps from creating executable content
    "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84" = 1  # Block Office apps from injecting into other processes
    "26190899-1602-49e8-8b27-eb1d0a1ce869" = 1  # Block Office communication app from creating child processes
    "e6db77e5-3df2-4cf1-b95a-636979351e5b" = 1  # Block persistence through WMI event subscription
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4" = 1  # Block untrusted unsigned processes from USB
    "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b" = 1  # Block Win32 API calls from Office macros
    "c1db55ab-c21a-4637-bb3f-a12568109d35" = 1  # Use advanced protection against ransomware
}
try {
    $asrPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules"
    if (-not (Test-Path $asrPath)) { New-Item -Path $asrPath -Force | Out-Null }
    foreach ($rule in $asrRules.Keys) {
        Set-ItemProperty -Path $asrPath -Name $rule -Value $asrRules[$rule] -Type String -Force
    }
    Write-Host "[OK] CIS 18.10.42.6.1.2 - ASR rules configured (15 rules = Block)" -ForegroundColor Green
    $PassCount++
} catch {
    Write-Host "[ERROR] CIS 18.10.42.6.1.2 - ASR rules: $_" -ForegroundColor Red
    $ErrorCount++
}
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" "EnableNetworkProtection" 1 DWord "18.10.42.6.3.1" "Network Protection = Block (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" "MpEnableFileHashComputation" 1 DWord "18.10.42.7.1" "Enable file hash computation = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" "DisableSignatureRetirement" 0 DWord "18.10.42.8.1" "Convert warn verdict to block = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0 DWord "18.10.42.10.3" "Turn off real-time protection = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableBehaviorMonitoring" 0 DWord "18.10.42.10.4" "Turn on behavior monitoring = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableScriptScanning" 0 DWord "18.10.42.10.5" "Turn on script scanning = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation\Behavioral Network Blocks\Brute Force" "BruteForceProtectionAggressiveness" 1 DWord "18.10.42.11.1.1.1" "Brute-Force Protection aggressiveness = Medium (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation\Behavioral Network Blocks\Brute Force" "BruteForceProtectionConfiguredState" 2 DWord "18.10.42.11.1.1.2" "Remote Encryption Protection Mode = Audit (2)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Remediation\Behavioral Network Blocks\Remote Encryption" "RemoteEncryptionProtectionAggressiveness" 1 DWord "18.10.42.11.1.2.1" "Remote Encryption Protection aggressiveness = Medium (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" "DisableGenericRePorts" 1 DWord "18.10.42.12.1" "Configure Watson events = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableScanningMappedNetworkDrivesForFullScan" 0 DWord "18.10.42.13.1" "Scan excluded files during quick scans = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisablePackedExeScanning" 0 DWord "18.10.42.13.2" "Scan packed executables = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableRemovableDriveScanning" 0 DWord "18.10.42.13.3" "Scan removable drives = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "QuickScanInterval" 7 DWord "18.10.42.13.4" "Trigger quick scan after 7 days = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" "DisableEmailScanning" 0 DWord "18.10.42.13.5" "Turn on e-mail scanning = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "PUAProtection" 1 DWord "18.10.42.16" "Configure detection for PUAs = Block (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" "DisableLocalAdminMerge" 1 DWord "18.10.42.17" "Control whether exclusions are visible to local users = Enabled"
Write-Host ""

# =============================================================================
# 18.10.56.1 - Push To Install
# =============================================================================
Write-Host "--- 18.10.56 Push To Install ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall" "DisablePushToInstall" 1 DWord "18.10.56.1" "Turn off Push To Install = Enabled"
Write-Host ""

# =============================================================================
# 18.10.57 - Remote Desktop Services (missing controls)
# OMITE controles que bloquean RDP: 9.1, 9.3, 9.4, 9.5
# =============================================================================
Write-Host "--- 18.10.57 Remote Desktop Services ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableClip" 0 DWord "18.10.57.2.2" "Do not allow passwords to be saved = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fSingleSessionPerUser" 1 DWord "18.10.57.3.2.1" "Restrict RDS users to single session = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableAudioCapture" 1 DWord "18.10.57.3.3.1" "Allow UI Automation redirection = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCcm" 1 DWord "18.10.57.3.3.2" "Do not allow COM port redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableCdm" 1 DWord "18.10.57.3.3.3" "Do not allow drive redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableLocationRedir" 1 DWord "18.10.57.3.3.4" "Do not allow location redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableLPT" 1 DWord "18.10.57.3.3.5" "Do not allow LPT port redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisablePNPRedir" 1 DWord "18.10.57.3.3.6" "Do not allow PnP device redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDisableWebAuthn" 1 DWord "18.10.57.3.3.7" "Do not allow WebAuthn redirection = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "SCClipLevel" 0 DWord "18.10.57.3.3.8" "Restrict clipboard server to client = Disabled (transfers allowed for RDP use)"
# RDP Security - OMITE los que bloquean acceso
Skip-Control "18.10.57.3.9.1" "Always prompt for password upon connection" "Interfiere con RDP sin NLA en VM standalone"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fEncryptRPCTraffic" 1 DWord "18.10.57.3.9.2" "Require secure RPC communication = Enabled"
Skip-Control "18.10.57.3.9.3" "Require SSL security layer for RDP" "Causó bloqueo RDP - requiere certificado de dominio"
Skip-Control "18.10.57.3.9.4" "Require NLA for RDP" "VM standalone sin dominio - bloquea acceso RDP"
Skip-Control "18.10.57.3.9.5" "Set client connection encryption level = High" "Requiere certificado SSL de dominio"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxIdleTime" 900000 DWord "18.10.57.3.10.1" "Idle session limit = 15 min (900000ms)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MaxDisconnectionTime" 60000 DWord "18.10.57.3.10.2" "Disconnected session limit = 1 min"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "DeleteTempDirsOnExit" 1 DWord "18.10.57.3.11.1" "Do not delete temp folders upon exit = Disabled (delete them)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "PerSessionTempDir" 1 DWord "18.10.57.3.11.2" "Do not use temporary folders per session = Disabled"
Write-Host ""

# =============================================================================
# 18.10.58.1 - RSS Feeds
# =============================================================================
Write-Host "--- 18.10.58 RSS Feeds ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" "DisableEnclosureDownload" 1 DWord "18.10.58.1" "Prevent downloading of enclosures = Enabled"
Write-Host ""

# =============================================================================
# 18.10.59 - Search
# =============================================================================
Write-Host "--- 18.10.59 Search ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCloudSearch" 0 DWord "18.10.59.2" "Allow Cloud Search = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowIndexingEncryptedStoresOrItems" 0 DWord "18.10.59.3" "Allow indexing of encrypted files = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "EnableDynamicContentInWSB" 0 DWord "18.10.59.4" "Allow search highlights = Disabled"
Write-Host ""

# =============================================================================
# 18.10.63.1 - Software Protection Platform
# =============================================================================
Write-Host "--- 18.10.63 Software Protection ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" "NoGenTicket" 1 DWord "18.10.63.1" "Turn off KMS Client Online AVS Validation = Enabled"
Write-Host ""

# =============================================================================
# 18.10.77 - Windows Defender SmartScreen
# =============================================================================
Write-Host "--- 18.10.77 SmartScreen ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1 DWord "18.10.77.2.1" "Configure Windows Defender SmartScreen = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "ShellSmartScreenLevel" "Block" String "18.10.77.2.1" "SmartScreen Level = Warn and prevent bypass"
Write-Host ""

# =============================================================================
# 18.10.81 - Windows Ink Workspace
# =============================================================================
Write-Host "--- 18.10.81 Windows Ink Workspace ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowSuggestedAppsInWindowsInkWorkspace" 0 DWord "18.10.81.1" "Allow suggested apps in Ink Workspace = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 1 DWord "18.10.81.2" "Allow Windows Ink Workspace = On but disallow above lock (1)"
Write-Host ""

# =============================================================================
# 18.10.82 - Windows Installer
# =============================================================================
Write-Host "--- 18.10.82 Windows Installer ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "EnableUserControl" 0 DWord "18.10.82.1" "Allow user control over installs = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "AlwaysInstallElevated" 0 DWord "18.10.82.2" "Always install with elevated privileges = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" "SafeForScripting" 0 DWord "18.10.82.3" "Prevent IE security prompt for Installer scripts = Disabled"
Write-Host ""

# =============================================================================
# 18.10.83 - Windows Logon Options
# =============================================================================
Write-Host "--- 18.10.83 Windows Logon Options ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableMPR" 0 DWord "18.10.83.1" "Transmission of user password in MPR notifications = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableAutomaticRestartSignOn" 1 DWord "18.10.83.2" "Sign-in and lock automatically after restart = Disabled"
Write-Host ""

# =============================================================================
# 18.10.88 - Windows PowerShell
# =============================================================================
Write-Host "--- 18.10.88 Windows PowerShell ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" "EnableScriptBlockLogging" 1 DWord "18.10.88.1" "Turn on PowerShell Script Block Logging = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" "EnableTranscripting" 1 DWord "18.10.88.2" "Turn on PowerShell Transcription = Enabled"
Write-Host ""

# =============================================================================
# 18.10.90 - WinRM Client and Service
# =============================================================================
Write-Host "--- 18.10.90 WinRM ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowBasic" 0 DWord "18.10.90.1.1" "WinRM Client: Allow Basic auth = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowUnencryptedTraffic" 0 DWord "18.10.90.1.2" "WinRM Client: Allow unencrypted traffic = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" "AllowDigest" 0 DWord "18.10.90.1.3" "WinRM Client: Disallow Digest auth = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowBasic" 0 DWord "18.10.90.2.1" "WinRM Service: Allow Basic auth = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowAutoConfig" 0 DWord "18.10.90.2.2" "WinRM Service: Allow remote server management = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowUnencryptedTraffic" 0 DWord "18.10.90.2.3" "WinRM Service: Allow unencrypted traffic = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "DisableRunAs" 1 DWord "18.10.90.2.4" "WinRM Service: Disallow RunAs credentials = Enabled"
Write-Host ""

# =============================================================================
# 18.10.91.1 - Windows Remote Shell
# =============================================================================
Write-Host "--- 18.10.91 Windows Remote Shell ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" "AllowRemoteShellAccess" 0 DWord "18.10.91.1" "Allow Remote Shell Access = Disabled"
Write-Host ""

# =============================================================================
# 18.10.93 - Windows Security
# =============================================================================
Write-Host "--- 18.10.93 Windows Security ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 1 DWord "18.10.93.2.1" "Prevent users from modifying settings = Enabled"
Write-Host ""

# =============================================================================
# 18.10.94 - Windows Update
# =============================================================================
Write-Host "--- 18.10.94 Windows Update ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 0 DWord "18.10.94.1.1" "No auto-restart with logged on users = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0 DWord "18.10.94.2.1" "Configure Automatic Updates = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "ScheduledInstallDay" 0 DWord "18.10.94.2.2" "Scheduled install day = Every day (0)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "ManagePreviewBuildsPolicyValue" 1 DWord "18.10.94.4.1" "Manage preview builds = Disabled (1)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferQualityUpdates" 1 DWord "18.10.94.4.2" "Select when Quality Updates received = 0 days"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DeferQualityUpdatesPeriodInDays" 0 DWord "18.10.94.4.2" "Quality Updates deferral = 0 days"
Write-Host ""

# =============================================================================
# 18.11 - Custom Settings
# =============================================================================
Write-Host "--- 18.11 Custom Settings ---" -ForegroundColor Magenta
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" "WpadOverride" 1 DWord "18.11.1" "Disable WPAD = Enabled"
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "ProxySettingsPerUser" 1 DWord "18.11.2" "Disable proxy authentication = Enabled"
Write-Host ""

# =============================================================================
# VERIFICACION FINAL - Confirmar RDP intacto
# =============================================================================
Write-Host "--- Verificación final de acceso RDP ---" -ForegroundColor Red
$rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
if ($rdp -eq 0) {
    Write-Host "[OK] RDP habilitado correctamente" -ForegroundColor Green
} else {
    Write-Host "[FIXING] RDP estaba deshabilitado - corrigiendo..." -ForegroundColor Yellow
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 -Force
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    Write-Host "[OK] RDP habilitado" -ForegroundColor Green
}

# =============================================================================
# RESUMEN
# =============================================================================
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN PARTE 5" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Controles aplicados : $PassCount" -ForegroundColor Green
Write-Host " Errores             : $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host " Omitidos (justif.)  : $SkipCount" -ForegroundColor Yellow
Write-Host ""
Write-Host " Controles OMITIDOS intencionalmente:" -ForegroundColor Yellow
Write-Host "  18.6.21.2 - fBlockNonDomain (Azure es red no-dominio)" -ForegroundColor Yellow
Write-Host "  18.9.26.1 - LAPS BackupDirectory=AD (sin Active Directory)" -ForegroundColor Yellow
Write-Host "  18.9.27.2 - LSASS RunAsPPL (boot issues en Azure VM)" -ForegroundColor Yellow
Write-Host "  18.10.57.3.9.1 - Always prompt password (interfiere RDP sin NLA)" -ForegroundColor Yellow
Write-Host "  18.10.57.3.9.3 - SecurityLayer=SSL (bloquea RDP sin cert. dominio)" -ForegroundColor Yellow
Write-Host "  18.10.57.3.9.4 - NLA (bloquea RDP en VM standalone)" -ForegroundColor Yellow
Write-Host "  18.10.57.3.9.5 - MinEncryptionLevel=High (requiere cert. dominio)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Parte 5 completada. Reinicia la VM para aplicar todos los cambios." -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
