function Update-AtomPluginList {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $(
            if ($script:atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' }
            else { 'Category' }
        ),
        [Switch]$Reload
    )

    Update-AtomVisibilityButton
    $descriptionButton.Visibility = if ($script:downloadMode) { 'Collapsed' } else { 'Visible' }
    $descriptionButton.ToolTip = if ($atomSettings.ShowPluginDescriptions.Value) { 'Hide descriptions' } else { 'Show descriptions' }
    [Windows.Automation.AutomationProperties]::SetName($descriptionButton, $descriptionButton.ToolTip)
    $descriptionIcon = if ($atomSettings.ShowPluginDescriptions.Value) { 'SubtitlesIcon' } else { 'SubtitlesOffIcon' }
    Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ descriptionButton = $descriptionIcon } -Filled:([bool]$atomSettings.ShowPluginDescriptions.Value)

    $selectedPrograms =
        if ($script:downloadMode) {
            @(Get-AtomDownloadItem | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        } else {
            @()
        }

    $script:downloadRows = @{}
    if ($script:downloadMode) {
        $script:downloadRecords = @{}
        try {
            $manifest = Get-DownloadManifest
            foreach ($property in $manifest.Programs.PSObject.Properties) { $script:downloadRecords[$property.Name] = $property.Value }
        } catch { $downloadStorageText.Text = $_.Exception.Message }
    }
    $downloadManagerPanel.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }
    $pluginWrapPanel.Children.Clear()
    $pluginImageTimer.Stop()
    $script:pluginImageQueue.Clear()
    $downloadSelectedButton.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }
    $programUpdateButton.Visibility = if ($script:downloadMode) { 'Visible' } else { 'Collapsed' }

    # Reload plugin configuration and file discovery only when explicitly invalidated.
    if ($Reload) {
        . $atomPath\Config\Plugins.ps1
        $script:programs = $programs
        $script:programDefaults = $programDefaults
    }
    if ($Reload -or !$script:pluginFiles) {
        $script:pluginFiles = @(Get-ChildItem -LiteralPath $pluginsPath -File | Where-Object Extension -in '.ps1', '.bat', '.cmd', '.exe', '.lnk')
        $script:userPluginRecords = @(Get-AtomUserPlugin -RootPath (Join-Path (Split-Path $atomPath) 'UserPlugins'))
    }

    if ($Reload -or !$script:pluginIconNames) {
        $script:pluginIconNames = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($iconFile in Get-ChildItem -LiteralPath "$resourcesPath\Icons\Program Icons" -File -Filter '*.png') {
            [void]$script:pluginIconNames.Add($iconFile.BaseName)
        }
    }

    $pluginSources = @($script:pluginFiles)
    $reservedNames = @($script:pluginFiles.BaseName) + @($script:programDefaults.Keys)
    $seenUserNames = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($userPlugin in $script:userPluginRecords) {
        if ($reservedNames -contains $userPlugin.Name -or !$seenUserNames.Add($userPlugin.Name)) {
            Write-Warning "User plugin '$($userPlugin.Name)' has a name collision and was not loaded. Its files are kept in '$($userPlugin.Directory)'."
            continue
        }
        $programs[$userPlugin.Name] = $userPlugin.Metadata
        $pluginSources += [PSCustomObject]@{
            BaseName = $userPlugin.Name; FullName = $userPlugin.FullName
            Extension = [IO.Path]::GetExtension($userPlugin.FullName)
            Directory = [IO.DirectoryInfo]::new($userPlugin.Directory)
            UserPluginId = $userPlugin.Id; IconPath = $userPlugin.IconPath
        }
    }
    if ($script:downloadMode) {
        $pluginFileNames = @($script:pluginFiles.BaseName)
        $pluginSources += @(
            $programs.GetEnumerator() | Where-Object {
                $_.Value.DownloadOnly -and $_.Value.ProgramInfo -and $pluginFileNames -notcontains $_.Key
            } | ForEach-Object {
                [PSCustomObject]@{
                    BaseName  = $_.Key
                    FullName  = $null
                    Extension = $null
                    Directory = [PSCustomObject]@{ FullName = $pluginsPath }
                }
            }
        )
    }

    $plugins = $pluginSources | ForEach-Object {
        $name = $_.BaseName
        $pluginConfig = $programs[$name]
        $category = if ($pluginConfig.Category) { [String]$pluginConfig.Category } elseif ($_.Directory.FullName -ne $pluginsPath) { $_.Directory.Name } else { 'Uncategorized' }
        $fullName = $_.FullName
        $programInfo = $programs[$name].ProgramInfo

        # Omit context-specific plugins unless their condition explicitly succeeds.
        # Exclude non-downloadable/hidden entries before running visibility probes.
        if ($script:downloadMode -and (!$programInfo -or (!$atomSettings.ShowHiddenPlugins.Value -and $pluginConfig.Hidden))) { return }
        if ($pluginConfig.ShowIf -is [ScriptBlock]) {
            try {
                $visibilityResult = @(& $pluginConfig.ShowIf)
                if (
                    $visibilityResult.Count -ne 1 -or
                    $visibilityResult[0] -isnot [Boolean] -or
                    !$visibilityResult[0]
                ) {
                    return
                }
            } catch {
                Write-Warning "Unable to evaluate ShowIf for '$name': $($_.Exception.Message)"
                return
            }
        }

        if (!$script:downloadMode -and $pluginConfig.DownloadOnly) {
            return
        } elseif ($script:downloadMode) {
            # Download mode only applies to plugins backed by a downloadable program.
            if (!$programInfo -or (!$atomSettings.ShowHiddenPlugins.Value -and $pluginConfig.Hidden)) { return }
        } elseif ($pluginConfig) {
            if (
                (!$inPE -and $pluginConfig.WorksInOs -eq $false) -or
                ($inPE -and $pluginConfig.WorksInPe -eq $false) -or
                (!$atomSettings.ShowHiddenPlugins.Value -and $pluginConfig.Hidden)
            ) {
                return
            }
        }

        [PSCustomObject]@{
            Name         = $name
            FullName     = $fullName
            UserPluginId = $_.UserPluginId
            IconPath     = if ($_.IconPath) { $_.IconPath } else { $pluginConfig.IconPath }
            Config       = $pluginConfig
            ProgramInfo  = $programInfo
            Category     = $category
            GroupCategory =
                if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
                else { $category }
			LaunchParams = switch ($_.Extension) {
				'.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.exe' { @{ FilePath = $fullName } }
				'.lnk' { @{ FilePath = $fullName } }
				'.ps1' { @{ FilePath = 'powershell'; ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$fullName`"" } }
			}
        }
    } | Sort-Object GroupCategory, Name

    # Group plugins for UI
    $pluginGroups = $plugins | Group-Object GroupCategory

    foreach ($group in $pluginGroups) {
        # Create listbox for each plugin category
        $textBlock = [System.Windows.Controls.TextBlock]::new()
        $textBlock.Text = $group.Name
        $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        $textBlock.FontSize = 14
        $textBlock.Margin = '0,10,0,0'
        $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

        $listBox = [System.Windows.Controls.ListBox]::new()
        $listBox.Background = 'Transparent'
        $listBox.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $listBox.BorderThickness = 0
        $listBox.Margin = 5
        $listBox.Padding = 0
        $listBox.Width = 200
        $listBox.SetValue([System.Windows.Controls.ScrollViewer]::HorizontalScrollBarVisibilityProperty, [System.Windows.Controls.ScrollBarVisibility]::Disabled)

        if (!$script:downloadMode) {
            $listBox.Add_PreviewMouseLeftButtonDown({
                param($sender, $eventArgs)

                $item = [Windows.Controls.ItemsControl]::ContainerFromElement($sender, $eventArgs.OriginalSource)
                if ($item -isnot [Windows.Controls.ListBoxItem]) { return }

                $window.Tag.PluginDragSource = $item
                $window.Tag.PluginClickSource = $item
                $window.Tag.PluginDragStart = $eventArgs.GetPosition($window)
            })

            $listBox.Add_PreviewMouseMove({
                param($sender, $eventArgs)

                $source = $window.Tag.PluginDragSource
                if (
                    $eventArgs.LeftButton -ne [Windows.Input.MouseButtonState]::Pressed -or
                    !$source -or
                    !$sender.Items.Contains($source)
                ) {
                    return
                }

                $currentPoint = $eventArgs.GetPosition($window)
                if (
                    [Math]::Abs($currentPoint.X - $window.Tag.PluginDragStart.X) -lt [Windows.SystemParameters]::MinimumHorizontalDragDistance -and
                    [Math]::Abs($currentPoint.Y - $window.Tag.PluginDragStart.Y) -lt [Windows.SystemParameters]::MinimumVerticalDragDistance
                ) {
                    return
                }

                $data = [Windows.DataObject]::new()
                $data.SetData('ATOM.PluginName', $source.Tag.Name)
                $data.SetData('ATOM.PluginCategory', $source.Tag.Category)
                $window.Tag.PluginDragSource = $null
                $window.Tag.PluginClickSource = $null
                $eventArgs.Handled = $true
                [void][Windows.DragDrop]::DoDragDrop($source, $data, [Windows.DragDropEffects]::Move)
            })

            $invokePluginFromMouseEvent = {
                param($sender, $eventArgs)

                $item = [Windows.Controls.ItemsControl]::ContainerFromElement($sender, $eventArgs.OriginalSource)
                if ($item -is [Windows.Controls.ListBoxItem] -and $window.Tag.PluginClickSource -eq $item) {
                    Invoke-AtomPlugin -Plugin $item.Tag
                }
                $window.Tag.PluginClickSource = $null
                $window.Tag.PluginDragSource = $null
            }
            if ($atomSettings.PluginClicks.Value -eq 2) {
                $listBox.Add_MouseDoubleClick($invokePluginFromMouseEvent)
            } else {
                $listBox.Add_MouseLeftButtonUp($invokePluginFromMouseEvent)
            }

        }

        # Build menus on demand in both modes, rather than for every downloaded row.
        $listBox.Add_MouseRightButtonUp({
                param($sender, $eventArgs)

                $item = [Windows.Controls.ItemsControl]::ContainerFromElement($sender, $eventArgs.OriginalSource)
                if ($item -isnot [Windows.Controls.ListBoxItem]) { return }
                if (!$item.ContextMenu) { $item.ContextMenu = & $item.ContextMenuFactory }
                $item.ContextMenu.IsOpen = $true
                $eventArgs.Handled = $true
            })

        $categoryHeader = $textBlock
        if (!$script:downloadMode) {
            $categoryHeader.Tag = @{ AddPluginCategory = $(if ($SortMode -eq 'Category') { $group.Name } else { 'Uncategorized' }) }
            $categoryHeader.Background = [Windows.Media.Brushes]::Transparent
        }
        $categoryCheckBox = $null

        if ($script:downloadMode) {
            $categoryHeaderParams = @{
                ControlType = 'CheckBox'
                Text = $group.Name
                Tag = $listBox
                ToolTip = "Select all available programs in $($group.Name)"
            }
            $categoryHeader = New-ListBoxControlItem @categoryHeaderParams
            $categoryHeader.Margin = '0,10,0,0'
            $categoryHeader.Text.FontSize = 14
            $categoryHeader.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
            $categoryCheckBox = $categoryHeader.Control
            $categoryCheckBox.Margin = '2.5,0,2.5,0'
            $categoryCheckBox.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)

            $categoryCheckBox.Add_Checked({
                if ($window.Tag.UpdatingDownloadSelection) { return }
                $window.Tag.UpdatingDownloadSelection = $true
                try {
                    $this.Tag.Items | Where-Object { $_.IsEnabled -and $_.Visibility -eq 'Visible' } | ForEach-Object { $_.Control.IsChecked = $true }
                } finally {
                    $window.Tag.UpdatingDownloadSelection = $false
                }
                Update-AtomDownloadSelectionState
            })
            $categoryCheckBox.Add_Unchecked({
                if ($window.Tag.UpdatingDownloadSelection) { return }
                $window.Tag.UpdatingDownloadSelection = $true
                try {
                    $this.Tag.Items | Where-Object { $_.IsEnabled -and $_.Visibility -eq 'Visible' } | ForEach-Object { $_.Control.IsChecked = $false }
                } finally {
                    $window.Tag.UpdatingDownloadSelection = $false
                }
                Update-AtomDownloadSelectionState
            })
        }

        $border = [System.Windows.Controls.Border]::new()
        $border.Style = $window.FindResource('CustomBorder')
        $border.Margin = '0,5,0,0'
        $border.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
        $border.Child = $listBox

        # Configure listbox into plugin wrappanel
        $grid = [System.Windows.Controls.Grid]::new()
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.Margin = '0,0,10,0'
        $grid.Tag = $categoryCheckBox

        if (!$script:downloadMode -and $SortMode -eq 'Category') {
            $grid.AllowDrop = $true
            $grid.DataContext = $group.Name

            $grid.Add_DragOver({
                param($sender, $eventArgs)

                $sourceCategory =
                    if ($eventArgs.Data.GetDataPresent('ATOM.PluginCategory')) { [String]$eventArgs.Data.GetData('ATOM.PluginCategory') }
                    else { $null }

                $eventArgs.Effects =
                    if ($sourceCategory -and $sourceCategory -ne $sender.DataContext) { [Windows.DragDropEffects]::Move }
                    else { [Windows.DragDropEffects]::None }
                $eventArgs.Handled = $true
            })

            $grid.Add_Drop({
                param($sender, $eventArgs)

                if ($eventArgs.Data.GetDataPresent('ATOM.PluginName')) {
                    try {
                        Set-AtomPluginCategory -Name ([String]$eventArgs.Data.GetData('ATOM.PluginName')) -Category ([String]$sender.DataContext)
                    } catch {
                        $statusBarStatus.Text = "Unable to move plugin: $($_.Exception.Message)"
                    }
                }
                $eventArgs.Handled = $true
            })
        }

        $grid.Children.Add($categoryHeader) | Out-Null
        $grid.Children.Add($border) | Out-Null
        $grid.RowDefinitions[0].Height = [System.Windows.GridLength]::Auto
        $pluginWrapPanel.Children.Add($grid) | Out-Null

        foreach ($plugin in $group.Group) {
            $name = $plugin.Name
            $programState = Get-AtomManagedProgramState -Plugin $plugin
            $iconPath = "$resourcesPath\Icons\Program Icons\$name.png"

            if (!$script:pluginIconNames.Contains($name)) {
                $firstLetter = $name.Substring(0,1)
                $iconPath =
                    if ($firstLetter -match '^[A-Z]') { "$resourcesPath\Icons\Default\$firstLetter.png" }
                    else { "$resourcesPath\Icons\Default\#.png" }
            }
            if ($plugin.IconPath -and (Test-Path -LiteralPath $plugin.IconPath -PathType Leaf)) { $iconPath = $plugin.IconPath }
            $plugin.IconPath = $iconPath
            $iconCacheKey = "$([IO.Path]::GetFullPath($iconPath))|32"
            $cachedIcon = $ImageCache[$iconCacheKey]

            $listBoxItemParams = @{
                DeferImageLoad = $true
                Text = $name
                ImageSource = $iconPath
                ToolTip =
                    if ($atomSettings.ShowToolTips.Value -and $plugin.Config.ToolTip) { $plugin.Config.ToolTip }
                    else { $null }
            }

            $trailingContent = @()
            if ($script:downloadMode -and $programState.IsAvailable -and $script:availableProgramUpdates -contains $name) {
                $updateIcon = New-VectorIcon -Window $window -Icon 'UpdateIcon' -ForegroundResource 'controlBrush' -Size 14 -OpticalSize 20
                $updateIcon.Tag = 'UpdateAvailable'
                $updateIcon.Margin = '6,0,2.5,0'
                $trailingContent += $updateIcon
            }
            if (!$script:downloadMode -and $plugin.Config.Favorite) {
                $favoriteIcon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentBrush' -Size 14 -OpticalSize 20 -Filled
                $favoriteIcon.Tag = 'Favorite'
                $favoriteIcon.Margin = '6,0,2.5,0'
                $trailingContent += $favoriteIcon
            }
            if ($plugin.Config.Hidden) {
                $hiddenIcon = New-VectorIcon -Window $window -Icon 'VisibilityOffIcon' -ForegroundResource 'surfaceText' -Size 14 -OpticalSize 20
                $hiddenIcon.Tag = 'Hidden'
                $hiddenIcon.Margin = '6,0,2.5,0'
                $trailingContent += $hiddenIcon
            }
            if ($programState.IsAvailable) {
                $offlineIcon = New-VectorIcon -Window $window -Icon 'OfflineDownloadIcon' -ForegroundResource 'surfaceText' -Size 14 -OpticalSize 20
                $offlineIcon.Tag = 'OfflineDownload'
                $offlineIcon.Margin = '6,0,2.5,0'
                $offlineIcon.ToolTip = 'Available offline'
                $trailingContent += $offlineIcon
            }
            if ($trailingContent.Count) { $listBoxItemParams.TrailingContent = $trailingContent }

            if ($script:downloadMode) {
                $listBoxItemParams.ControlType = 'CheckBox'
                $listBoxItemParams.Tag = $name
            }

            $listBoxItem = New-ListBoxControlItem @listBoxItemParams
            if ($cachedIcon) {
                $listBoxItem.Image.Source = $cachedIcon
            } else {
                $script:pluginImageQueue.Enqueue($listBoxItem)
            }
            $listBoxItem.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $searchMetadata = @($plugin.Config.Aliases)
            if ($atomSettings.SearchPluginTags.Value) { $searchMetadata += @($plugin.Config.Tags) }
            $listBoxItem.DataContext = "$name $($searchMetadata -join ' ')"
            $listBoxItem.Tag = $plugin
            if ($atomSettings.ShowPluginDescriptions.Value -and ![String]::IsNullOrWhiteSpace($plugin.Config.Description)) {
                Add-AtomPluginDescription -Item $listBoxItem -Description $plugin.Config.Description
            }

            $contextMenuFactory = {
            $contextMenu = New-Object System.Windows.Controls.ContextMenu
            $contextMenu.Style = $window.FindResource('CustomContextMenu')
            $contextMenu.Background = $window.FindResource('accentBrush')
            $contextMenu.Add_Opened({
                $this.Background = $window.FindResource('accentBrush')
                foreach ($menuItem in $this.Items) {
                    $menuItem.Foreground = $window.FindResource('accentText')
                }
            }.GetNewClosure())

            $menuHeaderPanel = New-Object Windows.Controls.StackPanel
            $menuHeaderPanel.Orientation = [Windows.Controls.Orientation]::Horizontal

            $menuHeaderImage = New-Object Windows.Controls.Image
            $menuHeaderImage.Source = Get-CachedImage -Path $iconPath
            $menuHeaderImage.Width = 20
            $menuHeaderImage.Height = 20
            $menuHeaderImage.Margin = '0,0,8,0'
            $menuHeaderPanel.Children.Add($menuHeaderImage) | Out-Null

            $menuHeaderText = New-Object Windows.Controls.TextBlock
            $menuHeaderText.Text = $plugin.Name
            $menuHeaderText.FontWeight = [Windows.FontWeights]::SemiBold
            $menuHeaderText.VerticalAlignment = [Windows.VerticalAlignment]::Center
            $menuHeaderPanel.Children.Add($menuHeaderText) | Out-Null

            $menuHeaderItem = New-Object Windows.Controls.MenuItem
            $menuHeaderItem.Header = $menuHeaderPanel
            $menuHeaderItem.Style = $window.FindResource('CustomContextMenuHeader')
            $contextMenu.Items.Add($menuHeaderItem) | Out-Null

            $menuSeparator = New-Object Windows.Controls.Separator
            $menuSeparator.Style = $window.FindResource('CustomContextMenuSeparator')
            $contextMenu.Items.Add($menuSeparator) | Out-Null
            $favoriteMenuItem = New-Object Windows.Controls.MenuItem
            $favoriteMenuItem.Header = if ($plugin.Config.Favorite) { 'Unfavorite' } else { 'Favorite' }
            $favoriteMenuItem.Tag = @{
                Name = $plugin.Name
                Favorite = !$plugin.Config.Favorite
            }
            $favoriteMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $favoriteMenuItem.InputGestureText = 'Space'
            $favoriteMenuItem.Icon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20 -Filled:$plugin.Config.Favorite
            $favoriteMenuItem.Add_Click({
                Set-AtomPluginFavorite -Name $this.Tag.Name -Favorite $this.Tag.Favorite
            })
            $contextMenu.Items.Add($favoriteMenuItem) | Out-Null

            $visibilityMenuItem = New-Object Windows.Controls.MenuItem
            $visibilityMenuItem.Header = if ($plugin.Config.Hidden) { 'Unhide' } else { 'Hide' }
            $visibilityMenuItem.Tag = @{
                Name = $plugin.Name
                Hidden = !$plugin.Config.Hidden
            }
            $visibilityMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $visibilityIcon = if ($plugin.Config.Hidden) { 'VisibilityIcon' } else { 'VisibilityOffIcon' }
            $visibilityMenuItem.Icon = New-VectorIcon -Window $window -Icon $visibilityIcon -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
            $visibilityMenuItem.Add_Click({
                Set-AtomPluginVisibility -Name $this.Tag.Name -Hidden $this.Tag.Hidden
            })
            $contextMenu.Items.Add($visibilityMenuItem) | Out-Null

            $actionMenuItems = @($favoriteMenuItem, $visibilityMenuItem)
            $hasPluginFile = $plugin.FullName -and (Test-Path -LiteralPath $plugin.FullName -PathType Leaf)
            if ($hasPluginFile -or $programState.IsAvailable) {
                $utilitySeparator = New-Object Windows.Controls.Separator
                $utilitySeparator.Style = $window.FindResource('CustomContextMenuSeparator')
                $contextMenu.Items.Add($utilitySeparator) | Out-Null
            }

            if ($hasPluginFile) {
                $fileLocationMenuItem = New-Object Windows.Controls.MenuItem
                $fileLocationMenuItem.Header = 'Open File Location'
                $fileLocationMenuItem.Tag = $plugin
                $fileLocationMenuItem.Style = $window.FindResource('CustomContextMenuItem')
                $fileLocationMenuItem.Icon = New-VectorIcon -Window $window -Icon 'FolderOpenIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
                $fileLocationMenuItem.Add_Click({ Open-AtomPluginFileLocation -Plugin $this.Tag })
                $contextMenu.Items.Add($fileLocationMenuItem) | Out-Null
                $actionMenuItems += $fileLocationMenuItem

                if ([IO.Path]::GetExtension($plugin.FullName) -in '.ps1', '.bat', '.cmd') {
                    $editMenuItem = New-Object Windows.Controls.MenuItem
                    $editMenuItem.Header = 'Open in Editor'
                    $editMenuItem.Tag = $plugin
                    $editMenuItem.Style = $window.FindResource('CustomContextMenuItem')
                    $editMenuItem.Icon = New-VectorIcon -Window $window -Icon 'OpenInBrowserIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
                    $editMenuItem.Add_Click({ Open-AtomPluginInEditor -Plugin $this.Tag })
                    $contextMenu.Items.Add($editMenuItem) | Out-Null
                    $actionMenuItems += $editMenuItem
                }
            }

            if ($programState.IsAvailable) {
                $removeDownloadMenuItem = New-Object Windows.Controls.MenuItem
                $removeDownloadMenuItem.Header = 'Remove Offline Download'
                $removeDownloadMenuItem.Tag = $plugin
                $removeDownloadMenuItem.Style = $window.FindResource('CustomContextMenuItem')
                $removeDownloadMenuItem.Icon = New-VectorIcon -Window $window -Icon 'DeleteIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
                $removeDownloadMenuItem.Add_Click({ Remove-AtomOfflineDownload -Plugin $this.Tag })
                $contextMenu.Items.Add($removeDownloadMenuItem) | Out-Null
                $actionMenuItems += $removeDownloadMenuItem
            }

            $propertiesMenuItem = New-Object Windows.Controls.MenuItem
            if ($plugin.UserPluginId) {
                $deletePluginItem = [Windows.Controls.MenuItem]::new()
                $deletePluginItem.Header = 'Delete plugin'
                $deletePluginItem.Tag = $plugin
                $deletePluginItem.Style = $window.FindResource('CustomContextMenuItem')
                $deletePluginItem.Add_Click({ Confirm-AtomUserPluginDeletion -Plugin $this.Tag })
                [void]$contextMenu.Items.Add($deletePluginItem)
                $actionMenuItems += $deletePluginItem
            }
            $propertiesMenuItem.Header = 'Properties'
            $propertiesMenuItem.Tag = $plugin
            $propertiesMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $propertiesMenuItem.InputGestureText = 'Alt+Enter'
            $propertiesMenuItem.Icon = New-VectorIcon -Window $window -Icon 'HelpIcon' -ForegroundResource 'accentText' -Size 14 -OpticalSize 20
            $propertiesMenuItem.Add_Click({ Show-AtomPluginProperties -Plugin $this.Tag })
            $contextMenu.Items.Add($propertiesMenuItem) | Out-Null
            $actionMenuItems += $propertiesMenuItem

            foreach ($actionMenuItem in $actionMenuItems) {
                $actionMenuItem.Add_MouseEnter({
                    $this.Background = $window.FindResource('accentHighlight')
                }.GetNewClosure())
                $actionMenuItem.Add_MouseLeave({
                    $this.Background = [Windows.Media.Brushes]::Transparent
                })
            }
            $contextMenu
            }.GetNewClosure()
            $listBoxItem.PSObject.Properties.Add([Management.Automation.PSNoteProperty]::new('ContextMenuFactory', $contextMenuFactory))
            [System.Windows.Controls.ContextMenuService]::SetShowOnDisabled($listBoxItem, $true)

            if ($script:downloadMode) {
                # Match the checkbox template's 20px artwork to the launch row's 16px icon height.
                $listBoxItem.Control.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)
                $listBoxItem.Control.IsChecked = $selectedPrograms -contains $name
                $listBoxItem.Control.Add_Checked({ Set-AtomDownloadDependencySelection -Name $this.Tag -Selected $true })
                $listBoxItem.Control.Add_Unchecked({ Set-AtomDownloadDependencySelection -Name $this.Tag -Selected $false })

                Add-AtomDownloadDetails -Item $listBoxItem -ProgramState $programState
                $listBox.Items.Add($listBoxItem) | Out-Null
                continue
            }

            $listBoxItem.Tag = $plugin

            $listBox.Items.Add($listBoxItem) | Out-Null
        }
    }

    if ($script:pluginImageQueue.Count) {
        $imageItems = $script:pluginImageQueue.ToArray()
        $script:pluginImageQueue.Clear()
        $script:decodedPluginImages = [Collections.Concurrent.BlockingCollection[Object]]::new()

        Invoke-Runspace -Isolated -InputVariables @{
            ImageItems = $imageItems
            DecodedImages = $script:decodedPluginImages
            ImageCache = $ImageCache
        } -ScriptBlock {
            Add-Type -AssemblyName PresentationFramework
            try {
                foreach ($item in $ImageItems) {
                    $bitmap = $null
                    $errorMessage = $null
                    try {
                        $resolvedPath = [IO.Path]::GetFullPath($item.DeferredImageSource)
                        $cacheKey = "$resolvedPath|32"
                        $bitmap = $ImageCache[$cacheKey]
                        if (!$bitmap) {
                            $stream = [IO.MemoryStream]::new([IO.File]::ReadAllBytes($resolvedPath), $false)
                            try {
                                $bitmap = [Windows.Media.Imaging.BitmapImage]::new()
                                $bitmap.BeginInit()
                                $bitmap.CacheOption = [Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                                $bitmap.DecodePixelWidth = 32
                                $bitmap.StreamSource = $stream
                                $bitmap.EndInit()
                                $bitmap.Freeze()
                            } finally {
                                $stream.Dispose()
                            }
                            $ImageCache[$cacheKey] = $bitmap
                        }
                    } catch {
                        $errorMessage = $_.Exception.Message
                    }
                    $DecodedImages.Add([PSCustomObject]@{
                        Item = $item
                        Source = $bitmap
                        Error = $errorMessage
                    })
                }
            } finally {
                $DecodedImages.CompleteAdding()
            }
        }
        $pluginImageTimer.Start()
    }
    if ($script:downloadMode) { Update-AtomDownloadSelectionState; Update-AtomCatalogFilter }
}
