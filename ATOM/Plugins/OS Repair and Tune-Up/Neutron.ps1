Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\..\Functions\AtomModule.psm1"
Import-Module "$psScriptRoot\..\..\Functions\AtomWpfModule.psm1"
$neutronDependencies = "$dependenciesPath\Neutron"
$programIcons        = "$neutronDependencies\Icons"
$neutronShortcuts    = "$neutronDependencies\Shortcuts"
$neutronPanels       = "$neutronDependencies\Panels"
$hashtable           = "$neutronDependencies\Programs.ps1"

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Neutron"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    Width="800" Height="800"
    MinWidth="800" MinHeight="600"
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
                <Image Width="40" Height="40" Source="$resourcesPath\Icons\Plugins\Neutron.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
                <Image Width="130" Height="130" Source="$neutronDependencies\Neutron.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="60,5,0,0"/>
                <Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
                <Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
            </Grid>
            
            <Grid Grid.Row="1" Margin="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <ScrollViewer Name="scrollViewer0" Grid.Column="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                    <StackPanel Margin="10,10,10,0">
                        <Label Content="Customizations" Foreground="{DynamicResource surfaceText}" FontWeight="Bold"/>
                        <Border Style="{StaticResource CustomBorder}">
                            <ListBox Name="customizationPanel" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderThickness="0" Padding="5"/>
                        </Border>
                        <Label Content="Timezone" Foreground="{DynamicResource surfaceText}" FontWeight="Bold" Margin="0,5,0,0"/>
                        <Border Style="{StaticResource CustomBorder}" Padding="5">
                            <StackPanel Name="timezonePanel"/>
                        </Border>
                        <Label Content="Shortcuts" Foreground="{DynamicResource surfaceText}" FontWeight="Bold" Margin="0,5,0,0"/>
                        <StackPanel Name="shortcutPanel"/>
                    </StackPanel>
                </ScrollViewer>
                
                <Grid Grid.Column="1">
                    <ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                        <StackPanel>
                            <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="0,70,10,5" Padding="5">
                                <StackPanel>
                                    <TextBlock Text="Install Methods" FontWeight="Bold" Foreground="{DynamicResource surfaceText}" TextAlignment="Center" VerticalAlignment="Center" Margin="5"/>
                                    
                                    <WrapPanel Orientation="Horizontal" HorizontalAlignment="Center">
                                        <CheckBox Name="wingetCheckBox" Content="Winget" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget [Priority-1]&#x0a;[Package Manager] [Very safe]"/>
                                        <CheckBox Name="chocoCheckBox" Content="Choco" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ Chocolatey [Priority-2]&#x0a;[Package Manager] [Safe]"/>
                                        <CheckBox Name="scoopCheckBox" Content="Scoop" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ Scoop [Priority-3]&#x0a;[Package Manager] [Safe] [BETA]"/>
                                        <CheckBox Name="wingetAltCheckBox" Content="Winget alt" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget's 'Installer Url' [Priority-4]&#x0a;[URL] [Winget] [No Hash Validation]"/>
                                        <CheckBox Name="urlCheckBox" Content="URL" Foreground="{DynamicResource surfaceText}" IsChecked="True" Margin="5" ToolTip="Download w/ direct URL [Priority-5]&#x0a;[URL] [Vendor Site]"/>
                                        <CheckBox Name="mirrorCheckBox" Content="Mirror" Foreground="{DynamicResource surfaceText}" IsChecked="False" Margin="5" ToolTip="Download w/ mirror URL [Priority-6]&#x0a;[URL] [Mirror Site]"/>
                                    </WrapPanel>
                                </StackPanel>
                            </Border>
                            
                            <StackPanel Name="installPanel" Margin="0,0,10,5"/>
                        </StackPanel>
                    </ScrollViewer>
                    
                    <Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="0,10,28,5" Padding="5">
                        <Grid Height="Auto">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            
                            <Button Name="backspaceButton" Grid.Column="0" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
                            <TextBlock Name="searchTextBlock" Grid.Column="1" Text="Search programs" Foreground="{DynamicResource surfaceText}" TextAlignment="Left" VerticalAlignment="Center" Opacity="0.69" Margin="5"/>
                            <TextBox Name="searchTextBox" Grid.Column="1" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Left" VerticalAlignment="Center" Margin="5"/>
                            <Image Name="searchImage" Grid.Column="2" Width="16" Height="16" Margin="5"/>
                        </Grid>
                    </Border>
                </Grid>
                
                <Border Grid.Column="2" Style="{StaticResource CustomBorder}" Margin="0,10,10,10">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="30"/>
                        </Grid.RowDefinitions>
                        
                        <ScrollViewer Name="scrollViewer2" Grid.Row="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                            <TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
                        </ScrollViewer>
                        
                        <ProgressBar Name="progressBar" Grid.Row="1" Margin="10,0,10,10"/>
                        <TextBlock Name="progressBarText" Grid.Row="1" Foreground="{DynamicResource primaryText}" TextAlignment="Center" VerticalAlignment="Center" FontSize="10" Margin="10,0,10,10"/>
                    </Grid>
                </Border>
            </Grid>
            
            <Grid Grid.Row="2">
                <Button Name="runButton" Content="Run" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10,0,10,10" Style="{StaticResource RoundedButton}"/>
            </Grid>
            
        </Grid>
    </Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$minimizeButton     = $window.FindName('minimizeButton')
