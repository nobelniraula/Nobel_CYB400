#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs Sysmon on Windows 10 with the Nobel lab malware-analysis configuration.
#>

param(
    [string]$SysmonPath = ".\Sysmon64.exe",
    [string]$ConfigPath = ".\sysmon-config-win10.xml"
)

$ErrorActionPreference = "Stop"

Write-Host "[*] Checking files..." -ForegroundColor Cyan
if (-not (Test-Path $SysmonPath)) {
    Write-Error "Sysmon64.exe not found at $SysmonPath. Download from Microsoft Sysinternals."
}
if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config not found at $ConfigPath. Copy configs/sysmon-config-win10.xml here."
}

$existing = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "[*] Existing Sysmon service found – updating configuration..." -ForegroundColor Yellow
    & $SysmonPath -c $ConfigPath
} else {
    Write-Host "[*] Installing Sysmon with Nobel lab config..." -ForegroundColor Cyan
    & $SysmonPath -accepteula -i $ConfigPath
}

Start-Sleep -Seconds 2

$svc = Get-Service -Name Sysmon64 -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -eq "Running") {
    Write-Host "[+] Sysmon64 is running." -ForegroundColor Green
} else {
    Write-Warning "Sysmon service not running. Check Event Viewer."
}

Write-Host "[*] Recent Sysmon events (last 3):" -ForegroundColor Cyan
try {
    Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 3 |
        Format-Table TimeCreated, Id, Message -Wrap
} catch {
    Write-Warning "Could not read Sysmon log yet. It may need a moment."
}

Write-Host "`n[+] Done. Remember to add the localfile block to the Wazuh agent ossec.conf and restart the agent." -ForegroundColor Green