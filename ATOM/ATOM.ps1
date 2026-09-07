$versionData = Import-PowerShellDataFile -Path "$PSScriptRoot\Config\Version.psd1"
$version = "v$($versionData.Version)"
Add-Type -AssemblyName PresentationFramework

# Load the launcher and its explicitly registered dependencies
$atomStartupFunctions = @(
    'Get-AtomFileHash'
    'Get-AtomUpdateContext'
    'Get-AtomUpdateState'
    'Invoke-Runspace'
    'New-AtomFileManifest'
    'Set-AtomPluginOverride'
    'Set-WindowStyle'
    'Write-AtomFileAtomic'
    'Write-AtomSettingsFile'
    'Write-AtomUpdateState'
)
. "$PSScriptRoot/Functions/Import-Atom.ps1" -Function $atomStartupFunctions -Group Launcher -Feature Catalog,Wpf

$script:atomSettings = $atomSettings
$script:programDefaults = $programDefaults

$settingsXaml = @"
<StackPanel MaxWidth="300" Margin="5">
    <!-- PAGE HEADER -->
    <StackPanel Orientation="Horizontal">
        <TextBlock Text="Settings" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
    </StackPanel>

    <!-- GENERAL PANEL -->
    <TextBlock Text="General" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel Name="generalSettingsPanel"/>
    </Border>

    <!-- PLUGINS PANEL -->
    <TextBlock Text="Plugins" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel Name="pluginSettingsPanel"/>
    </Border>

    <!-- QUIPS PANEL -->
    <TextBlock Text="Quips" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel Name="quipSettingsPanel"/>
    </Border>

    <!-- APPEARANCE PANEL -->
    <TextBlock Text="Appearance" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel>
            <Grid Margin="5,12,5,10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>
                <TextBlock Text="UI scaling" Foreground="{DynamicResource surfaceText}" FontSize="12" VerticalAlignment="Center" Margin="5,0,0,0"/>
                <TextBlock Name="uiScalingValueText" Grid.Column="1" Foreground="{DynamicResource surfaceText}" FontSize="12" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,5,0"/>
                <Slider Name="uiScalingSlider" Grid.Row="1" Grid.ColumnSpan="2" Minimum="1" Maximum="1.5" TickFrequency="0.125" SmallChange="0.125" LargeChange="0.125" IsSnapToTickEnabled="True" IsMoveToPointEnabled="True" Margin="5,12,5,5" ToolTip="Scale the entire interface between 1.0x and 1.5x"/>
            </Grid>
            <Button Name="themeSelectorButton" Background="Transparent" Style="{StaticResource RoundedButton}" HorizontalAlignment="Stretch" HorizontalContentAlignment="Stretch" ToolTip="Show theme options">
                <Grid Margin="5,2.5">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Theme:" Foreground="{DynamicResource surfaceText}" FontSize="12" VerticalAlignment="Center"/>
                    <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Center">
                        <TextBlock Name="themeSelectorText" Foreground="{DynamicResource surfaceText}" FontSize="12" VerticalAlignment="Center" Margin="0,0,8,0"/>
                        <Border Name="themePrimarySwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center" CornerRadius="4,0,0,4"/>
                        <Border Name="themeBackgroundSwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center"/>
                        <Border Name="themeSurfaceSwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center"/>
                        <Border Name="themeAccentSwatch" Width="12" Height="12" Margin="1" VerticalAlignment="Center" CornerRadius="0,4,4,0"/>
                    </StackPanel>
                    <ContentControl Name="themeSelectorIndicator" Grid.Column="2" Width="16" Height="16" VerticalAlignment="Center" Margin="8,0,0,0"/>
                </Grid>
            </Button>
            <WrapPanel Name="themePanel" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,5,0,0" Visibility="Collapsed"/>
        </StackPanel>
    </Border>

    <!-- ATOM PANEL -->
    <TextBlock Text="ATOM" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="1"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <Button Name="pathButton" Grid.Row="0" Grid.Column="0" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Open ATOM folder"/>
            <TextBlock Name="pathTextBox" Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="2" Text="$atomPath" Foreground="{DynamicResource surfaceText}" TextTrimming="CharacterEllipsis" VerticalAlignment="Center" Margin="5,2" ToolTip="$atomPath"/>

            <Border Grid.Row="1" Grid.ColumnSpan="3" Height="1" Background="{DynamicResource surfaceText}" Opacity="0.12" Margin="5,0"/>

            <Button Name="githubButton" Grid.Row="2" Grid.Column="0" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Open ATOM repository in browser"/>
            <TextBlock Name="githubTextBox" Grid.Row="2" Grid.Column="1" Foreground="{DynamicResource surfaceText}" TextTrimming="CharacterEllipsis" VerticalAlignment="Center" Margin="5,2"/>
        </Grid>
    </Border>

    <!-- RESET SETTINGS PANEL -->
    <TextBlock Text="Reset settings" FontSize="12" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <Button Name="defaultSwitchButton" Width="130" Background="{DynamicResource accentBrush}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5">
            <StackPanel Orientation="Horizontal">
                <ContentControl Name="restoreImage" Width="16" Height="16" Margin="5"/>
                <TextBlock Text="Restore Defaults" FontSize="11" Foreground="{DynamicResource accentText}" VerticalAlignment="Center"/>
            </StackPanel>
        </Button>
    </Border>
</StackPanel>
"@

$updatesXaml = @"
<StackPanel MaxWidth="300" Margin="5">
    <!-- UPDATE PANEL -->
    <TextBlock Text="Updates" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" Margin="10,10,10,0"/>
    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5,2,5,5" Padding="5">
        <StackPanel>
            <StackPanel Name="updateChannelPanel"/>
            <Grid>
                <TextBlock Text="Installed:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="installedVersionText" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
            </Grid>
            <Grid>
                <TextBlock Text="Status:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                <TextBlock Name="updateText" MaxWidth="185" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" TextAlignment="Right" TextWrapping="Wrap" Margin="5"/>
            </Grid>
            <Button Name="updateActionButton" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Stretch" Style="{StaticResource RoundedButton}" Margin="5" ToolTip="Check for updates or apply the available ATOM action">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <ContentControl Name="updateActionImage" Width="16" Height="16" Margin="5"/>
                    <TextBlock Name="updateActionText" Text="Check for Updates" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                </StackPanel>
            </Button>
            <Button Name="healthCheckButton" Background="Transparent" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5,0,5,5" ToolTip="Verify ATOM-owned files without affecting user-added files">
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                    <ContentControl Name="healthCheckImage" Width="14" Height="14" Margin="5"/>
                    <TextBlock Text="Verify ATOM Files" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
                </StackPanel>
            </Button>
            <TextBlock Name="healthCheckText" FontSize="11" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Center" TextAlignment="Center" TextWrapping="Wrap" Margin="5,0,5,5" Visibility="Collapsed"/>
        </StackPanel>
    </Border>

</StackPanel>
"@