$closeButton        = $window.FindName('closeButton')
$runButton          = $window.Findname('runButton')
$customizationPanel = $window.FindName('customizationPanel')
$timezonePanel      = $window.FindName('timezonePanel')
$shortcutPanel      = $window.FindName('shortcutPanel')
$installPanel       = $window.FindName('installPanel')
$searchTextBlock    = $window.FindName('searchTextBlock')
$searchTextBox      = $window.FindName('searchTextBox')
$wingetCheckBox     = $window.FindName('wingetCheckBox')
$chocoCheckBox      = $window.FindName('chocoCheckBox')
$scoopCheckBox      = $window.FindName('scoopCheckBox')
$wingetAltCheckBox  = $window.FindName('wingetAltCheckBox')
$urlCheckBox        = $window.FindName('urlCheckBox')
$mirrorCheckBox     = $window.FindName('mirrorCheckBox')
$outputBox          = $window.FindName('outputBox')
$progressBar        = $window.FindName('progressBar')
$progressBarText    = $window.FindName('progressBarText')

# Set icon sources
$primaryResources = @{
    "minimizeButton" = "Minimize"
    "closeButton" = "Close"
}

$surfaceResources = @{
    "checkedImage" = "Checkbox - Checked"
    "uncheckedImage" = "Checkbox - Unchecked"
    "backspaceButton" = "Backspace"
    "searchImage" = "Browse"
}

Set-ResourcePath -ColorRole Primary -ResourceMappings $primaryResources
Set-ResourcePath -ColorRole Surface -ResourceMappings $surfaceResources

# Construct panels
. $neutronPanels\Panel-Customizations.ps1
. $neutronPanels\Panel-Timezones.ps1
. $neutronPanels\Panel-Shortcuts.ps1
. $neutronPanels\Panel-Programs.ps1

0..2 | ForEach-Object { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

$runButton.Tooltip = "- Perform selected customizations `n- Set selected timezone`n- Install selected programs"
$runButton.Add_Click({
    $script:scrollToEnd = $window.FindName("scrollViewer2").ScrollToEnd()
    
    Invoke-Runspace -ScriptBlock {
        # Disable run button while runspace is running
        Invoke-Ui { $runButton.Content = "Running..."; $runButton.IsEnabled = $false }

        # Import functions into runspace
        'Get-FileFromUrl', 'Install-Choco', 'Install-Program', 'Install-Scoop', 'Install-Winget' | ForEach-Object {
            . "$functionsPath\$_.ps1"
        }
        
        # Run Customizations
        if ($selectedScripts -ne $null) {
            Write-Host "Customizations:"
            foreach ($script in $selectedScripts) { Invoke-Expression $script }
            Write-Host ""
        }
        
        # Set Timezone
        if ($checkedTimezone) {
            Write-Host "Timezone"

            try {
                Start-Service w32time
                w32tm /resync
                Write-Host "- Time synchronized"
            } catch {
                Write-Host "- Failed to sync time"
            }
        }
        
        # Install package managers
        if ($selectedPrograms -ne $null) {
            switch ($true) {
                $useWinget { Install-Winget }
                $useChoco  { Install-Choco }
                $useScoop  { Install-Scoop }
            }
        }

        # Install selected programs
        foreach ($program in $selectedPrograms.Keys) {
            $params = $selectedPrograms.$program

            Write-Host $program

            if ($useWinget -and $params.Winget -and (Install-Program -FilePath 'winget' -ArgumentList "install --id $($params.Winget) --accept-package-agreements --accept-source-agreements --force" -Description 'Winget')) { continue }
            if ($useChoco -and $params.Choco -and (Install-Program -FilePath 'choco' -ArgumentList "install $($params.Choco) -y" -Description 'Choco')) { continue }
            if ($useScoop -and $params.Scoop -and (Install-Program -FilePath 'powershell' -ArgumentList "scoop install $($params.Scoop)" -Description 'Scoop')) { continue }
            if ($useWingetAlt -and $params.Winget -and (Install-Program -Url (winget show $params.Winget | Select-String "Installer Url").Line.Replace("Installer Url: ", "").Trim() -Description 'Winget URL')) { continue }
            if ($useUrl -and $params.Url -and (Install-Program -Url $params.Url -Description 'URL')) { continue }
            if ($useMirror -and $params.Mirror -and (Install-Program -Url $params.Mirror -Description 'Mirror')) { continue }
        }
        
        # Uncheck customizations checkboxes
        Invoke-Ui {
            foreach ($item in $customizationPanel.Items) {
                if ($item.IsChecked) {
                    $item.IsChecked = $false
                    $item.IsEnabled = $false
                    $item.Opacity = 0.44
                }
            }
        }
        
        # Uncheck programs checkboxes
        Invoke-Ui {
            foreach ($item in $installPanel.Children.Items.Content.Children) {
                if ($item -is [System.Windows.Controls.CheckBox]) {
                    $item.IsChecked = $false
                }
            }
        }
        
        # Save log
        $outputText = Invoke-Ui -GetValue { $outputBox.Text }
        $dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
        $logPath = Join-Path $atomTemp "neutron-$dateTime.txt"
        $outputText | Out-File -FilePath $logPath
        Write-Host "`nLog saved to $logPath"
        
        # Success message
        Write-Host "`nNeutron completed."
        
        # Re-enable run button
        Invoke-Ui { $runButton.Content = "Run"; $runButton.IsEnabled = $true }
    }
})

Set-WindowSize

$window.ShowDialog() | Out-Null