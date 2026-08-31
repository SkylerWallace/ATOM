#Requires -RunAsAdministrator
<#
.SYNOPSIS
Updates RDS service data from one or more Windows ISOs.
.DESCRIPTION
Uses RDS.7z as the source/destination for Lookup-Table.ps1, Services.reg, and
an empty TempHive. Omit -ImageIndex for index 1, specify multiple indexes, or
use '*' for all indexes. Multiple ISO paths and wildcards are supported.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory, Position = 0)]
    [string[]]$IsoPath,
    [string]$ArchivePath = (Join-Path $PSScriptRoot 'RDS.7z'),
    [string]$SevenZipPath,
    [string[]]$ImageIndex,
    [switch]$UpdateLookupTable,
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

if (-not ('RdsTextHasher' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
public static class RdsTextHasher {
    public static string Hash(string value) {
        using (SHA256 sha = SHA256.Create()) {
            byte[] bytes = Encoding.UTF8.GetBytes(value);
            return BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "");
        }
    }
    public static string[] HashMany(string[] values) {
        string[] hashes = new string[values.Length];
        Parallel.For(0, values.Length, i => {
            using (SHA256 sha = SHA256.Create()) {
                byte[] bytes = Encoding.UTF8.GetBytes(values[i]);
                hashes[i] = BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-", "");
            }
        });
        return hashes;
    }
}
'@
}

function Get-RdsVariantCache {
    param([Parameter(Mandatory)][string]$ServicesFile)
    $groups = @{}
    $nextIndex = @{}
    $currentGroup = $null
    foreach ($line in [IO.File]::ReadLines($ServicesFile)) {
        if ($line.Length -gt 2 -and $line[0] -eq '[' -and $line[$line.Length - 1] -eq ']') {
            $path = $line.Substring(1, $line.Length - 2)
            $parts = $path.Split('\')
            $currentGroup = $null
            if ($parts.Count -ge 5 -and $parts[0] -eq 'HKEY_LOCAL_MACHINE' -and $parts[1] -eq 'TempHive') {
                $service = $parts[2]
                $variant = 0
                if ([int]::TryParse($parts[3], [ref]$variant) -and $parts[4] -eq $service) {
                    $currentGroup = "$service`0$variant"
                    if (!$groups.ContainsKey($currentGroup)) {
                        $groups[$currentGroup] = New-Object Collections.Generic.List[string]
                    }
                    $root = "HKEY_LOCAL_MACHINE\TempHive\$service\$variant\$service"
                    $relative = $path.Substring($root.Length)
                    $groups[$currentGroup].Add("[HKEY_LOCAL_MACHINE\RDS_ROOT$relative]")
                    if (!$nextIndex.ContainsKey($service) -or $variant -ge $nextIndex[$service]) {
                        $nextIndex[$service] = $variant + 1
                    }
                }
            }
            continue
        }
        if ($currentGroup) { $groups[$currentGroup].Add($line) }
    }
    $hashes = @{}
    foreach ($groupKey in $groups.Keys) {
        $parts = $groupKey.Split([char]0)
        $service = $parts[0]
        if (!$hashes.ContainsKey($service)) { $hashes[$service] = @{} }
        $text = (($groups[$groupKey] -join "`n").Trim())
        $hashes[$service][([RdsTextHasher]::HashMany(@($text)))[0]] = [int]$parts[1]
    }
    [pscustomobject]@{ Hashes = $hashes; NextIndex = $nextIndex }
}

function Get-RdsServiceData {
    param(
        [Parameter(Mandatory)][string]$ServicesSubKey,
        [Parameter(Mandatory)][string]$TemporaryPath
    )
    $exportPath = Join-Path $TemporaryPath "Services-$([guid]::NewGuid().ToString('N')).reg"
    $groups = @{}
    try {
        Write-Progress -Id 2 -ParentId 1 -Activity 'Reading services' `
            -Status 'Exporting Services registry tree' -PercentComplete 0
        Invoke-RegExe -ArgumentList @('export', "HKLM\$ServicesSubKey", $exportPath, '/y') | Out-Null
        $rootPrefix = "HKEY_LOCAL_MACHINE\$ServicesSubKey\"
        $currentService = $null
        $currentRoot = $false
        foreach ($line in [IO.File]::ReadLines($exportPath)) {
            if ($line.Length -gt 2 -and $line[0] -eq '[' -and $line[$line.Length - 1] -eq ']') {
                $path = $line.Substring(1, $line.Length - 2)
                $currentService = $null
                $currentRoot = $false
                if ($path.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
                    $relativePath = $path.Substring($rootPrefix.Length)
                    $separatorIndex = $relativePath.IndexOf('\')
                    $service = if ($separatorIndex -ge 0) {
                        $relativePath.Substring(0, $separatorIndex)
                    }
                    else {
                        $relativePath
                    }
                    if (!$groups.ContainsKey($service)) {
                        $groups[$service] = [pscustomobject]@{
                            SourceRoot = "$rootPrefix$service"
                            Lines      = New-Object Collections.Generic.List[string]
                            Type       = 0
                        }
                    }
                    $currentService = $service
                    $currentRoot = $relativePath -eq $service
                    $groups[$service].Lines.Add($line)
                }
                continue
            }
            if (!$currentService) { continue }
            $groups[$currentService].Lines.Add($line)
            if ($currentRoot -and $line -match '^"Type"=dword:([0-9a-fA-F]+)$') {
                $groups[$currentService].Type = [Convert]::ToInt32($matches[1], 16)
            }
        }
        $serviceNames = @($groups.Keys | Where-Object {
            ([int]$groups[$_].Type -band 0x30) -ne 0
        } | Sort-Object)
        $sourceTexts = New-Object string[] $serviceNames.Count
        $normalizedTexts = New-Object string[] $serviceNames.Count
        for ($i = 0; $i -lt $serviceNames.Count; $i++) {
            $service = $serviceNames[$i]
            if (($i % 20) -eq 0 -or $i -eq $serviceNames.Count - 1) {
                Write-Progress -Id 2 -ParentId 1 -Activity 'Reading services' `
                    -Status "$service ($($i + 1) of $($serviceNames.Count))" `
                    -PercentComplete ([int]((($i + 1) / [Math]::Max($serviceNames.Count, 1)) * 100))
            }
            $sourceText = (($groups[$service].Lines -join "`n").Trim())
            $sourceTexts[$i] = $sourceText
            $normalizedTexts[$i] = $sourceText.Replace(
                $groups[$service].SourceRoot,
                'HKEY_LOCAL_MACHINE\RDS_ROOT'
            )
        }
        $hashes = [RdsTextHasher]::HashMany($normalizedTexts)
        $result = @{}
        for ($i = 0; $i -lt $serviceNames.Count; $i++) {
            $service = $serviceNames[$i]
            $result[$service] = [pscustomobject]@{
                Hash       = $hashes[$i]
                SourceRoot = $groups[$service].SourceRoot
                Text       = $sourceTexts[$i]
            }
        }
        $result
    }
    finally {
        Remove-Item -LiteralPath $exportPath -Force -ErrorAction SilentlyContinue
        Write-Progress -Id 2 -ParentId 1 -Activity 'Reading services' -Completed
    }
}

