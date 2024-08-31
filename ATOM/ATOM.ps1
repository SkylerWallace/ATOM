$version = "v2.11"
Add-Type -AssemblyName PresentationFramework

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$scriptPath = $MyInvocation.MyCommand.Path
$atomPath = $scriptPath | Split-Path
$drivePath = $scriptPath | Split-Path -Qualifier
$logsPath = Join-Path $atomPath "Logs"
$dependenciesPath = Join-Path $atomPath "Dependencies"
$audioPath = Join-Path $dependenciesPath "Audio"
$iconsPath = Join-Path $dependenciesPath "Icons"
$pluginsIconsPath = Join-Path $iconsPath "Plugins"
$settingsPath = Join-Path $dependenciesPath "Settings"

# Import ATOM core resources
. (Join-Path $dependenciesPath "ATOM-Module.ps1")

# Import settings xaml
. (Join-Path $atomPath "ATOM-SettingsXAML.ps1")

$xaml = @"
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
	UseLayoutRounding="True"
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
					</Grid>
					
					<Grid Grid.Column="1" Margin="5,10,10,10">
						<Button Name="peButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,80,0" Opacity="0.44" ToolTip="Reboot to PE" IsEnabled="False"/>
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
				<TextBlock Name="statusBarStatus" Foreground="{DynamicResource accentText}" FontSize="10" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,5,0"/>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$mainWindow = $window.FindName("mainWindow")
$mainWindow.Title = "ATOM $version"
$logo = $window.FindName("logo")
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

# Load settings & color theming
. (Join-Path $settingsPath "Settings-Default.ps1")
. (Join-Path $settingsPath "Settings-Custom.ps1")

# Load quips
. (Join-Path $dependenciesPath "Quippy.ps1")

# Configure PE button based on online OS or PE environment
$inPe = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$pePath = Join-Path $drivePath "sources\boot.wim"
$peOnDrive = Test-Path $pePath
$peDependencies = Join-Path $dependenciesPath "PE"

if ($inPe) {
	# Automatically launch MountOS if in PE
	$mountOs = Get-ChildItem $atomPath -Filter "MountOS.ps1" -Recurse | Select -Expand FullName
	Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$mountOs`"" -Wait
} elseif ($peOnDrive) {
	$peButton.isEnabled = $true
	$peButton.Opacity = 1.0
}

$peButton.Add_Click({
	$boot2PE = Join-Path $peDependencies "Boot2PE.bat"
	Start-Process cmd.exe -WindowStyle Hidden -ArgumentList "/c `"$boot2PE`""
})

