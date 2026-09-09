function Save-AtomUserPlugin {
    <# .SYNOPSIS
        Stores scripts in Plugins and metadata/ownership in Config/PluginsUser.ps1.
    #>
    param(
        [Parameter(Mandatory)][String]$RootPath,
        [Parameter(Mandatory)][Collections.IDictionary]$Metadata,
        [String]$Id,
        [String[]]$ReservedNames = @(),
        [String]$SourceScript,
        [AllowEmptyString()][String]$IconSource
    )
    $name = ([String]$Metadata.Name).Trim()
    if (!$name -or $name.Length -gt 100 -or $name.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0 -or $name.EndsWith('.') -or $name -match '^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)') { throw 'Enter a valid Windows filename for the plugin name, without an extension.' }
    $native = @(Get-AtomNativePluginName -RootPath $RootPath)
    $existing = @(Get-AtomUserPlugin -RootPath $RootPath -NativeNames $native)
    $previous = $null
    if ($Id) {
        $previous = $existing | Where-Object Id -eq $Id | Select-Object -First 1
        if (!$previous) { throw 'The plugin no longer exists or belongs to ATOM.' }
    }
    if ($native -contains $name -or $ReservedNames -contains $name -or @($existing | Where-Object { $_.Id -ne $Id -and $_.Name -eq $name }).Count) { throw "A plugin named '$name' already exists. Choose another name." }
    $extension = if ($previous) { [IO.Path]::GetExtension($previous.FullName) } else { [IO.Path]::GetExtension([String]$Metadata.Script) }
    if ($extension -notin '.ps1', '.cmd', '.bat') { throw 'Choose PowerShell, CMD, or BAT script type.' }
    $folder = [IO.Path]::GetFullPath((Join-Path $RootPath 'Plugins'))
    [void][IO.Directory]::CreateDirectory($folder)
    if ((Get-Item -LiteralPath $folder).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Plugins cannot be a linked directory when editing scripts.' }
    $destination = Join-Path $folder ($name + $extension)
    $previousPath = if ($previous) { $previous.FullName } else { $null }
    foreach ($file in Get-ChildItem -LiteralPath $folder -File) {
        if ($file.BaseName -eq $name -and $file.FullName -ne $previousPath) { throw "A file named '$($file.Name)' already exists." }
    }
    if ($previous -and (Get-Item -LiteralPath $previousPath).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked plugin scripts cannot be edited or renamed by ATOM.' }
    if ($SourceScript -and !$previous -and (!(Test-Path -LiteralPath $SourceScript -PathType Leaf) -or [IO.Path]::GetExtension($SourceScript) -ne $extension)) { throw 'The source script must match the selected script type.' }
    if ($IconSource -and (!(Test-Path -LiteralPath $IconSource -PathType Leaf) -or [IO.Path]::GetExtension($IconSource) -notin '.png', '.jpg', '.jpeg', '.ico')) { throw 'Choose a PNG, JPEG, or ICO image.' }
    $overridePath = Join-Path $RootPath 'Config/PluginsUser.ps1'
    $overrides = Read-AtomPluginOverrides -Path $overridePath
    if ($overrides.Contains($name) -and (!$previous -or $previous.Name -ne $name)) { throw "Metadata already exists for '$name'. Choose another name." }
    $data = [ordered]@{}
    if ($previous -and $overrides.Contains($previous.Name)) {
        foreach ($key in $overrides[$previous.Name].Keys) { $data[$key] = $overrides[$previous.Name][$key] }
    }
    $pluginId = if ($previous.IsUserOwned) { $previous.Id } elseif ($Metadata.PluginId -match '^[a-f0-9]{32}$') { $Metadata.PluginId } else { [Guid]::NewGuid().ToString('N') }
    if (@($existing | Where-Object { $_.IsUserOwned -and $_.Id -eq $pluginId -and $_.Id -ne $Id }).Count) { throw 'This plugin ID is already registered.' }
    $data.UserOwned = $true
    $data.PluginId = $pluginId
    $data.FileName = [IO.Path]::GetFileName($destination)
    foreach ($key in 'Category', 'Description', 'ToolTip') { $data[$key] = [String]$Metadata[$key] }
    if ([String]::IsNullOrWhiteSpace($data.Category)) { $data.Category = 'Uncategorized' }
    foreach ($key in 'Tags', 'Aliases') { $data[$key] = @($Metadata[$key] | ForEach-Object { ([String]$_).Trim() } | Where-Object { $_ } | Select-Object -Unique) }
    foreach ($key in 'Silent', 'Hidden', 'Favorite') { $data[$key] = [Boolean]$Metadata[$key] }
    foreach ($key in 'WorksInOs', 'WorksInPe') {
        $data[$key] = if ($Metadata.Contains($key)) { [Boolean]$Metadata[$key] } elseif ($previous) { [Boolean]$previous.Metadata[$key] } else { $key -eq 'WorksInOs' }
    }
    $created = [Collections.Generic.List[String]]::new()
    $renamed = $false
    try {
        if (!$previous) {
            if ($SourceScript) { [IO.File]::Copy($SourceScript, $destination, $false) }
            else {
                $content = if ($extension -eq '.ps1') { "# Add your PowerShell commands here.`r`n" } else { "@echo off`r`nrem Add your commands here.`r`n" }
                [IO.File]::WriteAllText($destination, $content)
            }
            $created.Add($destination)
        } elseif ($destination -cne $previousPath) {
            Move-Item -LiteralPath $previousPath -Destination $destination -ErrorAction Stop
            $renamed = $true
        }
        if ($PSBoundParameters.ContainsKey('IconSource')) {
            $data.IconPath = ''
            $data.OwnedIcon = ''
            if ($IconSource) {
                $relativeIcon = 'Resources/Icons/User Icons/' + [Guid]::NewGuid().ToString('N') + [IO.Path]::GetExtension($IconSource).ToLowerInvariant()
                $iconPath = Join-Path $RootPath $relativeIcon
                [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($iconPath))
                [IO.File]::Copy($IconSource, $iconPath, $false)
                $created.Add($iconPath)
                $data.IconPath = $relativeIcon
                $data.OwnedIcon = $relativeIcon
            }
        }
        if ($previous) { [void]$overrides.Remove($previous.Name) }
        $overrides[$name] = $data
        Write-AtomPluginOverrides -Path $overridePath -Overrides $overrides
    } catch {
        if ($renamed) { Move-Item -LiteralPath $destination -Destination $previousPath -ErrorAction Stop }
        foreach ($file in $created) { [IO.File]::Delete($file) }
        throw
    }
    return $pluginId
}
