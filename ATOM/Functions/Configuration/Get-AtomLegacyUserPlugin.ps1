function Get-AtomLegacyUserPlugin {
    <# .SYNOPSIS
        Reads separately owned plugin bundles without executing their metadata.
    #>
    param([Parameter(Mandatory)][String]$RootPath)
    if (!(Test-Path -LiteralPath $RootPath -PathType Container)) { return }
    if ((Get-Item -LiteralPath $RootPath).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'User plugin storage cannot be a link.' }
    foreach ($directory in Get-ChildItem -LiteralPath $RootPath -Directory) {
        if ($directory.Name -notmatch '^[a-f0-9]{32}$' -or $directory.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        $metadataPath = Join-Path $directory.FullName 'plugin.json'
        if (!(Test-Path -LiteralPath $metadataPath -PathType Leaf)) { continue }
        try {
            $data = Get-Content -LiteralPath $metadataPath -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            if ($data.SchemaVersion -ne 1 -or [String]::IsNullOrWhiteSpace($data.Name) -or $data.Script -notmatch '^script\.(ps1|cmd|bat)$') { throw 'Invalid plugin metadata.' }
            $metadata = @{}
            foreach ($key in 'Name', 'Category', 'Description', 'ToolTip', 'Tags', 'Aliases', 'Silent', 'Hidden', 'Favorite', 'Script', 'Icon') { $metadata[$key] = $data.$key }
            # Older bundles had no environment restrictions; preserve that behavior.
            foreach ($key in 'WorksInOs', 'WorksInPe') {
                $metadata[$key] = if ($data.PSObject.Properties[$key]) { [Boolean]$data.$key } else { $true }
            }
            $iconPath = $null
            if ($data.Icon) {
                if ($data.Icon -notmatch '^icon-[a-f0-9]{32}\.(png|jpg|jpeg|ico)$') { throw 'Invalid icon filename.' }
                $iconPath = Join-Path $directory.FullName $data.Icon
            }
            [PSCustomObject]@{
                Id = $directory.Name
                Name = [String]$data.Name
                FullName = Join-Path $directory.FullName $data.Script
                Directory = $directory.FullName
                IconPath = $iconPath
                Metadata = $metadata
            }
        } catch { Write-Warning "Unable to load user plugin '$($directory.Name)': $($_.Exception.Message)" }
    }
}
