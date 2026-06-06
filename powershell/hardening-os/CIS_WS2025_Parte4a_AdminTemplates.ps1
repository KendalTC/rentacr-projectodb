# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# PARTE 4a: Administrative Templates - Secciones 18.1 a 18.6
# SEGURIDAD: Este script SOLO modifica claves de registro.
#            NO toca User Rights, NO toca RDP, NO toca cuentas.
# =============================================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " CIS WS2025 v2.0.0 - Parte 4a: Admin Templates 18.1-18.6" -ForegroundColor Cyan
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
# 18.1 CONTROL PANEL
# =============================================================================
Write-Host "--- 18.1 Control Panel ---" -ForegroundColor Magenta

# 18.1.1.1 - Prevent enabling lock screen camera
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera" 1 DWord "18.1.1.1" "Prevent enabling lock screen camera = Enabled"

# 18.1.1.2 - Prevent enabling lock screen slide show
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 1 DWord "18.1.1.2" "Prevent enabling lock screen slide show = Enabled"

# 18.1.2.2 - Allow users to enable online speech recognition
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" "AllowInputPersonalization" 0 DWord "18.1.2.2" "Allow online speech recognition = Disabled"

# 18.1.3 - Allow Online Tips
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "AllowOnlineTips" 0 DWord "18.1.3" "Allow Online Tips = Disabled"

# =============================================================================
# 18.4 MS SECURITY GUIDE
# =============================================================================
Write-Host ""
Write-Host "--- 18.4 MS Security Guide ---" -ForegroundColor Magenta

# 18.4.1 - Apply UAC restrictions to local accounts on network logons
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "LocalAccountTokenFilterPolicy" 0 DWord "18.4.1" "Apply UAC restrictions to local accounts on network logons = Enabled"

# 18.4.2 - Configure SMB v1 client driver: Disable driver
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10" "Start" 4 DWord "18.4.2" "SMB v1 client driver = Disabled (4)"

# 18.4.3 - Configure SMB v1 server: Disabled
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1" 0 DWord "18.4.3" "SMB v1 server = Disabled"

# 18.4.4 - Enable Certificate Padding (both 32-bit and 64-bit)
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config" "EnableCertPaddingCheck" "1" String "18.4.4" "Enable Certificate Padding = Enabled (32-bit)"
Set-RegValue "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" "EnableCertPaddingCheck" "1" String "18.4.4" "Enable Certificate Padding = Enabled (64-bit)"

# 18.4.5 - Enable SEHOP
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0 DWord "18.4.5" "Enable SEHOP = Enabled"

# 18.4.6 - NetBT NodeType: P-node (2)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NodeType" 2 DWord "18.4.6" "NetBT NodeType = P-node (2)"

# =============================================================================
# 18.5 MSS (LEGACY)
# =============================================================================
Write-Host ""
Write-Host "--- 18.5 MSS (Legacy) ---" -ForegroundColor Magenta

# 18.5.1 - AutoAdminLogon: Disabled
Set-RegValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoAdminLogon" "0" String "18.5.1" "AutoAdminLogon = Disabled"

# 18.5.2 - DisableIPSourceRouting IPv6: Highest protection (2)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisableIPSourceRouting" 2 DWord "18.5.2" "DisableIPSourceRouting IPv6 = Highest protection (2)"

# 18.5.3 - DisableIPSourceRouting IPv4: Highest protection (2)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "DisableIPSourceRouting" 2 DWord "18.5.3" "DisableIPSourceRouting IPv4 = Highest protection (2)"

# 18.5.4 - EnableICMPRedirect: Disabled (0)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "EnableICMPRedirect" 0 DWord "18.5.4" "EnableICMPRedirect = Disabled"

# 18.5.6 - NoNameReleaseOnDemand: Enabled (1)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" "NoNameReleaseOnDemand" 1 DWord "18.5.6" "NoNameReleaseOnDemand = Enabled"

# 18.5.7 - PerformRouterDiscovery: Disabled (0)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "PerformRouterDiscovery" 0 DWord "18.5.7" "PerformRouterDiscovery = Disabled"

# 18.5.8 - SafeDllSearchMode: Enabled (1)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "SafeDllSearchMode" 1 DWord "18.5.8" "SafeDllSearchMode = Enabled"

# 18.5.9 - TcpMaxDataRetransmissions IPv6: 3
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "TcpMaxDataRetransmissions" 3 DWord "18.5.9" "TcpMaxDataRetransmissions IPv6 = 3"

