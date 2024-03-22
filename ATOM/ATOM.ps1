$version = "v2.10"
Add-Type -AssemblyName PresentationFramework

# Get script path, method compatible with ps2exe
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
	$scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	$scriptFullPath = $MyInvocation.MyCommand.Definition
} else { 
	$scriptFullPath = ([Environment]::GetCommandLineArgs()[0])
	$scriptPath = Split-Path -Parent -Path $scriptFullPath
}

# Set registry value based on the script extension
$scriptExtension = [System.IO.Path]::GetExtension($scriptFullPath)
if ($scriptExtension -eq ".ps1") {
	$atomPath = $scriptPath
	$scriptFullPath = $MyInvocation.MyCommand.Path
	$registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptFullPath`"`""
} elseif ($scriptExtension -eq ".exe") {
	$atomPath = Join-Path $scriptPath "ATOM"
	$registryValue = $scriptFullPath
}

$drivePath = Split-Path -Qualifier $PSScriptRoot
$logsPath = Join-Path $atomPath "Logs"
$dependenciesPath = Join-Path $atomPath "Dependencies"
$audioPath = Join-Path $dependenciesPath "Audio"
$iconsPath = Join-Path $dependenciesPath "Icons"
$pluginsIconsPath = Join-Path $iconsPath "Plugins"
$settingsPath = Join-Path $dependenciesPath "Settings"

# Import custom window resources and color theming
$dictionaryPath = Join-Path $dependenciesPath "ResourceDictionary.ps1"
. $dictionaryPath

# Import settings xaml
$settingsXamlPath = Join-Path $atomPath "ATOM-SettingsXAML.ps1"
. $settingsXamlPath

[xml]$xaml = @"
<Window x:Name="mainWindow"
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Background = "Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	Width="469" SizeToContent="Height"
	MinWidth="255" MinHeight="600"
	MaxWidth="923" MaxHeight="800"
	Top="0" Left="0"
	RenderOptions.BitmapScalingMode="HighQuality">

	<Window.Resources>
		$resourceDictionary
	</Window.Resources>

	<WindowChrome.WindowChrome>
		<WindowChrome CaptionHeight="0" CornerRadius="{DynamicResource cornerStrength}"/>
	</WindowChrome.WindowChrome>

	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource backgroundBrush}" CornerRadius="{DynamicResource cornerStrength}">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="70"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryBrush}" CornerRadius="{DynamicResource cornerStrength1}"/>
				<Grid>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width="*"/>
						<ColumnDefinition Width="Auto"/>
					</Grid.ColumnDefinitions>
					
					<Grid Grid.Column="0" Margin="10,10,5,10">
						<Image Name="logo" Width="130" Height="60" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,5,0,0"/>
						<Button Name="superSecretButton" Width="6" Height="6" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Left" Margin="129,23,0,0"/>
					</Grid>
					
					<Grid Grid.Column="1" Margin="5,10,10,10">
						<Button Name="peButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,80,0"/>
						<Button Name="refreshButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,40,0" ToolTip="Reload Plugins"/>
						<Button Name="settingsButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,0,0" ToolTip="Settings"/>
						<Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,80,0" ToolTip="Minimize"/>
						<Button Name="columnButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,40,0"/>
						<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,0,0" ToolTip="Close"/>
					</Grid>
				</Grid>
			</Grid>
			
			<ScrollViewer Name="scrollViewer" Grid.Row="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}">
				<WrapPanel Name="pluginWrapPanel" Orientation="Horizontal" Margin="10,0,0,10"/>
			</ScrollViewer>
			
			<ScrollViewer Name="scrollViewerSettings" Grid.Row="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}" Visibility="Collapsed">
				$settingsXaml
			</ScrollViewer>
			
			<Grid Grid.Row="2" Margin="10,0,10,10">
				<Rectangle Height="20" Fill="{DynamicResource accentBrush}" RadiusX="5" RadiusY="5"/>
				<Grid>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width="*"/>
						<ColumnDefinition Width="Auto"/>
					</Grid.ColumnDefinitions>
					
					<TextBlock Name="statusBarStatus" Grid.Column="0" Foreground="{DynamicResource accentText}" FontSize="10" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,5,0"/>
					<TextBlock Name="statusBarVersion" Grid.Column="1" Foreground="{DynamicResource accentText}" FontSize="10" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5,0,10,0"/>
				</Grid>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$mainWindow = $window.FindName("mainWindow")
