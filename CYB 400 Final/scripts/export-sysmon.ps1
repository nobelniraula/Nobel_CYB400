#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Export recent Sysmon events for malsandbox consumption.
.EXAMPLE
    .\export-sysmon.ps1 -Minutes 15 -OutFile C:\Samples\run.csv
#>

param(
    [int]$Minutes = 10,
    [datetime]$StartTime = (Get-Date).AddMinutes(-$Minutes),
    [string]$OutFile = ".\sysmon-export.csv",
    [ValidateSet("CSV","JSON")]
    [string]$Format = "CSV"
)

$ErrorActionPreference = "Stop"

Write-Host "[*] Exporting Sysmon events since $StartTime ..." -ForegroundColor Cyan

$events = Get-WinEvent -FilterHashtable @{
    LogName = "Microsoft-Windows-Sysmon/Operational"
    StartTime = $StartTime
} -ErrorAction SilentlyContinue

if (-not $events) {
    Write-Warning "No Sysmon events found in the time window."
    exit 1
}

Write-Host "[*] Found $($events.Count) events." -ForegroundColor Green

$flat = foreach ($e in $events) {
    $xml = [xml]$e.ToXml()
    $data = @{}
    foreach ($d in $xml.Event.EventData.Data) {
        $data[$d.Name] = $d.'#text'
    }

    [PSCustomObject]@{
        TimeCreated     = $e.TimeCreated
        EventID         = $e.Id
        Computer        = $e.MachineName
        Image           = $data["Image"]
        ParentImage     = $data["ParentImage"]
        CommandLine     = $data["CommandLine"]
        ParentCommandLine = $data["ParentCommandLine"]
        User            = $data["User"]
        TargetFilename  = $data["TargetFilename"]
        TargetObject    = $data["TargetObject"]
        DestinationIp   = $data["DestinationIp"]
        DestinationPort = $data["DestinationPort"]
        SourceImage     = $data["SourceImage"]
        TargetImage     = $data["TargetImage"]
        Hashes          = $data["Hashes"]
        Protocol        = $data["Protocol"]
        QueryName       = $data["QueryName"]
        Message         = $e.Message
    }
}

if ($Format -eq "CSV") {
    $flat | Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8
} else {
    $flat | ConvertTo-Json -Depth 4 | Set-Content -Path $OutFile -Encoding UTF8
}

Write-Host "[+] Exported to $OutFile" -ForegroundColor Green
Write-Host "    Copy this file together with the sample to your analysis host and run:" -ForegroundColor Cyan
Write-Host "    malsandbox-bot sample.exe $([System.IO.Path]::GetFileName($OutFile)) --pdf report.pdf" -ForegroundColor Yellow