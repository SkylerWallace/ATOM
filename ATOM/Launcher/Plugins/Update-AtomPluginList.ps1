function Update-AtomPluginList {
    param (
        [ValidateSet('Category', 'Alphabetical')]
        [String]$SortMode = $(
            if ($script:atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' }
            else { 'Category' }
        ),
        [Switch]$Reload,
        [Switch]$KeepOtherView
    )

    $restartDownloads = !$script:downloadMode -and $script:downloadCatalogBuild
    if ($script:downloadCatalogBuild) { Stop-AtomDownloadCatalogBuild }
    if (!$KeepOtherView) {
        $otherView = if ($script:downloadMode) { $script:catalogViews.Plugins } else { $script:catalogViews.Downloads }
        $otherView.NeedsRefresh = $true
        if (!$script:catalogView.NeedsRefresh) {
            $script:catalogView.ScrollOffset = $script:catalogView.ScrollViewer.VerticalOffset
        }
    }
    $script:catalogView.NeedsRefresh = $true

    Initialize-AtomPluginList -SortMode $SortMode -Reload:$Reload -DownloadMode $script:downloadMode
    if ($restartDownloads) { Start-AtomDownloadCatalogBuild }
}

function Start-AtomDownloadCatalogBuild {
    if ($script:downloadCatalogBuild -or !$script:catalogViews.Downloads.NeedsRefresh) { return }

    # Give WPF a render and input turn before building the first batch.
    $sortMode = if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'Alphabetical' } else { 'Category' }
    $script:downloadCatalogBuild = @{ SortMode = $sortMode }
    Update-AtomDownloadCatalogLoading
    $script:downloadCatalogBuild.Operation = $window.Dispatcher.BeginInvoke([Action]{
        try {
            $build = $script:downloadCatalogBuild
            Initialize-AtomPluginList -SortMode $build.SortMode -DownloadMode $true -Deferred
        } catch {
            Set-AtomDownloadCatalogBuildError -Message $_.Exception.Message
        }
    }, [Windows.Threading.DispatcherPriority]::Background)
}