$contentXaml = @"
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="0"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Border Name="sidebar" Grid.Row="1" Panel.ZIndex="1" Width="48" Background="{DynamicResource backgroundBrush}" BorderBrush="{DynamicResource backgroundHighlight}" BorderThickness="0,0,0,0">
                <Border.Effect>
                    <DropShadowEffect Color="{DynamicResource shadowColor}" Opacity="0.22" BlurRadius="10" ShadowDepth="3" Direction="0"/>
                </Border.Effect>
                <Border.Resources>
                    <Style x:Key="SidebarButtonStyle" TargetType="Button">
                        <Setter Property="Background" Value="Transparent"/>
                        <Setter Property="Foreground" Value="{DynamicResource backgroundText}"/>
                        <Setter Property="HorizontalContentAlignment" Value="Left"/>
                        <Setter Property="Height" Value="38"/>
                        <Setter Property="Margin" Value="4,2"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border x:Name="buttonBorder" Background="{TemplateBinding Background}" CornerRadius="6" BorderThickness="1" BorderBrush="Transparent">
                                        <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center" Margin="10,0"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter TargetName="buttonBorder" Property="Background" Value="{DynamicResource backgroundHighlight}"/>
                                        </Trigger>
                                        <Trigger Property="IsKeyboardFocused" Value="True">
                                            <Setter TargetName="buttonBorder" Property="BorderBrush" Value="{DynamicResource backgroundText}"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                        <Style.Triggers>
                            <Trigger Property="Tag" Value="Selected">
                                <Setter Property="Background" Value="{DynamicResource backgroundHighlight}"/>
                            </Trigger>
                        </Style.Triggers>
                    </Style>
                </Border.Resources>
                <StackPanel Margin="0,8,0,0">
                    <Button Name="sidebarToggleButton" Style="{StaticResource SidebarButtonStyle}" ToolTip="Expand navigation" AutomationProperties.Name="Expand navigation">
                        <StackPanel Orientation="Horizontal">
                            <ContentControl Name="sidebarToggleIcon" Width="18" Height="18">
                                <ContentControl.LayoutTransform>
                                    <RotateTransform Angle="180"/>
                                </ContentControl.LayoutTransform>
                            </ContentControl>
                            <TextBlock Name="sidebarToggleLabel" Text="Collapse" Margin="12,0,0,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        </StackPanel>
                    </Button>
                    <Border Height="1" Background="{DynamicResource backgroundHighlight}" Margin="8,6"/>
                    <Button Name="pluginsButton" Style="{StaticResource SidebarButtonStyle}" ToolTip="Plugins" AutomationProperties.Name="Plugins" Tag="Selected">
                        <StackPanel Orientation="Horizontal">
                            <ContentControl Name="pluginsNavIcon" Width="18" Height="18"/>
                            <TextBlock Name="pluginsNavLabel" Text="Plugins" Margin="12,0,0,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        </StackPanel>
                    </Button>
                    <Button Name="downloadsButton" Style="{StaticResource SidebarButtonStyle}" ToolTip="Downloads" AutomationProperties.Name="Downloads">
                        <StackPanel Orientation="Horizontal">
                            <ContentControl Name="downloadsNavIcon" Width="18" Height="18"/>
                            <TextBlock Name="downloadsNavLabel" Text="Downloads" Margin="12,0,0,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        </StackPanel>
                    </Button>
                    <Button Name="settingsButton" Style="{StaticResource SidebarButtonStyle}" ToolTip="Settings" AutomationProperties.Name="Settings">
                        <StackPanel Orientation="Horizontal">
                            <ContentControl Name="settingsNavIcon" Width="18" Height="18"/>
                            <TextBlock Name="settingsNavLabel" Text="Settings" Margin="12,0,0,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        </StackPanel>
                    </Button>
                    <Button Name="updatesButton" Style="{StaticResource SidebarButtonStyle}" ToolTip="Updates" AutomationProperties.Name="Updates">
                        <StackPanel Orientation="Horizontal">
                            <ContentControl Name="updatesNavIcon" Width="18" Height="18"/>
                            <TextBlock Name="updatesNavLabel" Text="Updates" Margin="12,0,0,0" VerticalAlignment="Center" Visibility="Collapsed"/>
                        </StackPanel>
                    </Button>
                </StackPanel>
            </Border>

            <Grid Name="pluginsPage" Grid.Row="1" Grid.Column="1">
                <ScrollViewer Name="scrollViewer" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}">
                    <StackPanel>
                        <Border Height="{Binding ActualHeight, ElementName=catalogToolbar}" Margin="0,15,0,5"/>
                        <WrapPanel Name="pluginWrapPanel" Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,0,0,10"/>
                    </StackPanel>
                </ScrollViewer>

                <StackPanel Name="catalogToolbar" Panel.ZIndex="10" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="10,10,28,5">
                    <Border Name="searchBar" Style="{StaticResource CustomBorder}" Padding="5">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="25"/>
                            </Grid.RowDefinitions>
                        <Grid Grid.Row="0">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <Button Name="backspaceButton" Grid.Column="0" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <ContentControl Name="searchImage" Grid.Column="1" Opacity="0.38" Width="16" Height="16" Margin="0"/>
                            <TextBlock Name="searchTextBlock" Grid.Column="2" Text="Search" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5"/>
                            <TextBox Name="searchTextBox" Grid.Column="2" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5" ToolTip="Search plugins (Ctrl+F)"/>
                            <Button Name="descriptionButton" Grid.Column="3" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Show descriptions"/>
                            <Button Name="visibilityButton" Grid.Column="4" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <Button Name="sortButton" Grid.Column="5" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                        </Grid>

                        <Grid Grid.Row="1" Height="2" Margin="5,2">
                            <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.44"/>
                            <ProgressBar Name="statusBarProgress" Height="2" Minimum="0" Maximum="100" Value="0" Background="Transparent" Foreground="{DynamicResource surfaceText}" IsHitTestVisible="False"/>
                        </Grid>

                            <Grid Grid.Row="2">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBlock Name="statusBarStatus" Foreground="{DynamicResource surfaceText}" FontSize="10" HorizontalAlignment="Stretch" VerticalAlignment="Center" TextTrimming="CharacterEllipsis" Margin="5"/>
                                <Button Name="refreshButton" Grid.Column="1" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5,0" ToolTip="Reload plugins (F5)"/>
                            </Grid>
                        </Grid>
                    </Border>
                    <Border Name="downloadManagerPanel" Style="{StaticResource CustomBorder}" Visibility="Collapsed" Margin="0,8,0,0" Padding="10">
                        <StackPanel>
                            <WrapPanel>
                                <TextBlock Text="Show:" Foreground="{DynamicResource surfaceText}" VerticalAlignment="Center" Margin="0,0,6,0"/>
                                <ComboBox Name="downloadFilter" Width="150" Style="{StaticResource CustomComboBox}" SelectedIndex="0" AutomationProperties.Name="Download status filter">
                                    <ComboBoxItem Content="All"/>
                                    <ComboBoxItem Content="Downloaded"/>
                                    <ComboBoxItem Content="Not downloaded"/>
                                    <ComboBoxItem Content="Updates available"/>
                                    <ComboBoxItem Content="Failed"/>
                                </ComboBox>
                            </WrapPanel>

                            <WrapPanel Name="statusActions" Orientation="Horizontal" HorizontalAlignment="Left" Margin="0,8,0,0">
                                <Button Name="programUpdateButton" Content="Check Updates" Height="21" MinWidth="95" Background="{DynamicResource controlBrush}" Foreground="{DynamicResource controlText}" HorizontalAlignment="Left" VerticalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="0,2,6,2" Padding="8,0" Visibility="Collapsed" ToolTip="Check all downloaded programs for updates"/>
                                <Button Name="downloadSelectedButton" Content="Download / Update Selected" Height="21" MinWidth="175" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Left" VerticalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="0,2,6,2" Padding="8,0" Visibility="Collapsed" IsEnabled="False" ToolTip="Download new programs or update selected programs"/>
                            </WrapPanel>
                            <Border Height="1" Background="{DynamicResource surfaceText}" Opacity="0.2" Margin="0,8,0,3"/>
                            <Grid Margin="0,5,0,0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <StackPanel>
                                    <TextBlock Name="downloadSummaryText" Foreground="{DynamicResource surfaceText}" FontSize="10" TextWrapping="Wrap"/>
                                    <TextBlock Name="downloadStorageText" Text="Storage not measured" Foreground="{DynamicResource surfaceText}" FontSize="10" TextWrapping="Wrap" Margin="0,3,0,0"/>
                                </StackPanel>
                                <Button Name="downloadStorageButton" Grid.Column="1" Content="Refresh Storage" Style="{StaticResource RoundedButton}" Background="Transparent" Foreground="{DynamicResource surfaceText}" VerticalAlignment="Center" Margin="8,0,0,0" Padding="6,2"/>
                            </Grid>
                        </StackPanel>
                    </Border>
                </StackPanel>
            </Grid>

            <ScrollViewer Name="scrollViewerSettings" Grid.Row="1" Grid.Column="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}" Visibility="Collapsed">
                $settingsXaml
            </ScrollViewer>
            <ScrollViewer Name="scrollViewerUpdates" Grid.Row="1" Grid.Column="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}" Visibility="Collapsed">
                $updatesXaml
            </ScrollViewer>

        </Grid>
"@

$titleContentXaml = @'
<Viewbox x:Name="atomLogo" Grid.Column="0" Width="105" Height="30" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,5">
    <Canvas Width="1905" Height="358">
        <Path Data="{StaticResource AtomLogoGeometry}" Fill="{DynamicResource primaryText}"/>
    </Canvas>
</Viewbox>
'@

$windowParameters = @{
    Title                 = "ATOM $version"
    TitleContentXaml      = $titleContentXaml
    ContentXaml           = $contentXaml
    Width                 = 469
    Height                = 600
    MinWidth              = 255
    MinHeight             = 600
    MaxWidth              = 923
    MaxHeight             = 800
    SizeToContent         = 'Height'
    WindowStartupLocation = 'Manual'
    WireWindowButtons     = $false
}
$window = New-AtomWindow @windowParameters
$window.Top = 0
$window.Left = 0

