function Show-AtomPluginProperties {
    param (
        [Parameter(Mandatory)]
        [Object]$Plugin
    )

    $pluginFile = Get-Item -LiteralPath $Plugin.FullName
    $programInfo = $Plugin.ProgramInfo
    $programPath = if ($programInfo.DestinationPath -and $programInfo.RelativePath) { Join-Path $programInfo.DestinationPath $programInfo.RelativePath }
    $programFile = if ($programPath -and (Test-Path -LiteralPath $programPath -PathType Leaf)) { Get-Item -LiteralPath $programPath }
    $versionInfo = if ($programFile) { $programFile.VersionInfo }

    $sections = [ordered]@{
        Plugin = [ordered]@{
            Name                 = $Plugin.Name
            Aliases              = (@($Plugin.Config.Aliases) -join ', ')
            Tags                 = (@($Plugin.Config.Tags) -join ', ')
            Tooltip              = $Plugin.Config.ToolTip
            Category             = $Plugin.Category
            'File type'          = $pluginFile.Extension.TrimStart('.').ToUpperInvariant()
            'File location'      = $pluginFile.FullName
            'File size'          = "$([Math]::Round($pluginFile.Length / 1KB, 2)) KB"
            'Last modified'      = $pluginFile.LastWriteTime
            Favorite             = [Boolean]$Plugin.Config.Favorite
            Hidden               = $Plugin.Config.Hidden
            'Silent launch'      = $Plugin.Config.Silent
            'Works in Windows'   = $Plugin.Config.WorksInOs
            'Works in Windows PE'= $Plugin.Config.WorksInPe
        }
    }

    if ($programInfo) {
        $sections.Program = [ordered]@{
            Downloaded         = [Boolean]$programFile
            Executable         = $programPath
            'Detected version' = $(if ($versionInfo.ProductVersion) { $versionInfo.ProductVersion } else { $versionInfo.FileVersion })
            'Product name'     = $versionInfo.ProductName
            'Product version'  = $versionInfo.ProductVersion
            'File version'     = $versionInfo.FileVersion
            Company            = $versionInfo.CompanyName
            Description        = $versionInfo.FileDescription
            'Executable size'  = $(if ($programFile) { "$([Math]::Round($programFile.Length / 1MB, 2)) MB" })
            'Last modified'    = $(if ($programFile) { $programFile.LastWriteTime })
        }

        $downloadConfiguration = [ordered]@{}
        foreach ($entry in $programInfo.GetEnumerator() | Sort-Object Key) {
            $label = if ($entry.Key -eq 'ScriptBlock') { 'Custom download logic' } else { $entry.Key }
            $downloadConfiguration[$label] = if ($entry.Key -eq 'ScriptBlock') { [Boolean]$entry.Value } else { $entry.Value }
        }
        $sections['Download configuration'] = $downloadConfiguration
    }

    $manifestPath = Join-Path $programsPath 'downloads.json'
    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        try {
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
            $recordProperty = $manifest.Programs.PSObject.Properties[$Plugin.Name]
            if ($recordProperty) {
                $downloadRecord = [ordered]@{}
                foreach ($property in $recordProperty.Value.PSObject.Properties) {
                    $downloadRecord[$property.Name] = $property.Value
                }
                $sections['Download record'] = $downloadRecord
            }
        } catch {}
    }

    $text = foreach ($section in $sections.GetEnumerator()) {
        $section.Key.ToUpperInvariant()
        foreach ($entry in $section.Value.GetEnumerator()) {
            $value = $entry.Value
            if ($value -is [Boolean]) { $value = if ($value) { 'Yes' } else { 'No' } }
            elseif ($value -is [DateTime]) { $value = $value.ToString('g') }
            elseif ($null -eq $value -or [String]::IsNullOrWhiteSpace([String]$value)) { $value = 'Not specified' }
            "$($entry.Key): $value"
        }
        ''
    }

    $dialog = New-Object Windows.Window
    $dialog.Title = "$($Plugin.Name) Properties"
    $dialog.Owner = $window
    $dialog.Width = 700
    $dialog.Height = 600
    $dialog.MinWidth = 450
    $dialog.MinHeight = 300
    $dialog.WindowStartupLocation = 'CenterOwner'
    $dialog.ShowInTaskbar = $false
    $dialog.Background = $window.FindResource('backgroundBrush')

    $details = New-Object Windows.Controls.TextBox
    $details.Text = ($text -join [Environment]::NewLine).TrimEnd()
    $details.IsReadOnly = $true
    $details.AcceptsReturn = $true
    $details.TextWrapping = 'NoWrap'
    $details.VerticalScrollBarVisibility = 'Auto'
    $details.HorizontalScrollBarVisibility = 'Auto'
    $details.FontFamily = 'Consolas'
    $details.FontSize = 12
    $details.Margin = 10
    $details.Padding = 10
    $details.Background = $window.FindResource('surfaceBrush')
    $details.Foreground = $window.FindResource('surfaceText')
    $details.BorderBrush = $window.FindResource('accentBrush')
    $dialog.Content = $details

    [void]$dialog.ShowDialog()
}