$mainWindow.Title = "ATOM $version"
$logo = $window.FindName("logo")
$superSecretButton = $window.FindName("superSecretButton")
$peButton = $window.FindName("peButton")
$refreshButton = $window.FindName("refreshButton")
$settingsButton = $window.FindName("settingsButton")
$minimizeButton = $window.FindName("minimizeButton")
$columnButton = $window.FindName("columnButton")
$closeButton = $window.FindName("closeButton")
$scrollViewer = $window.FindName("scrollViewer")
$scrollViewerSettings = $window.FindName("scrollViewerSettings")
$pluginWrapPanel = $window.FindName("pluginWrapPanel")
$statusBarStatus = $window.FindName("statusBarStatus")
$statusBarVersion = $window.FindName("statusBarVersion")
$statusBarVersion.Text = "$version"

# Load settings & color theming
$defaultSettingsConfig = Join-Path $settingsPath "Settings-Default.ps1"
$settingsConfig = Join-Path $settingsPath "Settings-Custom.ps1"
. $defaultSettingsConfig
. $settingsConfig

# Load quips
$quipPath = Join-Path $dependenciesPath "Quippy.ps1"
. $quipPath

# Configure PE button based on online OS or PE environment
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$pePath = Join-Path $drivePath "sources\boot.wim"
$peOnDrive = Test-Path $pePath
if ($inPE) {
	$peButtonFileName = "MountOS"
	$peButton.ToolTip = "Launch MountOS"
	
	$peButton.Add_Click({
		$mountOS = Join-Path $dependenciesPath "MountOS.ps1"
		Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$mountOS`""
	})
} elseif ($peOnDrive) {
	$peButtonFileName = "Reboot2PE"
	$peButton.ToolTip = "Reboot to PE"
	
	$peButton.Add_Click({
		$boot2PE = Join-Path $dependenciesPath "Boot2PE.bat"
		Start-Process cmd.exe -WindowStyle Hidden -ArgumentList "/c `"$boot2PE`""
	})
} else {
	$peButtonFileName = "Reboot2PE"
	$peButton.isEnabled = $false
	$peButton.Opacity = 0.5
}