# Set icon sources
$primaryResources = @{
	"logo" = "ATOM Logo"
	"peButton" = "Reboot2PE"
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

$runOncePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
Create-Runspace -ScriptBlock {
	# Output BitLocker key to text file in log path
	if ($saveEncryptionKeys -and !$inPE) {
		# Name encryption key file based on current time & date
		$onlineOS = (Get-WmiObject -Class Win32_OperatingSystem).SystemDrive
		$currentDateTime = Get-Date -Format "MMddyy_HHmmss"
		$logFile = Join-Path $logsPath "EncryptionKey-$currentDateTime.txt"
		
		# Output encryption key to txt file if drive is encrypted
		$encryptionKey = (manage-bde -protectors -get $onlineOS | Select-String -Pattern '\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}').Matches.Value
		if ($encryptionKey) { $encryptionKey | Out-File -Append $logFile }
		
		# Remove old encryption keys, keep last 5 most recent
		$oldLogs = Get-ChildItem $logsPath\EncryptionKey-*.txt | Sort CreationTime -Descending | Select -Skip 5 | Remove-Item -Force
	}

	# Launch ATOM on reboot
	if ($launchOnRestart) {
		$registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"`""
		New-ItemProperty -Path $runOncePath -Name "ATOM" -Value $registryValue -Force | Out-Null
	}
}

# Function to load plugins in listboxes
function Load-Plugins {
	$pluginWrapPanel.Children.Clear()
	
	# Load plugin info
	. (Join-Path $dependenciesPath "Plugins-Hashtable.ps1")
	
	# Get folders for each plugin category
	$script:categoryPaths = Get-ChildItem $atomPath | Where { $_.Name -like "Plugins -*" -or $_.Name -eq "Additional Plugins" } | Sort Name -Unique
	
	foreach ($category in $categoryPaths) {
		# Early continue: 'Show Additional Plugins' setting disabled
		if (!$showAdditionalPlugins -and $category.Name -eq "Additional Plugins") { continue }
		
		# Create listbox for each plugin category
		$textBlock = New-Object System.Windows.Controls.TextBlock
		$textBlock.Text = $category.Name -replace '^Plugins - ',''
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
		$files = Get-ChildItem $category.FullName -Include *.ps1, *.bat, *.cmd, *.exe, *.lnk -Recurse | Sort Name
		
		foreach ($file in $files) {
			# Add plugin to category stackpanel
			$baseName = $file.BaseName
			
			# Configure plugin if defined in pluginInfo Hashtable
			if ($pluginInfo.Keys -contains $baseName) {
				$pluginDefined = $true
				$info = $pluginInfo[$baseName]
				
				$skipPlugin =
					(!$inPE -and $info['WorksInOs'] -eq $false) -or
					($inPE -and $info['WorksInPe'] -eq $false) -or
					(!$showHiddenPlugins -and $info['Hidden'] -eq $true)
				
				if ($skipPlugin) {
					continue
				}
			}
			
			# Add icon path
			$iconPath = Join-Path $pluginsIconsPath "$baseName.png"
			$iconExists = Test-Path $iconPath
			if (!$iconExists) {
				$firstLetter = $baseName.Substring(0,1)
				$iconPath = if ($firstLetter -match "^[A-Z]") { Join-Path $iconsPath "Default\Default$firstLetter.png" }
							else { Join-Path $iconsPath "\Default\Default.png" }
			}
			
			# Setup plugin for listbox
			$image = New-Object System.Windows.Controls.Image
			$image.Source = $iconPath
			$image.Width = 16
			$image.Height = 16
			
			$textBlock = New-Object System.Windows.Controls.TextBlock
			$textBlock.Text = $baseName
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
			$listBoxItem.ToolTip =	if ($showTooltips -and $pluginDefined) { $info['ToolTip'] }
			
			# Run plugin with double-click
			$listBoxItem.Add_MouseDoubleClick({
				$selectedFile = $this.Tag
				$extension = [System.IO.Path]::GetExtension($selectedFile).ToLower()
				$name = [System.IO.Path]::GetFileNameWithoutExtension($selectedFile)
				$statusBarStatus.Text = "Running $name"
				
				# Launch configs for each supported file extension
				$launchParams = switch ($extension) {
					'.bat' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$selectedFile`"" } }
					'.cmd' { @{ FilePath = 'cmd'; ArgumentList = "/c `"$selectedFile`"" } }
					'.exe' { @{ FilePath = $selectedFile } }
					'.lnk' { @{ FilePath = $selectedFile } }
					'.ps1' { @{ FilePath = 'powershell'; ArgumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$selectedFile`"" } }
				}
				
				$launchParams.WindowStyle = if ($pluginInfo[$name].Silent -and !$debugMode) { 'Hidden' } else { 'Normal' }
				Start-Process @launchParams
			})
			
			# Open context-menu with right-click
			$listBoxItem.Add_MouseRightButtonUp({
				$contextMenu = New-Object System.Windows.Controls.ContextMenu
				$contextMenu.Background = $accentBrush
				$contextMenu.Style = $window.FindResource("CustomContextMenu")
				$selectedFile = $this.Tag
				
				foreach ($category in $categoryPaths) {
					$menuItem = New-Object System.Windows.Controls.MenuItem
					$menuItem.Foreground = $accentText
					$menuItem.Header = "Move to " + ($category -replace '^Plugins - ', '')
					$menuItem.Tag = @{ File = $selectedFile; Category = $category }
					
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
function Load-Quip {
	$randomQuip = Get-Random -InputObject $quips -Count 1
	$statusBarStatus.Text = "$randomQuip"
}

Load-Quip

$refreshButton.Add_Click({
	Spin-RefreshButton
	Load-Quip
	Load-Plugins
	$window.SizeToContent = "Height"
})

# Import logic for ATOM settings
. (Join-Path $atomPath "ATOM-Settings.ps1")

# Toggle visibility of plugins/settings
$settingsButton.Add_Click({
	if ($settingsToggled) {
		$script:settingsToggled = $false
		$scrollViewer.Visibility = "Visible"
		$scrollViewerSettings.Visibility = "Collapsed"
	} else {
		$script:settingsToggled = $true
		$scrollViewer.Visibility = "Collapsed"
		$scrollViewerSettings.Visibility = "Visible"
	}
	
	Load-Plugins
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

# Function to configure window width per plugin column
function Columns {
	param(
		[switch]$get,
		[switch]$set,
		[int]$columns
	)
	
	switch ($columns) {
		1		{ $width = 255 }
		2		{ $width = 469 }
		3		{ $width = 687 }
		default	{ $width = 469 }
	}
	
	if ($get) { return $width }
	if ($set) { $window.Width = $width }
}

# Set plugin columns from startup columns user-setting
Columns -Set $startupColumns

# Toggle between 1 & 2 columns
$columnButton.Add_Click({
	Columns -Set $(
		if ($window.Width -gt ((Columns -Get 1) + 2) -and $window.Width -le (Columns -Get 2)) { 1 }
		else { 2 }
	)
})

# Function to update column button image based on window width
function Update-ExpandCollapseButton {
	if ($window.Width -gt ((Columns -Get 1) + 2) -and $window.Width -le (Columns -Get 2)) {
		$columnButton.ToolTip = "One-Column View"
		$columnResource = @{ "columnButton" = "Column-1" }
		Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $columnResource
	} else {
		$columnButton.ToolTip = "Two-Column View"
		$columnResource = @{ "columnButton" = "Column-2" }
		Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $columnResource
	}
}

Update-ExpandCollapseButton

$window.Add_SizeChanged({ Update-ExpandCollapseButton })

$closeButton.Add_Click({
	if (Get-ItemProperty -Path $runOncePath -Name "ATOM" -ErrorAction SilentlyContinue) {
		Remove-ItemProperty -Path $runOncePath -Name "ATOM" -Force | Out-Null
	}
	
	$window.Close()
})

# Make scrollviewer work with scrollwheel
$scrollViewer.AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{
	param($sender, $e)
	$sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta)
}, $true)

# Click-to-drag window
$window.Add_MouseLeftButtonDown({$this.DragMove()})

Adjust-WindowSize

$window.ShowDialog() | Out-Null