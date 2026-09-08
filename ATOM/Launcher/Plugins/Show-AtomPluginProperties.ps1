function Show-AtomPluginProperties {
    param([Object]$Plugin, [String]$Category = 'Uncategorized')
    $sections = [ordered]@{}
    if ($Plugin) {
        $pluginFile = if ($Plugin.FullName) { Get-Item -LiteralPath $Plugin.FullName -ErrorAction SilentlyContinue }
        $sections.File = [ordered]@{
            Ownership = $(if ($Plugin.UserPluginId) { 'User-created plugin' } else { 'Built-in / unmanaged plugin (read-only)' })
            Location = $Plugin.FullName
            'File size' = $(if ($pluginFile) { "$([Math]::Round($pluginFile.Length / 1KB, 2)) KB" } else { 'File missing' })
            'Last modified' = $(if ($pluginFile) { $pluginFile.LastWriteTime.ToString('g') })
            Favorite = [Boolean]$Plugin.Config.Favorite
        }
        $programInfo = $Plugin.ProgramInfo
        $programPath = if ($programInfo.DestinationPath -and $programInfo.RelativePath) { Join-Path $programInfo.DestinationPath $programInfo.RelativePath }
        $programFile = if ($programPath -and (Test-Path -LiteralPath $programPath -PathType Leaf)) { Get-Item -LiteralPath $programPath }
        $versionInfo = if ($programFile) { $programFile.VersionInfo }
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


    }
    $dialog = New-AtomPluginPropertiesWindow -Plugin $Plugin -Sections $sections -Category $Category
    $dialog.Tag.Save.Tag = $dialog
    $dialog.Tag.Save.Add_Click({
        $editor = $this.Tag
        $fields = $editor.Tag.Fields
        try {
            $metadata = @{
                Name = $fields.Name.Text
                Script = $fields.Type.SelectedValue
                Category = $(if ($fields.Category.SelectedValue -eq '__new_category__') { $fields.NewCategory.Text.Trim() } else { $fields.Category.SelectedValue })
                Description = $fields.Description.Text
                ToolTip = $fields.ToolTip.Text
                Tags = @($fields.Tags.Text -split ',')
                Aliases = @($fields.Aliases.Text -split ',')
                Silent = [Boolean]$fields.Silent.IsChecked
                Hidden = [Boolean]$fields.Hidden.IsChecked
                WorksInOs = [Boolean]$fields.WorksInOs.IsChecked
                WorksInPe = [Boolean]$fields.WorksInPe.IsChecked
                Favorite = [Boolean]$editor.Tag.Plugin.Config.Favorite
            }
            if ([String]::IsNullOrWhiteSpace($metadata.Category)) { throw 'Enter a category name.' }
            $saveArguments = @{
                RootPath = Join-Path (Split-Path $atomPath) 'UserPlugins'
                Metadata = $metadata
                ReservedNames = @($script:programDefaults.Keys) + @($programs.Keys | Where-Object { $script:userPluginRecords.Name -notcontains $_ }) + @(Get-ChildItem -LiteralPath $pluginsPath -File | ForEach-Object BaseName)
            }
            if ($editor.Tag.Plugin.UserPluginId) { $saveArguments.Id = $editor.Tag.Plugin.UserPluginId }
            if ($fields.Source -and $fields.Source.Text) { $saveArguments.SourceScript = $fields.Source.Text }
            if ($fields.Icon.Text -ne [String]$editor.Tag.Plugin.IconPath) {
                if ($fields.Icon.Text) { [void](Get-CachedImage -Path $fields.Icon.Text) }
                $saveArguments.IconSource = $fields.Icon.Text
            }
            [void](Save-AtomUserPlugin @saveArguments)
            $editor.DialogResult = $true
        } catch { $editor.Tag.Error.Text = $_.Exception.Message }
    })
    if ($dialog.ShowDialog()) {
        Update-AtomPluginList -Reload
        Update-AtomCatalogFilter
        $statusBarStatus.Text = if ($Plugin) { 'Plugin metadata saved' } else { 'Plugin created. Use Open in Editor to edit its script.' }
    }
}