# A rounded Border paints its own corners but does not clip child backgrounds.
# Clip at the unscaled window boundary so the sidebar follows the window radius
# at every UI scale, without changing the sidebar or page layout.
$window.FindName('atomBackground').Add_SizeChanged({
    param($sender, $eventArgs)

    $sender.Clip = [Windows.Media.RectangleGeometry]::new(
        [Windows.Rect]::new(0, 0, $sender.ActualWidth, $sender.ActualHeight),
        $sender.CornerRadius.TopLeft,
        $sender.CornerRadius.TopLeft
    )
})

# Assign variables to elements in XAML
$refreshButton          = $window.FindName('refreshButton')
$descriptionButton      = $window.FindName('descriptionButton')
$settingsButton         = $window.FindName('settingsButton')
$pluginsButton          = $window.FindName('pluginsButton')
$updatesButton          = $window.FindName('updatesButton')
$sidebar                = $window.FindName('sidebar')
$sidebarToggleButton    = $window.FindName('sidebarToggleButton')
$pluginsPage            = $window.FindName('pluginsPage')
$scrollViewerUpdates    = $window.FindName('scrollViewerUpdates')
$script:activePage = 'Plugins'
$script:sidebarExpanded = $false
$minimizeButton         = $window.FindName('atomMinimizeButton')
$closeButton            = $window.FindName('atomCloseButton')
$scrollViewer           = $window.FindName('scrollViewer')
$scrollViewerSettings   = $window.FindName('scrollViewerSettings')
$pluginWrapPanel        = $window.FindName('pluginWrapPanel')
$statusBarProgress      = $window.FindName('statusBarProgress')
$statusBarStatus        = $window.FindName('statusBarStatus')
$statusActions          = $window.FindName('statusActions')
$visibilityButton       = $window.FindName('visibilityButton')
$downloadsButton        = $window.FindName('downloadsButton')
$downloadSelectedButton = $window.FindName('downloadSelectedButton')
$programUpdateButton    = $window.FindName('programUpdateButton')

$script:downloadMode = $false
$script:downloadTransferState = $null
$window.Tag = @{
    UpdatingDownloadSelection = $false
    DownloadRefreshPending = $false
    DownloadCompletionStatus = $null
    UpdateQueue = $null
    CompactStatusLayout = $null
    PluginClickSource = $null
    PluginDragSource = $null
    PluginDragStart = $null
}

$script:pluginImageQueue = [Collections.Generic.Queue[Object]]::new()
$script:decodedPluginImages = $null
$pluginImageTimer = [Windows.Threading.DispatcherTimer]::new([Windows.Threading.DispatcherPriority]::Background)
$pluginImageTimer.Interval = [TimeSpan]::FromMilliseconds(1)
$pluginImageTimer.Add_Tick({
    # Decoding happens off-thread, so source assignment is now cheap. Drain most
    # normal plugin sets in two ticks while retaining a bound for large libraries.
    foreach ($imageIndex in 1..24) {
        $decodedImage = $null
        if ($script:decodedPluginImages.TryTake([ref]$decodedImage)) {
            if ($decodedImage.Source) {
                $decodedImage.Item.Image.Source = $decodedImage.Source
            } elseif ($decodedImage.Error) {
                Write-Warning "Unable to load plugin icon '$($decodedImage.Item.DeferredImageSource)': $($decodedImage.Error)"
            }
            continue
        }
        if ($script:decodedPluginImages.IsCompleted) {
            $this.Stop()
        }
        return
    }
})

# Load quips
. $configPath\Quippy.ps1

# Automatically launch MountOS when ATOM is running in Windows PE.
$inPe = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
if ($inPe) {
    $mountOs = Get-ChildItem $atomPath -Filter 'MountOS.ps1' -Recurse | Select-Object -Expand FullName
    $powerShellHost = (Get-Process -Id $PID).Path
    Start-Process $powerShellHost -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$mountOs`"" -Wait
}
# Set icon sources
$sidebarIconResources = @{
    'pluginsNavIcon' = 'CategoryIcon'
    'downloadsNavIcon' = 'DownloadIcon'
    'settingsNavIcon' = 'SettingsIcon'
    'updatesNavIcon' = 'UpdateIcon'
    'sidebarToggleIcon' = 'ArrowBackIcon'
}

$surfaceIconResources = @{
    'backspaceButton' = 'BackspaceIcon'
    'searchImage' = 'SearchIcon'
    'refreshButton' = 'RefreshIcon'
    'themeSelectorIndicator' = 'ArrowDropDownIcon'
    'visibilityButton' = $(if ($atomSettings.ShowHiddenPlugins.Value) { 'VisibilityIcon' } else { 'VisibilityOffIcon' })

    'sortButton' = $(if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { 'TextDescendingIcon' } else { 'CategoryIcon' })
    'pathButton' = 'FolderOpenIcon'
    'githubButton' = 'GitHubIcon'
    'healthCheckImage' = 'CheckboxIcon'
}

$accentIconResources = @{
    'updateActionImage' = 'DownloadIcon'
    'restoreImage' = 'ResetWrenchIcon'
}

Set-VectorIcon -Window $window -ForegroundResource backgroundText -ResourceMappings $sidebarIconResources
Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings $surfaceIconResources
Set-VectorIcon -Window $window -ForegroundResource accentText -ResourceMappings $accentIconResources

# Launch ATOM on reboot
$runOncePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
if ($atomSettings.LaunchOnRestart.Value) {
    $registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$psCommandPath`"`""
    New-ItemProperty -Path $runOncePath -Name "ATOM" -Value $registryValue -Force | Out-Null
}

Invoke-Runspace -ScriptBlock {
    # Output BitLocker key to text file in log path
    if ($atomSettings.SaveEncryptionsKey.Value -and !$inPE) {
        # Name encryption key file based on current time & date
        $onlineOS = (Get-WmiObject -Class Win32_OperatingSystem).SystemDrive
        $currentDateTime = Get-Date -Format "MMddyy_HHmmss"
        $logFile = Join-Path $logsPath "EncryptionKey-$currentDateTime.txt"

        # Output encryption key to txt file if drive is encrypted
        $encryptionKey = (manage-bde -protectors -get $onlineOS | Select-String -Pattern '\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}').Matches.Value
        if ($encryptionKey) { $encryptionKey | Out-File -Append $logFile }

        # Remove old encryption keys, keep last 5 most recent
        Get-ChildItem $logsPath\EncryptionKey-*.txt | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | Remove-Item -Force
    }
}

# Download manager state persists for this ATOM session, including failed attempts.

$script:downloadResults = [Hashtable]::Synchronized(@{})
$script:downloadVersions = @{}
$script:downloadRows = @{}
$script:downloadRecords = @{}
$downloadFilter = $window.FindName('downloadFilter')
$downloadManagerPanel = $window.FindName('downloadManagerPanel')
$downloadSummaryText = $window.FindName('downloadSummaryText')
$downloadStorageText = $window.FindName('downloadStorageText')
$downloadStorageButton = $window.FindName('downloadStorageButton')
$downloadManagerTimer = [Windows.Threading.DispatcherTimer]::new()
$downloadManagerTimer.Interval = [TimeSpan]::FromMilliseconds(500)
$downloadManagerTimer.Add_Tick({
    if ($script:downloadStorageScan -and $script:downloadStorageScan.Done) {
        if ($script:downloadStorageScan.Error) { $downloadStorageText.Text = 'Storage scan failed: ' + $script:downloadStorageScan.Error }
        else { $script:downloadStorage = $script:downloadStorageScan.Result }
        $script:downloadStorageScan = $null
    }
    if ($script:activePage -eq 'Downloads') { Update-AtomCatalogFilter }
    elseif (!$script:downloadStorageScan) { $this.Stop() }
})
$downloadFilter.Add_SelectionChanged({ Update-AtomCatalogFilter })
# Match Settings' custom placement callback. Configure it again on opening,
# since a collapsed page may load before its ComboBox template is realized.
$configureDownloadFilterPopup = {
    param($sender, $eventArgs)

    [void]$sender.ApplyTemplate()
    if (!$sender.Template) { return }
    $popup = $sender.Template.FindName('Popup', $sender)
    if (!$popup) { return }

    $popup.PlacementTarget = $sender
    $popup.Placement = [Windows.Controls.Primitives.PlacementMode]::Custom
    $popup.CustomPopupPlacementCallback = [Windows.Controls.Primitives.CustomPopupPlacementCallback]{
        param($popupSize, $targetSize, $offset)

        return [Windows.Controls.Primitives.CustomPopupPlacement[]]@(
            [Windows.Controls.Primitives.CustomPopupPlacement]::new(
                [Windows.Point]::new(0, 0),
                [Windows.Controls.Primitives.PopupPrimaryAxis]::None
            )
        )
    }
}
$downloadFilter.Add_Loaded($configureDownloadFilterPopup)
$downloadFilter.Add_DropDownOpened($configureDownloadFilterPopup)
$downloadStorageButton.Add_Click({ Start-AtomDownloadStorageScan })

