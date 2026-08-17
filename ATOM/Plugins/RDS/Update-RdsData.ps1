#Requires -RunAsAdministrator

<#
.SYNOPSIS
Adds the default service configuration from a Windows ISO to the RDS data files.

.DESCRIPTION
Uses 7-Zip to extract one client edition's registry hives from an ISO, derives its
Windows release from the offline registry, and compares every user-mode service with
Services.reg. Only new variants are appended. With -UpdateLookupTable, the matching
variant index is also added to Lookup-Table.ps1.

The Pro image is selected by default because one release ID can map to only one
service configuration in the current lookup-table format. Use -ImageIndex to choose
a different edition deliberately.

.EXAMPLE
.\Update-RdsData.ps1 -IsoPath C:\ISOs\Win11_24H2.iso -UpdateLookupTable -UpdateArchive

.EXAMPLE
.\Update-RdsData.ps1 -IsoPath C:\ISOs\Win11_24H2.iso -ImageIndex 6 -WhatIf
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$IsoPath,

    [string]$DataPath = (Join-Path $PSScriptRoot 'RDS'),

    [string]$SevenZipPath,

    [ValidateRange(1, 999)]
    [int]$ImageIndex,

    [switch]$UpdateLookupTable,

    [switch]$UpdateArchive,

    [switch]$ReplaceLookupEntry
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

function Invoke-RegExe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$ArgumentList
    )

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = & reg.exe @ArgumentList 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    if ($exitCode) {
        $message = ($output | ForEach-Object ToString) -join ' '
        throw "reg.exe $($ArgumentList[0]) failed ($exitCode): $message"
    }
    $output | ForEach-Object ToString
}

function Get-RdsRegistryTreeHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SubKey,

        [Parameter(Mandatory)]
        [string]$TemporaryPath
    )

    $exportPath = Join-Path $TemporaryPath "Hash-$([guid]::NewGuid().ToString('N')).reg"
    try {
        Invoke-RegExe -ArgumentList @('export', "HKLM\$SubKey", $exportPath, '/y') | Out-Null
        $content = [IO.File]::ReadAllText($exportPath)
        $registryRoot = "HKEY_LOCAL_MACHINE\$SubKey"
        if (!$content.Contains($registryRoot)) {
            throw "Could not normalize the registry export for HKLM\$SubKey."
        }

        $content = $content.Replace($registryRoot, 'HKEY_LOCAL_MACHINE\RDS_ROOT')
        $content = $content.Substring($content.IndexOf('[')).Trim()
        $content = $content.Replace([Environment]::NewLine, [string][char]10)
        $bytes = [Text.Encoding]::UTF8.GetBytes($content)
        $sha256 = [Security.Cryptography.SHA256]::Create()
        try {
            ([BitConverter]::ToString($sha256.ComputeHash($bytes))).Replace('-', '')
        }
        finally {
            $sha256.Dispose()
        }
    }
    finally {
        Remove-Item -LiteralPath $exportPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-RdsImageInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SoftwareHiveName,

        [Parameter(Mandatory)]
        $WindowsImage
    )

    $path = "Registry::HKEY_LOCAL_MACHINE\$SoftwareHiveName\Microsoft\Windows NT\CurrentVersion"
    $info = Get-ItemProperty -LiteralPath $path
    $values = @{}
    foreach ($property in $info.PSObject.Properties) { $values[$property.Name] = $property.Value }
    $build = [int]$(if ($values.CurrentBuildNumber) { $values.CurrentBuildNumber } else { $values.CurrentBuild })
    $release = if ($values.DisplayVersion) { $values.DisplayVersion } else { $values.ReleaseId }

    if (!$release) {
        throw 'The offline SOFTWARE hive does not contain DisplayVersion or ReleaseId.'
    }
    if ($values.InstallationType -and $values.InstallationType -ne 'Client') {
        throw "The selected image is '$($values.InstallationType)'. RDS currently supports client Windows images."
    }

    $majorVersion = if ($build -ge 22000) { 11 } else { 10 }
    [pscustomobject]@{
        WindowsId   = "Windows$majorVersion-$release"
        ProductName = $values.ProductName
        Edition     = $values.EditionID
        Build       = if ($null -ne $values.UBR) { "$build.$($values.UBR)" } else { [string]$build }
        ImageIndex  = $WindowsImage.ImageIndex
        ImageName   = $WindowsImage.ImageName
    }
}

