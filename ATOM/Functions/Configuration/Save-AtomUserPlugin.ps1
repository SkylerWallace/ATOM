function Save-AtomUserPlugin {
    <# .SYNOPSIS
        Creates or updates a user plugin bundle, retaining its stable script path.
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
    if (!$name -or $name.Length -gt 100 -or $name -match '[\x00-\x1f]') { throw 'Enter a plugin name between 1 and 100 characters, without control characters.' }
    $existing = @(Get-AtomUserPlugin -RootPath $RootPath)
    $previous = $null
    if ($Id) {
        if ($Id -notmatch '^[a-f0-9]{32}$') { throw 'Invalid user plugin ID.' }
        $previous = $existing | Where-Object Id -eq $Id | Select-Object -First 1
        if (!$previous) { throw 'This user plugin no longer exists.' }
    }
    if ($ReservedNames -contains $name -or @($existing | Where-Object { $_.Id -ne $Id -and $_.Name -eq $name }).Count) { throw "A plugin named '$name' already exists. Choose another name." }
    $scriptName = if ($previous) { $previous.Metadata.Script } else { [String]$Metadata.Script }
    if ($scriptName -notmatch '^script\.(ps1|cmd|bat)$') { throw 'Choose PowerShell, CMD, or BAT script type.' }
    if ($SourceScript -and !$previous) {
        if (!(Test-Path -LiteralPath $SourceScript -PathType Leaf) -or [IO.Path]::GetExtension($SourceScript) -ne [IO.Path]::GetExtension($scriptName)) { throw 'The source script must match the selected script type.' }
    }
    if ($IconSource -and (!(Test-Path -LiteralPath $IconSource -PathType Leaf) -or [IO.Path]::GetExtension($IconSource) -notin '.png', '.jpg', '.jpeg', '.ico')) { throw 'Choose a PNG, JPEG, or ICO image.' }
    if (!$Id) { $Id = [Guid]::NewGuid().ToString('N') }
    $directory = Join-Path ([IO.Path]::GetFullPath($RootPath)) $Id
    $data = [ordered]@{ SchemaVersion = 1; Name = $name; Script = $scriptName }
    foreach ($key in 'Category', 'Description', 'ToolTip') { $data[$key] = [String]$Metadata[$key] }
    if ([String]::IsNullOrWhiteSpace($data.Category)) { $data.Category = 'Uncategorized' }
    foreach ($key in 'Tags', 'Aliases') { $data[$key] = @($Metadata[$key] | ForEach-Object { ([String]$_).Trim() } | Where-Object { $_ } | Select-Object -Unique) }
    foreach ($key in 'Silent', 'Hidden', 'Favorite') { $data[$key] = [Boolean]$Metadata[$key] }
    foreach ($key in 'WorksInOs', 'WorksInPe') {
        $data[$key] = if ($Metadata.Contains($key)) { [Boolean]$Metadata[$key] }
            elseif ($previous) { [Boolean]$previous.Metadata[$key] }
            else { $key -eq 'WorksInOs' }
    }
    $data.Icon = if ($previous) { $previous.Metadata.Icon } else { '' }
    $createdFiles = [Collections.Generic.List[String]]::new()
    try {
        [void][IO.Directory]::CreateDirectory($directory)
        if (!$previous) {
            $scriptPath = Join-Path $directory $scriptName
            if ($SourceScript) { [IO.File]::Copy($SourceScript, $scriptPath, $false) }
            else {
                $content = if ($scriptName -eq 'script.ps1') { "# Add your PowerShell commands here.`r`n" } else { "@echo off`r`nrem Add your commands here.`r`n" }
                [IO.File]::WriteAllText($scriptPath, $content)
            }
            $createdFiles.Add($scriptPath)
        }
        if ($PSBoundParameters.ContainsKey('IconSource')) {
            $data.Icon = ''
            if ($IconSource) {
                $data.Icon = 'icon-' + [Guid]::NewGuid().ToString('N') + [IO.Path]::GetExtension($IconSource).ToLowerInvariant()
                $iconPath = Join-Path $directory $data.Icon
                [IO.File]::Copy($IconSource, $iconPath, $false)
                $createdFiles.Add($iconPath)
            }
        }
        Write-AtomFileAtomic -Path (Join-Path $directory 'plugin.json') -Content ($data | ConvertTo-Json -Depth 5)
    } catch {
        foreach ($file in $createdFiles) { [IO.File]::Delete($file) }
        if (!$previous -and [IO.Directory]::Exists($directory) -and ![IO.Directory]::EnumerateFileSystemEntries($directory).GetEnumerator().MoveNext()) { [IO.Directory]::Delete($directory) }
        throw
    }
    return $Id
}