Update-AtomPluginList

# Rebuild download controls on the main UI runspace after a background download finishes.
$downloadRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
$downloadRefreshTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$downloadRefreshTimer.Add_Tick({
    $this.Stop()
    if (!$window.Tag.DownloadRefreshPending) { return }

    try {
        if ($window.Tag.CompletedDownloads) {
            $script:availableProgramUpdates = @($script:availableProgramUpdates | Where-Object { $window.Tag.CompletedDownloads -notcontains $_ })
            $window.Tag.CompletedDownloads = $null
        }
        Update-AtomPluginList
        $statusBarStatus.Text = $window.Tag.DownloadCompletionStatus
        Start-AtomDownloadStorageScan
    } catch {
        $statusBarStatus.Text = 'Downloads finished, but the plugin list could not be refreshed'
    } finally {
        $window.Tag.DownloadRefreshPending = $false
    }
})

# Render file-transfer progress on the main UI thread.
$downloadProgressTimer = New-Object System.Windows.Threading.DispatcherTimer
$downloadProgressTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$downloadProgressTimer.Add_Tick({
    $state = $script:downloadTransferState
    if (!$state -or !$state.Program) { return }

    $sizeText =
        if ($null -ne $state.TotalBytes) { "$([math]::Ceiling($state.TotalBytes / 1MB))MB" }
        elseif ($state.Status -eq 'Connecting') { 'Calculating...' }
        else { 'Unknown size' }

    $transferStatuses = 'Pending','Connecting','Downloading','Receiving','Verifying','Completed'
    $statusBarStatus.Text =
        if ($state.Status -and $state.Status -notin $transferStatuses) { "$($state.Program) - $($state.Status)" }
        else { "Downloading $($state.Program) [$sizeText]" }
    $statusBarProgress.Value =
        if ($null -ne $state.PercentComplete) { [math]::Min(100, [math]::Max(0, $state.PercentComplete)) }
        else { 0 }
})

# Search bar controls
$searchBar       = $window.FindName('searchBar')
$searchTextBlock = $window.FindName('searchTextBlock')
$searchTextBox   = $window.FindName('searchTextBox')

$backspaceButton = $window.FindName('backspaceButton')
$backspaceButton.Tooltip = "Clear search box"
$backspaceButton.Add_Click({
    Clear-AtomSearchTextBox
})

$searchTextBox.Add_GotFocus({
    if ($searchTextBlock.Visibility -eq "Visible") { $searchTextBlock.Visibility = "Collapsed" }
})

$searchTextBox.Add_LostFocus({
    if ($searchTextBox.Text -eq "") { $searchTextBlock.Visibility = "Visible" }
})

$searchTimer = [System.Windows.Threading.DispatcherTimer]::new()
$searchTimer.Interval = [TimeSpan]::FromMilliseconds(125)
$searchTimer.Add_Tick({
    $this.Stop()
    Update-AtomCatalogFilter
})

$searchTextBox.Add_TextChanged({
    $searchTimer.Stop()
    $searchTimer.Start()
})

# Plugin sort button
$sortButton = $window.FindName('sortButton')

$sortButton.ToolTip =
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') { "Sort by category" }
    else { "Sort alphabetically" }

$sortButton.Add_Click({
    if ($atomSettings.SortPlugins.Value -eq 'Alphabetical') {
        $sortButton.ToolTip = "Sort alphabetically"
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'CategoryIcon' }
        $script:atomSettings.SortPlugins.Value = 'Category'
        Save-AtomSettings
        Set-AtomPluginSortLayout -SortMode Category
    } else {
        $sortButton.ToolTip = "Sort by category"
        Set-VectorIcon -Window $window -ForegroundResource surfaceText -ResourceMappings @{ 'sortButton' = 'TextDescendingIcon' }
        $script:atomSettings.SortPlugins.Value = 'Alphabetical'
        Save-AtomSettings
        Set-AtomPluginSortLayout -SortMode Alphabetical
    }
})

# Persist the Plugins page's description preference from its toolbar.
$descriptionButton.Add_Click({
    $script:atomSettings.ShowPluginDescriptions.Value = !$script:atomSettings.ShowPluginDescriptions.Value
    Save-AtomSettings
    Update-AtomPluginList
    Update-AtomCatalogFilter
})

# Toggle hidden plugins in both launch and download modes.
$visibilityButton.Add_Click({
    $script:atomSettings.ShowHiddenPlugins.Value = !$script:atomSettings.ShowHiddenPlugins.Value
    Save-AtomSettings
    Update-AtomVisibilityButton
    Update-AtomPluginList
})

# Apply results in the main PowerShell runspace, where row and icon helpers exist.
$programUpdateResultTimer = [Windows.Threading.DispatcherTimer]::new()
$programUpdateResultTimer.Interval = [TimeSpan]::FromMilliseconds(100)
$programUpdateResultTimer.Add_Tick({
    $this.Stop()
    $result = $window.Tag.ProgramUpdateResult
    $window.Tag.ProgramUpdateResult = $null
    try {
        if (!$result -or $result.Failed) { throw 'Unable to check for program updates' }
        $script:availableProgramUpdates = @($result.Entries | Where-Object UpdateAvailable | ForEach-Object Name)
        foreach ($entry in $result.Entries) { $script:downloadVersions[$entry.Name] = $entry }
        Update-AtomPluginList
        foreach ($item in @(Get-AtomDownloadItem)) {
            if ($item.IsEnabled -and $script:availableProgramUpdates -contains [String]$item.Control.Tag) {
                $item.Control.IsChecked = $true
            }
        }
        Update-AtomDownloadSelectionState
        $count = $script:availableProgramUpdates.Count
        $statusBarStatus.Text = if ($count -eq 1) { '1 update available' } else { "$count updates available" }
    } catch {
        $statusBarStatus.Text = "Unable to display update results: $($_.Exception.Message)"
    } finally {
        $programUpdateButton.Content = 'Check Updates'
        $programUpdateButton.IsEnabled = $true
        $downloadSelectedButton.IsEnabled = @(Get-AtomDownloadItem | Where-Object { $_.IsEnabled -and $_.Control.IsChecked }).Count -gt 0
        $visibilityButton.IsEnabled = $true
        $pluginsButton.IsEnabled = $true
        $refreshButton.IsEnabled = $true
        $sortButton.IsEnabled = $true
    }
})

# Check installed portable programs, then pass available updates to the download workflow.
$programUpdateButton.Add_Click({
    $script:downloadButtonWasEnabled = $downloadSelectedButton.IsEnabled
    foreach ($item in @(Get-AtomDownloadItem)) {
        $updateIcon = @($item.TrailingContent | Where-Object Tag -eq 'UpdateAvailable') | Select-Object -First 1
        if ($updateIcon) { $updateIcon.Visibility = 'Collapsed' }
    }
    $statusBarStatus.Text = 'Checking for program updates...'
    $statusBarProgress.Value = 0
    $programUpdateButton.Content = 'Checking...'
    $programUpdateButton.IsEnabled = $false
    $downloadSelectedButton.IsEnabled = $false
    $visibilityButton.IsEnabled = $false
    $pluginsButton.IsEnabled = $false
    $refreshButton.IsEnabled = $false
    $sortButton.IsEnabled = $false

    try {
        Invoke-Runspace -ScriptBlock {
            $checkFailed = $false
            $updateNames = @()

            try {
                . $configPath\Plugins.ps1
                . $atomPath\Functions\Import-Atom.ps1 -Function Get-ProgramUpdates
                $updateNames = @(Get-ProgramUpdates -Programs $programs -IncludeCurrent)
            } catch {
                $checkFailed = $true
            }

            # Dispatcher access alone does not import the main runspace's functions.
            # Publish data and let its timer create/update the WPF rows.
            Invoke-Ui {
                $window.Tag.ProgramUpdateResult = @{ Failed = $checkFailed; Entries = @($updateNames) }
                $programUpdateResultTimer.Start()
            }

        }
    } catch {
        $programUpdateButton.Content = 'Check Updates'
        $programUpdateButton.IsEnabled = $true
        $visibilityButton.IsEnabled = $true
        $pluginsButton.IsEnabled = $true
        $refreshButton.IsEnabled = $true
        $sortButton.IsEnabled = $true
        $statusBarStatus.Text = 'Unable to start update check'
        Update-AtomDownloadSelectionState
    }
})

