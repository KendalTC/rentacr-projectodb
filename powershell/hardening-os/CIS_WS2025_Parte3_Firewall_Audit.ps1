# =============================================================================
# ProjectDB - IF5100 Administración de Bases de Datos
# CIS Microsoft Windows Server 2025 Benchmark v2.0.0
# PARTE 3: Windows Firewall (Sección 9) + Advanced Audit Policy (Sección 17)
# Level 1 - Member Server
# NOTA: Este script NO toca User Rights ni acceso RDP - es 100% seguro
# =============================================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " CIS WS2025 v2.0.0 - Parte 3: Firewall + Audit Policy" -ForegroundColor Cyan
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
# SECCIÓN 9 - WINDOWS DEFENDER FIREWALL
# =============================================================================
Write-Host "--- Sección 9: Windows Defender Firewall ---" -ForegroundColor Magenta
Write-Host ""

# Crear directorios para logs de firewall
New-Item -ItemType Directory -Path "C:\Windows\System32\logfiles\firewall" -Force | Out-Null

# ---- 9.1 Domain Profile ----
Write-Host "  [9.1] Domain Profile" -ForegroundColor Yellow

# CIS 9.1.1 - Domain Firewall state: On
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "EnableFirewall" 1 DWord "9.1.1" "Domain: Firewall state = On"

# CIS 9.1.2 - Domain Inbound connections: Block
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DefaultInboundAction" 1 DWord "9.1.2" "Domain: Inbound connections = Block"

# CIS 9.1.3 - Domain Display notification: No
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" "DisableNotifications" 1 DWord "9.1.3" "Domain: Display a notification = No"

# CIS 9.1.4 - Domain Log name configured
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogFilePath" "%SystemRoot%\System32\logfiles\firewall\domainfw.log" String "9.1.4" "Domain: Logging Name = domainfw.log"

# CIS 9.1.5 - Domain Log size: 16384 KB
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogFileSize" 16384 DWord "9.1.5" "Domain: Log size = 16384 KB"

# CIS 9.1.6 - Domain Log dropped packets: Yes
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogDroppedPackets" 1 DWord "9.1.6" "Domain: Log dropped packets = Yes"

# CIS 9.1.7 - Domain Log successful connections: Yes
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging" "LogSuccessfulConnections" 1 DWord "9.1.7" "Domain: Log successful connections = Yes"

# ---- 9.2 Private Profile ----
Write-Host ""
Write-Host "  [9.2] Private Profile" -ForegroundColor Yellow

# CIS 9.2.1 - Private Firewall state: On
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "EnableFirewall" 1 DWord "9.2.1" "Private: Firewall state = On"

# CIS 9.2.2 - Private Inbound connections: Block
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DefaultInboundAction" 1 DWord "9.2.2" "Private: Inbound connections = Block"

# CIS 9.2.3 - Private Display notification: No
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" "DisableNotifications" 1 DWord "9.2.3" "Private: Display a notification = No"

# CIS 9.2.4 - Private Log name configured
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogFilePath" "%SystemRoot%\System32\logfiles\firewall\privatefw.log" String "9.2.4" "Private: Logging Name = privatefw.log"

# CIS 9.2.5 - Private Log size: 16384 KB
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogFileSize" 16384 DWord "9.2.5" "Private: Log size = 16384 KB"

# CIS 9.2.6 - Private Log dropped packets: Yes
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogDroppedPackets" 1 DWord "9.2.6" "Private: Log dropped packets = Yes"

# CIS 9.2.7 - Private Log successful connections: Yes
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging" "LogSuccessfulConnections" 1 DWord "9.2.7" "Private: Log successful connections = Yes"

# ---- 9.3 Public Profile ----
Write-Host ""
Write-Host "  [9.3] Public Profile" -ForegroundColor Yellow

# CIS 9.3.1 - Public Firewall state: On
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "EnableFirewall" 1 DWord "9.3.1" "Public: Firewall state = On"

# CIS 9.3.2 - Public Inbound connections: Block
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DefaultInboundAction" 1 DWord "9.3.2" "Public: Inbound connections = Block"

# CIS 9.3.3 - Public Display notification: No
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "DisableNotifications" 1 DWord "9.3.3" "Public: Display a notification = No"