# 18.5.10 - TcpMaxDataRetransmissions IPv4: 3
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "TcpMaxDataRetransmissions" 3 DWord "18.5.10" "TcpMaxDataRetransmissions IPv4 = 3"

# 18.5.11 - WarningLevel: 90%
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Eventlog\Security" "WarningLevel" 90 DWord "18.5.11" "Security event log warning level = 90%"

# =============================================================================
# 18.6 NETWORK
# =============================================================================
Write-Host ""
Write-Host "--- 18.6 Network ---" -ForegroundColor Magenta

# 18.6.4.1 - Configure multicast DNS (mDNS): Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMDNS" 0 DWord "18.6.4.1" "Configure multicast DNS (mDNS) = Disabled"

# 18.6.4.2 - Configure NetBIOS settings: Disable NetBIOS (2)
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableNetbios" 2 DWord "18.6.4.2" "Configure NetBIOS settings = Disable NetBIOS (2)"

# 18.6.4.4 - Turn off multicast name resolution (LLMNR): Enabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0 DWord "18.6.4.4" "Turn off multicast name resolution = Enabled"

# 18.6.5.1 - Enable Font Providers: Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableFontProviders" 0 DWord "18.6.5.1" "Enable Font Providers = Disabled"

# 18.6.7.1 - LanmanServer: Audit client does not support encryption
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditClientDoesNotSupportEncryption" 1 DWord "18.6.7.1" "Audit client does not support encryption = Enabled"

# 18.6.7.2 - LanmanServer: Audit client does not support signing
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditClientDoesNotSupportSigning" 1 DWord "18.6.7.2" "Audit client does not support signing = Enabled"

# 18.6.7.3 - LanmanServer: Audit insecure guest logon
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "AuditInsecureGuestLogon" 1 DWord "18.6.7.3" "LanmanServer: Audit insecure guest logon = Enabled"

# 18.6.7.4 - LanmanServer: Enable authentication rate limiter
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "EnableAuthRateLimiter" 1 DWord "18.6.7.4" "Enable authentication rate limiter = Enabled"

# 18.6.7.5 - Enable remote mailslots (Bowser): Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Bowser" "EnableMailslots" 0 DWord "18.6.7.5" "Enable remote mailslots (Bowser) = Disabled"

# 18.6.7.6 - LanmanServer: MinSmb2Dialect = 785 (SMB 3.1.1)
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "MinSmb2Dialect" 785 DWord "18.6.7.6" "LanmanServer MinSmb2Dialect = 785 (SMB 3.1.1)"

# 18.6.7.7 - Set authentication rate limiter delay: 2000ms
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanServer" "InvalidAuthenticationDelay" 2000 DWord "18.6.7.7" "Authentication rate limiter delay = 2000ms"

# 18.6.8.1 - LanmanWorkstation: Audit insecure guest logon
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditInsecureGuestLogon" 1 DWord "18.6.8.1" "LanmanWorkstation: Audit insecure guest logon = Enabled"

# 18.6.8.2 - LanmanWorkstation: Audit server does not support encryption
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditServerDoesNotSupportEncryption" 1 DWord "18.6.8.2" "Audit server does not support encryption = Enabled"

# 18.6.8.3 - LanmanWorkstation: Audit server does not support signing
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AuditServerDoesNotSupportSigning" 1 DWord "18.6.8.3" "Audit server does not support signing = Enabled"

# 18.6.8.4 - Enable insecure guest logons: Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestLogons" 0 DWord "18.6.8.4" "Enable insecure guest logons = Disabled"

# 18.6.8.5 - Enable remote mailslots (NetworkProvider): Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider" "EnableMailslots" 0 DWord "18.6.8.5" "Enable remote mailslots (NetworkProvider) = Disabled"

# 18.6.8.6 - LanmanWorkstation: MinSmb2Dialect = 785 (SMB 3.1.1)
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "MinSmb2Dialect" 785 DWord "18.6.8.6" "LanmanWorkstation MinSmb2Dialect = 785 (SMB 3.1.1)"

# 18.6.8.7 - Require Encryption: Enabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "RequireEncryption" 1 DWord "18.6.8.7" "Require Encryption = Enabled"

# 18.6.9.1 - Turn on Mapper I/O (LLTDIO) driver: Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowLLTDIOOnDomain" 0 DWord "18.6.9.1" "LLTDIO driver = Disabled (domain)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowLLTDIOOnPublicNet" 0 DWord "18.6.9.1" "LLTDIO driver = Disabled (public)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "EnableLLTDIO" 0 DWord "18.6.9.1" "LLTDIO driver = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "ProhibitLLTDIOOnPrivateNet" 0 DWord "18.6.9.1" "LLTDIO driver = Disabled (private)"

