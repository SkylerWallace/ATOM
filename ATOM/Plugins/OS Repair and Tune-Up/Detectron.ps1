Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\..\Functions\AtomModule.psm1"
Import-Module "$psScriptRoot\..\..\Functions\AtomWpfModule.psm1"
$detectronDependencies  = "$dependenciesPath\Detectron"
$detectronFunctions     = "$detectronDependencies\Functions"
$detectronOptimizations = "$detectronDependencies\Optimizations"
$detectronPanels        = "$detectronDependencies\Panels"
$detectronPrograms      = "$detectronDependencies\Programs"

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Detectron"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    Width="600" Height="800"
    MinWidth="400" MinHeight="600"
    MaxWidth="800" MaxHeight="1000"
    UseLayoutRounding="True"
    RenderOptions.BitmapScalingMode="HighQuality">
    
    <Window.Resources>
        $resourceDictionary
    </Window.Resources>
    
    <WindowChrome.WindowChrome>
        <WindowChrome CaptionHeight="0" CornerRadius="10"/>
    </WindowChrome.WindowChrome>
    
    <Border BorderBrush="Transparent" BorderThickness="1" Background="{DynamicResource backgroundBrush}" CornerRadius="5">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="60"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            
            <Grid Grid.Row="0">
                <Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
                <Image Width="40" Height="40" Source="$resourcesPath\Icons\Plugins\Detectron.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,10,0,5"/>
                <TextBlock Text="D E T E C T R O N" Foreground="{DynamicResource primaryText}" FontSize="20" FontWeight="Bold" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="60,10,0,5"/>
                <Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
                <Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
            </Grid>
            
            <Grid Grid.Row="1" Margin="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <ScrollViewer Name="scrollViewer0" Grid.Column="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                    <StackPanel Name="uninstallPanel" Margin="0,10,10,5"/>
                </ScrollViewer>
                
                <Border Grid.Column="1" Style="{StaticResource CustomBorder}" Margin="5,10,10,0">
                    <ScrollViewer Name="scrollViewer1" Grid.Column="1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                        <TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
                    </ScrollViewer>
                </Border>
            </Grid>
            
            <Grid Grid.Row="2">
                <Button Name="runButton" Content="Run" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10" Style="{StaticResource RoundedButton}"/>
            </Grid>
            
        </Grid>
    </Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$minimizeButton = $window.FindName('minimizeButton')
$closeButton    = $window.FindName('closeButton')
$runButton      = $window.Findname('runButton')
$uninstallPanel = $window.FindName('uninstallPanel')
$outputBox      = $window.FindName('outputBox')

# Set icon sources
$primaryResources = @{
    "minimizeButton" = "Minimize"
    "closeButton" = "Close"
}

$surfaceResources = @{
    "checkedImage" = "Checkbox - Checked"
    "uncheckedImage" = "Checkbox - Unchecked"
}

Set-ResourcePath -ColorRole Primary -ResourceMappings $primaryResources
Set-ResourcePath -ColorRole Surface -ResourceMappings $surfaceResources

# Construct panels
. $detectronPanels\Panel-Notifications.ps1
. $detectronPanels\Panel-Optimizations.ps1
. $detectronPanels\Panel-Programs.ps1
. $detectronPanels\Panel-Apps.ps1

0..1 | ForEach-Object { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

# Remove ScreenConnectClient if detected
$netPath = Join-Path $env:localappdata "Apps\2.0"
$files = Get-ChildItem -Path $netPath -Filter "screen*.exe" -Recurse -File -ErrorAction SilentlyContinue
if ($files) { 
    Get-Process | Where-Object { $_.Name -like "screenconnect*" } | Stop-Process -Force
    $files | ForEach-Object { Remove-Item $_.Directory.FullName -Recurse -Force }
    $outputBox.Text = "ScreenConnectClient removed."
}

$runButton.Tooltip = "- Perform selected optimizations `n- Uninstall selected apps"
$runButton.Add_Click({
    $script:scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()

    $script:selectedScripts = ($optimizationsItems | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag }) -join ";"
    $script:selectedPrograms = $listBoxes.Values | ForEach-Object { $_.Items } | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }
    $script:selectedApps = $appxListBox.Items | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }

    Invoke-Runspace -ScriptBlock {
        # Disable update button while runspace is running
        Invoke-Ui { $runButton.Content = "Running..."; $runButton.IsEnabled = $false }
        
        # Import programs and apps hashtables into runspace
        Get-ChildItem -Path $detectronPrograms -Filter *.ps1 | ForEach-Object {
            Invoke-Expression -Command (Get-Content $_.FullName | Out-String)
        }
        
        # Import functions into runspace
        Get-ChildItem -Path $detectronFunctions -Filter *.ps1 | ForEach-Object {
            Invoke-Expression -Command (Get-Content $_.FullName | Out-String)
        }
        
        # Perform checked optimizations
        Perform-Optimizations
        
        # Uninstall checked programs
        Uninstall-Programs
        
        # Uninstall checked apps
        Uninstall-Apps
        
        <#
        # Uncheck checkboxes
        $uninstallPanel.Dispatcher.Invoke([action]{
            foreach ($listBox in $uninstallPanel.Children) {
                if ($listBox -is [System.Windows.Controls.ListBox]) {
                    foreach ($checkBox in $listBox.Items) {
                        if ($checkBox -is [System.Windows.Controls.CheckBox]) {
                            $checkBox.IsChecked = $false
                        }
                    }
                }
            }
        }, "Render")
        #>
        
        # Save log
        $outputText = Invoke-Ui -GetValue { $outputBox.Text }
        $dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $logPath = Join-Path $atomTemp "detectron-$dateTime.txt"
        $outputText | Out-File -FilePath $logPath
        Write-Host "Log saved to $logPath"
        
        # Success message
        Write-Host "`nDetectron finished."
        
        # Re-enable run button
        Invoke-Ui { $runButton.Content = "Run"; $runButton.IsEnabled = $true }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null