function Add-RdsServiceData {
    param(
        [Parameter(Mandatory)]$ServiceData,
        [Parameter(Mandatory)][string]$DestinationKey,
        [Parameter(Mandatory)][string]$ServicesFile
    )
    $destinationRoot = "HKEY_LOCAL_MACHINE\TempHive\$DestinationKey"
    $body = $ServiceData.Text.Replace($ServiceData.SourceRoot, $destinationRoot)
    [IO.File]::AppendAllText($ServicesFile, "`r`n`r`n$body", [Text.UTF8Encoding]::new($false))
}

function Get-RdsImageInfo {
    [CmdletBinding()]
    param(
        [string]$SoftwareHiveName,
        [Parameter(Mandatory)]
        $WindowsImage,
        [Parameter(Mandatory)]
        [Collections.IDictionary]$WindowsImages
    )
    $imageNameProperty = $WindowsImage.PSObject.Properties['ImageName']
    $imageDescriptionProperty = $WindowsImage.PSObject.Properties['ImageDescription']
    $buildProperty = $WindowsImage.PSObject.Properties['Build']
    $imageName = if ($imageNameProperty) { [string]$imageNameProperty.Value } else { '' }
    $imageDescription = if ($imageDescriptionProperty) { [string]$imageDescriptionProperty.Value } else { '' }
    $imageBuild = if ($buildProperty) { [string]$buildProperty.Value } else { '' }
    if (!$SoftwareHiveName) {
        $candidates = @($WindowsImages.GetEnumerator() | Where-Object {
            $known = $_.Value
            [string]$known['ImageName'] -eq $imageName -and
            (
                !$known['ImageDescription'] -or
                !$imageDescription -or
                [string]$known['ImageDescription'] -eq $imageDescription
            ) -and
            (
                [string]$known['CurrentBuildNumber'] -eq $imageBuild -or
                [string]$known['BuildLab'] -like "$imageBuild.*" -or
                [string]$known['BuildLabEx'] -like "$imageBuild.*"
            )
        })

        if ($candidates.Count -eq 1) {
            $entry = $candidates[0]
            $known = $entry.Value
            $build = [string]$known['CurrentBuildNumber']

            return [pscustomobject]@{
                WindowsId   = [string]$entry.Key
                ProductName = $known['ProductName']
                Edition     = ($imageName -replace '^Windows\s+\d+\s+', '')
                Build       = if ($known['UBR']) { "$build.$($known['UBR'])" } else { $build }
                ImageIndex  = $WindowsImage.PSObject.Properties['ImageIndex'].Value
                ImageName   = $imageName
            }
        }

        return $null
    }
    $path = "Registry::HKEY_LOCAL_MACHINE\$SoftwareHiveName\Microsoft\Windows NT\CurrentVersion"
    $info = Get-ItemProperty -LiteralPath $path
    $values = @{}
    foreach ($property in $info.PSObject.Properties) {
        $values[$property.Name] = $property.Value
    }
    $build = if ($values.ContainsKey('CurrentBuildNumber')) {
        [int]$values['CurrentBuildNumber']
    }
    elseif ($values.ContainsKey('CurrentBuild')) {
        [int]$values['CurrentBuild']
    }
    else {
        throw 'The offline SOFTWARE hive does not contain a Windows build number.'
    }
    $installationType = if ($values.ContainsKey('InstallationType')) {
        [string]$values['InstallationType']
    }
    if ($installationType -and $installationType -ne 'Client') {
        throw "The selected image is '$installationType'. RDS currently supports client Windows images."
    }
    $metadata = [ordered]@{}
    foreach ($name in 'BuildLab', 'BuildLabEx', 'CurrentBuild', 'CurrentBuildNumber',
        'DisplayVersion', 'EditionID', 'InstallationType', 'ProductName', 'ReleaseId', 'UBR') {
        if ($values.ContainsKey($name) -and $null -ne $values[$name] -and [string]$values[$name] -ne '') {
            $metadata[$name] = $values[$name]
        }
    }
    foreach ($name in 'ImageName', 'ImageDescription', 'Architecture') {
        $property = $WindowsImage.PSObject.Properties[$name]
        if ($property -and $null -ne $property.Value -and [string]$property.Value -ne '') {
            $metadata[$name] = $property.Value
        }
    }
    $release = if ($metadata['DisplayVersion']) {
        [string]$metadata['DisplayVersion']
    }
    elseif ($metadata['ReleaseId']) {
        [string]$metadata['ReleaseId']
    }
    else {
        @{
            10240 = '1507'
            10586 = '1511'
            14393 = '1607'
            15063 = '1703'
            16299 = '1709'
            17134 = '1803'
            17763 = '1809'
            18362 = '1903'
            18363 = '1909'
            19041 = '2004'
            19042 = '20H2'
            19043 = '21H1'
            19044 = '21H2'
            19045 = '22H2'
            22000 = '21H2'
            22621 = '22H2'
            22631 = '23H2'
            26100 = '24H2'
            26200 = '25H2'
        }[$build]
    }
    if (!$release) {
        $release = "build$build"
    }
    $edition = ($imageName `
        -replace '^Windows\s+\d+\s+', '' `
        -replace '[^a-zA-Z0-9]+', '_').Trim('_').ToLower()
    if (!$edition) { $edition = 'unknown' }
    $majorVersion = if ($build -ge 22000) { 11 } else { 10 }
    $windowsId = "win${majorVersion}_$($release.ToLower())_$edition"
    if (!$WindowsImages.Contains($windowsId)) {
        $WindowsImages[$windowsId] = $metadata
    }
    [pscustomobject]@{
        WindowsId   = $windowsId
        ProductName = $metadata['ProductName']
        Edition     = ($imageName -replace '^Windows\s+\d+\s+', '')
        Build       = if ($metadata['UBR']) { "$build.$($metadata['UBR'])" } else { [string]$build }
        ImageIndex  = $WindowsImage.PSObject.Properties['ImageIndex'].Value
        ImageName   = $imageName
    }
}