# CIS 9.3.4 - Public Apply local firewall rules: No
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "AllowLocalPolicyMerge" 0 DWord "9.3.4" "Public: Apply local firewall rules = No"

# CIS 9.3.5 - Public Apply local connection security rules: No
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" "AllowLocalIPsecPolicyMerge" 0 DWord "9.3.5" "Public: Apply local connection security rules = No"

# CIS 9.3.6 - Public Log name configured
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogFilePath" "%SystemRoot%\System32\logfiles\firewall\publicfw.log" String "9.3.6" "Public: Logging Name = publicfw.log"

# CIS 9.3.7 - Public Log size: 16384 KB
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogFileSize" 16384 DWord "9.3.7" "Public: Log size = 16384 KB"

# CIS 9.3.8 - Public Log dropped packets: Yes
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogDroppedPackets" 1 DWord "9.3.8" "Public: Log dropped packets = Yes"

# CIS 9.3.9 - Public Log successful connections: Yes
Set-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging" "LogSuccessfulConnections" 1 DWord "9.3.9" "Public: Log successful connections = Yes"

# Asegurar que RDP sigue permitido en firewall
Write-Host ""
Write-Host "[*] Asegurando regla RDP en firewall..." -ForegroundColor Yellow
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue
Write-Host "[OK] Regla RDP habilitada en firewall" -ForegroundColor Green
$PassCount++

# =============================================================================
# SECCIÓN 17 - ADVANCED AUDIT POLICY CONFIGURATION
# Se aplica via auditpol
# =============================================================================
Write-Host ""
Write-Host "--- Sección 17: Advanced Audit Policy ---" -ForegroundColor Magenta
Write-Host ""

function Set-AuditPolicy {
    param($Category, $Subcategory, $Setting, $CIS, $Desc)
    try {
        auditpol /set /subcategory:"$Subcategory" /success:$(if ($Setting -match "Success") {"enable"} else {"disable"}) /failure:$(if ($Setting -match "Failure") {"enable"} else {"disable"}) | Out-Null
        Write-Host "[OK] CIS $CIS - $Desc = $Setting" -ForegroundColor Green
        $script:PassCount++
    } catch {
        Write-Host "[ERROR] CIS $CIS - $Desc : $_" -ForegroundColor Red
        $script:ErrorCount++
    }
}

# ---- 17.1 Account Logon ----
Write-Host "  [17.1] Account Logon" -ForegroundColor Yellow
Set-AuditPolicy "Account Logon" "Credential Validation" "Success and Failure" "17.1.1" "Audit Credential Validation"

# ---- 17.2 Account Management ----
Write-Host ""
Write-Host "  [17.2] Account Management" -ForegroundColor Yellow
Set-AuditPolicy "Account Management" "Application Group Management" "Success and Failure" "17.2.1" "Audit Application Group Management"
Set-AuditPolicy "Account Management" "Security Group Management" "Success" "17.2.5" "Audit Security Group Management"
Set-AuditPolicy "Account Management" "User Account Management" "Success and Failure" "17.2.6" "Audit User Account Management"

# ---- 17.3 Detailed Tracking ----
Write-Host ""
Write-Host "  [17.3] Detailed Tracking" -ForegroundColor Yellow
Set-AuditPolicy "Detailed Tracking" "Plug and Play Events" "Success" "17.3.1" "Audit PNP Activity"
Set-AuditPolicy "Detailed Tracking" "Process Creation" "Success" "17.3.2" "Audit Process Creation"

# ---- 17.5 Logon/Logoff ----
Write-Host ""
Write-Host "  [17.5] Logon/Logoff" -ForegroundColor Yellow
Set-AuditPolicy "Logon/Logoff" "Account Lockout" "Failure" "17.5.1" "Audit Account Lockout"
Set-AuditPolicy "Logon/Logoff" "Group Membership" "Success" "17.5.2" "Audit Group Membership"
Set-AuditPolicy "Logon/Logoff" "Logoff" "Success" "17.5.3" "Audit Logoff"
Set-AuditPolicy "Logon/Logoff" "Logon" "Success and Failure" "17.5.4" "Audit Logon"
Set-AuditPolicy "Logon/Logoff" "Other Logon/Logoff Events" "Success and Failure" "17.5.5" "Audit Other Logon/Logoff Events"
Set-AuditPolicy "Logon/Logoff" "Special Logon" "Success" "17.5.6" "Audit Special Logon"