# 18.6.9.2 - Turn on Responder (RSPNDR) driver: Disabled
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowRspndrOnDomain" 0 DWord "18.6.9.2" "RSPNDR driver = Disabled (domain)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "AllowRspndrOnPublicNet" 0 DWord "18.6.9.2" "RSPNDR driver = Disabled (public)"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "EnableRspndr" 0 DWord "18.6.9.2" "RSPNDR driver = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LLTD" "ProhibitRspndrOnPrivateNet" 0 DWord "18.6.9.2" "RSPNDR driver = Disabled (private)"

# 18.6.10.2 - Turn off Microsoft Peer-to-Peer Networking Services
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Peernet" "Disabled" 1 DWord "18.6.10.2" "Turn off Microsoft Peer-to-Peer Networking = Enabled"

# 18.6.11.2 - Prohibit installation of Network Bridge
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_AllowNetBridge_NLA" 0 DWord "18.6.11.2" "Prohibit Network Bridge installation = Enabled"

# 18.6.11.3 - Prohibit use of Internet Connection Sharing
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_ShowSharedAccessUI" 0 DWord "18.6.11.3" "Prohibit Internet Connection Sharing = Enabled"

# 18.6.11.4 - Require domain users to elevate when setting network location
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_StdDomainUserSetLocation" 1 DWord "18.6.11.4" "Require elevation for network location = Enabled"

# 18.6.14.1 - Hardened UNC Paths
$uncPaths = @{
    "\\\\*\\NETLOGON" = "RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1"
    "\\\\*\\SYSVOL"   = "RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1"
}
try {
    $uncPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
    if (-not (Test-Path $uncPath)) { New-Item -Path $uncPath -Force | Out-Null }
    foreach ($key in $uncPaths.Keys) {
        Set-ItemProperty -Path $uncPath -Name $key -Value $uncPaths[$key] -Type String -Force
    }
    Write-Host "[OK] CIS 18.6.14.1 - Hardened UNC Paths configured" -ForegroundColor Green
    $PassCount++
} catch {
    Write-Host "[ERROR] CIS 18.6.14.1 - Hardened UNC Paths: $_" -ForegroundColor Red
    $ErrorCount++
}

# 18.6.19.2.1 - Disable IPv6 (DisabledComponents = 0xff = 255)
Set-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 255 DWord "18.6.19.2.1" "Disable IPv6 = 0xff (all IPv6 disabled)"

# 18.6.20.1 - Configuration of wireless settings using Windows Connect Now
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "EnableRegistrars" 0 DWord "18.6.20.1" "Windows Connect Now wireless config = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableUPnPRegistrar" 0 DWord "18.6.20.1" "WCN UPnP Registrar = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableInBand802DOT11Registrar" 0 DWord "18.6.20.1" "WCN InBand 802.11 = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableFlashConfigRegistrar" 0 DWord "18.6.20.1" "WCN Flash Config = Disabled"
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\Registrars" "DisableWPDRegistrar" 0 DWord "18.6.20.1" "WCN WPD Registrar = Disabled"

# 18.6.20.2 - Prohibit access of the Windows Connect Now wizards
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WCN\UI" "DisableWcnUi" 1 DWord "18.6.20.2" "Prohibit WCN wizards = Enabled"

# 18.6.21.1 - Minimize simultaneous connections to Internet or domain
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections" 3 DWord "18.6.21.1" "Minimize simultaneous connections = 3 (Prevent Wi-Fi when on Ethernet)"

# 18.6.21.2 - Prohibit connection to non-domain networks
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fBlockNonDomain" 1 DWord "18.6.21.2" "Prohibit connection to non-domain networks = Enabled"

# =============================================================================
# VERIFICACION FINAL
# =============================================================================
Write-Host ""
Write-Host "--- Verificación acceso RDP ---" -ForegroundColor Yellow
$rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
Write-Host "RDP habilitado: $(if ($rdp -eq 0) {'SI - OK'} else {'NO - ERROR'})" -ForegroundColor $(if ($rdp -eq 0) {'Green'} else {'Red'})

# =============================================================================
# RESUMEN
# =============================================================================
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN PARTE 4a" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Controles aplicados : $PassCount" -ForegroundColor Green
Write-Host " Errores             : $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host ""
Write-Host "Parte 4a completada. Continuar con Parte 4b (secciones 18.9+)." -ForegroundColor Cyan
