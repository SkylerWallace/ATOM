function Get-AtomManagedProgramState {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    $programInfo = $Plugin.ProgramInfo
    if (!$programInfo.DestinationPath -or !$programInfo.RelativePath) { return }

    try {
        $managedRoot = [IO.Path]::GetFullPath($programsPath).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
        $destinationPath = [IO.Path]::GetFullPath([String]$programInfo.DestinationPath).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
        $managedPrefix = $managedRoot + [IO.Path]::DirectorySeparatorChar
        if (!$destinationPath.StartsWith($managedPrefix, [StringComparison]::OrdinalIgnoreCase)) { return }

        $configuredPath = Join-Path $destinationPath ([String]$programInfo.RelativePath).TrimStart('\', '/')
        $launchPath = if (![Management.Automation.WildcardPattern]::ContainsWildcardCharacters($configuredPath)) {
            if ([IO.File]::Exists($configuredPath)) { $configuredPath }
        } else { @(Get-Item -Path $configuredPath -ErrorAction SilentlyContinue |
            Where-Object { !$_.PSIsContainer } |
            Sort-Object FullName -Descending |
            Select-Object -First 1).FullName }
        [PSCustomObject]@{
            DestinationPath = $destinationPath
            LaunchPath = $launchPath
            IsAvailable = [Boolean]$launchPath
        }
    } catch {
        return
    }
}
