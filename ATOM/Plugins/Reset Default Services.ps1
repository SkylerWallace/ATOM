param([switch]$continue)

# Declaring relative paths needed for rest of script
$scriptPath    = $psCommandPath
$atomPath      = "$psScriptRoot\.."
$rdsPath       = "$psScriptRoot\RDS"
$clearTempHive = "$rdsPath\Clear-TempHive.ps1"

# Clear temp hive upon start and exit of script
if (!$continue) {
    Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$clearTempHive`"" -Wait
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -Continue" -Wait
    Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$clearTempHive`"" -Wait
    exit
}

# Set window title and CLI colors
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80, 30)
$host.UI.RawUI.WindowTitle = "Reset Default Services"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Determine if using on online/offline OS
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$hiveMounted = Test-Path "HKLM:\RemoteOS-HKLM-SYSTEM"

if($inPE -and $hiveMounted) {
    $softwareHive = "HKLM:\RemoteOS-HKLM-SOFTWARE"
    $systemHive = "HKLM:\RemoteOS-HKLM-SYSTEM"
} elseif ($inPE -and !$hiveMounted) {
    Write-Host "OS is offline!"
    Write-Host "Please mount offline OS with MountOS to proceed."
    Read-Host "Press 'Enter' to exit script"
    exit
} else {
    $softwareHive = "HKLM:\SOFTWARE"
    $systemHive = "HKLM:\SYSTEM"
}

# Windows identity used to match the RDS image catalog
$ntPath = Join-Path $softwareHive "Microsoft\Windows NT\CurrentVersion"
$windowsInfo = Get-ItemProperty $ntPath
$winBuild = [string]$windowsInfo.CurrentBuildNumber

# Create temp dir if not detected
$atomTemp = Join-Path $env:TEMP "ATOM Temp"
$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
if (!(Test-Path $atomTemp)) { New-Item -Path $atomTemp -ItemType Directory -Force }

###########################################################
###########################################################

function Invoke-Header {
    Clear-Host
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor "Cyan"
    Write-Host "║                                      ║" -ForegroundColor "Cyan"
    Write-Host "║        Reset Default Services        ║" -ForegroundColor "Cyan"
    Write-Host "║                                      ║" -ForegroundColor "Cyan"
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor "Cyan"
    Write-Host ""
}