# Permanently download the selected portable programs in a background runspace
$downloadSelectedButton.Add_Click({
    $script:downloadIsUpdate = $null -ne $window.Tag.UpdateQueue
    $script:checkedItems =
        if ($script:downloadIsUpdate) {
            $queue = @($window.Tag.UpdateQueue)
            $window.Tag.UpdateQueue = $null
            $queue
        } else {
            @(Get-AtomDownloadItem | Where-Object { $_.IsEnabled -and $_.Control.IsChecked } | ForEach-Object { $_.Control.Tag })
        }

    if (!$pluginsButton.IsEnabled -or $script:checkedItems.Count -eq 0) { return }
    $script:retryDownloadNames = @($script:checkedItems | Where-Object { $script:downloadResults[$_].Status -in 'Failed', 'Blocked' })
    foreach ($name in $script:checkedItems) { $script:downloadResults[$name] = @{ Status = 'Queued'; Error = $null } }
    $pluginsButton.IsEnabled = $false
    $downloadSelectedButton.IsEnabled = $false
    $programUpdateButton.IsEnabled = $false
    Update-AtomDownloadDetails

    $script:downloadTransferState = [hashtable]::Synchronized(@{
        Program = $null
        Status = 'Pending'
        TotalBytes = $null
        PercentComplete = $null
        IsCompleted = $false
        TrackHash = $true
    })
    $statusBarProgress.Value = 0
    $downloadProgressTimer.Start()

    try {
        Invoke-Runspace -ScriptBlock {
            $failedDownloads = 0
            $downloadErrors = @()
            $downloadProcessFailed = $false
            $downloadProcessError = $null
            $alreadyUpToDate = $false

            try {
                # Only lock download-related controls after the runspace is running.
                Invoke-Ui {
                    $downloadSelectedButton.Content = if ($downloadIsUpdate) { 'Updating...' } else { 'Downloading...' }
                    $downloadSelectedButton.IsEnabled = $false
                    $programUpdateButton.IsEnabled = $false
                    $visibilityButton.IsEnabled = $false
                    $pluginsButton.IsEnabled = $false
                    $refreshButton.IsEnabled = $false
                    $sortButton.IsEnabled = $false
                }

                . $configPath\Plugins.ps1
                . $atomPath\Functions\Import-Atom.ps1 -Function Start-Program,Get-ProgramUpdates,Set-DownloadRecord

                if (!(Test-Path $programsPath)) {
                    New-Item -Path $programsPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                }

                # Check selected installed programs before downloading. New entries
                # are queued immediately; installed entries are queued only when a
                # newer version (or changed executable) is available.
                $selectedForCheck = [ordered]@{}
                $newProgramNames = [Collections.Generic.List[String]]::new()
                foreach ($selectedProgram in @($checkedItems)) {
                    $downloadResults[$selectedProgram] = @{ Status = 'Checking'; Error = $null }
                    if (!$programs.Contains($selectedProgram)) { throw "Download entry '$selectedProgram' is not configured." }
                    $selectedInfo = $programs[$selectedProgram].ProgramInfo
                    $selectedPath = if ($selectedInfo) { Join-Path $selectedInfo.DestinationPath ([String]$selectedInfo.RelativePath).TrimStart('\', '/') }
                    if ($retryDownloadNames -notcontains $selectedProgram -and $selectedPath -and (Get-Item -Path $selectedPath -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer } | Select-Object -First 1)) {
                        $selectedForCheck[$selectedProgram] = $programs[$selectedProgram]
                    } else {
                        [void]$newProgramNames.Add($selectedProgram)
                    }
                }
                $selectedUpdateNames = [Collections.Generic.List[String]]::new()
                if ($selectedForCheck.Count) {
                    foreach ($selectedName in $selectedForCheck.Keys) {
                        try {
                            $singleProgram = [ordered]@{}
                            $singleProgram[$selectedName] = $selectedForCheck[$selectedName]
                            if (@(Get-ProgramUpdates -Programs $singleProgram).Count) {
                                [void]$selectedUpdateNames.Add($selectedName)
                            } else { $downloadResults[$selectedName] = @{ Status = 'No update found'; Error = $null } }
                        } catch {
                            throw "Unable to check '$selectedName' for updates: $($_.Exception.Message)"
                        }
                    }
                }
                $checkedItems = @($newProgramNames + $selectedUpdateNames)
                $downloadIsUpdate = $selectedUpdateNames.Count -gt 0
                if (!$checkedItems.Count) {
                    $alreadyUpToDate = $true
                    return
                }

                Invoke-Ui {
                    $downloadSelectedButton.Content = if ($downloadIsUpdate) { 'Updating...' } else { 'Downloading...' }
                    $statusBarStatus.Text = if ($downloadIsUpdate) { 'Updating selected programs...' } else { 'Downloading selected programs...' }
                }

                # Add missing dependencies before their selected dependents while
                # leaving already-installed dependencies untouched.
                $downloadQueue = [Collections.Generic.List[String]]::new()
                $dependencyStack = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
                function Add-AtomDownloadWithDependencies ([String]$Name) {
                    if (!$programs.Contains($Name)) { throw "Download dependency '$Name' is not configured." }
                    if (!$dependencyStack.Add($Name)) { throw "Circular download dependency detected at '$Name'." }
                    try {
                        foreach ($dependency in @($programs[$Name].Dependencies | Where-Object { $_ })) {
                            $dependencyInfo = $programs[$dependency].ProgramInfo
                            if (!$dependencyInfo) { throw "Download dependency '$dependency' has no ProgramInfo configuration." }
                            $dependencyPattern = Join-Path $dependencyInfo.DestinationPath ([String]$dependencyInfo.RelativePath).TrimStart('\', '/')
                            if (!(Get-Item -Path $dependencyPattern -ErrorAction SilentlyContinue | Where-Object { !$_.PSIsContainer } | Select-Object -First 1)) {
                                Add-AtomDownloadWithDependencies -Name $dependency
                            }
                        }
                        if (!$downloadQueue.Contains($Name)) { $downloadQueue.Add($Name) }
                    } finally {
                        [void]$dependencyStack.Remove($Name)
                    }
                }
                foreach ($selectedProgram in $checkedItems) { Add-AtomDownloadWithDependencies -Name $selectedProgram }
                $checkedItems = @($downloadQueue)

                foreach ($queuedName in $checkedItems) { $downloadResults[$queuedName] = @{ Status = 'Queued'; Error = $null } }
                foreach ($program in $checkedItems) {
                    $failedDependencies = @($programs[$program].Dependencies | Where-Object { $_ -and $checkedItems -contains $_ -and $downloadResults[$_].Status -in 'Failed', 'Blocked' })
                    if ($failedDependencies.Count) {
                        $downloadResults[$program] = @{ Status = 'Blocked'; Error = 'Dependency failed: ' + ($failedDependencies -join ', ') }
                        $failedDownloads++
                        $downloadErrors += "${program}: dependency failed"
                        continue
                    }
                    $downloadResults[$program] = @{ Status = 'Running'; Error = $null }
                    $downloadTransferState.Program = $program
                    $downloadTransferState.Status = 'Connecting'
                    $downloadTransferState.TotalBytes = $null
                    $downloadTransferState.PercentComplete = $null
                    $downloadTransferState.IsCompleted = $false
                    $downloadTransferState.Version = $null
                    $downloadTransferState.Source = $null
                    $downloadTransferState.ResolvedUri = $null
                    $downloadTransferState.Uri = $null
                    $downloadTransferState.DownloadHash = $null

                    try {
                        $programParams = $programs[$program].ProgramInfo
                        if (!$programParams) { throw "No ProgramInfo configuration exists for '$program'." }

                        Start-Program @programParams -DownloadOnly -ProgressState $downloadTransferState -ErrorAction Stop | Out-Null

                        $configuredPath = Join-Path $programParams.DestinationPath ([String]$programParams.RelativePath).TrimStart('\', '/')
                        $programPath = @(Get-Item -Path $configuredPath -ErrorAction SilentlyContinue |
                            Where-Object { !$_.PSIsContainer } |
                            Sort-Object FullName -Descending |
                            Select-Object -First 1).FullName
                        if (!$programPath) {
                            throw "Downloaded program was not found at '$configuredPath'."
                        }

                        Set-DownloadRecord -Name $program -ProgramInfo $programParams -ProgressState $downloadTransferState | Out-Null
                        $downloadResults[$program] = @{ Status = 'Completed'; Error = $null }
                    } catch {
                        $downloadResults[$program] = @{ Status = 'Failed'; Error = $_.Exception.Message }
                        $failedDownloads++
                        $downloadErrors += "${program}: $($_.Exception.Message)"
                    }
                }
            } catch {
                $downloadProcessFailed = $true
                $downloadProcessError = $_.Exception.Message
                foreach ($pendingName in @($downloadResults.Keys)) {
                    if ($downloadResults[$pendingName].Status -in 'Queued', 'Checking', 'Running') {
                        $downloadResults[$pendingName] = @{ Status = 'Failed'; Error = $downloadProcessError }
                    }
                }
            } finally {
                # Hand completion back to a main-runspace timer. Do not mutate checkbox
                # controls from this background-owned dispatcher callback.
                Invoke-Ui {
                    $downloadProgressTimer.Stop()
                    $statusBarProgress.Value = 0
                    $window.Tag.DownloadCompletionStatus =
                        if ($downloadProcessFailed) { "Download process failed: $downloadProcessError" }
                        elseif ($alreadyUpToDate) { 'Selected programs are already up to date' }
                        elseif ($failedDownloads) {
                            if ($downloadErrors.Count -eq 1) { $downloadErrors[0] }
                            elseif ($downloadIsUpdate) { "$failedDownloads updates failed: $($downloadErrors -join ' | ')" }
                            else { "$failedDownloads downloads failed: $($downloadErrors -join ' | ')" }
                        }
                        else { if ($downloadIsUpdate) { 'Updates complete' } else { 'Downloads complete' } }

                    $window.Tag.DownloadRefreshPending = $true
                    $window.Tag.CompletedDownloads = @($checkedItems | Where-Object { $downloadResults[$_].Status -eq 'Completed' })
                    $downloadSelectedButton.Content = 'Download / Update Selected'
                    $downloadSelectedButton.IsEnabled = $false
                    $programUpdateButton.IsEnabled = $true
                    $visibilityButton.IsEnabled = $true
                    $pluginsButton.IsEnabled = $true
                    $refreshButton.IsEnabled = $true
                    $sortButton.IsEnabled = $true
                    $downloadRefreshTimer.Start()
                }
            }
        }
    } catch {
        # Handle a failure to create/start the runspace itself.
        $downloadSelectedButton.Content = 'Download / Update Selected'
        $downloadSelectedButton.IsEnabled = $true
        $programUpdateButton.IsEnabled = $true
        $visibilityButton.IsEnabled = $true
        $pluginsButton.IsEnabled = $true
        $refreshButton.IsEnabled = $true
        $sortButton.IsEnabled = $true
        $downloadProgressTimer.Stop()
        $statusBarProgress.Value = 0
        foreach ($name in $script:checkedItems) { $script:downloadResults[$name] = @{ Status = 'Failed'; Error = $_.Exception.Message } }
        $statusBarStatus.Text = 'Unable to start download process'
        Update-AtomDownloadDetails
    }
})

Set-AtomQuip

$refreshButton.Add_Click({ Invoke-AtomPluginRefresh })

$pluginsButton.Add_Click({ Set-AtomPage -Page Plugins })
$downloadsButton.Add_Click({ Set-AtomPage -Page Downloads })
$settingsButton.Add_Click({ Set-AtomPage -Page Settings })
$updatesButton.Add_Click({ Set-AtomPage -Page Updates })
$sidebarToggleButton.Add_Click({
    $script:sidebarExpanded = !$script:sidebarExpanded
    $oldWidth = $sidebar.Width
    $oldWindowWidth = $window.Width
    $sidebar.Width = if ($script:sidebarExpanded) { 144 } else { 48 }
    foreach ($labelName in 'sidebarToggleLabel', 'pluginsNavLabel', 'downloadsNavLabel', 'settingsNavLabel', 'updatesNavLabel') {
        $window.FindName($labelName).Visibility = if ($script:sidebarExpanded) { 'Visible' } else { 'Collapsed' }
    }
    $sidebarToggleButton.ToolTip = if ($script:sidebarExpanded) { 'Collapse navigation' } else { 'Expand navigation' }
    [Windows.Automation.AutomationProperties]::SetName($sidebarToggleButton, $sidebarToggleButton.ToolTip)
    $window.FindName('sidebarToggleIcon').LayoutTransform.Angle = if ($script:sidebarExpanded) { 0 } else { 180 }
    $scale = [Double]$window.Resources['uiScale']
    $window.MinWidth = ($windowParameters.MinWidth + $sidebar.Width) * $scale
    $window.MaxWidth = ($windowParameters.MaxWidth + $sidebar.Width) * $scale
    $window.Width = [Math]::Min($window.MaxWidth, [Math]::Max($window.MinWidth, $oldWindowWidth + ($sidebar.Width - $oldWidth) * $scale))
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

# Set plugin columns from startup columns user-setting
Set-AtomPluginColumnCount -ColumnCount $atomSettings.StartupColumns.Value

$closeButton.Add_Click({
    if (Get-ItemProperty -Path $runOncePath -Name "ATOM" -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $runOncePath -Name "ATOM" -Force | Out-Null
    }

    $window.Close()
})

Add-AtomScrollViewerBehavior -Window $window -Name 'scrollViewer'

Set-WindowSize

# ATOM settings

####################
##  Update panel  ##
####################

$installedVersionText = $window.FindName('installedVersionText')
$updateChannelPanel = $window.FindName('updateChannelPanel')
$updateChannelSelectorStyle = $window.FindResource('CustomComboBox')
$updateChannelItem = New-ListBoxControlItem -ControlType ComboBox -ControlAlignment Right -ControlOptions ([ordered]@{
    'Stable' = 'main'
    'Development' = 'dev'
}) -SelectedValue $script:atomSettings['UpdateChannel']['Value'] -ControlStyle $updateChannelSelectorStyle -ControlWidth 145 -Text 'Update channel' -Tag 'UpdateChannel' -ToolTip 'Choose the GitHub branch used for ATOM updates'
$updateChannelItem.MinHeight = 28
$updateChannelItem.VerticalContentAlignment = 'Center'
$updateChannelItem.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
$updateChannelPanel.Children.Add($updateChannelItem) | Out-Null
$updateChannelSelector = $updateChannelItem.Control
$updateActionButton = $window.FindName('updateActionButton')
$updateActionText = $window.FindName('updateActionText')
$updateActionImage = $window.FindName('updateActionImage')
$healthCheckButton = $window.FindName('healthCheckButton')
$healthCheckText = $window.FindName('healthCheckText')
$updateStatePath = Join-Path $configPath 'UpdateState.json'

$updateText = $window.FindName('updateText')
$lastCheckedPath = Join-Path $configPath "time.txt"
if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
$updateText.Text = if ($lastCheckedContent) { "Last checked $lastCheckedContent" } else { 'Not checked' }

$updateActionStates = @{
    Check      = @{ Text = 'Check for Updates'; Icon = 'DownloadIcon'; Enabled = $true; ToolTip = 'Check the selected channel for ATOM updates' }
    Checking   = @{ Text = 'Checking...'; Icon = 'RefreshIcon'; Enabled = $false; ToolTip = 'Checking the selected channel for ATOM updates' }
    CheckAgain = @{ Text = 'Check Again'; Icon = 'RefreshIcon'; Enabled = $true; ToolTip = 'Check the selected channel again' }
    Update     = @{ Text = 'Update ATOM'; Icon = 'UpdateIcon'; Enabled = $true; ToolTip = 'Install the available ATOM update' }
    Synchronize = @{ Text = 'Synchronize ATOM'; Icon = 'UpdateIcon'; Enabled = $true; ToolTip = 'Synchronize this source copy with the selected ATOM channel' }
    Repair     = @{ Text = 'Repair ATOM'; Icon = 'ResetWrenchIcon'; Enabled = $true; ToolTip = 'Replace missing or modified ATOM-owned files' }
    Retry      = @{ Text = 'Retry Update Check'; Icon = 'RefreshIcon'; Enabled = $true; ToolTip = 'Retry checking the selected channel for updates' }
}
$setUpdateAction = {
    param ([Parameter(Mandatory)][String]$State)

    $actionState = $updateActionStates[$State]
    if (!$actionState) { throw "Unknown update action state '$State'." }

    $updateActionButton.Tag = $State
    $updateActionButton.IsEnabled = $actionState.Enabled
    $updateActionButton.Opacity = if ($actionState.Enabled) { 1.0 } else { 0.44 }
    $updateActionButton.ToolTip = $actionState.ToolTip
    $updateActionText.Text = $actionState.Text
    $updateActionImage.Content = $window.FindResource($actionState.Icon)
}
& $setUpdateAction 'Check'

Update-AtomUpdateContext
$updateChannelSelector.SelectedValue = $script:atomSettings['UpdateChannel']['Value']

$updateActionButton.Add_Click({
    switch ($this.Tag) {
        { $_ -in 'Check', 'CheckAgain', 'Retry' } { Test-AtomUpdate }
        { $_ -in 'Update', 'Synchronize', 'Repair' } { Start-AtomUpdate }
    }
})

$healthCheckButton.Add_Click({ Test-AtomInstallationHealth })

$updateChannelSelector.Add_SelectionChanged({
    if (!$this.SelectedValue) { return }

    $script:atomSettings['UpdateChannel']['Value'] = [String]$this.SelectedValue
    Update-AtomUpdateContext
    & $setUpdateAction 'Check'
    $updateText.Text = "Not checked for '$($script:updateBranch)'"
    $healthCheckText.Text = ''
    $healthCheckText.Visibility = 'Collapsed'

    if (!$script:restoringDefaults) { Save-AtomSettings }
})

##################
##  Path panel  ##
##################

$pathButton = $window.FindName('pathButton')
$pathButton.Add_Click({ Start-Process explorer $atomPath })

####################
##  Github panel  ##
####################

$atomUrl = "https://github.com/SkylerWallace/ATOM"

$githubButton = $window.FindName('githubButton')
$githubButton.Add_Click({ Start-Process $atomUrl })

$githubTextBox = $window.FindName('githubTextBox')
$githubTextBox.Text = $atomUrl
$githubTextBox.ToolTip = $atomUrl

###################
##  Theme panel  ##
###################

$themeSelectorButton = $window.FindName('themeSelectorButton')
$themeSelectorText = $window.FindName('themeSelectorText')
$themeSelectorIndicator = $window.FindName('themeSelectorIndicator')
$themePanel = $window.FindName('themePanel')
$uiScalingSlider = $window.FindName('uiScalingSlider')
$uiScalingValueText = $window.FindName('uiScalingValueText')

$uiScalingSlider.Value = [Double]$atomSettings.UIScaling.Value
Set-AtomUiScaling -Scale $uiScalingSlider.Value
$uiScalingSlider.Add_PreviewMouseLeftButtonDown({
    $script:uiScalingDragActive = $true
})
$completeUiScalingDrag = {
    if (!$script:uiScalingDragActive) { return }

    $script:uiScalingDragActive = $false
    Set-AtomUiScaling -Scale $script:atomSettings.UIScaling.Value
    Save-AtomSettings
}
$uiScalingSlider.Add_PreviewMouseLeftButtonUp($completeUiScalingDrag)
$uiScalingSlider.Add_LostMouseCapture($completeUiScalingDrag)
$uiScalingSlider.Add_ValueChanged({
    $script:atomSettings.UIScaling.Value = [Math]::Round($this.Value * 8) / 8
    if ($script:uiScalingDragActive) {
        $uiScalingValueText.Text = '{0:0.0##}x' -f $script:atomSettings.UIScaling.Value
        return
    }

    Set-AtomUiScaling -Scale $script:atomSettings.UIScaling.Value
    if (!$script:restoringDefaults) { Save-AtomSettings }
})

$themeSwatches = @{
    primaryBrush = $window.FindName('themePrimarySwatch')
    backgroundBrush = $window.FindName('themeBackgroundSwatch')
    surfaceBrush = $window.FindName('themeSurfaceSwatch')
    accentBrush = $window.FindName('themeAccentSwatch')
}

$themeSelectorButton.Add_Click({
    Set-AtomThemeSelectorExpanded ($themePanel.Visibility -ne [System.Windows.Visibility]::Visible)
})

Update-AtomThemeSelector
Set-AtomThemeSelectorExpanded $false
foreach ($theme in $themes.GetEnumerator() | Sort-Object Key) {
    $button = New-Object System.Windows.Controls.Button
    $button.Width = 75
    $button.Margin = 2.5
    $button.Tag = $theme.Name, $theme.Value
    $button.Background = "Transparent"
    $button.Style = $window.Resources["RoundedButton"]
    $button.Add_Click({
        # Save theme
        $script:atomSettings.Theme.Value = $this.Tag[0]
        Save-AtomSettings

        # Update variables
        foreach ($key in $this.Tag[1].Keys) {
            New-Variable -Name $key -Value $this.Tag[1].$key -Scope Script -Force
        }
        $controlBrush = if ($this.Tag[1].Contains('controlBrush')) { $this.Tag[1].controlBrush } else { $this.Tag[1].primaryBrush }
        New-Variable -Name controlBrush -Value $controlBrush -Scope Script -Force
        $controlText = if ($this.Tag[1].Contains('controlText')) { $this.Tag[1].controlText } else { $this.Tag[1].primaryText }
        New-Variable -Name controlText -Value $controlText -Scope Script -Force
        Get-AtomThemeShadowResources -Theme $this.Tag[1] -Defaults $themeShadowDefaults | ForEach-Object {
            $_.GetEnumerator() | ForEach-Object {
                New-Variable -Name $_.Key -Value $_.Value -Scope Script -Force
            }
        }

        # Update resources dynamically based on their type
        foreach ($resName in $window.Resources.Keys) {
            # Check if the resource key matches a global variable
            if (Get-Variable -Name $resName -Scope Script -ErrorAction SilentlyContinue) {
                $globalValue = (Get-Variable -Name $resName -Scope Script).Value

                # Determine the type of the resource and update accordingly
                $resource = $window.Resources[$resName]
                if ($resource -is [System.Windows.Media.SolidColorBrush]) {
                    $window.Resources[$resName] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($globalValue))
                } elseif ($resource -is [System.Windows.Media.Color]) {
                    $window.Resources[$resName] = [System.Windows.Media.ColorConverter]::ConvertFromString($globalValue)
                } elseif ($resource -is [Double]) {
                    $window.Resources[$resName] = [Double]$globalValue
                }
            }
        }

        $window.Resources["gradientStrength"] = $gradientStrength
        Set-AtomThemeGradient -Window $window -Theme $this.Tag[1] -Defaults $themeGradientDefaults

        Update-AtomThemeSelector
    })

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Margin = "2.5,2.5,2.5,0"
    $textBlock.FontSize = 11
    $textBlock.Text = $theme.Name
    $textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "surfaceText")
    $textBlock.Background = "Transparent"
    $textBlock.TextAlignment = "Center"
    $textBlock.TextWrapping = "Wrap"

    $border1 = New-Object System.Windows.Controls.Border
    $border1.Width = 12; $border1.Height = 12
    $border1.Margin = 1
    $border1.CornerRadius = "5,0,0,5"
    $border1.Background = $theme.Value.primaryBrush

    $border2 = New-Object System.Windows.Controls.Border
    $border2.Width = 12; $border2.Height = 12
    $border2.Margin = 1
    $border2.Background = $theme.Value.backgroundBrush

    $border3 = New-Object System.Windows.Controls.Border
    $border3.Width = 12; $border3.Height = 12
    $border3.Margin = 1
    $border3.Background = $theme.Value.surfaceBrush

    $border4 = New-Object System.Windows.Controls.Border
    $border4.Width = 12; $border4.Height = 12
    $border4.Margin = 1
    $border4.CornerRadius = "0,5,5,0"
    $border4.Background = $theme.Value.accentBrush

    $borderStackPanel = New-Object System.Windows.Controls.StackPanel
    $borderStackPanel.Orientation = "Horizontal"
    $borderStackPanel.HorizontalAlignment = "Center"
    $borderStackPanel.Margin = 2.5
    $borderStackPanel.AddChild($border1)
    $borderStackPanel.AddChild($border2)
    $borderStackPanel.AddChild($border3)
    $borderStackPanel.AddChild($border4)

    $stackPanel = New-Object System.Windows.Controls.StackPanel
    $stackPanel.AddChild($textBlock)
    $stackPanel.AddChild($borderStackPanel)
    $button.Content = $stackPanel

    $themePanel = $window.FindName('themePanel')
    $themePanel.AddChild($button)
}

####################
##  Toggle panel  ##
####################

$settingsPanels = [ordered]@{
    General = $window.FindName('generalSettingsPanel')
    Plugins = $window.FindName('pluginSettingsPanel')
    Quips   = $window.FindName('quipSettingsPanel')
}
$settingsRowMinHeight = 28

# Default settings button
$defaultSwitchButton = $window.FindName('defaultSwitchButton')
$defaultSwitchButton.Add_Click({
    $confirmationText = @(
        'Restore all eligible settings to their defaults?'
        ''
        'Your update channel will be preserved.'
    ) -join [Environment]::NewLine
    $confirmation = [Windows.MessageBox]::Show(
        $window,
        $confirmationText,
        'Restore Default Settings',
        [Windows.MessageBoxButton]::YesNo,
        [Windows.MessageBoxImage]::Question
    )
    if ($confirmation -ne [Windows.MessageBoxResult]::Yes) { return }

    $defaultSettings = & {
        . "$configPath\Settings.ps1"
        $atomSettings
    }

    foreach ($defaultSettingName in $defaultSettings.Keys) {
        if ($defaultSettings[$defaultSettingName].RestoreDefault -eq $false) { continue }
        $script:atomSettings[$defaultSettingName].Value = $defaultSettings[$defaultSettingName].Value
    }

    # Update controls without saving once per changed control.
    $script:restoringDefaults = $true
    try {
        $uiScalingSlider.Value = [Double]$script:atomSettings.UIScaling.Value
        $settingsPanels.Values.Children | Where-Object { $_ -is [System.Windows.Controls.ListBoxItem] } | ForEach-Object {
            $listBoxItem = $_

            if ($listBoxItem.Control -is [System.Windows.Controls.Primitives.ToggleButton]) {
                $settingName = $listBoxItem.Control.Tag
                $listBoxItem.Control.IsChecked = [bool]$script:atomSettings[$settingName].Value
            } elseif ($listBoxItem.Control -is [System.Windows.Controls.ComboBox]) {
                $settingName = $listBoxItem.Control.Tag
                $listBoxItem.Control.SelectedValue = $script:atomSettings[$settingName].Value
            }
        }
    } finally {
        $script:restoringDefaults = $false
    }

    # Save settings
    $script:pluginListDirty = $true
    Save-AtomSettings
})

$atomShortcuts = @(
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Down)
        GestureText = 'Down'
        Description = 'Focus search result'
        ToolTipTarget = $null
        CanExecute = { $searchTextBox.IsKeyboardFocusWithin -and @(Get-AtomVisiblePluginItems).Count }
        Action = { Set-AtomFocusedPluginItem -Item (Get-AtomVisiblePluginItems)[0] }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Enter)
        GestureText = 'Enter'
        Description = 'Open the only search result'
        ToolTipTarget = $null
        CanExecute = { $searchTextBox.IsKeyboardFocusWithin -and !$script:downloadMode -and @(Get-AtomVisiblePluginItems).Count -eq 1 }
        Action = { Invoke-AtomSingleSearchResult }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Enter)
        GestureText = 'Enter'
        Description = 'Open plugin'
        ToolTipTarget = $null
        CanExecute = { !$script:downloadMode -and $null -ne (Get-AtomFocusedPluginItem) }
        Action = { Invoke-AtomPlugin -Plugin (Get-AtomFocusedPluginItem).Tag }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Space)
        GestureText = 'Space'
        Description = 'Favorite or select plugin'
        ToolTipTarget = $null
        CanExecute = { $null -ne (Get-AtomFocusedPluginItem) }
        Action = { Toggle-AtomFocusedPlugin }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Enter, [Windows.Input.ModifierKeys]::Alt)
        GestureText = 'Alt+Enter'
        Description = 'Plugin properties'
        ToolTipTarget = $null
        CanExecute = { !$script:downloadMode -and $null -ne (Get-AtomFocusedPluginItem) }
        Action = { Show-AtomPluginProperties -Plugin (Get-AtomFocusedPluginItem).Tag }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::F10, [Windows.Input.ModifierKeys]::Shift)
        GestureText = 'Shift+F10'
        Description = 'Plugin menu'
        ToolTipTarget = $null
        CanExecute = { $null -ne (Get-AtomFocusedPluginItem) }
        Action = { Open-AtomPluginContextMenu }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Apps)
        GestureText = 'Menu'
        Description = 'Plugin menu'
        ToolTipTarget = $null
        CanExecute = { $null -ne (Get-AtomFocusedPluginItem) }
        Action = { Open-AtomPluginContextMenu }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::A, [Windows.Input.ModifierKeys]::Control)
        GestureText = 'Ctrl+A'
        Description = 'Select all downloads'
        ToolTipTarget = $null
        CanExecute = { $script:downloadMode -and $null -ne (Get-AtomFocusedPluginItem) }
        Action = { Select-AllAtomDownloads }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::F, [Windows.Input.ModifierKeys]::Control)
        GestureText = 'Ctrl+F'
        Description = 'Search plugins'
        ToolTipTarget = $searchTextBox
        CanExecute = { $true }
        Action = { Focus-AtomSearch }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::F5)
        GestureText = 'F5'
        Description = 'Reload plugins'
        ToolTipTarget = $refreshButton
        CanExecute = { $refreshButton.IsEnabled }
        Action = { Invoke-AtomPluginRefresh }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::OemComma, [Windows.Input.ModifierKeys]::Control)
        GestureText = 'Ctrl+,'
        Description = 'Settings'
        ToolTipTarget = $settingsButton
        CanExecute = { $script:activePage -ne 'Settings' }
        Action = { Set-AtomPage -Page Settings }
    }
    [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Windows.Input.Key]::Left, [Windows.Input.ModifierKeys]::Alt)
        GestureText = 'Alt+Left'
        Description = 'Back to plugins'
        ToolTipTarget = $pluginsButton
        CanExecute = { $script:activePage -ne 'Plugins' }
        Action = { Set-AtomPage -Page Plugins }
    }
)

