<#
.SYNOPSIS
    Gathers CCDC Asset Inventory items specified in the inject prompt.
#>

[CmdletBinding()]
param(
    # Set the high-level role here (e.g., "Active Directory Domain Controller", "Web Server", "Database Server")
    [string]$AssignedRole = "Windows Host / Inferred from installed roles"
)

$ErrorActionPreference = "SilentlyContinue"

# 1. Hostname & Domain
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$hostname = $computer.DNSHostName

# 2. IP Addresses (Excludes loopback and APIPA)
$ipAddresses = (Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }).IPAddress -join ", "

# 3. OS and Version
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$osFull = "$($os.Caption) (Version: $($os.Version), Build: $($os.BuildNumber))"

# 4. Inferred Server Roles (Windows Server Feature Check)
$detectedRoles = @()
if (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue) {
    $installedFeatures = Get-WindowsFeature | Where-Object { $_.Installed -and $_.FeatureType -eq "Role" }
    if ($installedFeatures) {
        $detectedRoles = $installedFeatures.DisplayName
    }
}
$finalRole = if ($detectedRoles.Count -gt 0) { $detectedRoles -join ", " } else { $AssignedRole }

# 5. Listening Ports, Associated Services, Executable Paths, and File Versions
$listeningConnections = Get-NetTCPConnection -State Listen | Sort-Object LocalPort -Unique

$servicesAndPorts = foreach ($conn in $listeningConnections) {
    $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
    $procPath = $proc.Path
    
    # Check if process is tied to an official Windows Service
    $svc = Get-CimInstance -ClassName Win32_Service -Filter "ProcessId = $($conn.OwningProcess)"
    $svcName = if ($svc) { ($svc.Name -join ", ") } else { "N/A (Standalone Process)" }

    # Retrieve binary file version
    $fileVersion = "Unknown"
    if ($procPath -and (Test-Path $procPath)) {
        $versionInfo = (Get-Item $procPath).VersionInfo
        $fileVersion = if ($versionInfo.ProductVersion) { $versionInfo.ProductVersion } else { $versionInfo.FileVersion }
    }

    [PSCustomObject]@{
        Port        = $conn.LocalPort
        Address     = $conn.LocalAddress
        ProcessName = $proc.ProcessName
        ServiceName = $svcName
        Version     = $fileVersion
        BinaryPath  = $procPath
    }
}

# --- DISPLAY OUTPUT ---
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "                ASSET INVENTORY SUMMARY                 " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan

[PSCustomObject]@{
    "Hostname"       = $hostname
    "IP Address(es)" = $ipAddresses
    "OS & Version"   = $osFull
    "Network Role"   = $finalRole
} | Format-List

Write-Host "--- LISTENING SERVICES & VERSIONS ---" -ForegroundColor Yellow
$servicesAndPorts | Format-Table Port, Address, ProcessName, ServiceName, Version -AutoSize

# Export directly to CSV for quick submission
$exportPath = ".\Inject12_Inventory_$($hostname).csv"
$servicesAndPorts | Export-Csv -Path $exportPath -NoTypeInformation
Write-Host "[+] Detailed port/service version list saved to: $exportPath`n" -ForegroundColor Green