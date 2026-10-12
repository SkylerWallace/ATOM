function Save-AtomPlugin {
    <# .SYNOPSIS
        Saves user-owned plugins, or creates an official plugin in the built-in catalog.
    .DESCRIPTION
        Official creation writes a permanent ID and metadata to Config/Plugins.ps1.
        Script and icon creation are rolled back if metadata persistence fails.
        Existing official plugins must be edited in source control.
    #>
    param(
        [Parameter(Mandatory)][String]$RootPath,
        [Parameter(Mandatory)][Collections.IDictionary]$Metadata,
        [String]$Id,
        [String[]]$ReservedNames = @(),
        [String]$SourceScript,
        [AllowEmptyString()][String]$IconSource,
        [Switch]$Official
    )
    if ($Official -and $Id) { throw 'Official mode can only create a new plugin.' }
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
    if (@($overrides.GetEnumerator() | Where-Object { $_.Value.Name -eq $name -and $_.Key -ne $Id }).Count) { throw "Metadata already exists for '$name'. Choose another name." }
    $data = [ordered]@{}
    if ($previous -and $overrides.Contains($previous.Id)) {
        foreach ($key in $overrides[$previous.Id].Keys) { $data[$key] = $overrides[$previous.Id][$key] }
    }
    $pluginId = if ($previous.IsUserOwned) { $previous.Id } elseif (!$Official -and $Metadata.Id -match '^[a-f0-9]{32}$') { $Metadata.Id } else { [Guid]::NewGuid().ToString('N') }
    $nativeIds = @(& {
        param($CatalogPath)
        . $CatalogPath
        $programDefaults.Values.Id
    } (Join-Path $RootPath 'Config/Plugins.ps1'))
    if ($nativeIds -contains $pluginId -or ($overrides.Contains($pluginId) -and $pluginId -ne $Id)) { throw 'This plugin ID is already registered.' }
    $data.Id = $pluginId
    if (!$Official) {
        $data.UserOwned = $true
        $data.Name = $name
        $data.FileName = [IO.Path]::GetFileName($destination)
    }
    foreach ($key in 'Category', 'Description', 'ToolTip') { $data[$key] = [String]$Metadata[$key] }
    if ([String]::IsNullOrWhiteSpace($data.Category)) { $data.Category = 'Uncategorized' }
    foreach ($key in 'Tags', 'Aliases') { $data[$key] = @($Metadata[$key] | ForEach-Object { ([String]$_).Trim() } | Where-Object { $_ } | Select-Object -Unique) }
    foreach ($key in 'Silent', 'Hidden') { $data[$key] = [Boolean]$Metadata[$key] }
    $data.RequiresAdmin = if ($Metadata.Contains('RequiresAdmin')) { [Boolean]$Metadata.RequiresAdmin } elseif ($previous -and $previous.Metadata.Contains('RequiresAdmin')) { [Boolean]$previous.Metadata.RequiresAdmin } else { $true }
    if (!$Official) { $data.Favorite = [Boolean]$Metadata.Favorite }
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
            if (!$Official) { $data.OwnedIcon = '' }
            if ($IconSource) {
                $iconExtension = [IO.Path]::GetExtension($IconSource).ToLowerInvariant()
                $relativeIcon = if ($Official) { "Plugins/$name/$name$iconExtension" } else { 'Resources/Icons/User Icons/' + [Guid]::NewGuid().ToString('N') + $iconExtension }
                $iconPath = Join-Path $RootPath $relativeIcon
                [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($iconPath))
                if ((Get-Item -LiteralPath ([IO.Path]::GetDirectoryName($iconPath))).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Plugin icons cannot be stored in a linked directory.' }
                [IO.File]::Copy($IconSource, $iconPath, $false)
                $created.Add($iconPath)
                $data.IconPath = $relativeIcon
                if (!$Official) { $data.OwnedIcon = $relativeIcon }
            }
        }
        if ($Official) {
            Add-AtomOfficialPluginDefinition -Path (Join-Path $RootPath 'Config/Plugins.ps1') -Name $name -Metadata $data
        } else {
            if ($previous) { [void]$overrides.Remove($previous.Id) }
            $overrides[$pluginId] = $data
            Write-AtomPluginOverrides -Path $overridePath -Overrides $overrides
        }
    } catch {
        if ($renamed) { Move-Item -LiteralPath $destination -Destination $previousPath -ErrorAction Stop }
        foreach ($file in $created) { [IO.File]::Delete($file) }
        throw
    }
    return $pluginId
}
