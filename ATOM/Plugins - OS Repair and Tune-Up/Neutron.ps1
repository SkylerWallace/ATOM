# Launch: Hidden

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing

$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$neutronDependencies = Join-Path $dependenciesPath "Neutron"
$programIcons = Join-Path $neutronDependencies "Icons"
$neutronCustomizations = Join-Path $neutronDependencies "Customizations"
$neutronShortcuts = Join-Path $neutronDependencies "Shortcuts"
$neutronPanels = Join-Path $neutronDependencies "Panels"
$neutronFunctions = Join-Path $neutronDependencies "Functions"
$hashtable = Join-Path $neutronDependencies "Programs.ps1"

# Import custom window resources and color theming
$dictionaryPath = Join-Path $dependenciesPath "ResourceDictionary.ps1"
. $dictionaryPath

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
						<StackPanel Name="installPanel" Margin="0,60,10,5"/>
					</ScrollViewer>
					
					<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" VerticalAlignment="Top" Margin="0,10,25,5" Padding="5">
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
					<ScrollViewer Name="scrollViewer2" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
					</ScrollViewer>
				</Border>
			</Grid>
			
			<Grid Grid.Row="2">
				<Button Name="runButton" Content="Run" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10,0,10,10" Style="{StaticResource RoundedButton}"/>
			</Grid>
			
		</Grid>
	</Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

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
$outputBox = $window.FindName("outputBox")

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

Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources
Set-ResourceIcons -iconCategory "Surface" -resourceMappings $surfaceResources

# Construct customization panel
$panelCustomizations = Join-Path $neutronPanels "Panel-Customizations.ps1"
. $panelCustomizations

# Construct timezone panel
$panelTimezones = Join-Path $neutronPanels "Panel-Timezones.ps1"
. $panelTimezones

# Construct shortcut panel
$panelShortcuts = Join-Path $neutronPanels "Panel-Shortcuts.ps1"
. $panelShortcuts

# Construct installer panel
$panelPrograms = Join-Path $neutronPanels "Panel-Programs.ps1"
. $panelPrograms

0..2 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

$runButton.Tooltip = "- Perform selected customizations `n- Set selected timezone`n- Install selected programs"
$runButton.Add_Click({
	$scrollToEnd = $window.FindName("scrollViewer2").ScrollToEnd()
	
	$runspace = [runspacefactory]::CreateRunspace()
	$runspace.ApartmentState = "STA"
	$runspace.ThreadOptions = "ReuseThread"
	$runspace.Open()
	
	$runspace.SessionStateProxy.SetVariable('customizationPanel', $customizationPanel)
	$runspace.SessionStateProxy.SetVariable('installPanel', $installPanel)
	
	$runspace.SessionStateProxy.SetVariable('outputBox', $outputBox)
	$runspace.SessionStateProxy.SetVariable('runButton', $runButton)
	$runspace.SessionStateProxy.SetVariable('hashtable', $hashtable)
	$runspace.SessionStateProxy.SetVariable('selectedScripts', $selectedScripts)
	$runspace.SessionStateProxy.SetVariable('radioButtons', $radioButtons)
	$runspace.SessionStateProxy.SetVariable('selectedInstallPrograms', $selectedInstallPrograms)
	$runspace.SessionStateProxy.SetVariable('neutronFunctions', $neutronFunctions)
	$runspace.SessionStateProxy.SetVariable('scrollToEnd', $scrollToEnd)
	
	$powershell = [powershell]::Create().AddScript({
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke([action]{ $outputBox.Text += "$Text`r`n"; $scrollToEnd }, "Render")
		}
		
		$runButton.Dispatcher.Invoke([action]{ $runButton.Content = "Running..."; $runButton.IsEnabled = $false }, "Render")
		
		# Import functions into runspace
		Get-ChildItem -Path $neutronFunctions -Filter *.ps1 | ForEach-Object {
			Invoke-Expression -Command (Get-Content $_.FullName | Out-String)
		}
		
		# Run Customizations
		if ($selectedScripts -ne $null) { Write-OutputBox "Customizations:"; foreach ($script in $selectedScripts) { . $script }; Write-OutputBox "" }
		
		# Set Timezone
		Change-Timezone
		
		# Install Programs
		if ($selectedInstallPrograms -ne $null) { Install-Programs -selectedInstallPrograms $selectedInstallPrograms }
		
		# Uncheck customizations checkboxes
		$customizationPanel.Dispatcher.Invoke([action]{
			foreach ($item in $customizationPanel.Items) {
				if ($item.IsEnabled) {
					$item.IsChecked = $false
				}
			}
		}, "Render")
		
		# Uncheck programs checkboxes
		$installPanel.Dispatcher.Invoke([action]{
			foreach ($listBox in $installPanel.Children) {
				foreach ($listBoxItem in $listBox.Items) {
					$stackPanel = $listBoxItem.Content
					foreach ($child in $stackPanel.Children) {
						if ($child -is [System.Windows.Controls.CheckBox]) {
							$child.IsChecked = $false
						}
					}
				}
			}
		}, "Render")

		# Save Neutron log
		$atomTemp = Join-Path $env:TEMP "ATOM Temp"
		if (!(Test-Path $atomTemp)) {
			New-Item -Path $atomTemp -ItemType Directory -Force
		}
		
		try {
			$outputText = $outputBox.Dispatcher.Invoke([Func[string]]{ $outputBox.Text })
			$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
			$logPath = Join-Path $atomTemp "neutron-$dateTime.txt"
			$outputText | Out-File -FilePath $logPath
			Write-OutputBox "Log saved to $logPath"
		} catch {
			Write-OutputBox "Failed to save log"
		}
		
		Write-OutputBox "`nNeutron completed."
		
		$runButton.Dispatcher.Invoke([action]{ $runButton.Content = "Run"; $runButton.IsEnabled = $true }, "Render")
	})
	$powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
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