function Get-RdsSevenZipPath {
    [CmdletBinding()]
    param([string]$Path)

    $programFilesX86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    $candidates = @(
        $Path
        (Get-Command 7z.exe -CommandType Application -ErrorAction SilentlyContinue).Source
        ([IO.Path]::Combine([string[]]@($env:ProgramFiles, '7-Zip', '7z.exe')))
        $(if ($programFilesX86) { [IO.Path]::Combine([string[]]@($programFilesX86, '7-Zip', '7z.exe')) })
        ([IO.Path]::Combine([string[]]@($env:USERPROFILE, 'scoop', 'apps', '7zip', 'current', '7z.exe')))
        ([IO.Path]::Combine([string[]]@($PSScriptRoot, '..', '..', 'Programs', '7-Zip', '7z.exe')))
    )

    $sevenZip = $candidates | Where-Object {
        $_ -and (Test-Path -LiteralPath $_ -PathType Leaf)
    } | Select-Object -First 1
    if (!$sevenZip) {
        throw '7z.exe was not found. Install 7-Zip or provide -SevenZipPath.'
    }
    (Resolve-Path -LiteralPath $sevenZip).Path
}

function Invoke-SevenZip {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SevenZipPath,

        [Parameter(Mandatory)]
        [string[]]$ArgumentList
    )

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = & $SevenZipPath @ArgumentList 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode) {
        $message = ($output | ForEach-Object ToString) -join ' '
        throw "7-Zip failed ($exitCode): $message"
    }
    $output | ForEach-Object ToString
}

function Get-RdsWindowsImage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$MetadataPath,

        [int]$Index
    )

    [xml]$metadata = Get-Content -LiteralPath $MetadataPath -Raw
    $images = @($metadata.WIM.IMAGE | ForEach-Object {
        [pscustomobject]@{
            ImageIndex = [int]$_.INDEX
            ImageName  = [string]$_.NAME
        }
    })
    if ($Index) {
        $image = $images | Where-Object ImageIndex -eq $Index
        if (!$image) { throw "Image index $Index was not found in the WIM metadata." }
        return $image
    }

    $image = $images | Where-Object ImageName -Match '^Windows (10|11) Pro$' | Select-Object -First 1
    if (!$image) {
        $image = $images | Where-Object {
            $_.ImageName -match ' Pro( |$)' -and $_.ImageName -notmatch ' N( |$)'
        } | Select-Object -First 1
    }
    if (!$image) { $image = $images | Select-Object -First 1 }
    $image
}

function Get-RdsLookupTableText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Collections.IDictionary]$LookupTable
    )

    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('$lookupTable = [ordered]@{')

    foreach ($service in $LookupTable.Keys | Sort-Object) {
        $escapedService = ([string]$service).Replace("'", "''")
        $lines.Add("    '$escapedService' = [ordered]@{")
        foreach ($windowsId in $LookupTable[$service].Keys) {
            $escapedId = ([string]$windowsId).Replace("'", "''")
            $lines.Add("        '$escapedId' = $($LookupTable[$service][$windowsId])")
        }
        $lines.Add('    }')
    }
    $lines.Add('}')
    $lines -join "`r`n"
}

function Add-RdsRegistryExport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourceKey,

        [Parameter(Mandatory)]
        [string]$DestinationKey,

        [Parameter(Mandatory)]
        [string]$ServicesFile,

        [Parameter(Mandatory)]
        [string]$TemporaryPath
    )

    $exportPath = Join-Path $TemporaryPath 'Service.reg'
    Invoke-RegExe -ArgumentList @('export', "HKLM\$SourceKey", $exportPath, '/y') | Out-Null
    $export = [IO.File]::ReadAllText($exportPath)
    $sourceHeader = "HKEY_LOCAL_MACHINE\$SourceKey"
    if (!$export.Contains($sourceHeader)) {
        throw "Could not locate the exported registry root for $SourceKey."
    }

    $body = $export.Replace($sourceHeader, "HKEY_LOCAL_MACHINE\TempHive\$DestinationKey")
    $body = $body -replace '^\uFEFF?Windows Registry Editor Version 5\.00\s*', ''
    [IO.File]::AppendAllText(
        $ServicesFile,
        "`r`n`r`n$($body.Trim())",
        [Text.UTF8Encoding]::new($false)
    )
}