# Set icon sources
$primaryResources = @{
	"logo" = "ATOM Logo"
	"peButton" = $peButtonFileName
	"settingsButton" = "Settings"
	"refreshButton" = "Refresh"
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

$backgroundResources = @{
	"navButton" = "Back"
}

$surfaceResources = @{
	"pathButton" = "Folder"
	"githubImage" = "GitHub"
	"githubLinkButton" = "Link"
	"githubLaunchButton" = "Launch"
}

$accentResources = @{
	"checkUpdatesImage" = "Download"
	"updateImage" = "Update"
	"restoreImage" = "Restore"
	"saveImage" = "Save"
}

Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $primaryResources
Set-ResourceIcons -IconCategory "Background" -ResourceMappings $backgroundResources
Set-ResourceIcons -IconCategory "Surface" -ResourceMappings $surfaceResources
Set-ResourceIcons -IconCategory "Accent" -ResourceMappings $accentResources

# Output BitLocker key to text file in log path
if ($saveEncryptionKeys -and !$inPE) {
	$onlineOS = (Get-WmiObject -Class Win32_OperatingSystem).SystemDrive
	$currentDateTime = Get-Date -Format "MMddyy_HHmmss"
	$logFile = Join-Path $logsPath "EncryptionKey-$currentDateTime.txt"
	$encryptionKey = (manage-bde -protectors -get $onlineOS | Select-String -Pattern '\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}').Matches.Value
	$encryptionKey | Out-File -Append $logFile

	$oldLogs = Get-ChildItem $logsPath\EncryptionKey-*.txt | Sort-Object CreationTime -Descending | Select-Object -Skip 5
	$oldLogs | Remove-Item -Force
}

# Launch ATOM on reboot
if ($launchOnRestart) {
	$runOncePath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
	New-ItemProperty -Path $runOncePath -Name "ATOM" -Value $registryValue -Force | Out-Null
}

# Configuration for launching plugins based on file extension (used in Load-Plugins)
$commandConfig = @{
	'.ps1' = @{ProcessName = 'powershell'; ArgTemplate = '-NoProfile -ExecutionPolicy Bypass -File "{0}"'; HiddenFlag = '# Launch: Hidden'}
	'.bat' = @{ProcessName = 'cmd'; ArgTemplate = '/c "{0}"'; HiddenFlag = 'REM Launch: Hidden'}
	'.cmd' = @{ProcessName = 'cmd'; ArgTemplate = '/c "{0}"'; HiddenFlag = 'REM Launch: Hidden'}
}

# Function to load plugins in listboxes
function Load-Plugins {
	$pluginWrapPanel.Children.Clear()
	
	if ($showAdditionalPlugins) {
		$pluginFolders = Get-ChildItem -Path $atomPath -Directory | Where-Object { $_.Name -like "Plugins -*" -or $_.Name -eq "Additional Plugins" } | Sort-Object Name
	} else {
		$pluginFolders = Get-ChildItem -Path $atomPath -Directory | Where-Object { $_.Name -like "Plugins -*" } | Sort-Object Name
		$categoryNames = @("Additional Plugins")
	}
	
	$categoryNames += $pluginFolders | ForEach-Object { $_.Name } | Sort-Object -Unique
	
	foreach ($pluginFolder in $pluginFolders) {
		# Create listbox for each plugin category
		$textBlock = New-Object System.Windows.Controls.TextBlock
		$textBlock.Text = $pluginFolder.Name -replace '^Plugins - ',''
		$textBlock.Foreground = $backgroundText
		$textBlock.FontSize = 14
		$textBlock.Margin = "0,10,0,0"
		$textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom

		$listBox = New-Object System.Windows.Controls.ListBox
		$listBox.Background = "Transparent"
		$listBox.Foreground = $surfaceText
		$listBox.BorderThickness = 0
		$listBox.Margin = 5
		$listBox.Padding = 0
		$listBox.Width = 200
		$listBox.Tag = $categoryNames

		$border = New-Object System.Windows.Controls.Border
		$border.Style = $window.FindResource("CustomBorder")
		$border.Margin = "0,5,0,0"
		$border.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)
		$border.Child = $listBox
		
		# Configure listbox into plugin wrappanel
		$grid = New-Object System.Windows.Controls.Grid
		$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
		$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
		$grid.Margin = "0,0,10,0"
		$grid.Children.Add($textBlock) | Out-Null
		$grid.Children.Add($border) | Out-Null
		$grid.RowDefinitions[0].Height = [System.Windows.GridLength]::new(30)
		$pluginWrapPanel.Children.Add($grid) | Out-Null
		
		# Get all supported plugins from plugin folder
		$files = Get-ChildItem -Path $pluginFolder.FullName -Include *.ps1, *.bat, *.cmd, *.exe, *.lnk -Recurse | Sort-Object Name
		
		foreach ($file in $files) {
			# Add plugin to category stackpanel
			$nameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
			$iconPath = Join-Path $pluginsIconsPath "$nameWithoutExtension.png"
			$iconExists = Test-Path $iconPath
			if (!$iconExists) {
				$firstLetter = $nameWithoutExtension.Substring(0,1)
				$iconPath = if ($firstLetter -match "^[A-Z]") { Join-Path $iconsPath "\Default\Default$firstLetter.png" }
							else { Join-Path $iconsPath "\Default\Default.png" }
			}
			
			$image = New-Object System.Windows.Controls.Image
			$image.Source = $iconPath
			$image.Tag = $file.FullName
			$image.Width = 16
			$image.Height = 16
			
			$textBlock = New-Object System.Windows.Controls.TextBlock
			$textBlock.Text = $nameWithoutExtension
			$textBlock.Tag = $file.FullName
			$textBlock.Margin = "5,0,0,0"
			$textBlock.VerticalAlignment = "Center"
			
			$stackPanel = New-Object System.Windows.Controls.StackPanel
			$stackPanel.Orientation = "Horizontal"
			$stackPanel.Children.Add($image) | Out-Null
			$stackPanel.Children.Add($textBlock) | Out-Null

			$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
			$listBoxItem.Tag = $file.FullName
			$listBoxItem.Foreground = $surfaceText
			$listBoxItem.Content = $stackPanel	
			
			# Run plugin with double-click
			$listBoxItem.Add_MouseDoubleClick({
				$selectedFile = $_.Source.Tag
				$extension = [System.IO.Path]::GetExtension($selectedFile).ToLower()
				$nameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($selectedFile)
				$statusBarStatus.Text = "Running $nameWithoutExtension"
				
				$config = $commandConfig[$extension]
				if ($config -ne $null) {
					$firstLine = Get-Content $selectedFile -First 1
					$arguments = $config.ArgTemplate -f $selectedFile
					$windowStyle = if ($firstLine -eq $config.HiddenFlag) { 'Hidden' } else { 'Normal' }
					
					Start-Process $config.ProcessName -WindowStyle $windowStyle -ArgumentList $arguments
				}
				elseif ($extension -eq '.exe' -or $extension -eq '.lnk') {
					Start-Process -FilePath $selectedFile
				}
			})
			
			# Open context-menu with right-click
			$listBoxItem.Add_MouseRightButtonUp({
				$contextMenu = New-Object System.Windows.Controls.ContextMenu
				$contextMenu.Background = $accentBrush
				$contextMenu.Style = $window.FindResource("CustomContextMenu")
				$categories = $this.Parent.Tag
				$selectedFile = $_.Source.Tag
				
				foreach ($category in $categories) {
					$menuItem = New-Object System.Windows.Controls.MenuItem
					$menuItem.Foreground = $accentText
					$menuItem.Header = "Move to " + ($category -replace '^Plugins - ', '')
					$menuItem.Tag = @{ "File" = $selectedFile; "Category" = $category }
					
					# Move plugin to selected plugin category
					$menuItem.Add_Click({
						$selectedFile = $this.Tag["File"]
						$selectedCategory = $this.Tag["Category"]
						$destinationPath = Join-Path $atomPath $selectedCategory
						
						Move-Item -LiteralPath $selectedFile -Destination $destinationPath -Force
						Load-Plugins
					})
					
					$contextMenu.Items.Add($menuItem)
				}
				
				$contextMenu.IsOpen = $true
			})
			
			$listBox.Items.Add($listBoxItem) | Out-Null
		}
	}
}

