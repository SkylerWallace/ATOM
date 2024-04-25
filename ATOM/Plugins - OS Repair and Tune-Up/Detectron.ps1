# Launch: Hidden

Add-Type -AssemblyName PresentationFramework

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$atomPath = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$programIcons = Join-Path $iconsPath "Plugins"
$detectronDependencies = Join-Path $dependenciesPath "Detectron"
$detectronFunctions = Join-Path $detectronDependencies "Functions"
$detectronOptimizations = Join-Path $detectronDependencies "Optimizations"
$detectronPanels = Join-Path $detectronDependencies "Panels"
$detectronPrograms = Join-Path $detectronDependencies "Programs"

# Import custom window resources and color theming
$dictionaryPath = Join-Path $dependenciesPath "ResourceDictionary.ps1"
. $dictionaryPath

# Import runspace function
$runspacePath = Join-Path $dependenciesPath "Create-Runspace.ps1"
. $runspacePath

[xml]$xaml = @"
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
				<Image Name="logo" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,10,0,5"/>
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
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign variables to elements in XAML
$logo = $window.FindName("logo")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")
$runButton = $window.Findname('runButton')
$uninstallPanel = $window.FindName('uninstallPanel')
$outputBox = $window.FindName('outputBox')

$logo.Source = Join-Path $iconsPath "Plugins\Detectron.png"

# Set icon sources
$primaryResources = @{
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

$surfaceResources = @{
	"checkedImage" = "Checkbox - Checked"
	"uncheckedImage" = "Checkbox - Unchecked"
}

Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources
Set-ResourceIcons -iconCategory "Surface" -resourceMappings $surfaceResources

# Browser notifications
$panelNotifications = Join-Path $detectronPanels "Panel-Notifications.ps1"
. $panelNotifications

# Construct optimizations panel
$panelOptimizations = Join-Path $detectronPanels "Panel-Optimizations.ps1"
. $panelOptimizations

# Construct uninstallers panel
$panelPrograms = Join-Path $detectronPanels "Panel-Programs.ps1"
. $panelPrograms

# Construct apps panel
$panelApps = Join-Path $detectronPanels "Panel-Apps.ps1"
. $panelApps

0..1 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
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
	$scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
	
	$selectedScripts = ($optimizationsItems | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag }) -join ";"
	$selectedPrograms = $listBoxes.Values | ForEach-Object { $_.Items } | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }
	$selectedApps = $appxListBox.Items | Where-Object { $_.IsChecked } | ForEach-Object { $_.Tag }

	Create-RunSpace -ScriptBlock {
		$runButton.Dispatcher.Invoke([action]{ $runButton.Content = "Running..."; $runButton.IsEnabled = $false }, "Render")
		
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
		
		# Save Detectron log
		$atomTemp = Join-Path $env:TEMP "ATOM Temp"
		if (!(Test-Path $atomTemp)) {
			New-Item -Path $atomTemp -ItemType Directory -Force
		}
		
		try {
			$outputText = $outputBox.Dispatcher.Invoke([Func[string]]{ $outputBox.Text })
			$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
			
			$logPath = Join-Path $atomTemp "detectron-$dateTime.txt"
			$outputText | Out-File -FilePath $logPath
			Write-OutputBox "Log saved to $logPath"
		} catch {
			Write-OutputBox "Failed to save log"
		}
		
		Write-OutputBox "`nDetectron finished."
		
		$runButton.Dispatcher.Invoke([action]{ $runButton.Content = "Run"; $runButton.IsEnabled = $true }, "Render")
	}
})

# Finds the resolution of the primary display and the display scaling setting
# If the "effective" resolution will cause Neutron's window to clip, it will decrease the window size
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Display
{
	[DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
	[DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
	public static int GetScreenHeight() { return GetDeviceCaps(GetDC(IntPtr.Zero), 10); }
	public static int GetScalingFactor() { return GetDeviceCaps(GetDC(IntPtr.Zero), 88); }
}
"@

$scalingDecimal = [Display]::GetScalingFactor()/ 96
$effectiveVertRes = ([double][Display]::GetScreenHeight()/ $scalingDecimal)
if ($effectiveVertRes -le (1.0 * $window.MaxHeight)) {
	$window.MinHeight = 0.6 * $effectiveVertRes
	$window.MaxHeight = 0.9 * $effectiveVertRes
}

$window.ShowDialog() | Out-Null