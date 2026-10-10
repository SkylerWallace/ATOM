<#
.SYNOPSIS
    Opens Microsoft Safety Scanner and refreshes older downloaded copies.
.DESCRIPTION
    Reuses a recent copy from Programs or the temporary directory. Copies at
    least nine days old are downloaded again before opening the scan wizard.
    Microsoft Safety Scanner enforces its own ten-day expiration.
.PARAMETER ScanType
    Runs a quiet Quick or Deep workflow scan. Omit to open the normal interface.
.PARAMETER LogDirectory
    Directory for workflow scan output and a copy of Microsoft's scan log.
#>
[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Deep')][string]$ScanType,
    [string]$LogDirectory,
    [hashtable]$ScanState
)

. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function Start-Program, Invoke-AtomAntivirusScan, Get-AtomWorkflowLogRoot -Feature Catalog

if ($ScanState -and $ScanState.StopRequested) {
    return [pscustomobject]@{Status='NeedsAttention';Summary='Scan stopped before launch.';Output=@{Cancelled=$true}}
}

$program = $programs.'Microsoft Safety Scanner'.ProgramInfo
$tempDirectory = Join-Path $env:TEMP 'Microsoft Safety Scanner'
$candidates = @(
    Join-Path $program.DestinationPath $program.RelativePath
    Join-Path $tempDirectory $program.RelativePath
)

$scanner = Get-Item -LiteralPath $candidates -ErrorAction SilentlyContinue |
    Where-Object { !$_.PSIsContainer } |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1

# Refresh before the documented expiration; file age is only a cache heuristic.
if (!$scanner -or $scanner.LastWriteTimeUtc -le [datetime]::UtcNow.AddDays(-9) -or $scanner.LastWriteTimeUtc -gt [datetime]::UtcNow) {
    $download = @{} + $program
    $download.DestinationPath = $tempDirectory
    $scanner = Start-Program @download -DownloadOnly -ErrorAction Stop
}

if (!$scanner) {
    throw 'Unable to download Microsoft Safety Scanner. Download a fresh copy from the Downloads page and try again.'
}

if ($ScanType) {
    if (!$LogDirectory) { $LogDirectory = Join-Path (Get-AtomWorkflowLogRoot) ('SafetyScanner-' + [guid]::NewGuid().ToString('N')) }
    Invoke-AtomAntivirusScan -Scanner SafetyScanner -ScanType $ScanType -Executable $scanner.FullName -LogDirectory $LogDirectory -ScanState $ScanState
} else {
    Start-Process -FilePath $scanner.FullName -Verb Open -WindowStyle Normal -Wait
}