foreach ($direction in 'Left', 'Right', 'Up', 'Down', 'Home', 'End') {
    $atomShortcuts += [PSCustomObject]@{
        Gesture = [Windows.Input.KeyGesture]::new([Enum]::Parse([Windows.Input.Key], $direction))
        GestureText = $direction
        Description = 'Navigate plugins'
        ToolTipTarget = $null
        CanExecute = { $null -ne (Get-AtomFocusedPluginItem) }.GetNewClosure()
        Action = { Move-AtomPluginFocus -Direction $direction }.GetNewClosure()
    }
}

foreach ($shortcut in $atomShortcuts) {
    if ($shortcut.ToolTipTarget) {
        $shortcut.ToolTipTarget.ToolTip = "$($shortcut.Description) ($($shortcut.GestureText))"
    }
}

$window.Add_PreviewKeyDown({
    param($sender, $eventArgs)

    if (
        [Windows.Input.Keyboard]::Modifiers -eq [Windows.Input.ModifierKeys]::None -and
        $eventArgs.Key -eq [Windows.Input.Key]::Escape
    ) {
        if (Invoke-AtomEscapeAction) { $eventArgs.Handled = $true }
        return
    }

    $pressedKey = if ($eventArgs.Key -eq [Windows.Input.Key]::System) { $eventArgs.SystemKey } else { $eventArgs.Key }
    $pressedModifiers = [Windows.Input.Keyboard]::Modifiers
    foreach ($shortcut in $atomShortcuts) {
        if (
            $shortcut.Gesture.Key -eq $pressedKey -and
            $shortcut.Gesture.Modifiers -eq $pressedModifiers -and
            (& $shortcut.CanExecute)
        ) {
            & $shortcut.Action
            $eventArgs.Handled = $true
            return
        }
    }
})