function Get-RdsSevenZipPath {
    [CmdletBinding()]
    param([string]$Path)
    $programFilesX86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    @(
        $Path
        (Get-Command 7z.exe -CommandType Application -ErrorAction SilentlyContinue).Source
        ([IO.Path]::Combine([string[]]@($env:ProgramFiles, '7-Zip', '7z.exe')))
        $(if ($programFilesX86) { [IO.Path]::Combine([string[]]@($programFilesX86, '7-Zip', '7z.exe')) })
        ([IO.Path]::Combine([string[]]@($env:USERPROFILE, 'scoop', 'apps', '7zip', 'current', '7z.exe')))
        ([IO.Path]::Combine([string[]]@($PSScriptRoot, '..', '..', 'Programs', '7-Zip', '7z.exe')))
    ) | Where-Object {
        $_ -and (Test-Path -LiteralPath $_ -PathType Leaf)
    } | Select-Object -First 1
}

function ConvertTo-RdsPsLiteral {
    param($Value)
    if ($null -eq $Value) { return '$null' }
    if ($Value -is [bool]) { return '$' + $Value.ToString().ToLower() }
    if ($Value -is [byte] -or $Value -is [int16] -or $Value -is [int32] -or
        $Value -is [int64] -or $Value -is [uint16] -or $Value -is [uint32] -or
        $Value -is [uint64]) {
        return [string]$Value
    }
    "'" + ([string]$Value).Replace("'", "''") + "'"
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

function ConvertTo-RdsCommonLookupTable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Collections.IDictionary]$WindowsImages,
        [Parameter(Mandatory)][Collections.IDictionary]$LookupTable
    )

    $releaseGroups = [ordered]@{}
    foreach ($windowsId in $WindowsImages.Keys) {
        $releaseId = Get-RdsReleaseId -WindowsId $windowsId
        if (!$releaseGroups.Contains($releaseId)) {
            $releaseGroups[$releaseId] = [Collections.Generic.List[string]]::new()
        }
        $releaseGroups[$releaseId].Add([string]$windowsId)
    }

    $result = [ordered]@{}
    foreach ($service in $LookupTable.Keys) {
        $source = $LookupTable[$service]
        $target = [ordered]@{}

        foreach ($releaseId in $releaseGroups.Keys) {
            $windowsIds = @($releaseGroups[$releaseId])
            $hasReleaseData = $source.Contains($releaseId)
            if (!$hasReleaseData) {
                foreach ($windowsId in $windowsIds) {
                    if ($source.Contains($windowsId)) {
                        $hasReleaseData = $true
                        break
                    }
                }
            }
            if (!$hasReleaseData) { continue }

            $baseWindowsId = if ($windowsIds -contains "${releaseId}_home") {
                "${releaseId}_home"
            }
            elseif ($windowsIds -contains "${releaseId}_pro") {
                "${releaseId}_pro"
            }
            else {
                $windowsIds[0]
            }

            $baseValue = Get-RdsLookupValue -ServiceTable $source -WindowsId $baseWindowsId
            $target[$releaseId] = $baseValue

            foreach ($windowsId in $windowsIds) {
                $value = Get-RdsLookupValue -ServiceTable $source -WindowsId $windowsId
                if ($value -ne $baseValue) {
                    $target[$windowsId] = $value
                }
            }
        }

        if ($target.Count) { $result[$service] = $target }
    }

    $result
}