Load-Plugins

# Function to select random quip for status bar
function Refresh-StatusBar {
	$randomQuip = Get-Random -InputObject $quips -Count 1
	$statusBarStatus.Text = "$randomQuip"
}

Refresh-StatusBar

function Spin-RefreshButton {
	$animation = New-Object System.Windows.Media.Animation.DoubleAnimation
	$animation.From = 0
	$animation.To = 360
	$animation.Duration = New-Object Windows.Duration (New-Object TimeSpan 0,0,0,0,500)

	$animation.Easingfunction = New-Object System.Windows.Media.Animation.QuadraticEase
	$animation.Easingfunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseInOut

	$rotateTransform = New-Object System.Windows.Media.RotateTransform
	$refreshButton.RenderTransform = $rotateTransform
	$refreshButton.RenderTransformOrigin = '0.5,0.5'

	$rotateTransform.BeginAnimation([System.Windows.Media.RotateTransform]::AngleProperty, $animation)
}

$refreshButton.Add_Click({
	Spin-RefreshButton
	Refresh-StatusBar
	Load-Plugins
	$window.SizeToContent = "Height"
})

# Import logic for ATOM settings
$settingsScript = Join-Path $atomPath "ATOM-Settings.ps1"
. $settingsScript

# Toggle visibility of plugins/settings
$settingsButton.Add_Click({
	if ($settingsToggled) {
		$script:settingsToggled = $false
		$scrollViewer.Visibility = "Visible"
		$scrollViewerSettings.Visibility = "Collapsed"
		Load-Plugins
	} else {
		$script:settingsToggled = $true
		$scrollViewer.Visibility = "Collapsed"
		$scrollViewerSettings.Visibility = "Visible"
		Load-Plugins
	}
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

function Update-ExpandCollapseButton {
	if ($window.Width -gt 257 -and $window.Width -le 469) {
		$columnButton.ToolTip = "One-Column View"
		$columnResource = @{ "columnButton" = "Column-1" }
		Set-ResourceIcons -iconCategory "Primary" -resourceMappings $columnResource
	} else {
		$columnButton.ToolTip = "Two-Column View"
		$columnResource = @{ "columnButton" = "Column-2" }
		Set-ResourceIcons -iconCategory "Primary" -resourceMappings $columnResource
	}
}

Update-ExpandCollapseButton

switch ($startupColumns) {
	1 { $window.Width = 255 }
	2 { $window.Width = 469 }
	3 { $window.Width = 687 }
	default { $window.Width = 469 }
}

$columnButton.Add_Click({
	$children = $pluginWrapPanel.Children | ForEach-Object { $_ }
	$pluginWrapPanel.Children.Clear()
	if ($window.Width -gt 257 -and $window.Width -le 469) { $window.Width = 255 } else { $window.Width = 469 }
	$children | ForEach-Object { $pluginWrapPanel.Children.Add($_) }
})

$window.Add_SizeChanged({ Update-ExpandCollapseButton })

$closeButton.Add_Click({
	Remove-ItemProperty -Path $runOncePath -Name "ATOM" -Force | Out-Null
	$window.Close()
})

$superSecretButton.Add_Click({
	$wavFiles = Get-ChildItem -Path "$audioPath\Random" -Filter "*.wav"
	$randomWav = $wavFiles | Get-Random
	$secretAudio = New-Object System.Media.SoundPlayer
	$secretAudio.SoundLocation = $randomWav.FullName
	$secretAudio.Play()
})

$scrollViewer.AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true)

# Handle window dragging
$window.Add_MouseLeftButtonDown({$this.DragMove()})

# Finds the resolution of the primary display and the display scaling setting
# If the "effective" resolution will cause ATOM's window to clip, it will decrease the window size
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