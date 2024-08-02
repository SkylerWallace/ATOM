Add-Type -AssemblyName PresentationFramework

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$neutronDependencies = Join-Path $dependenciesPath "Neutron"
$programIcons = Join-Path $neutronDependencies "Icons"
$neutronShortcuts = Join-Path $neutronDependencies "Shortcuts"
$neutronPanels = Join-Path $neutronDependencies "Panels"
$neutronFunctions = Join-Path $neutronDependencies "Functions"
$hashtable = Join-Path $neutronDependencies "Programs.ps1"

# Import ATOM core resources
. (Join-Path $dependenciesPath "ATOM-Module.ps1")

[xml]$xaml = @"
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
				<Image Name="logo1" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
				<Image Name="logo2" Width="130" Height="130" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="60,5,0,0"/>
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
										<CheckBox Name="wingetCheckBox" Content="Winget" Foreground="{DynamicResource surfaceText}" Style="{StaticResource CustomCheckBoxStyle}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget [Priority-1]&#x0a;[Package Manager] [Very safe]"/>
										<CheckBox Name="chocoCheckBox" Content="Choco" Foreground="{DynamicResource surfaceText}" Style="{StaticResource CustomCheckBoxStyle}" IsChecked="False" Margin="5" ToolTip="Download w/ Chocolatey [Priority-2]&#x0a;[Package Manager] [Safe]"/>
										<CheckBox Name="scoopCheckBox" Content="Scoop" Foreground="{DynamicResource surfaceText}" Style="{StaticResource CustomCheckBoxStyle}" IsChecked="False" Margin="5" ToolTip="Download w/ Scoop [Priority-3]&#x0a;[Package Manager] [Safe] [BETA]"/>
										<CheckBox Name="wingetAltCheckBox" Content="Winget alt" Foreground="{DynamicResource surfaceText}" Style="{StaticResource CustomCheckBoxStyle}" IsChecked="True" Margin="5" ToolTip="Download w/ Winget's 'Installer Url' [Priority-4]&#x0a;[URL] [Winget] [No Hash Validation]"/>
										<CheckBox Name="urlCheckBox" Content="URL" Foreground="{DynamicResource surfaceText}" Style="{StaticResource CustomCheckBoxStyle}" IsChecked="True" Margin="5" ToolTip="Download w/ direct URL [Priority-5]&#x0a;[URL] [Vendor Site]"/>
										<CheckBox Name="mirrorCheckBox" Content="Mirror" Foreground="{DynamicResource surfaceText}" Style="{StaticResource CustomCheckBoxStyle}" IsChecked="False" Margin="5" ToolTip="Download w/ mirror URL [Priority-6]&#x0a;[URL] [Mirror Site]"/>
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
						
						<ProgressBar Name="progressBar" Grid.Row="1" Foreground="{DynamicResource surfaceHighlight}" Background="Transparent" BorderBrush="Transparent" Value="0" Opacity="0.36" Margin="10,0,10,10"/>
						<TextBlock Name="progressBarText" Grid.Row="1" Foreground="{DynamicResource surfaceText}" TextAlignment="Center" VerticalAlignment="Center" FontSize="10" Margin="10,0,10,10"/>
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
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign variables to elements in XAML
$logo1 = $window.FindName("logo1")
$logo2 = $window.FindName("logo2")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")
$runButton = $window.Findname("runButton")
$customizationPanel = $window.FindName("customizationPanel")
$timezonePanel = $window.FindName("timezonePanel")
$shortcutPanel = $window.FindName("shortcutPanel")
$installPanel = $window.FindName("installPanel")
$searchTextBlock = $window.FindName("searchTextBlock")
$searchTextBox = $window.FindName("searchTextBox")
$wingetCheckBox = $window.FindName("wingetCheckBox")
$chocoCheckBox = $window.FindName("chocoCheckBox")
$scoopCheckBox = $window.FindName("scoopCheckBox")
$wingetAltCheckBox = $window.FindName("wingetAltCheckBox")
$urlCheckBox = $window.FindName("urlCheckBox")
$mirrorCheckBox = $window.FindName("mirrorCheckBox")
$outputBox = $window.FindName("outputBox")
$progressBar = $window.FindName("progressBar")
$progressBarText = $window.FindName("progressBarText")

$logo1.Source = Join-Path $iconsPath "Plugins\Neutron.png"
$logo2.Source = Join-Path $iconsPath "Neutron.png"

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

Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $primaryResources
Set-ResourceIcons -IconCategory "Surface" -ResourceMappings $surfaceResources

# Construct panels
. (Join-Path $neutronPanels "Panel-Customizations.ps1")
. (Join-Path $neutronPanels "Panel-Timezones.ps1")
. (Join-Path $neutronPanels "Panel-Shortcuts.ps1")
. (Join-Path $neutronPanels "Panel-Programs.ps1")

0..2 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

$runButton.Tooltip = "- Perform selected customizations `n- Set selected timezone`n- Install selected programs"
$runButton.Add_Click({
	$scrollToEnd = $window.FindName("scrollViewer2").ScrollToEnd()
	
	# Create ATOM temp directory if not detected
	$atomTemp = Join-Path $env:TEMP "ATOM Temp"
	if (!(Test-Path $atomTemp)) {
		New-Item -Path $atomTemp -ItemType Directory -Force
	}
	
	Create-Runspace -ScriptBlock {
		# Disable run button while runspace is running
		Invoke-Ui { $runButton.Content = "Running..."; $runButton.IsEnabled = $false }
		
		# Import functions into runspace
		Get-ChildItem -Path $neutronFunctions -Filter *.ps1 | ForEach-Object {
			Invoke-Expression -Command (Get-Content $_.FullName | Out-String)
		}
		
		# Run Customizations
		if ($selectedScripts -ne $null) {
			Write-OutputBox "Customizations:"
			foreach ($script in $selectedScripts) { Invoke-Expression $script }
			Write-OutputBox ""
		}
		
		# Set Timezone
		Change-Timezone
		
		# Install Programs
		if ($selectedInstallPrograms -ne $null) {
			Install-Programs -SelectedInstallPrograms $selectedInstallPrograms
		}
		
		# Uncheck checkboxes
		Update-Checkboxes
		
		# Save log
		$outputText = Invoke-Ui -GetValue { $outputBox.Text }
		$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
		$logPath = Join-Path $atomTemp "neutron-$dateTime.txt"
		$outputText | Out-File -FilePath $logPath
		Write-OutputBox "Log saved to $logPath"
		
		# Success message
		Write-OutputBox "`nNeutron completed."
		
		# Re-enable run button
		Invoke-Ui { $runButton.Content = "Run"; $runButton.IsEnabled = $true }
	}
})

Adjust-WindowSize

$window.ShowDialog() | Out-Null