function Get-RdsLookupTableText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Collections.IDictionary]$WindowsImages,
        [Parameter(Mandatory)]
        [Collections.IDictionary]$LookupTable
    )
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('$windowsImages = [ordered]@{')
    foreach ($windowsId in $WindowsImages.Keys) {
        $lines.Add("    $windowsId = [ordered]@{")
        foreach ($property in $WindowsImages[$windowsId].Keys) {
            $lines.Add("        $property = $(ConvertTo-RdsPsLiteral $WindowsImages[$windowsId][$property])")
        }
        $lines.Add('    }')
    }
    $lines.Add('}')
    $lines.Add('')
    $lines.Add('$lookupTable = [ordered]@{')
    foreach ($service in $LookupTable.Keys | Sort-Object) {
        $escapedService = ([string]$service).Replace("'", "''")
        $lines.Add("    '$escapedService' = [ordered]@{")
        foreach ($windowsId in $LookupTable[$service].Keys) {
            $lines.Add("        $windowsId = $(ConvertTo-RdsPsLiteral $LookupTable[$service][$windowsId])")
        }
        $lines.Add('    }')
    }
    $lines.Add('}')
    $lines -join "`r`n"
}

function New-RdsTempHive {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    $name = "RDS_TEMP_$PID`_$([guid]::NewGuid().ToString('N').Substring(0, 8))"
    $key = "HKLM:\SOFTWARE\$name"
    try {
        New-Item -Path $key -Force | Out-Null
        Invoke-RegExe -ArgumentList @('save', "HKLM\SOFTWARE\$name", $Path, '/y') | Out-Null
    }
    finally {
        Remove-Item -LiteralPath $key -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Initialize-RdsData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ArchivePath,
        [Parameter(Mandatory)][string]$DestinationPath,
        [Parameter(Mandatory)][string]$SevenZipPath
    )

    if (Test-Path -LiteralPath $ArchivePath -PathType Leaf) {
        $process = Start-Process -FilePath $SevenZipPath -ArgumentList @(
            'x', $ArchivePath, "-o$DestinationPath", '-y'
        ) -WindowStyle Hidden -Wait -PassThru

        if ($process.ExitCode -gt 1) {
            throw "7-Zip failed to extract RDS.7z with exit code $($process.ExitCode)."
        }
    }

    $services = Join-Path $DestinationPath 'Services.reg'
    $lookup = Join-Path $DestinationPath 'Lookup-Table.ps1'
    $hive = Join-Path $DestinationPath 'TempHive'

    if (!(Test-Path -LiteralPath $services)) {
        [IO.File]::WriteAllText($services, "Windows Registry Editor Version 5.00`r`n", [Text.UTF8Encoding]::new($false))
    }
    if (!(Test-Path -LiteralPath $lookup)) {
        [IO.File]::WriteAllText($lookup, "`$windowsImages = [ordered]@{`r`n}`r`n`r`n`$lookupTable = [ordered]@{`r`n}`r`n", [Text.UTF8Encoding]::new($false))
    }
    if (!(Test-Path -LiteralPath $hive)) {
        New-RdsTempHive -Path $hive
    }
}