function Initialize-AtomPluginList {
    param ([String]$SortMode, [Boolean]$DownloadMode, [Switch]$Reload, [Switch]$Deferred)

    $catalogView = if ($DownloadMode) { $script:catalogViews.Downloads } else { $script:catalogViews.Plugins }
    $catalogPanel = $catalogView.Panel
    if ($DownloadMode -and !$script:downloadFilter) {
        $downloadFilterItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions ([ordered]@{ 'All' = 'All'; 'Downloaded' = 'Downloaded'; 'Not downloaded' = 'Not downloaded'; 'Updates available' = 'Updates available'; 'Failed' = 'Failed' }) -SelectedValue 'All' -ControlStyle $window.FindResource('CustomComboBox') -ControlWidth 172 -Text 'Show'
        $downloadFilterItem.Margin = '0'
        $downloadFilterItem.BorderThickness = 0
        $downloadFilterItem.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
        $downloadFilter = $downloadFilterItem.Control
        [Windows.Automation.AutomationProperties]::SetName($downloadFilter, 'Download status filter')
        $window.FindName('downloadFilterHost').Child = $downloadFilterItem
        $downloadFilter.Add_SelectionChanged({ Update-AtomCatalogFilter })
        $script:downloadFilter = $downloadFilter
    }

    if ($DownloadMode -eq $script:downloadMode) {
        Update-AtomVisibilityButton
        $descriptionButton.ToolTip = if ($atomSettings.ShowPluginDescriptions.Value) { 'Hide descriptions' } else { 'Show descriptions' }
        [Windows.Automation.AutomationProperties]::SetName($descriptionButton, $descriptionButton.ToolTip)
        $descriptionIcon = if ($atomSettings.ShowPluginDescriptions.Value) { 'SubtitlesIcon' } else { 'SubtitlesOffIcon' }
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ descriptionButton = $descriptionIcon } -Filled:([bool]$atomSettings.ShowPluginDescriptions.Value)
    }

    $selectedPrograms = @()
    if ($DownloadMode) {
        if ($null -eq $catalogView.PendingSelection) {
            $catalogView.PendingSelection = @(Get-AtomDownloadItem | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        }
        $selectedPrograms = $catalogView.PendingSelection
        $script:downloadRows = @{}
        $script:downloadRecords = @{}
        try {
            $manifest = Get-DownloadManifest
            foreach ($property in $manifest.Programs.PSObject.Properties) { $script:downloadRecords[$property.Name] = $property.Value }
        } catch { $downloadStorageText.Text = $_.Exception.Message }
    }
    $catalogPanel.Children.Clear()

    # Read the catalog on first use and reload it when explicitly invalidated.
    if ($Reload -or !$script:pluginFiles) {
        if (Move-AtomLegacyUserPlugins -RootPath $atomPath) { $Reload = $true }
    }
    if ($Reload -or $null -eq $script:programs) {
        . $atomPath\Config\Plugins.ps1
        $script:programs = $programs
        $script:programDefaults = $programDefaults
    }
    if ($Reload -or !$script:pluginFiles) {
        $script:pluginFiles = @(Get-ChildItem -LiteralPath $pluginsPath -File | Where-Object Extension -in '.ps1', '.bat', '.cmd', '.exe', '.lnk')
        $nativeNames = @(Get-AtomNativePluginName -RootPath $atomPath -CatalogNames @($script:programDefaults.Keys))
        $script:userPluginRecords = @(Get-AtomUserPlugin -RootPath $atomPath -NativeNames $nativeNames)
    }

    if ($Reload -or !$script:pluginIconNames) {
        $script:pluginIconNames = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($iconName in (Get-AtomProgramIcons -Directory "$resourcesPath\Icons\Program Icons" -NamesOnly)) {
            [void]$script:pluginIconNames.Add([IO.Path]::GetFileNameWithoutExtension($iconName))
        }
    }

    $pluginSources = @($script:pluginFiles)
    $userPluginByPath = @{}
    foreach ($userPlugin in $script:userPluginRecords) {
        $programs[$userPlugin.Name] = $userPlugin.Metadata
        $userPluginByPath[$userPlugin.FullName] = $userPlugin
    }
    if ($DownloadMode) {
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
        if ($DownloadMode -and (!$programInfo -or (!$atomSettings.ShowHiddenPlugins.Value -and $pluginConfig.Hidden))) { return }
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

        if (!$DownloadMode -and $pluginConfig.DownloadOnly) {
            return
        } elseif ($DownloadMode) {
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

        $userRecord = if ($fullName) { $userPluginByPath[$fullName] } else { $null }
        $explicitIconPath = $userRecord.IconPath
        if (!$explicitIconPath -and $pluginConfig.IconPath) {
            $explicitIconPath = if ([IO.Path]::IsPathRooted($pluginConfig.IconPath)) { $pluginConfig.IconPath } else { Join-Path $atomPath $pluginConfig.IconPath }
        }
        [PSCustomObject]@{
            Name         = $name
            FullName     = $fullName
            UserPluginId = $userRecord.Id
            IsUserOwned = [Boolean]$userRecord.IsUserOwned
            IconPath     = $explicitIconPath
            Config       = $pluginConfig
            ProgramInfo  = $programInfo
            IsScript = !$programInfo -and $_.Extension -in '.ps1', '.bat', '.cmd'
            Category     = $category
            GroupCategory =
                if ($SortMode -eq 'Alphabetical') { 'All Plugins' }
                else { $category }
			LaunchParams = switch ($_.Extension) {
				'.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$fullName`"" } }
				'.exe' { @{ FilePath = $fullName } }
				'.lnk' { @{ FilePath = $fullName } }
				'.ps1' { @{ FilePath = 'powershell'; ArgumentList = ("-NoProfile -ExecutionPolicy Bypass -File `"$fullName`" " + $pluginConfig.ArgumentList).TrimEnd() } }
			}
        }
    } | Sort-Object GroupCategory, Name

    # Group plugins for UI
    $catalogPanel.Orientation = if ($atomSettings.StackPluginCategories.Value) { 'Vertical' } else { 'Horizontal' }
    $catalogPanel.HorizontalAlignment = 'Center'

    $pluginGroups = @($plugins | Group-Object GroupCategory)

    $addCategory = {
        param ($group, $SortMode, $catalogPanel, [Boolean]$DownloadMode)

        # Create listbox for each plugin category
        $textBlock = [System.Windows.Controls.TextBlock]::new()
        $textBlock.Text = $group.Name
        $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
        $textBlock.FontSize = 14
        $textBlock.Margin = '0,8,0,0'
        $textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

        $listBox = [System.Windows.Controls.ListBox]::new()
        $listBox.Background = 'Transparent'
        $listBox.SetResourceReference([System.Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $listBox.BorderThickness = 0
        $listBox.Margin = 4
        $listBox.Padding = 0
        if ($atomSettings.StackPluginCategories.Value) {
            $listBox.ItemsPanel = [Windows.Markup.XamlReader]::Parse('<ItemsPanelTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"><WrapPanel ItemWidth="236" Margin="0,0,-18,0"/></ItemsPanelTemplate>')
        } else {
            $listBox.Width = 220
        }
        $listBox.SetValue([Windows.Controls.ScrollViewer]::VerticalScrollBarVisibilityProperty, [Windows.Controls.ScrollBarVisibility]::Disabled)
        $listBox.SetValue([System.Windows.Controls.ScrollViewer]::HorizontalScrollBarVisibilityProperty, [System.Windows.Controls.ScrollBarVisibility]::Disabled)

        if (!$DownloadMode) {
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
                    !$atomSettings.PluginDragAndDrop.Value -or
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
                $window.Tag.PluginDragTargetLabel = $null
                Add-Type -AssemblyName System.Windows.Forms
                if (!('AtomPluginDragWindow' -as [type])) {
                    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class AtomPluginDragWindow {
    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr window, IntPtr after, int x, int y, int width, int height, uint flags);
}
"@
                }
                $panel = [Windows.Controls.StackPanel]::new()
                $panel.Orientation = 'Horizontal'
                $panel.LayoutTransform = $window.FindResource('uiScaleTransform').CloneCurrentValue()
                $image = [Windows.Controls.Image]::new()
                $image.Width = 32
                $image.Height = 32
                $image.Opacity = 0.8
                $image.Source = if ($source.Image.Source) { $source.Image.Source } else { Get-CachedImage -Path $source.Tag.IconPath }
                $label = [Windows.Controls.TextBlock]::new()
                $label.Foreground = $window.FindResource('surfaceText')
                $background = [Windows.Controls.Border]::new()
                $background.Background = $window.FindResource('surfaceBrush')
                $background.CornerRadius = 5
                $background.Padding = '8,4'
                $background.Margin = '8,0,0,0'
                $background.VerticalAlignment = 'Center'
                $background.Visibility = 'Collapsed'
                $background.Child = $label
                [void]$panel.Children.Add($image)
                [void]$panel.Children.Add($background)
                $parameters = [Windows.Interop.HwndSourceParameters]::new('ATOM plugin drag preview')
                $parameters.WindowStyle = -2147483648 # WS_POPUP
                $parameters.ExtendedWindowStyle = 0x080000A0 # No activation, tool window, click-through
                $parameters.UsesPerPixelOpacity = $true
                $parameters.Width = 1
                $parameters.Height = 1
                $previewWindow = [Windows.Interop.HwndSource]::new($parameters)
                $previewWindow.RootVisual = $panel
                $previewSize = @{ Width = 0; Height = 0 }
                $refreshClock = [Diagnostics.Stopwatch]::StartNew()
                $feedback = [Windows.GiveFeedbackEventHandler]{
                    param($dragSender, $dragEvent)
                    $dragEvent.UseDefaultCursors = $false
                    $targetChanged = $label.Text -ne [string]$window.Tag.PluginDragTargetLabel
                    if (!$targetChanged -and $refreshClock.ElapsedMilliseconds -lt 16) { return }
                    $refreshClock.Restart()
                    if ($targetChanged) {
                        $label.Text = $window.Tag.PluginDragTargetLabel
                        $background.Visibility = if ($label.Text) { 'Visible' } else { 'Collapsed' }
                    }
                    [Windows.Input.Mouse]::SetCursor([Windows.Input.Cursors]::Arrow) | Out-Null
                    $cursor = [Windows.Forms.Cursor]::Position
                    if ($targetChanged -or !$previewSize.Width) {
                        $panel.Measure([Windows.Size]::new([double]::PositiveInfinity, [double]::PositiveInfinity))
                        $size = $previewWindow.CompositionTarget.TransformToDevice.Transform([Windows.Vector]::new($panel.DesiredSize.Width, $panel.DesiredSize.Height))
                        $previewSize.Width = [int][Math]::Ceiling($size.X)
                        $previewSize.Height = [int][Math]::Ceiling($size.Y)
                    }
                    [void][AtomPluginDragWindow]::SetWindowPos($previewWindow.Handle, [IntPtr]::new(-1), $cursor.X + 12, $cursor.Y + 12, $previewSize.Width, $previewSize.Height, 0x50)
                }.GetNewClosure()
                $source.Add_GiveFeedback($feedback)
                try {
                    [void][Windows.DragDrop]::DoDragDrop($source, $data, [Windows.DragDropEffects]::Move)
                } finally {
                    $previewWindow.Dispose()
                    $source.Remove_GiveFeedback($feedback)
                    [Windows.Input.Mouse]::SetCursor($null) | Out-Null
                    $window.Tag.PluginDragTargetLabel = $null
                }
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
        if (!$DownloadMode) {
            $categoryHeader.Tag = @{ AddPluginCategory = $(if ($SortMode -eq 'Category') { $group.Name } else { 'Uncategorized' }) }
            $categoryHeader.Background = [Windows.Media.Brushes]::Transparent
        }
        $categoryCheckBox = $null

        if ($DownloadMode) {
            $categoryHeaderParams = @{
                ControlType = 'CheckBox'
                Text = $group.Name
                Tag = $listBox
                ToolTip = "Select all available programs in $($group.Name)"
            }
            $categoryHeader = New-ListBoxControlItem @categoryHeaderParams
            $categoryHeader.Margin = '0,4,0,0'
            $categoryHeader.Text.FontSize = 14
            $categoryHeader.Text.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, 'backgroundText')
            $categoryCheckBox = $categoryHeader.Control
            $categoryCheckBox.Margin = '2,0'
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
        $border.Margin = '0,4,0,0'
        $border.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
        $border.Child = $listBox

        # Configure listbox into plugin wrappanel
        $grid = [System.Windows.Controls.Grid]::new()
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.RowDefinitions.Add([System.Windows.Controls.RowDefinition]::new())
        $grid.Margin = '0,0,8,0'
        $grid.Tag = $categoryCheckBox

        if (!$DownloadMode -and $SortMode -eq 'Category') {
            $grid.AllowDrop = $true
            $grid.Background = [Windows.Media.Brushes]::Transparent
            $grid.DataContext = $group.Name

            $grid.Add_DragOver({
                param($sender, $eventArgs)

                $sourceCategory =
                    if ($eventArgs.Data.GetDataPresent('ATOM.PluginCategory')) { [String]$eventArgs.Data.GetData('ATOM.PluginCategory') }
                    else { $null }

                $eventArgs.Effects =
                    if ($atomSettings.PluginDragAndDrop.Value -and $sourceCategory -and $eventArgs.Data.GetDataPresent('ATOM.PluginName')) { [Windows.DragDropEffects]::Move }
                    else { [Windows.DragDropEffects]::None }
                $window.Tag.PluginDragTargetLabel =
                    if ($eventArgs.Effects -eq [Windows.DragDropEffects]::Move -and $sourceCategory -ne $sender.DataContext) { "Move to $($sender.DataContext)" }
                    else { $null }
                $eventArgs.Handled = $true
            })

            $grid.Add_DragLeave({
                param($sender, $eventArgs)

                $point = $eventArgs.GetPosition($sender)
                if ($point.X -lt 0 -or $point.Y -lt 0 -or $point.X -gt $sender.ActualWidth -or $point.Y -gt $sender.ActualHeight) {
                    $window.Tag.PluginDragTargetLabel = $null
                }
            })

            $grid.Add_Drop({
                param($sender, $eventArgs)

                $window.Tag.PluginDragTargetLabel = $null
                if (!$atomSettings.PluginDragAndDrop.Value) { $eventArgs.Handled = $true; return }
                if ($eventArgs.Data.GetDataPresent('ATOM.PluginName') -and [String]$eventArgs.Data.GetData('ATOM.PluginCategory') -ne $sender.DataContext) {
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
        $catalogPanel.Children.Add($grid) | Out-Null

        $listBox
    }

    $addRow = {
        param ($plugin, $listBox, $selectedPrograms, [Boolean]$DownloadMode)

        $name = $plugin.Name
        $programState = Get-AtomManagedProgramState -Plugin $plugin
        $plugin | Add-Member -NotePropertyName IsOfflineAvailable -NotePropertyValue (!$plugin.ProgramInfo -or $programState.IsAvailable)
        $iconName = if ($plugin.Config.Icon) { $plugin.Config.Icon } else { $name }
        $iconPath = "$resourcesPath\Icons\Program Icons\$iconName.png"

        if (!$script:pluginIconNames.Contains($iconName)) {
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
        if (!$DownloadMode -and !$script:atomIsAdministrator -and $plugin.Config.RequiresAdmin -ne $false) {
            $adminIcon = New-VectorIcon -Window $window -Icon 'LockIcon' -ForegroundResource 'warningText' -Size 16 -OpticalSize 20
            $adminIcon.Tag = 'RequiresAdmin'
            $adminIcon.Margin = '1,0'
            $adminIcon.ToolTip = 'Requests administrator approval when launched'
            $trailingContent += $adminIcon
        }
        if ($DownloadMode -and $programState.IsAvailable -and $script:availableProgramUpdates -contains $name) {
            $updateIcon = New-VectorIcon -Window $window -Icon 'UpdateIcon' -ForegroundResource 'warningText' -Size 16 -OpticalSize 20
            $updateIcon.Tag = 'UpdateAvailable'
            $updateIcon.Margin = '1,0'
            $trailingContent += $updateIcon
        }
        if (!$DownloadMode -and $plugin.Config.Favorite) {
            $favoriteIcon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'infoText' -Size 16 -OpticalSize 20 -Filled
            $favoriteIcon.Tag = 'Favorite'
            $favoriteIcon.Margin = '1,0'
            $trailingContent += $favoriteIcon
        }
        if ($plugin.Config.Hidden) {
            $hiddenIcon = New-VectorIcon -Window $window -Icon 'VisibilityOffIcon' -ForegroundResource 'surfaceText' -Size 16 -OpticalSize 20
            $hiddenIcon.Tag = 'Hidden'
            $hiddenIcon.Margin = '1,0'
            $trailingContent += $hiddenIcon
        }
        if ($programState.IsAvailable) {
            $offlineIcon = New-VectorIcon -Window $window -Icon 'OfflineDownloadIcon' -ForegroundResource 'surfaceText' -Size 16 -OpticalSize 20
            $offlineIcon.Tag = 'OfflineDownload'
            $offlineIcon.Margin = '1,0'
            $offlineIcon.ToolTip = 'Available offline'
            $trailingContent += $offlineIcon
        }
        if ($trailingContent.Count) { $listBoxItemParams.TrailingContent = $trailingContent }

        if ($DownloadMode) {
            $listBoxItemParams.ControlType = 'CheckBox'
            $listBoxItemParams.Tag = $name
        }

        $listBoxItem = New-ListBoxControlItem @listBoxItemParams
        if ($atomSettings.StackPluginCategories.Value) { $listBoxItem.Width = 220; $listBoxItem.HorizontalAlignment = 'Left' }
        $listBoxItem.Content.MinHeight = 20
        $listBoxItem.Margin = [Windows.Thickness]::new(0, [double]$atomSettings.PluginRowSpacing.Value, 0, [double]$atomSettings.PluginRowSpacing.Value)
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
        $favoriteMenuItem.Icon = New-VectorIcon -Window $window -Icon 'StarIcon' -ForegroundResource 'accentText' -Size 16 -OpticalSize 20 -Filled:$plugin.Config.Favorite
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
        $visibilityMenuItem.Icon = New-VectorIcon -Window $window -Icon $visibilityIcon -ForegroundResource 'accentText' -Size 16 -OpticalSize 20
        $visibilityMenuItem.Add_Click({
            Set-AtomPluginVisibility -Name $this.Tag.Name -Hidden $this.Tag.Hidden
        })
        $contextMenu.Items.Add($visibilityMenuItem) | Out-Null
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
            $fileLocationMenuItem.Icon = New-VectorIcon -Window $window -Icon 'FolderOpenIcon' -ForegroundResource 'accentText' -Size 16 -OpticalSize 20
            $fileLocationMenuItem.Add_Click({ Open-AtomPluginFileLocation -Plugin $this.Tag })
            $contextMenu.Items.Add($fileLocationMenuItem) | Out-Null

            if ([IO.Path]::GetExtension($plugin.FullName) -in '.ps1', '.bat', '.cmd') {
                $editMenuItem = New-Object Windows.Controls.MenuItem
                $editMenuItem.Header = 'Open in Editor'
                $editMenuItem.Tag = $plugin
                $editMenuItem.Style = $window.FindResource('CustomContextMenuItem')
                $editMenuItem.Icon = New-VectorIcon -Window $window -Icon 'OpenInBrowserIcon' -ForegroundResource 'accentText' -Size 16 -OpticalSize 20
                $editMenuItem.Add_Click({ Open-AtomPluginInEditor -Plugin $this.Tag })
                $contextMenu.Items.Add($editMenuItem) | Out-Null
            }
        }

        if ($programState.IsAvailable) {
            $removeDownloadMenuItem = New-Object Windows.Controls.MenuItem
            $removeDownloadMenuItem.Header = 'Remove Offline Download'
            $removeDownloadMenuItem.Tag = $plugin
            $removeDownloadMenuItem.Style = $window.FindResource('CustomContextMenuItem')
            $removeDownloadMenuItem.Icon = New-VectorIcon -Window $window -Icon 'DeleteIcon' -ForegroundResource 'accentText' -Size 16 -OpticalSize 20
            $removeDownloadMenuItem.Add_Click({ Remove-AtomOfflineDownload -Plugin $this.Tag })
            $contextMenu.Items.Add($removeDownloadMenuItem) | Out-Null
        }

        $propertiesMenuItem = New-Object Windows.Controls.MenuItem
        if ($plugin.IsUserOwned) {
            $deletePluginItem = [Windows.Controls.MenuItem]::new()
            $deletePluginItem.Header = 'Delete plugin'
            $deletePluginItem.Tag = $plugin
            $deletePluginItem.Style = $window.FindResource('CustomContextMenuItem')
            $deletePluginItem.Icon = New-VectorIcon -Window $window -Icon 'DeleteIcon' -ForegroundResource 'accentText' -Size 16 -OpticalSize 20
            $deletePluginItem.Add_Click({ Confirm-AtomUserPluginDeletion -Plugin $this.Tag })
            [void]$contextMenu.Items.Add($deletePluginItem)
        }
        $propertiesMenuItem.Header = 'Properties'
        $propertiesMenuItem.Tag = $plugin
        $propertiesMenuItem.Style = $window.FindResource('CustomContextMenuItem')
        $propertiesMenuItem.InputGestureText = 'Alt+Enter'
        $propertiesMenuItem.Icon = New-VectorIcon -Window $window -Icon 'HelpIcon' -ForegroundResource 'accentText' -Size 16 -OpticalSize 20
        $propertiesMenuItem.Add_Click({ Show-AtomPluginProperties -Plugin $this.Tag })
        $contextMenu.Items.Add($propertiesMenuItem) | Out-Null

        $contextMenu
        }.GetNewClosure()
        $listBoxItem.PSObject.Properties.Add([Management.Automation.PSNoteProperty]::new('ContextMenuFactory', $contextMenuFactory))
        [System.Windows.Controls.ContextMenuService]::SetShowOnDisabled($listBoxItem, $true)

        if ($DownloadMode) {
            # Match the checkbox template's 20px artwork to the launch row's 16px icon height.
            $listBoxItem.Control.LayoutTransform = [System.Windows.Media.ScaleTransform]::new(0.8, 0.8)
            $listBoxItem.Control.IsChecked = $selectedPrograms -contains $name
            $listBoxItem.Control.Add_Checked({ Set-AtomDownloadDependencySelection -Name $this.Tag -Selected $true })
            $listBoxItem.Control.Add_Unchecked({ Set-AtomDownloadDependencySelection -Name $this.Tag -Selected $false })

            Add-AtomDownloadDetails -Item $listBoxItem -ProgramState $programState
            $listBox.Items.Add($listBoxItem) | Out-Null
            return
        }

        $listBoxItem.Tag = $plugin

        $listBox.Items.Add($listBoxItem) | Out-Null
    }

    if ($Deferred) {
        $build = $script:downloadCatalogBuild
        $build.Groups = $pluginGroups
        $build.GroupIndex = 0
        $build.RowIndex = 0
        $build.AddCategory = $addCategory
        $build.AddRow = $addRow
        $build.SelectedPrograms = $selectedPrograms
        Queue-AtomDownloadCatalogBatch
        return
    }

    foreach ($group in $pluginGroups) {
        $listBox = & $addCategory $group $SortMode $catalogPanel $DownloadMode
        foreach ($plugin in $group.Group) {
            & $addRow $plugin $listBox $selectedPrograms $DownloadMode
        }
    }
    Complete-AtomPluginList -DownloadMode $DownloadMode
}

function Complete-AtomPluginList {
    param ([Boolean]$DownloadMode)

    Start-AtomPluginImageLoad
    $catalogView = if ($DownloadMode) { $script:catalogViews.Downloads } else { $script:catalogViews.Plugins }
    if ($DownloadMode) { $catalogView.PendingSelection = $null }
    $catalogView.NeedsRefresh = $false

    if ($DownloadMode -ne $script:downloadMode) { return }
    if ($DownloadMode) { Update-AtomDownloadSelectionState }
    else { Update-AtomCatalogFilter }
    if ($catalogView.ScrollOffset -gt 0) {
        $catalogView.ScrollViewer.ScrollToVerticalOffset($catalogView.ScrollOffset)
    }
}

function Start-AtomPluginImageLoad {
    if ($script:pluginImageQueue.Count -and !$pluginImageTimer.IsEnabled) {
        # Share one decoder across both lists so switching views cannot strand icons.
        $window.Dispatcher.BeginInvoke([Action]{
            if (!$script:pluginImageQueue.Count -or $pluginImageTimer.IsEnabled) { return }
            $imageItems = $script:pluginImageQueue.ToArray()
            $script:pluginImageQueue.Clear()
            $script:decodedPluginImages = [Collections.Concurrent.BlockingCollection[Object]]::new()

            Invoke-Runspace -Isolated -InputVariables @{
                ImageItems = $imageItems
                DecodedImages = $script:decodedPluginImages
                ImageCache = $ImageCache
                ImageFunctionsPath = "$functionsPath/WPF"
            } -ScriptBlock {
                Add-Type -AssemblyName PresentationFramework
                . "$ImageFunctionsPath/Get-AtomProgramIcons.ps1"
                . "$ImageFunctionsPath/Get-CachedImage.ps1"
                try {
                    foreach ($item in $ImageItems) {
                        $bitmap = $null
                        $errorMessage = $null
                        try {
                            $bitmap = Get-CachedImage -Path $item.DeferredImageSource
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
        }, [Windows.Threading.DispatcherPriority]::ApplicationIdle) | Out-Null
    }
}

function Update-AtomDownloadCatalogLoading {
    $loading = $null -ne $script:downloadCatalogBuild
    $window.FindName('downloadsLoadingText').Visibility = if ($loading) { 'Visible' } else { 'Collapsed' }
    $script:catalogViews.Downloads.Panel.Visibility = if ($loading) { 'Collapsed' } else { 'Visible' }

    $catalogEnabled = !$script:downloadMode -or !$loading
    $window.FindName('catalogToolbar').IsEnabled = $catalogEnabled
    $window.FindName('statusActions').IsEnabled = $catalogEnabled
}

function Stop-AtomDownloadCatalogBuild {
    $operation = $script:downloadCatalogBuild.Operation
    $script:downloadCatalogBuild = $null
    if ($operation.Status -eq [Windows.Threading.DispatcherOperationStatus]::Pending) {
        [void]$operation.Abort()
    }
    Update-AtomDownloadCatalogLoading
}

function Set-AtomDownloadCatalogBuildError {
    param ([String]$Message)

    Stop-AtomDownloadCatalogBuild
    $script:catalogViews.Downloads.Panel.Children.Clear()
    $script:catalogViews.Downloads.NeedsRefresh = $true
    if ($script:activePage -eq 'Downloads') { $statusBarStatus.Text = "Unable to load downloads. $Message" }
    else { Write-Warning "Unable to load downloads. $Message" }
}

function Queue-AtomDownloadCatalogBatch {
    $script:downloadCatalogBuild.Operation = $window.Dispatcher.BeginInvoke([Action]{
        try {
            $build = $script:downloadCatalogBuild
            $batchClock = [Diagnostics.Stopwatch]::StartNew()
            # Keep each UI-thread batch short and allow input between batches.
            while ($build.GroupIndex -lt $build.Groups.Count) {
                $group = $build.Groups[$build.GroupIndex]
                if ($build.RowIndex -eq 0) {
                    $build.ListBox = & $build.AddCategory $group $build.SortMode $script:catalogViews.Downloads.Panel $true
                }
                & $build.AddRow $group.Group[$build.RowIndex] $build.ListBox $build.SelectedPrograms $true
                $build.RowIndex++
                if ($build.RowIndex -eq $group.Count) {
                    $build.GroupIndex++
                    $build.RowIndex = 0
                }
                if ($batchClock.ElapsedMilliseconds -ge 12) { break }
            }

            if ($build.GroupIndex -lt $build.Groups.Count) {
                Queue-AtomDownloadCatalogBatch
                return
            }

            Stop-AtomDownloadCatalogBuild
            Complete-AtomPluginList -DownloadMode $true
            if ($script:activePage -eq 'Downloads') { Start-AtomDownloadPageTracking }
        } catch {
            Set-AtomDownloadCatalogBuildError -Message $_.Exception.Message
        }
    }, [Windows.Threading.DispatcherPriority]::Background)
}

function Start-AtomDownloadPageTracking {
    $downloadManagerTimer.Start()
    if (!$script:downloadStorage) {
        $window.Dispatcher.BeginInvoke([Action]{
            if ($script:activePage -eq 'Downloads' -and !$script:downloadCatalogBuild -and !$script:downloadStorage) {
                Start-AtomDownloadStorageScan
            }
        }, [Windows.Threading.DispatcherPriority]::ApplicationIdle) | Out-Null
    }
}