function Update-RdsData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$IsoPath,

        [string]$DataPath = (Join-Path $PSScriptRoot 'RDS'),

        [string]$SevenZipPath,

        [int]$ImageIndex,

        [switch]$UpdateLookupTable,

        [switch]$UpdateArchive,

        [switch]$ReplaceLookupEntry
    )

    $isoPath = (Resolve-Path -LiteralPath $IsoPath).Path
    $dataPath = (Resolve-Path -LiteralPath $DataPath).Path
    $servicesPath = Join-Path $dataPath 'Services.reg'
    $lookupPath = Join-Path $dataPath 'Lookup-Table.ps1'
    $hivePath = Join-Path $dataPath 'TempHive'

    foreach ($path in $servicesPath, $lookupPath, $hivePath) {
        if (!(Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required RDS file not found: $path"
        }
    }

    $sevenZip = Get-RdsSevenZipPath -Path $SevenZipPath
    $workPath = Join-Path ([IO.Path]::GetTempPath()) "RDS-Update-$([guid]::NewGuid().ToString('N'))"
    $mediaPath = Join-Path $workPath 'Media'
    $imagePath = Join-Path $workPath 'Image'
    $metadataPath = Join-Path $workPath 'Metadata'
    $workDataPath = Join-Path $workPath 'RDS'
    New-Item -ItemType Directory -Path $mediaPath, $imagePath, $metadataPath, $workDataPath | Out-Null
    Copy-Item -LiteralPath $servicesPath, $lookupPath, $hivePath -Destination $workDataPath
    $workServices = Join-Path $workDataPath 'Services.reg'
    $workLookup = Join-Path $workDataPath 'Lookup-Table.ps1'
    $workHive = Join-Path $workDataPath 'TempHive'

    $id = "$PID`_$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    $dataHiveName = "RDS_DATA_$id"
    $systemHiveName = "RDS_SYSTEM_$id"
    $softwareHiveName = "RDS_SOFTWARE_$id"
    $loadedHives = [Collections.Generic.List[string]]::new()

    try {
        $separator = [string][char]92
        $installImage = $null
        foreach ($name in 'install.wim', 'install.esd') {
            $entry = ('sources', $name) -join $separator
            Write-Verbose "Extracting $entry from the ISO."
            Invoke-SevenZip -SevenZipPath $sevenZip -ArgumentList @(
                'e', $isoPath, "-o$mediaPath", '-y', $entry
            ) | Out-Null
            $candidate = Join-Path $mediaPath $name
            if (Test-Path -LiteralPath $candidate) {
                $installImage = $candidate
                break
            }
        }
        if (!$installImage) {
            throw 'The ISO does not contain an install.wim or install.esd under sources.'
        }

        Invoke-SevenZip -SevenZipPath $sevenZip -ArgumentList @(
            'e', $installImage, "-o$metadataPath", '-y', '[1].xml'
        ) | Out-Null
        $metadataFile = Join-Path $metadataPath '[1].xml'
        if (!(Test-Path -LiteralPath $metadataFile)) {
            throw '7-Zip did not extract the WIM image metadata.'
        }
        $image = Get-RdsWindowsImage -MetadataPath $metadataFile -Index $ImageIndex
        Write-Verbose "Extracting registry hives from image $($image.ImageIndex): $($image.ImageName)"

        $hivePrefix = ([string]$image.ImageIndex, 'Windows', 'System32', 'config') -join $separator
        $systemEntry = $hivePrefix + $separator + 'SYSTEM'
        $softwareEntry = $hivePrefix + $separator + 'SOFTWARE'
        Invoke-SevenZip -SevenZipPath $sevenZip -ArgumentList @(
            'x', $installImage, "-o$imagePath", '-y', $systemEntry, $softwareEntry
        ) | Out-Null
        $hiveRoot = Join-Path $imagePath $hivePrefix
        $systemHive = Join-Path $hiveRoot 'SYSTEM'
        $softwareHive = Join-Path $hiveRoot 'SOFTWARE'
        if (!(Test-Path $systemHive) -or !(Test-Path $softwareHive)) {
            throw '7-Zip did not extract both required registry hives.'
        }

        Invoke-RegExe -ArgumentList @(
            'load', "HKLM\$softwareHiveName", $softwareHive
        ) | Out-Null
        $loadedHives.Add($softwareHiveName)
        $imageInfo = Get-RdsImageInfo -SoftwareHiveName $softwareHiveName -WindowsImage $image
        Invoke-RegExe -ArgumentList @('unload', "HKLM\$softwareHiveName") | Out-Null
        $loadedHives.Remove($softwareHiveName) | Out-Null

        Invoke-RegExe -ArgumentList @(
            'load', "HKLM\$systemHiveName", $systemHive
        ) | Out-Null
        $loadedHives.Add($systemHiveName)

        Invoke-RegExe -ArgumentList @('load', "HKLM\$dataHiveName", $workHive) | Out-Null
        $loadedHives.Add($dataHiveName)
        $importPath = Join-Path $workPath 'Existing.reg'
        $existingReg = [IO.File]::ReadAllText($workServices).Replace(
            'HKEY_LOCAL_MACHINE\TempHive',
            "HKEY_LOCAL_MACHINE\$dataHiveName"
        )
        [IO.File]::WriteAllText($importPath, $existingReg, [Text.Encoding]::Unicode)
        Invoke-RegExe -ArgumentList @('import', $importPath) | Out-Null

        $lookupTable = $null
        . $workLookup
        if ($lookupTable -isnot [Collections.IDictionary]) {
            throw "$lookupPath did not define an IDictionary named `$lookupTable."
        }

        $select = Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\$systemHiveName\Select"
        $controlSetNumber = if ($null -ne $select.Current) { $select.Current } else { $select.Default }
        $controlSet = 'ControlSet{0:D3}' -f [int]$controlSetNumber
        $servicesSubKey = "$systemHiveName\$controlSet\Services"
        $servicesKey = Get-Item "Registry::HKEY_LOCAL_MACHINE\$servicesSubKey"

        $existingHashes = @{}
        $addedVariants = 0
        $reusedVariants = 0
        $mappedServices = 0
        $scannedServices = 0

        try {
        foreach ($serviceKey in $servicesKey.GetSubKeyNames() | Sort-Object) {
            $sourceSubKey = "$servicesSubKey\$serviceKey"
            $source = Get-Item "Registry::HKEY_LOCAL_MACHINE\$sourceSubKey"
            try {
                $type = $source.GetValue('Type', 0)
            }
            finally {
                $source.Close()
            }

            # SERVICE_WIN32_OWN_PROCESS (0x10) or SERVICE_WIN32_SHARE_PROCESS (0x20).
            # Device and file-system drivers are intentionally excluded from RDS.
            if (([int]$type -band 0x30) -eq 0) { continue }
            $scannedServices++

            if (!$existingHashes.ContainsKey($serviceKey)) {
                $existingHashes[$serviceKey] = @{}
                $variantRoot = "Registry::HKEY_LOCAL_MACHINE\$dataHiveName\$serviceKey"
                if (Test-Path $variantRoot) {
                    foreach ($variant in (Get-Item $variantRoot).GetSubKeyNames()) {
                        if ($variant -notmatch '^\d+$') { continue }
                        $variantSubKey = "$dataHiveName\$serviceKey\$variant\$serviceKey"
                        if (Test-Path "Registry::HKEY_LOCAL_MACHINE\$variantSubKey") {
                            $hash = Get-RdsRegistryTreeHash -SubKey $variantSubKey -TemporaryPath $workPath
                            $existingHashes[$serviceKey][$hash] = [int]$variant
                        }
                    }
                }
            }

            $sourceHash = Get-RdsRegistryTreeHash -SubKey $sourceSubKey -TemporaryPath $workPath
            $variantIndex = $existingHashes[$serviceKey][$sourceHash]
            if ($variantIndex) {
                $reusedVariants++
            }
            else {
                $indexes = @($existingHashes[$serviceKey].Values)
                $variantIndex = if ($indexes.Count) { ($indexes | Measure-Object -Maximum).Maximum + 1 } else { 1 }
                $destinationKey = "$serviceKey\$variantIndex\$serviceKey"
                Add-RdsRegistryExport -SourceKey $sourceSubKey -DestinationKey $destinationKey `
                    -ServicesFile $workServices -TemporaryPath $workPath
                Invoke-RegExe -ArgumentList @(
                    'copy', "HKLM\$sourceSubKey", "HKLM\$dataHiveName\$destinationKey", '/s', '/f'
                ) | Out-Null
                $existingHashes[$serviceKey][$sourceHash] = $variantIndex
                $addedVariants++
            }

            if (!$UpdateLookupTable) { continue }
            if (!$lookupTable.Contains($serviceKey)) {
                $lookupTable[$serviceKey] = [ordered]@{}
            }

            $oldIndex = $lookupTable[$serviceKey][$imageInfo.WindowsId]
            if ($oldIndex -and $oldIndex -ne $variantIndex -and !$ReplaceLookupEntry) {
                throw "Lookup entry $serviceKey/$($imageInfo.WindowsId) is $oldIndex, but this image resolved to $variantIndex. Use -ReplaceLookupEntry only if the selected edition should replace it."
            }
            $lookupTable[$serviceKey][$imageInfo.WindowsId] = $variantIndex
            $mappedServices++
        }
        }
        finally {
            $servicesKey.Close()
        }

        if ($UpdateLookupTable) {
            $lookupText = Get-RdsLookupTableText -LookupTable $lookupTable
            [IO.File]::WriteAllText($workLookup, "$lookupText`r`n", [Text.UTF8Encoding]::new($false))
        }

        $target = if ($UpdateLookupTable) { 'Services.reg and Lookup-Table.ps1' } else { 'Services.reg' }
        if ($PSCmdlet.ShouldProcess($dataPath, "Update $target for $($imageInfo.WindowsId)")) {
            Copy-Item -LiteralPath $workServices -Destination $servicesPath -Force
            if ($UpdateLookupTable) {
                Copy-Item -LiteralPath $workLookup -Destination $lookupPath -Force
            }

            if ($UpdateArchive) {
                $archivePath = Join-Path (Split-Path $dataPath -Parent) 'RDS.zip'
                $archiveWorkPath = Join-Path $workPath 'RDS.zip'
                Compress-Archive -Path (Join-Path $dataPath '*') -DestinationPath $archiveWorkPath -CompressionLevel Optimal
                Copy-Item -LiteralPath $archiveWorkPath -Destination $archivePath -Force
            }
        }

        [pscustomobject]@{
            WindowsId       = $imageInfo.WindowsId
            ProductName     = $imageInfo.ProductName
            Edition         = $imageInfo.Edition
            Build           = $imageInfo.Build
            ImageIndex      = $imageInfo.ImageIndex
            ImageName       = $imageInfo.ImageName
            ServicesScanned = $scannedServices
            ExistingVariant = $reusedVariants
            AddedVariant    = $addedVariants
            LookupEntries   = if ($UpdateLookupTable) { $mappedServices } else { 0 }
            ArchiveUpdated  = [bool]$UpdateArchive
        }
    }
    finally {
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
        $hives = @($loadedHives)
        [Array]::Reverse($hives)
        foreach ($hive in $hives) {
            try { Invoke-RegExe -ArgumentList @('unload', "HKLM\$hive") | Out-Null } catch { Write-Warning $_ }
        }
        if (Test-Path -LiteralPath $workPath) {
            Remove-Item -LiteralPath $workPath -Recurse -Force
        }
    }
}

Update-RdsData @PSBoundParameters