function Update-RdsArchive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ArchivePath,
        [Parameter(Mandatory)][string]$DataPath,
        [Parameter(Mandatory)][string]$SevenZipPath
    )

    $parent = Split-Path $ArchivePath -Parent
    if ($parent -and !(Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $arguments = @(
        'u', $ArchivePath, '-y', '-mx=9',
        'Lookup-Table.ps1', 'Services.reg', 'TempHive'
    )

    $process = Start-Process -FilePath $SevenZipPath -ArgumentList $arguments `
        -WorkingDirectory $DataPath -WindowStyle Hidden -Wait -PassThru

    if ($process.ExitCode -gt 1) {
        throw "7-Zip failed to update RDS.7z with exit code $($process.ExitCode)."
    }
}

function Get-RdsSelectedImages {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Images,
        [string[]]$ImageIndex
    )
    if (!$ImageIndex) {
        $ImageIndex = @('1')
    }
    elseif ($ImageIndex -contains '*') {
        return @($Images)
    }
    $indexes = foreach ($value in $ImageIndex) {
        $parsed = 0
        if (![int]::TryParse($value, [ref]$parsed) -or $parsed -lt 1) {
            throw "Invalid image index '$value'. Specify one or more positive integers, or '*'."
        }
        $parsed
    }
    foreach ($index in $indexes | Select-Object -Unique) {
        $image = $Images | Where-Object ImageIndex -eq $index
        if (!$image) { throw "Image index $index was not found in the install image." }
        $image
    }
}

function Get-RdsImageHives {
    param(
        [Parameter(Mandatory)][string]$InstallImage,
        [Parameter(Mandatory)]$Image,
        [Parameter(Mandatory)][string]$DestinationPath,
        [Parameter(Mandatory)][string]$MountPath
    )
    if ([IO.Path]::GetExtension($InstallImage) -ne '.wim') {
        throw '7-Zip is required for install.esd. Native fallback supports install.wim.'
    }
    Remove-Item $DestinationPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    Mount-WindowsImage -ImagePath $InstallImage -Index $Image.ImageIndex -Path $MountPath -ReadOnly | Out-Null
    try {
        $system = Join-Path $DestinationPath 'SYSTEM'
        $software = Join-Path $DestinationPath 'SOFTWARE'
        Copy-Item (Join-Path $MountPath 'Windows\System32\config\SYSTEM') $system
        Copy-Item (Join-Path $MountPath 'Windows\System32\config\SOFTWARE') $software
        [pscustomobject]@{ System = $system; Software = $software }
    }
    finally {
        Dismount-WindowsImage -Path $MountPath -Discard | Out-Null
    }
}

function Start-RdsImageHiveExtraction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$InstallImage,
        [Parameter(Mandatory)]$Image,
        [Parameter(Mandatory)][string]$DestinationPath,
        [Parameter(Mandatory)][string]$SevenZipPath
    )
    Remove-Item -LiteralPath $DestinationPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    $separator = [string][char]92
    $prefix = ([string]$Image.ImageIndex, 'Windows', 'System32', 'config') -join $separator
    $arguments = @(
        'x', $InstallImage, "-o$DestinationPath", '-y',
        ($prefix + $separator + 'SYSTEM'),
        ($prefix + $separator + 'SOFTWARE')
    )
    $process = Start-Process -FilePath $SevenZipPath -ArgumentList $arguments `
        -WindowStyle Hidden -PassThru
    [pscustomobject]@{
        Process         = $process
        SevenZipPath    = $SevenZipPath
        InstallImage    = $InstallImage
        ImageIndex      = [int]$Image.ImageIndex
        DestinationPath = $DestinationPath
        Prefix          = $prefix
    }
}

function Receive-RdsImageHiveExtraction {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Task)
    $Task.Process.WaitForExit()
    $Task.Process.Refresh()
    $root = Join-Path $Task.DestinationPath $Task.Prefix
    $system = Join-Path $root 'SYSTEM'
    $software = Join-Path $root 'SOFTWARE'
    if ((Test-Path -LiteralPath $system) -and (Test-Path -LiteralPath $software)) {
        return [pscustomobject]@{
            System   = $system
            Software = $software
        }
    }
    # Some single-index WIM/ESD files expose the image directly under Windows\...
    Remove-Item -LiteralPath $Task.DestinationPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path $Task.DestinationPath -Force | Out-Null
    $separator = [string][char]92
    $prefix = ('Windows', 'System32', 'config') -join $separator
    $arguments = @(
        'x', $Task.InstallImage, "-o$($Task.DestinationPath)", '-y',
        ($prefix + $separator + 'SYSTEM'),
        ($prefix + $separator + 'SOFTWARE')
    )
    $process = Start-Process -FilePath $Task.SevenZipPath -ArgumentList $arguments `
        -WindowStyle Hidden -Wait -PassThru
    $root = Join-Path $Task.DestinationPath $prefix
    $system = Join-Path $root 'SYSTEM'
    $software = Join-Path $root 'SOFTWARE'
    if ((Test-Path -LiteralPath $system) -and (Test-Path -LiteralPath $software)) {
        return [pscustomobject]@{
            System   = $system
            Software = $software
        }
    }
    throw "7-Zip could not locate SYSTEM and SOFTWARE for image index $($Task.ImageIndex). Exit code: $($process.ExitCode)."
}

function Update-RdsData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string[]]$IsoPath,
        [string]$ArchivePath = (Join-Path $PSScriptRoot 'RDS.7z'),
        [string]$SevenZipPath,
        [string[]]$ImageIndex,
        [switch]$UpdateLookupTable,
        [switch]$ReplaceLookupEntry
    )
    $archivePath = [IO.Path]::GetFullPath($ArchivePath)
    $sevenZip = Get-RdsSevenZipPath -Path $SevenZipPath
    if (!$sevenZip) { throw '7-Zip is required to read and write RDS.7z.' }

    $workPath = Join-Path ([IO.Path]::GetTempPath()) "RDS-Update-$([guid]::NewGuid().ToString('N'))"
    $workDataPath = Join-Path $workPath 'RDS'
    $imagePath = Join-Path $workPath 'Image'
    $mountPath = Join-Path $workPath 'Mount'
    New-Item -ItemType Directory -Path $workPath, $workDataPath, $imagePath, $mountPath | Out-Null
    $workServices = Join-Path $workDataPath 'Services.reg'
    $workLookup = Join-Path $workDataPath 'Lookup-Table.ps1'
    $workHive = Join-Path $workDataPath 'TempHive'
    $diskImage = $null
    $currentIso = $null
    try {
        Initialize-RdsData -ArchivePath $archivePath -DestinationPath $workDataPath -SevenZipPath $sevenZip
        $windowsImages = [ordered]@{}
        $lookupTable = [ordered]@{}
        . $workLookup
        if ($windowsImages -isnot [Collections.IDictionary]) { throw "$workLookup did not define an IDictionary named `$windowsImages." }
        if ($lookupTable -isnot [Collections.IDictionary]) { throw "$workLookup did not define an IDictionary named `$lookupTable." }
        $cache = Get-RdsVariantCache -ServicesFile $workServices
        $existingHashes = $cache.Hashes
        $nextVariant = $cache.NextIndex
        $results = [Collections.Generic.List[object]]::new()
        for ($isoNumber = 0; $isoNumber -lt $IsoPath.Count; $isoNumber++) {
            $currentIso = $IsoPath[$isoNumber]
            $diskImage = $null
            $nextExtraction = $null
            try {
                Write-Progress -Id 1 -Activity 'Updating RDS data' `
                    -Status "ISO $($isoNumber + 1) of $($IsoPath.Count): $([IO.Path]::GetFileName($currentIso))" `
                    -PercentComplete ([int](($isoNumber / [Math]::Max($IsoPath.Count, 1)) * 100))
                $diskImage = Mount-DiskImage -ImagePath $currentIso -PassThru
                $volume = $diskImage | Get-Volume | Where-Object DriveLetter | Select-Object -First 1
                if (!$volume) { throw 'The mounted ISO does not have an accessible drive letter.' }
                $mediaRoot = "$($volume.DriveLetter):\"
                $installImage = @(
                    Join-Path $mediaRoot 'sources\install.wim'
                    Join-Path $mediaRoot 'sources\install.esd'
                ) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
                if (!$installImage) { throw 'The ISO does not contain sources\install.wim or sources\install.esd.' }
                $images = @(Get-WindowsImage -ImagePath $installImage)
                $selectedImages = @(Get-RdsSelectedImages -Images $images -ImageIndex $ImageIndex)
                $isoImageDetail = $null
                $isoBuild = ''
                if ($selectedImages.Count) {
                    $isoImageDetail = Get-WindowsImage -ImagePath $installImage -Index $selectedImages[0].ImageIndex
                    $buildProperty = $isoImageDetail.PSObject.Properties['Build']
                    if ($buildProperty) { $isoBuild = [string]$buildProperty.Value }
                }
                $isoIdentity = $null

                if ($sevenZip -and $selectedImages.Count) {
                    $nextExtraction = Start-RdsImageHiveExtraction -InstallImage $installImage `
                        -Image $selectedImages[0] -DestinationPath (Join-Path $imagePath '0') `
                        -SevenZipPath $sevenZip
                }
                for ($imageNumber = 0; $imageNumber -lt $selectedImages.Count; $imageNumber++) {
                    $image = $selectedImages[$imageNumber]
                    Write-Progress -Id 1 -Activity 'Updating RDS data' `
                        -Status "ISO $($isoNumber + 1)/$($IsoPath.Count), image $($imageNumber + 1)/$($selectedImages.Count): $($image.ImageName)" `
                        -PercentComplete ([int]((($isoNumber + (($imageNumber + 1) / [Math]::Max($selectedImages.Count, 1))) / $IsoPath.Count) * 100))
                    if ($sevenZip) {
                        $hives = Receive-RdsImageHiveExtraction $nextExtraction
                        $nextExtraction = $null
                        if ($imageNumber + 1 -lt $selectedImages.Count) {
                            $next = $selectedImages[$imageNumber + 1]
                            $nextExtraction = Start-RdsImageHiveExtraction -InstallImage $installImage `
                                -Image $next -DestinationPath (Join-Path $imagePath ([string]($imageNumber + 1))) `
                                -SevenZipPath $sevenZip
                        }
                    }
                    else {
                        $hives = Get-RdsImageHives -InstallImage $installImage -Image $image `
                            -DestinationPath (Join-Path $imagePath ([string]$imageNumber)) -MountPath $mountPath
                    }
                    if (!(Test-Path $hives.System) -or !(Test-Path $hives.Software)) {
                        throw "Could not obtain both registry hives for image $($image.ImageIndex)."
                    }
                    $id = "$PID`_$($image.ImageIndex)_$([guid]::NewGuid().ToString('N').Substring(0, 8))"
                    $systemHiveName = "RDS_SYSTEM_$id"
                    $softwareHiveName = "RDS_SOFTWARE_$id"
                    $loadedHives = [Collections.Generic.List[string]]::new()
                    try {
                        $imageNameProperty = $image.PSObject.Properties['ImageName']
                        $imageDescriptionProperty = $image.PSObject.Properties['ImageDescription']
                        $architectureProperty = $image.PSObject.Properties['Architecture']
                        $imageMetadata = [pscustomobject]@{
                            ImageIndex       = $image.ImageIndex
                            ImageName        = if ($imageNameProperty) { $imageNameProperty.Value } else { '' }
                            ImageDescription = if ($imageDescriptionProperty) { $imageDescriptionProperty.Value } else { '' }
                            Architecture     = if ($architectureProperty) { $architectureProperty.Value } else { $null }
                            Build            = $isoBuild
                        }
                        if (!$isoIdentity) {
                            # Identify the release once from SOFTWARE, then reuse it for every edition in this ISO.
                            Invoke-RegExe -ArgumentList @('load', "HKLM\$softwareHiveName", $hives.Software) | Out-Null
                            $loadedHives.Add($softwareHiveName)
                            $imageInfo = Get-RdsImageInfo -SoftwareHiveName $softwareHiveName `
                                -WindowsImage $imageMetadata -WindowsImages $windowsImages
                            Invoke-RegExe -ArgumentList @('unload', "HKLM\$softwareHiveName") | Out-Null
                            $loadedHives.Remove($softwareHiveName) | Out-Null

                            $editionKey = ($imageInfo.Edition -replace '[^a-zA-Z0-9]+', '_').Trim('_').ToLower()
                            $prefixLength = $imageInfo.WindowsId.Length - $editionKey.Length - 1
                            $isoIdentity = [pscustomobject]@{
                                Prefix = $imageInfo.WindowsId.Substring(0, $prefixLength)
                                Build  = $imageInfo.Build
                            }
                        }
                        else {
                            $edition = ([string]$imageMetadata.ImageName -replace '^Windows\s+\d+\s+', '')
                            $editionKey = ($edition -replace '[^a-zA-Z0-9]+', '_').Trim('_').ToLower()
                            $windowsId = "$($isoIdentity.Prefix)_$editionKey"

                            if (!$windowsImages.Contains($windowsId)) {
                                $windowsImages[$windowsId] = [ordered]@{
                                    ImageName        = $imageMetadata.ImageName
                                    ImageDescription = $imageMetadata.ImageDescription
                                }
                            }

                            $known = $windowsImages[$windowsId]
                            $imageInfo = [pscustomobject]@{
                                WindowsId   = $windowsId
                                ProductName = if ($known['ProductName']) { $known['ProductName'] } else { $imageMetadata.ImageName }
                                Edition     = $edition
                                Build       = $isoIdentity.Build
                                ImageIndex  = $image.ImageIndex
                                ImageName   = $imageMetadata.ImageName
                            }
                        }
                        Invoke-RegExe -ArgumentList @('load', "HKLM\$systemHiveName", $hives.System) | Out-Null
                        $loadedHives.Add($systemHiveName)
                        $select = Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\$systemHiveName\Select"
                        $controlSetNumber = if ($null -ne $select.Current) { $select.Current } else { $select.Default }
                        $controlSet = 'ControlSet{0:D3}' -f [int]$controlSetNumber
                        $servicesSubKey = "$systemHiveName\$controlSet\Services"
                        # Installed Windows configures WLAN AutoConfig as Automatic, unlike the base WIM.
                        $wlanSvcPath = "Registry::HKEY_LOCAL_MACHINE\$servicesSubKey\WlanSvc"
                        if (Test-Path $wlanSvcPath) {
                            Set-ItemProperty -Path $wlanSvcPath -Name Start -Value 2
                            Remove-ItemProperty -Path $wlanSvcPath -Name DelayedAutoStart -ErrorAction SilentlyContinue
                        }
                        $addedVariants = 0
                        $reusedVariants = 0
                        $mappedServices = 0
                        $serviceData = Get-RdsServiceData -ServicesSubKey $servicesSubKey -TemporaryPath $workPath
                        $scanNames = @($serviceData.Keys | Sort-Object)
                        for ($serviceNumber = 0; $serviceNumber -lt $scanNames.Count; $serviceNumber++) {
                            $serviceKey = $scanNames[$serviceNumber]
                            $data = $serviceData[$serviceKey]
                            if (($serviceNumber % 10) -eq 0 -or $serviceNumber -eq $scanNames.Count - 1) {
                                Write-Progress -Id 2 -ParentId 1 -Activity 'Merging services' `
                                    -Status "$serviceKey ($($serviceNumber + 1) of $($scanNames.Count))" `
                                    -PercentComplete ([int]((($serviceNumber + 1) / [Math]::Max($scanNames.Count, 1)) * 100))
                            }
                            if (!$existingHashes.ContainsKey($serviceKey)) { $existingHashes[$serviceKey] = @{} }
                            $variantIndex = $existingHashes[$serviceKey][$data.Hash]
                            if ($variantIndex) {
                                $reusedVariants++
                            }
                            else {
                                $variantIndex = if ($nextVariant.ContainsKey($serviceKey)) { $nextVariant[$serviceKey] } else { 1 }
                                $nextVariant[$serviceKey] = $variantIndex + 1
                                Add-RdsServiceData -ServiceData $data `
                                    -DestinationKey "$serviceKey\$variantIndex\$serviceKey" -ServicesFile $workServices
                                $existingHashes[$serviceKey][$data.Hash] = $variantIndex
                                $addedVariants++
                            }
                            if (!$UpdateLookupTable) { continue }
                            if (!$lookupTable.Contains($serviceKey)) { $lookupTable[$serviceKey] = [ordered]@{} }
                            $oldIndex = Get-RdsLookupValue -ServiceTable $lookupTable[$serviceKey] -WindowsId $imageInfo.WindowsId
                            if ($oldIndex -and $oldIndex -ne $variantIndex -and !$ReplaceLookupEntry) {
                                throw "Lookup entry $serviceKey/$($imageInfo.WindowsId) is $oldIndex, but image $($image.ImageIndex) resolved to $variantIndex. Use -ReplaceLookupEntry to replace it."
                            }
                            $lookupTable[$serviceKey][$imageInfo.WindowsId] = $variantIndex
                            $mappedServices++
                        }
                        Write-Progress -Id 2 -ParentId 1 -Activity 'Merging services' -Completed
                        $results.Add([pscustomobject]@{
                            WindowsId       = $imageInfo.WindowsId
                            ProductName     = $imageInfo.ProductName
                            Edition         = $imageInfo.Edition
                            Build           = $imageInfo.Build
                            ImageIndex      = $imageInfo.ImageIndex
                            ImageName       = $imageInfo.ImageName
                            ServicesScanned = $scanNames.Count
                            ExistingVariant = $reusedVariants
                            AddedVariant    = $addedVariants
                            LookupEntries   = if ($UpdateLookupTable) { $mappedServices } else { 0 }
                        })
                    }
                    finally {
                        [GC]::Collect()
                        [GC]::WaitForPendingFinalizers()
                        $loaded = @($loadedHives)
                        [Array]::Reverse($loaded)
                        foreach ($hive in $loaded) {
                            try { Invoke-RegExe -ArgumentList @('unload', "HKLM\$hive") | Out-Null }
                            catch { Write-Warning $_ }
                        }
                    }
                }
            }
            finally {
                if ($nextExtraction) {
                    try {
                        if (!$nextExtraction.Process.HasExited) { $nextExtraction.Process.Kill() }
                        $nextExtraction.Process.Dispose()
                    }
                    catch {}
                    $nextExtraction = $null
                }
                if ($diskImage) { Dismount-DiskImage -ImagePath $currentIso -ErrorAction SilentlyContinue | Out-Null }
                $diskImage = $null
            }
        }
        if ($UpdateLookupTable) {
            $lookupTable = ConvertTo-RdsCommonLookupTable -WindowsImages $windowsImages -LookupTable $lookupTable
        }
        $lookupText = Get-RdsLookupTableText -WindowsImages $windowsImages -LookupTable $lookupTable
        [IO.File]::WriteAllText($workLookup, "$lookupText`r`n", [Text.UTF8Encoding]::new($false))
        Remove-Item -LiteralPath $workHive -Force -ErrorAction SilentlyContinue
        New-RdsTempHive -Path $workHive
        Write-Progress -Id 1 -Activity 'Updating RDS data' -Status 'Updating RDS.7z' -PercentComplete 100
        if ($PSCmdlet.ShouldProcess($archivePath, "Update RDS.7z from $($IsoPath.Count) ISO(s)")) {
            Update-RdsArchive -ArchivePath $archivePath -DataPath $workDataPath -SevenZipPath $sevenZip
        }
        $results
    }
    finally {
        Write-Progress -Id 2 -Activity 'Processing services' -Completed -ErrorAction SilentlyContinue
        Write-Progress -Id 1 -Activity 'Updating RDS data' -Completed -ErrorAction SilentlyContinue
        if ($diskImage -and $currentIso) { Dismount-DiskImage -ImagePath $currentIso -ErrorAction SilentlyContinue | Out-Null }
        if (Test-Path $mountPath) {
            try { Dismount-WindowsImage -Path $mountPath -Discard -ErrorAction SilentlyContinue | Out-Null } catch {}
        }
        Remove-Item -LiteralPath $workPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$resolvedIsoPaths = foreach ($path in $IsoPath) {
    $matches = @(Resolve-Path -Path $path -ErrorAction SilentlyContinue)
    if (!$matches.Count) { throw "ISO path '$path' was not found." }
    foreach ($match in $matches) {
        if (!(Test-Path -LiteralPath $match.Path -PathType Leaf)) { throw "'$($match.Path)' is not a file." }
        $match.Path
    }
}
$params = @{} + $PSBoundParameters
$params.IsoPath = @($resolvedIsoPaths | Select-Object -Unique)
Update-RdsData @params