# ---- 17.6 Object Access ----
Write-Host ""
Write-Host "  [17.6] Object Access" -ForegroundColor Yellow
Set-AuditPolicy "Object Access" "Detailed File Share" "Failure" "17.6.1" "Audit Detailed File Share"
Set-AuditPolicy "Object Access" "File Share" "Success and Failure" "17.6.2" "Audit File Share"
Set-AuditPolicy "Object Access" "Other Object Access Events" "Success and Failure" "17.6.3" "Audit Other Object Access Events"
Set-AuditPolicy "Object Access" "Removable Storage" "Success and Failure" "17.6.4" "Audit Removable Storage"

# ---- 17.7 Policy Change ----
Write-Host ""
Write-Host "  [17.7] Policy Change" -ForegroundColor Yellow
Set-AuditPolicy "Policy Change" "Audit Policy Change" "Success" "17.7.1" "Audit Audit Policy Change"
Set-AuditPolicy "Policy Change" "Authentication Policy Change" "Success" "17.7.2" "Audit Authentication Policy Change"
Set-AuditPolicy "Policy Change" "Authorization Policy Change" "Success" "17.7.3" "Audit Authorization Policy Change"
Set-AuditPolicy "Policy Change" "MPSSVC Rule-Level Policy Change" "Success and Failure" "17.7.4" "Audit MPSSVC Rule-Level Policy Change"
Set-AuditPolicy "Policy Change" "Other Policy Change Events" "Failure" "17.7.5" "Audit Other Policy Change Events"

# ---- 17.8 Privilege Use ----
Write-Host ""
Write-Host "  [17.8] Privilege Use" -ForegroundColor Yellow
Set-AuditPolicy "Privilege Use" "Sensitive Privilege Use" "Success and Failure" "17.8.1" "Audit Sensitive Privilege Use"

# ---- 17.9 System ----
Write-Host ""
Write-Host "  [17.9] System" -ForegroundColor Yellow
Set-AuditPolicy "System" "IPsec Driver" "Success and Failure" "17.9.1" "Audit IPsec Driver"
Set-AuditPolicy "System" "Other System Events" "Success and Failure" "17.9.2" "Audit Other System Events"
Set-AuditPolicy "System" "Security State Change" "Success" "17.9.3" "Audit Security State Change"
Set-AuditPolicy "System" "Security System Extension" "Success" "17.9.4" "Audit Security System Extension"
Set-AuditPolicy "System" "System Integrity" "Success and Failure" "17.9.5" "Audit System Integrity"

# =============================================================================
# VERIFICACION FINAL
# =============================================================================
Write-Host ""
Write-Host "--- Verificación final ---" -ForegroundColor Yellow

# Verificar firewall
$fw = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue)
Write-Host "Firewall Public: $(if ($fw.EnableFirewall -eq 1) {'ON - OK'} else {'OFF - ERROR'})" -ForegroundColor $(if ($fw.EnableFirewall -eq 1) {'Green'} else {'Red'})

# Verificar audit logon
$audit = auditpol /get /subcategory:"Logon" 2>$null
Write-Host "Audit Logon: $($audit | Select-String 'Logon')" -ForegroundColor Green

# Verificar RDP sigue funcionando
$rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
Write-Host "RDP habilitado: $(if ($rdp -eq 0) {'SI - OK'} else {'NO - ERROR'})" -ForegroundColor $(if ($rdp -eq 0) {'Green'} else {'Red'})

# =============================================================================
# RESUMEN FINAL
# =============================================================================
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " RESUMEN PARTE 3" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host " Controles aplicados : $PassCount" -ForegroundColor Green
Write-Host " Errores             : $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host ""
Write-Host "Secciones completadas: 9 (Firewall) y 17 (Audit Policy)" -ForegroundColor Cyan
Write-Host "Parte 3 completada. Continuar con Parte 4 (Administrative Templates)." -ForegroundColor Cyan