$window.Add_ContentRendered({
    if ($window.Tag.DownloadManifestSyncStarted) { return }
    $window.Tag.DownloadManifestSyncStarted = $true

    $window.Dispatcher.BeginInvoke([Action]{
        Invoke-Runspace -Isolated -InputVariables @{
            FunctionsPath = $functionsPath
            ManifestPrograms = $script:programs
            ProgramsPath = $programsPath
        } -ScriptBlock {
            . (Join-Path $FunctionsPath 'Import-Atom.ps1') -Function Sync-DownloadManifest
            Sync-DownloadManifest -Programs $ManifestPrograms | Out-Null
        }
    }, [Windows.Threading.DispatcherPriority]::ApplicationIdle) | Out-Null

    $window.Dispatcher.BeginInvoke(
        [Action]{ Initialize-AtomSettingsControls },
        [Windows.Threading.DispatcherPriority]::ApplicationIdle
    ) | Out-Null
})

try {
    $window.ShowDialog() | Out-Null
}
catch {
    Write-Host "`n========== SHOWDIALOG EXCEPTION ==========" -ForegroundColor Red

    $exception = $_.Exception
    $level = 0

    while ($exception) {
        Write-Host "`n--- Exception level $level ---" -ForegroundColor Yellow
        Write-Host "Type: $($exception.GetType().FullName)"
        Write-Host "Message: $($exception.Message)"
        Write-Host "`n$($exception.ToString())"

        $exception = $exception.InnerException
        $level++
    }

    Write-Host "`nPowerShell error:" -ForegroundColor Yellow
    Write-Host ($_ | Format-List * -Force | Out-String)

    Write-Host "`nScript stack:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace

    Write-Host "==========================================" -ForegroundColor Red
    Read-Host
}