function Get-SevenZipPath {
    @(
        (Get-Command 7z.exe -CommandType Application -ErrorAction SilentlyContinue).Source
        "$env:ProgramFiles\7-Zip\7z.exe"
        "$atomPath\Programs\7-Zip\7z.exe"
    ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}

function Set-RdsWindowsId {
    # Find the release from the catalog entry that contains build metadata
    $release = @($script:windowsImages.GetEnumerator() | Where-Object {
        [string]$_.Value.CurrentBuildNumber -eq $winBuild
    })

    if ($release.Count -ne 1) {
        throw "RDS does not contain a unique release for Windows build $winBuild."
    }

    # Remove the edition suffix from the metadata-bearing catalog entry
    $releasePrefix = $release[0].Key -replace '_[^_]+$', ''

    # Build the edition suffix from ProductName
    $edition = [string]$windowsInfo.ProductName
    $edition = $edition -replace '^Windows\s+\d+\s+', ''
    $edition = ($edition -replace '[^a-zA-Z0-9]+', '_').Trim('_').ToLower()

    $script:winId = "${releasePrefix}_$edition"

    if (!$script:windowsImages.Contains($script:winId)) {
        throw "RDS does not contain Windows image '$script:winId'."
    }

    $parts = $winId -split '_', 3
    $script:winName = $parts[0] -replace '^win', ''
    $script:winVer = $parts[1].ToUpper()
}

function Get-RdsReleaseId {
    param([Parameter(Mandatory)][string]$WindowsId)

    if ($WindowsId -match '^(win\d+_[^_]+)_') { return $matches[1] }
    $WindowsId
}

function Get-RdsLookupValue {
    param(
        [Parameter(Mandatory)][Collections.IDictionary]$ServiceTable,
        [Parameter(Mandatory)][string]$WindowsId
    )

    if ($ServiceTable.Contains($WindowsId)) {
        return $ServiceTable[$WindowsId]
    }

    $releaseId = Get-RdsReleaseId -WindowsId $WindowsId
    if ($ServiceTable.Contains($releaseId)) {
        return $ServiceTable[$releaseId]
    }

    $null
}

function RDS-MountHive {
    # Reg paths
    $script:regMount = "HKLM\TempHive"
    $script:regMountPs = Join-Path "HKLM:" (Split-Path $regMount -Leaf)

    # Extract RDS resources to ATOM temp
    $sevenZip = Get-SevenZipPath
    if (!$sevenZip) {
        throw "7-Zip is required to extract RDS.7z."
    }

    $rdsArchive = Join-Path $rdsPath "RDS.7z"
    if (!(Test-Path -LiteralPath $rdsArchive)) {
        throw "RDS.7z was not found at $rdsArchive."
    }

    & $sevenZip x $rdsArchive "-o$atomTemp" -y | Out-Null
    if ($LASTEXITCODE -gt 1) {
        throw "7-Zip failed to extract RDS.7z with exit code $LASTEXITCODE."
    }

    # Import lookup data
    . (Join-Path $atomTemp "Lookup-Table.ps1")
    $script:windowsImages = $windowsImages
    $script:lookupTable = $lookupTable
    [void]$script:lookupTable.Remove('TrustedInstaller')
    Set-RdsWindowsId

    # Mount temp hive
    $tempHive = Join-Path $atomTemp "TempHive"
    reg load $regMount $tempHive | Out-Null

    # Import default services reg values
    $servicesReg = Join-Path $atomTemp "Services.reg"
    reg import $servicesReg | Out-Null
}



function RDS-InstallService {
    param(
        [string]$service,
        [switch]$WhatIf
    )

    if ($WhatIf) {
        Write-Host "$service would be reinstalled" -ForegroundColor Cyan
        return
    }

    $lookupValue = Get-RdsLookupValue -ServiceTable $script:lookupTable[$service] -WindowsId $winId
    $sourceKey = Join-Path $regMountPs "${service}\${lookupValue}\$service"
    $destinationPath = Join-Path $systemHive "ControlSet001\Services"
    $destinationKey = Join-Path $destinationPath $service
    $backupKey = $null

    if (Test-Path $destinationKey) {
        $backupKey = $destinationKey + ".bak"
        $backupName = $service + ".bak"

        if (Test-Path $backupKey) {
            Remove-Item $backupKey -Recurse -Force
        }

        try {
            $errorActionPreference = "Stop"
            Rename-Item $destinationKey $backupName -Force
        } catch {
            Write-Host "Failed to modify $service" -ForegroundColor Red
            return
        } finally {
            $errorActionPreference = "Continue"
        }
    }

    try {
        $errorActionPreference = "Stop"
        Copy-Item $sourceKey $destinationPath -Recurse -Force
        if ($backupKey) { Remove-Item $backupKey -Recurse -Force }
        Write-Host "$service installed" -ForegroundColor Cyan
    } catch {
        if (Test-Path $destinationKey) { Remove-Item $destinationKey -Recurse -Force -ErrorAction SilentlyContinue }
        if ($backupKey -and (Test-Path $backupKey)) { Rename-Item $backupKey $service -Force }
        Write-Host "Failed to modify $service" -ForegroundColor Red
    } finally {
        $errorActionPreference = "Continue"
    }
}


function RDS-DefaultServices {
    param([switch]$WhatIf)

    Invoke-Header

    if ($WhatIf) {
        Write-Host "WhatIf mode: no changes will be made.`n" -ForegroundColor Yellow
    }

    Write-Host "Service              Before               After"                -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan

    $serviceCounter = 0
    $modifiedCounter = 0

    foreach ($service in $script:lookupTable.Keys) {
        $lookupValue = Get-RdsLookupValue -ServiceTable $script:lookupTable[$service] -WindowsId $winId
        if ($lookupValue -eq $null) { continue }

        $serviceCounter++
        $foregroundColor = "DarkGray"

        $currentStartup = Join-Path $systemHive "ControlSet001\Services\$service"
        $defaultStartup = Join-Path $regMountPs "${service}\${lookupValue}\$service"

        if (!(Test-Path $currentStartup)) {
            Write-Host "$service missing" -ForegroundColor Red
            continue
        }

        $currentStartupState = (Get-ItemProperty $currentStartup -Name "Start").Start
        $defaultStartupState = (Get-ItemProperty $defaultStartup -Name "Start").Start

        if ($currentStartupState -ne $defaultStartupState) {
            $modifiedCounter++
            $foregroundColor = "Cyan"

            if (!$WhatIf) {
                try {
                    $errorActionPreference = "Stop"
                    Set-ItemProperty -Path $currentStartup -Name "Start" -Value $defaultStartupState

                    $defaultDelayed = ($defaultStartupState -eq 2) -and
                        ((Get-ItemProperty $defaultStartup -Name "DelayedAutostart" -ErrorAction "SilentlyContinue").DelayedAutoStart -eq 1)

                    if ($defaultDelayed) {
                        Set-ItemProperty -Path $currentStartup -Name "DelayedAutostart" -Value 1
                    }
                } catch {
                    Write-Host "$service - Failed to restore" -ForegroundColor Red
                    continue
                } finally {
                    $errorActionPreference = "Continue"
                }
            }
        }

        $displayService = $service
        if ($displayService.Length -gt 18) {
            $displayService = $displayService.Substring(0,18)
        }

        $outputFormat = "{0,-20} {1,-20} {2,-20}" -f $displayService, $currentStartupState, $defaultStartupState
        Write-Host $outputFormat -ForegroundColor $foregroundColor
    }

    Write-Host "`nResults:" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Services checked: $serviceCounter" -ForegroundColor White
    Write-Host $(if ($WhatIf) { "Services needing changes: " } else { "Services changed: " }) -ForegroundColor White -NoNewLine
    Write-Host "$modifiedCounter" -ForegroundColor Cyan

    if (!$WhatIf -and $modifiedCounter) {
        Write-Host "Please restart to apply changes."
    }

    Read-Host "Press 'Enter' to return to Main Menu"
    Invoke-MainMenu
}


function RDS-MissingServices {
    Invoke-Header

    Write-Host "Service"                                                        -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan

    $serviceCounter = 0
    $modifiedCounter = 0

    foreach ($service in $script:lookupTable.Keys) {
        if ((Get-RdsLookupValue -ServiceTable $script:lookupTable[$service] -WindowsId $winId) -eq $null) { continue }

        $serviceCounter++
        $servicePath = Join-Path $systemHive "ControlSet001\Services\$service"

        if (Test-Path $servicePath) {
            Write-Host $service -ForegroundColor DarkGray
            continue
        }

        $modifiedCounter++
        RDS-InstallService $service
    }

    Write-Host "`nResults:" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "Services checked: $serviceCounter" -ForegroundColor White
    Write-Host "Services changed: " -ForegroundColor White -NoNewLine
    Write-Host "$modifiedCounter" -ForegroundColor Cyan

    if ($modifiedCounter) {
        Write-Host "Please restart to apply changes."
    }

    Read-Host "Press 'Enter' to return to Main Menu"
    Invoke-MainMenu
}

function RDS-SpecificService {
    do {
        Invoke-Header

        if ($invalidService) {
            Write-Host "Invalid service" -ForegroundColor Red
            Write-Host "- Windows version may not contain specified service`n"
        } elseif ($unsupportedService) {
            Write-Host "Unsupported service" -ForegroundColor Red
            Write-Host "- RDS does not support this service for this version of Windows`n"
        }

        $selectedService = Read-Host "Enter the service name to reinstall"

        if ($script:lookupTable[$selectedService] -eq $null) {
            $invalidService = $true
        } else {
            $invalidService = $false

            if ((Get-RdsLookupValue -ServiceTable $script:lookupTable[$selectedService] -WindowsId $winId) -ne $null) {
                $supportedService = $true
            } else {
                $unsupportedService = $true
            }
        }
    } until ($supportedService)

    $service = $script:lookupTable.Keys | Where-Object { $_ -ieq $selectedService }
    RDS-InstallService $service

    Write-Host "Please restart to apply changes."

    Read-Host "Press 'Enter' to return to Main Menu"
    Invoke-MainMenu
}



function RDS-SupportedWindows {
    Invoke-Header

    Write-Host "Supported Windows Images" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan

    foreach ($entry in $script:windowsImages.GetEnumerator()) {
        $name = [string]$entry.Value.ImageName
        if (!$name) { continue }

        $parts = $entry.Key -split '_', 3
        $version = $parts[1].ToUpper()

        Write-Host ("{0,-22} {1}" -f $version, $name)
    }

    Write-Host ""
    Read-Host "Press 'Enter' to return to Main Menu"
    Invoke-MainMenu
}

function RDS-VersionStartupStates {
    Invoke-Header

    Write-Host "Enter an RDS image ID, for example:" -ForegroundColor Cyan
    Write-Host "  win10_22h2_pro"
    Write-Host "  win11_25h2_home"
    Write-Host ""

    $selectedWinId = Read-Host "Image ID"

    if (!$script:windowsImages.Contains($selectedWinId)) {
        Write-Host "`nUnsupported Windows image '$selectedWinId'." -ForegroundColor Red
        Read-Host "Press 'Enter' to return to Main Menu"
        Invoke-MainMenu
        return
    }

    Invoke-Header
    Write-Host "Default startup states for $selectedWinId" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan

    foreach ($service in $script:lookupTable.Keys) {
        $lookupValue = Get-RdsLookupValue -ServiceTable $script:lookupTable[$service] -WindowsId $selectedWinId
        if ($lookupValue -eq $null) { continue }

        $servicePath = Join-Path $regMountPs "${service}\${lookupValue}\$service"
        if (!(Test-Path $servicePath)) { continue }

        $start = (Get-ItemProperty $servicePath -Name Start -ErrorAction SilentlyContinue).Start
        if ($start -eq $null) { continue }

        $startup = switch ($start) {
            0 { "Boot" }
            1 { "System" }
            2 {
                $delayed = (Get-ItemProperty $servicePath -Name DelayedAutoStart -ErrorAction SilentlyContinue).DelayedAutoStart
                if ($delayed -eq 1) { "Automatic (Delayed)" } else { "Automatic" }
            }
            3 { "Manual" }
            4 { "Disabled" }
            default { [string]$start }
        }

        Write-Host ("{0,-40} {1}" -f $service, $startup)
    }

    Write-Host ""
    Read-Host "Press 'Enter' to return to Main Menu"
    Invoke-MainMenu
}


function Invoke-MainMenu {
    do {
        Invoke-Header

        Write-Host "Windows $winName $winVer (Build $winBuild)"
        Write-Host ""

        Write-Host "╔═ OPTIONS ═════════════════════════════╗"
        Write-Host "║                                       ║"
        Write-Host "║ - [1] Restore Default Startup States  ║"
        Write-Host "║ - [2] Preview Startup State Changes   ║"
        Write-Host "║                                       ║"
        Write-Host "║ - [3] Reinstall Missing Services      ║"
        Write-Host "║ - [4] Reinstall Specific Service      ║"
        Write-Host "║                                       ║"
        Write-Host "║ - [5] Show Supported Windows Images   ║"
        Write-Host "║ - [6] Show Startup States for Version ║"
        Write-Host "║                                       ║"
        Write-Host "║ - [X] Exit                            ║"
        Write-Host "║                                       ║"
        Write-Host "╚═══════════════════════════════════════╝"
        Write-Host ""

        $answer = Read-Host "Select an option and press Enter"
    } until ($answer -in @(1, 2, 3, 4, 5, 6, 'X'))

    switch ($answer) {
        1   { RDS-DefaultServices }
        2   { RDS-DefaultServices -WhatIf }
        3   { RDS-MissingServices }
        4   { RDS-SpecificService }
        5   { RDS-SupportedWindows }
        6   { RDS-VersionStartupStates }
        'X' { exit }
    }
}

RDS-MountHive
Invoke-MainMenu
