function New-AtomWindow {
    <#
    .SYNOPSIS
        Creates an ATOM-styled WPF window with a standard title bar.

    .DESCRIPTION
        Wraps plugin-specific XAML in the shared ATOM window chrome. The returned
        Window exposes its standard elements through FindName(). Only the title bar
        initiates window dragging, so controls in the content area remain usable.

    .EXAMPLE
        $window = New-AtomWindow -Title 'Example' -ContentXaml '<Grid/>'
        $window.ShowDialog() | Out-Null
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ContentXaml,

        [string]$IconPath,
        [string]$TitleContentXaml,
        [string]$HeaderActionsXaml = '',
        [ValidateRange(200, 10000)]
        [double]$Width = 600,

        [ValidateRange(150, 10000)]
        [double]$Height = 400,

        [ValidateRange(0, 10000)]
        [double]$MinWidth = 400,

        [ValidateRange(0, 10000)]
        [double]$MinHeight = 250,

        [ValidateRange(200, 10000)]
        [double]$MaxWidth = 10000,

        [ValidateRange(150, 10000)]
        [double]$MaxHeight = 10000,

        [ValidateSet('CenterScreen', 'CenterOwner', 'Manual')]
        [string]$WindowStartupLocation = 'CenterScreen',

        [ValidateSet('CanResize', 'CanMinimize', 'NoResize')]
        [string]$ResizeMode = 'CanResize',

        [System.Windows.Window]$Owner,
        [ValidateSet('Manual', 'Width', 'Height', 'WidthAndHeight')]
        [string]$SizeToContent = 'Manual',
        [bool]$Topmost = $false,
        [bool]$ShowInTaskbar = $true,
        [bool]$WireWindowButtons = $true
    )

    if ($MinWidth -gt $Width -or $Width -gt $MaxWidth) {
        throw 'Width must be between MinWidth and MaxWidth.'
    }
    if ($MinHeight -gt $Height -or $Height -gt $MaxHeight) {
        throw 'Height must be between MinHeight and MaxHeight.'
    }

    $escapedTitle = [Security.SecurityElement]::Escape($Title)
    $titleIconXaml = ''
    $windowIconAttribute = ''
    $titleMargin = '14,0'
    if ($IconPath) {
        $resolvedIconPath = Resolve-Path -LiteralPath $IconPath -ErrorAction Stop
        $iconUri = [Uri]::new($resolvedIconPath.Path).AbsoluteUri
        $escapedIconUri = [Security.SecurityElement]::Escape($iconUri)
        $titleIconXaml = '<Image x:Name="atomIcon" Width="30" Height="30" Source="{0}" Stretch="Uniform" Margin="14,0,8,0"/>' -f $escapedIconUri
        $windowIconAttribute = 'Icon="{0}"' -f $escapedIconUri
        $titleMargin = '0'
    }
    $resolvedTitleContentXaml = if ($TitleContentXaml) {
        $TitleContentXaml
    } else {
@"
                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    $titleIconXaml
                    <TextBlock x:Name="atomTitle" Text="$escapedTitle" Foreground="{DynamicResource primaryText}" FontSize="18" FontWeight="Bold" VerticalAlignment="Center" Margin="$titleMargin"/>
                </StackPanel>
"@
    }

    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="atomWindow"
        Title="$escapedTitle"
        $windowIconAttribute
        Background="Transparent"
        AllowsTransparency="True"
        WindowStyle="None"
        WindowStartupLocation="$WindowStartupLocation"
        ResizeMode="$ResizeMode"
        SizeToContent="$SizeToContent"
        Topmost="$Topmost"
        ShowInTaskbar="$ShowInTaskbar"
        Width="$Width"
        Height="$Height"
        MinWidth="$MinWidth"
        MinHeight="$MinHeight"
        MaxWidth="$MaxWidth"
        MaxHeight="$MaxHeight"
        UseLayoutRounding="True"
        RenderOptions.BitmapScalingMode="HighQuality">
    <Window.Resources>
        $resourceDictionary
    </Window.Resources>
    <WindowChrome.WindowChrome>
        <WindowChrome CaptionHeight="0" CornerRadius="{DynamicResource cornerStrength}"/>
    </WindowChrome.WindowChrome>
    <Border x:Name="atomBackground" Background="{DynamicResource backgroundBrush}" CornerRadius="{DynamicResource cornerStrength}">
        <Grid x:Name="atomLayoutRoot" LayoutTransform="{DynamicResource uiScaleTransform}">

            <Grid.RowDefinitions>
                <RowDefinition Height="48"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            <Grid x:Name="atomTitleBar" Grid.Row="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <Border Grid.ColumnSpan="2" Background="{DynamicResource primaryBrush}" CornerRadius="{DynamicResource cornerStrength1}"/>
                $resolvedTitleContentXaml
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="4,0,8,0">
                    $HeaderActionsXaml
                    <Button x:Name="atomMinimizeButton" Width="28" Height="28" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Minimize"/>
                    <Button x:Name="atomCloseButton" Width="28" Height="28" Style="{StaticResource RoundHoverButtonStyle}" Margin="2" ToolTip="Close"/>
                </StackPanel>
            </Grid>
            <Grid x:Name="atomContent" Grid.Row="1">$ContentXaml</Grid>
        </Grid>
    </Border>
</Window>
"@

    try {
        $window = [Windows.Markup.XamlReader]::Parse($xaml)
    } catch {
        throw "Unable to create ATOM window '$Title': $($_.Exception.Message)"
    }

    if ($Owner) { $window.Owner = $Owner }
    Set-AtomThemeGradient -Window $window -Theme $themes[$atomSettings.Theme.Value] -Defaults $themeGradientDefaults

    $titleBar = $window.FindName('atomTitleBar')
    $minimizeButton = $window.FindName('atomMinimizeButton')
    $closeButton = $window.FindName('atomCloseButton')

    $windowForEvents = $window
    $resizeModeForEvents = $ResizeMode
    $titleBar.Add_MouseLeftButtonDown({
        if ($_.ClickCount -eq 2 -and $resizeModeForEvents -eq 'CanResize') {
            $windowForEvents.WindowState = if ($windowForEvents.WindowState -eq 'Maximized') { 'Normal' } else { 'Maximized' }
        } else {
            $windowForEvents.DragMove()
        }
    }.GetNewClosure())
    if ($WireWindowButtons) {
        $minimizeButton.Add_Click({ $windowForEvents.WindowState = 'Minimized' }.GetNewClosure())
        $closeButton.Add_Click({ $windowForEvents.Close() }.GetNewClosure())
    }

    if ($ResizeMode -eq 'NoResize') {
        $minimizeButton.Visibility = 'Collapsed'
    }

    Set-VectorIcon -Window $window -ForegroundResource primaryText -ResourceMappings @{
        atomMinimizeButton = 'MinimizeIcon'
        atomCloseButton = 'CloseIcon'
    }

    return $window
}
