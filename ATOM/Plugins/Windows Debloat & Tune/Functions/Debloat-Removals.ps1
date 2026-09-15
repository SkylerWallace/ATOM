function Test-DebloatUnusedAppx {
    param($Package, $Definition)
    if ($Definition.Important -or !$Definition.UserData -or $Package.IsFramework -or $Package.IsResourcePackage -or $Package.NonRemovable) { return $false }
    if ($Package.Name -ne $Definition.PackageName -or $Package.PublisherId -ne $Definition.PublisherId) { return $false }
    $root = [IO.Path]::GetFullPath((Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) "Packages\$($Package.PackageFamilyName)")).TrimEnd('\')
    $data = [IO.Path]::GetFullPath((Join-Path $root $Definition.UserData.TrimStart('\','/')))
    if (!$data.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) { return $false }
    return !(Test-Path -LiteralPath $data -ErrorAction Stop)
}

function New-DebloatRemovalQueue {
    <# .SYNOPSIS
        Resolves explicit program selections and cataloged AppX packages with no detected user data.
    #>
    param(
        [string[]]$ProgramNames,
        [ValidateSet('Malware', 'Bloatware')]
        [string[]]$ProgramCategories,
        [switch]$UnusedAppx,
        [string]$DependenciesPath
    )

    . (Join-Path $DependenciesPath 'Programs.ps1')
    foreach ($name in $ProgramNames) {
        if (!$programs.Contains($name) -or $programs[$name].Category -notin 'Malware','Bloatware') {
            throw "Select a program name from the Malware or Bloatware catalog: $name"
        }
    }
    $explicitNames = @($ProgramNames)
    $ProgramNames = @((@($ProgramNames) + @($programs.Keys | Where-Object { $programs[$_].Category -in $ProgramCategories })) | Where-Object { $_ })
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $installed = if ($ProgramNames.Count) { @(Get-App -ErrorAction Stop) } else { @() }
    foreach ($name in ($ProgramNames | Select-Object -Unique)) {
        $definition = $programs[$name]
        if ($definition.Detect -or $definition.Uninstall) { throw "Custom unattended removal is not configured for $name." }
        $matches = @($installed | Where-Object {
            $app = $_
            if ($definition.Match) { @($definition.Match | Where-Object { $app.DisplayName -match $_ }).Count -gt 0 }
            else { $app.DisplayName -eq $name }
        })
        if (!$matches.Count) {
            if ($name -in $explicitNames) {
                [pscustomobject]@{Kind='Program';Id=$name;Name=$name;SkipReason='Not installed.'}
            }
        }
        foreach ($app in $matches) {
            if (!$seen.Add($app.PsPath)) { continue }
            [pscustomobject]@{Kind='Program';Id=$app.PsPath;Name=$app.DisplayName;Target=$app;Unattended=$true}
        }
    }
    if ($UnusedAppx) {
        . (Join-Path $DependenciesPath 'Apps.ps1')
        $packages = @(Get-AppxPackage -ErrorAction Stop)
        foreach ($name in $apps.Keys) {
            $definition = $apps[$name]
            foreach ($package in $packages) {
                if ($package.Name -ne $definition.PackageName -or $package.PublisherId -ne $definition.PublisherId) { continue }
                if (!(Test-DebloatUnusedAppx -Package $package -Definition $definition)) { continue }
                if (!$seen.Add($package.PackageFullName)) { continue }
                [pscustomobject]@{
                    Kind='AppX';Id=$package.PackageFullName;Name=$name
                    PackageName=$package.Name;PackageFullName=$package.PackageFullName
                    Definition=$definition;UnusedOnly=$true
                }
            }
        }
    }
}

function Get-DebloatQuietUninstall {
    param($App)
    $command = if ($App.QuietUninstallString) { [string]$App.QuietUninstallString } else { [string]$App.UninstallString }
    $command = [Environment]::ExpandEnvironmentVariables($command)
    $match = [regex]::Match($command, '^\s*(?:"(?<exe>[^"]+\.exe)"|(?<exe>.+?\.exe))\s*(?<args>.*)$', 'IgnoreCase')
    if (!$match.Success) { throw 'No supported unattended executable uninstall command is registered.' }
    $exe = $match.Groups['exe'].Value
    $arguments = $match.Groups['args'].Value
    if ([IO.Path]::GetFileName($exe) -ieq 'msiexec.exe') {
        $product = [regex]::Match($arguments, '(?i)/(?:x|i)\s*(?<id>\{[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\})')
        if (!$product.Success) { throw 'MSI uninstall command has no product code.' }
        return @{ FilePath=(Join-Path $env:SystemRoot 'System32\msiexec.exe'); ArgumentList="/x $($product.Groups['id'].Value) /qn /norestart" }
    }
    if (!$App.QuietUninstallString) { throw 'No quiet uninstall command is registered; manual removal is required.' }
    if (![IO.Path]::IsPathRooted($exe)) { throw 'Quiet uninstaller must have an absolute executable path.' }
    $parameters = @{FilePath=$exe}
    if ($arguments) { $parameters.ArgumentList=$arguments }
    $parameters
}

function Remove-DebloatProgram {
    param($App)
    if (!(Test-Path -LiteralPath $App.PsPath -ErrorAction Stop)) { return }
    $current = Get-ItemProperty -LiteralPath $App.PsPath -ErrorAction Stop
    if ($current.DisplayName -ne $App.DisplayName -or $current.UninstallString -ne $App.UninstallString -or $current.QuietUninstallString -ne $App.QuietUninstallString) { throw 'Uninstall registration changed; scan again.' }
    $parameters = Get-DebloatQuietUninstall -App $current
    $process = Start-Process @parameters -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
    if ($process.ExitCode -notin 0,1641,3010) { throw "Uninstaller exited with code $($process.ExitCode)." }
    if (Test-Path -LiteralPath $App.PsPath -ErrorAction Stop) { throw "Uninstall registration remains (exit code $($process.ExitCode)); a restart or manual review may be required." }
}
