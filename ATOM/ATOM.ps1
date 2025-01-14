$version = "v2.12"
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$scriptPath			= $psCommandPath
$atomPath			= $psScriptRoot
$drivePath			= $atomPath | Split-Path -Qualifier
$dependenciesPath	= "$atomPath\Dependencies"
$logsPath			= "$atomPath\Logs"
$pluginsPath		= "$atomPath\Plugins"
$resourcesPath		= "$atomPath\Resources"
$settingsPath		= "$atomPath\Settings"

# Import ATOM core resources
. $atomPath\CoreModule.ps1

$settingsXaml = @"
<StackPanel MaxWidth="300" Margin="5">
	<!-- NAV STACKPANEL -->
	<StackPanel Orientation="Horizontal">
		<Button Name="navButton" Width="25" Height="25" Style="{StaticResource RoundHoverButtonStyle}" Margin="5"/>
		<TextBlock Text="Settings" FontSize="20" FontWeight="Bold" Foreground="{DynamicResource backgroundText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
	</StackPanel>

	<!-- UPDATE STACKPANEL -->
	<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
		<StackPanel>
			<Grid>
				<TextBlock Text="ATOM Version:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<TextBlock Name="versionText" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<Grid>
				<TextBlock Text="Hash:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<TextBlock Name="versionHash" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<Grid>
				<TextBlock Text="Last checked:" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<TextBlock Name="updateText" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			
			<WrapPanel Orientation="Horizontal" HorizontalAlignment="Center">
				<Button Name="checkUpdateButton" Width="130" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5" ToolTip="Check GitHub for ATOM updates">
					<StackPanel Orientation="Horizontal">
						<Image Name="checkUpdatesImage" Width="16" Height="16" Margin="5"/>
						<TextBlock Text="Check for Updates" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
					</StackPanel>
				</Button>
				<Button Name="updateButton" Width="130" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" IsEnabled="False" Opacity="0.2" Margin="5" ToolTip="Updating ATOM will not remove custom plugins">
					<StackPanel Orientation="Horizontal">
						<Image Name="updateImage" Width="16" Height="16" Margin="5"/>
						<TextBlock Text="Update ATOM" FontSize="11" VerticalAlignment="Center" Margin="0,5,5,5"/>
					</StackPanel>
				</Button>
			</WrapPanel>
		</StackPanel>
	</Border>

	<!-- SWITCHES STACKPANEL -->
	<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
		<StackPanel>
			<!-- SAVE ENCRYPTION KEYS -->
			<Grid ToolTip="Save computers encryption key to $logsPath">
				<TextBlock Text="Save Encryption Keys" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<ToggleButton Name="keysSwitch" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<!-- LAUNCH ATOM ON RESTART -->
			<Grid ToolTip="Start ATOM when computer reboots">
				<TextBlock Text="Launch on Restart" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<ToggleButton Name="restartSwitch" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<!-- SHOW PLUGIN TOOLTIPS -->
			<Grid ToolTip="Show tooltips when hovering over plugins">
				<TextBlock Text="Show Plugin Tooltips" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<ToggleButton Name="tooltipSwitch" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<!-- SHOW HIDDEN PLUGINS  -->
			<Grid ToolTip="Show Hidden Plugins for each plugin category">
				<TextBlock Text="Show Hidden Plugins" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<ToggleButton Name="hiddenSwitch" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<!-- SHOW ADDITIONAL PLUGINS -->
			<Grid ToolTip="Show Additional Plugins in plugin categories">
				<TextBlock Text="Show Additional Plugins" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<ToggleButton Name="additionalSwitch" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<!-- DEBUG MODE -->
			<Grid ToolTip="Disable silent launch of plugins">
				<TextBlock Text="Debug Mode" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<ToggleButton Name="debugSwitch" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5"/>
			</Grid>
			
			<!-- STARTUP COLUMNS -->
			<Grid ToolTip="Default plugin category columns when starting ATOM">
				<TextBlock Text="Startup Columns" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<StackPanel Name="startupColumnsStackPanel" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center"/>
			</Grid>
			
			<!-- SAVE BUTTONS -->
			<WrapPanel Orientation="Horizontal" HorizontalAlignment="Center">
				<Button Name="defaultSwitchButton" Width="130" Background="{DynamicResource accentBrush}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5">
					<StackPanel Orientation="Horizontal">
						<Image Name="restoreImage" Width="16" Height="16" Margin="5"/>
						<TextBlock Text="Restore Defaults" FontSize="11" Foreground="{DynamicResource accentText}" VerticalAlignment="Center"/>
					</StackPanel>
				</Button>
				<Button Name="saveSwitchButton" Width="130" Background="{DynamicResource accentBrush}" HorizontalAlignment="Center" Style="{StaticResource RoundedButton}" Margin="5">
					<StackPanel Orientation="Horizontal">
						<Image Name="saveImage" Width="16" Height="16" Margin="5"/>
						<TextBlock Text="Save Settings" FontSize="11" Foreground="{DynamicResource accentText}" VerticalAlignment="Center"/>
					</StackPanel>
				</Button>
			</WrapPanel>
		</StackPanel>
	</Border>
	
	<!-- COLORS -->
	<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
		<WrapPanel Name="colorsPanel" Orientation="Horizontal" HorizontalAlignment="Center"/>
	</Border>
	
	<!-- PATH STACKPANEL -->
	<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
		<StackPanel>
			<Grid>
				<TextBlock Text="ATOM Path" FontSize="12" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5"/>
				<Button Name="pathButton" Height="25" Width="25" HorizontalAlignment="Right" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Open in Explorer"/>
			</Grid>
			<TextBox Name="pathTextBox" Text="$atomPath" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Center" VerticalAlignment="Center" IsReadOnly="True" Margin="5"/>
		</StackPanel>
	</Border>
		
	<!-- GITHUB STACKPANEL -->
	<Border Style="{StaticResource CustomBorder}" HorizontalAlignment="Stretch" Margin="5" Padding="5">
		<StackPanel>
			<Grid>
				<StackPanel Orientation="Horizontal" HorizontalAlignment="Left">
					<Image Name="githubImage" Width="20" Height="20" VerticalAlignment="Center" Margin="5"/>
					<TextBlock Text="GitHub" FontSize="12" Foreground="{DynamicResource surfaceText}" VerticalAlignment="Center" Margin="5"/>
				</StackPanel>
				<StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
					<Button Name="githubLinkButton" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Copy URL to clipboard"/>
					<Button Name="githubLaunchButton" Height="25" Width="25" VerticalAlignment="Center" Style="{StaticResource RoundHoverButtonStyle}" Margin="5" ToolTip="Open URL in web browser"/>
				</StackPanel>
			</Grid>
			<TextBox Name="githubTextBox" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderBrush="Transparent" TextAlignment="Center" VerticalAlignment="Center" Margin="5" IsReadOnly="True"/>
		</StackPanel>
	</Border>
</StackPanel>
"@

$mainXaml = @"
<Window x:Name="mainWindow"
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title = "ATOM $version"
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
$window = [Windows.Markup.XamlReader]::Parse($mainXaml)

# Assign variables to elements in XAML
$mainWindow				= $window.FindName('mainWindow')
$peButton				= $window.FindName('peButton')
$refreshButton			= $window.FindName('refreshButton')
$settingsButton			= $window.FindName('settingsButton')
$minimizeButton			= $window.FindName('minimizeButton')
$columnButton			= $window.FindName('columnButton')
$closeButton			= $window.FindName('closeButton')
$scrollViewer			= $window.FindName('scrollViewer')
$scrollViewerSettings	= $window.FindName('scrollViewerSettings')
$pluginWrapPanel		= $window.FindName('pluginWrapPanel')
$statusBarStatus		= $window.FindName('statusBarStatus')

# Load settings & color theming
. $settingsPath\Settings-Default.ps1
. $settingsPath\Settings-Custom.ps1

# Load quips
. $resourcesPath\Quippy.ps1

# Configure PE button based on online OS or PE environment
$inPe = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$pePath = Join-Path $drivePath "sources\boot.wim"
$peOnDrive = Test-Path $pePath
$peDependencies = Join-Path $dependenciesPath "PE"

if ($inPe) {
	# Automatically launch MountOS if in PE
	$mountOs = Get-ChildItem $atomPath -Filter "MountOS.ps1" -Recurse | Select-Object -Expand FullName
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

Set-ResourcePath -ColorRole "Primary" -ResourceMappings $primaryResources
Set-ResourcePath -ColorRole "Background" -ResourceMappings $backgroundResources
Set-ResourcePath -ColorRole "Surface" -ResourceMappings $surfaceResources
Set-ResourcePath -ColorRole "Accent" -ResourceMappings $accentResources

$runOncePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
Invoke-Runspace -ScriptBlock {
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
		Get-ChildItem $logsPath\EncryptionKey-*.txt | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | Remove-Item -Force
	}

	# Launch ATOM on reboot
	if ($launchOnRestart) {
		$registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`"`""
		New-ItemProperty -Path $runOncePath -Name "ATOM" -Value $registryValue -Force | Out-Null
	}
}

# Function to load plugins in listboxes
function Import-Plugins {
	$pluginWrapPanel.Children.Clear()
	
	# Load plugin params
	. $atomPath\Config\PluginsParams.ps1
	
	# Get folders for each plugin category
	$script:categoryPaths = Get-ChildItem $pluginsPath | Sort-Object Name -Unique
	
	foreach ($category in $categoryPaths) {
		# Early continue: 'Show Additional Plugins' setting disabled
		if (!$showAdditionalPlugins -and $category.Name -eq "Additional Plugins") { continue }
		
		# Create listbox for each plugin category
		$textBlock = New-Object System.Windows.Controls.TextBlock
		$textBlock.Text = $category.Name
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
		$files = Get-ChildItem $category.FullName -Include *.ps1, *.bat, *.cmd, *.exe, *.lnk -Recurse | Sort-Object Name
		
		foreach ($file in $files) {
			# Add plugin to category stackpanel
			$baseName = $file.BaseName
			
			# Configure plugin if defined in pluginInfo Hashtable
			if ($pluginInfo.Keys -contains $baseName) {
				$pluginDefined = $true
				$info = $pluginInfo[$baseName]
				
				$skipPlugin =
					(!$inPE -and $info.WorksInOs -eq $false) -or
					($inPE -and $info.WorksInPe -eq $false) -or
					(!$showHiddenPlugins -and $info.Hidden -eq $true)
				
				if ($skipPlugin) {
					continue
				}
			}
			
			# Add icon path
			$iconPath = "$resourcesPath\Icons\Plugins\$baseName.png"

			if (!(Test-Path $iconPath)) {
				$firstLetter = $baseName.Substring(0,1)
				$iconPath =
					if ($firstLetter -match "^[A-Z]") { "$resourcesPath\Icons\Default\$firstLetter.png" }
					else { "$resourcesPath\Icons\Default\#.png" }
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
			$listBoxItem.ToolTip =	if ($showTooltips -and $pluginDefined -and $info.ToolTip) { $info.ToolTip }
			
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
				
				# 'Move to' plugin category options
				foreach ($category in $categoryPaths) {
					$menuItem = New-Object System.Windows.Controls.MenuItem
					$menuItem.Foreground = $accentText
					$menuItem.Header = "Move to " + ($category -replace '^Plugins - ', '')
					$menuItem.Tag = @{ File = $selectedFile; Category = $category }
					
					# Move plugin to selected plugin category
					$menuItem.Add_Click({
						$selectedFile = $this.Tag.File
						$selectedCategory = $this.Tag.Category
						$destinationPath = Join-Path $atomPath $selectedCategory
						
						Move-Item -LiteralPath $selectedFile -Destination $destinationPath -Force
						Import-Plugins
					})
					
					$contextMenu.Items.Add($menuItem)
				}
				
				$contextMenu.IsOpen = $true
			})
			
			$listBox.Items.Add($listBoxItem) | Out-Null
		}
	}
}

Import-Plugins

# Function to select random quip for status bar
function Set-Quip {
	$randomQuip = Get-Random -InputObject $quips -Count 1
	$statusBarStatus.Text = "$randomQuip"
}

Set-Quip

$refreshButton.Add_Click({
	Start-ButtonSpin
	Set-Quip
	Import-Plugins
	$window.SizeToContent = "Height"
})

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
	
	Import-Plugins
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
		Set-ResourcePath -ColorRole "Primary" -ResourceMappings $columnResource
	} else {
		$columnButton.ToolTip = "Two-Column View"
		$columnResource = @{ "columnButton" = "Column-2" }
		Set-ResourcePath -ColorRole "Primary" -ResourceMappings $columnResource
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

Set-WindowSize

# ATOM settings

#############################
####   NAV STACKPANEL    ####
#############################

$navButton = $window.FindName("navButton")
$navButton.Add_Click({
	$script:settingsToggled = $false
	$scrollViewer.Visibility = "Visible"
	$scrollViewerSettings.Visibility = "Collapsed"
	
	Import-Plugins
})

#############################
####  UPDATE  STACKPANEL ####
#############################

$versionText = $window.FindName("versionText")
$versionText.Text = "$version"

$versionHash = $window.FindName("versionHash")
$localCommitPath = Join-Path $settingsPath "hash.txt"
$localCommitHash = Get-Content -Path $localCommitPath
$versionHash.Text = "$($localCommitHash.Substring(0, 7))"

$updateText = $window.FindName("updateText")
$lastCheckedPath = Join-Path $settingsPath "time.txt"
if (Test-Path $lastCheckedPath) { $lastCheckedContent = Get-Content -Path $lastCheckedPath }
$updateText.Text = "$lastCheckedContent"

function Test-AtomUpdate {
	$apiUrl = "https://api.github.com/repos/SkylerWallace/ATOM/commits?per_page=1"
	$response = Invoke-RestMethod -Uri $apiUrl
	$authorName = $response[0].commit.author.name
	$latestCommitHash = 
		if ($authorName -eq "GitHub Actions") { $response[0].parents[0].sha }
		else { $response[0].sha }
	
	if ($localCommitHash -ne $latestCommitHash) {
		$updateButton.Opacity = 1.0
		$updateButton.IsEnabled = "True"
		$updateText.Text = "Update available!"
	} else {
		Get-Date -Format "MM/dd/yy h:mmtt" | Out-File $lastCheckedPath
		$lastCheckedContent = Get-Content -Path $lastCheckedPath
		$updateText.Text = "$lastCheckedContent"
	}
}

$checkUpdateButton = $window.FindName("checkUpdateButton")
$checkUpdateButton.Add_Click({ Test-AtomUpdate })

$updateButton = $window.FindName("updateButton")
$updateButton.Add_Click({
	$updateAtomPath = "$dependenciesPath\Update-ATOM.ps1"
	Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$updateAtomPath`""
})

#############################
#### SWITCHES STACKPANEL ####
#############################

function New-SettingSwitch {
	param($switchName,$variableName)
	
	New-Variable -Name $switchName -Value $window.FindName($switchName) -Scope Script
	(Get-Variable -Name $switchName -ValueOnly).IsChecked = if ((Get-Variable -Name $variableName -ValueOnly) -eq $true) { $true } else { $false }
	
	(Get-Variable -Name $switchName -ValueOnly).Tag = $variableName
	(Get-Variable -Name $switchName -ValueOnly).Add_Click({
		Set-Variable -Name $this.Tag -Value $this.IsChecked -Scope Script
	})
}

## SWITCHES
###########

New-SettingSwitch -SwitchName "keysSwitch" -VariableName "saveEncryptionKeys"
New-SettingSwitch -SwitchName "restartSwitch" -VariableName "launchOnRestart"
New-SettingSwitch -SwitchName "tooltipSwitch" -VariableName "showTooltips"
New-SettingSwitch -SwitchName "hiddenSwitch" -VariableName "showHiddenPlugins"
New-SettingSwitch -SwitchName "additionalSwitch" -VariableName "showAdditionalPlugins"
New-SettingSwitch -SwitchName "debugSwitch" -VariableName "debugMode"

## STARTUP COLUMNS
##################

$startupColumnsStackPanel = $window.FindName("startupColumnsStackPanel")
for ($i = 1; $i -le 3; $i++) {
	$columnRdBtn = New-Object System.Windows.Controls.RadioButton
	$columnRdBtn.Content = $i
	$columnRdBtn.Tag = $i
	$columnRdBtn.Foreground = $surfaceText
	$columnRdBtn.GroupName = "Columns"
	$columnRdBtn.Margin = 5
	$columnRdBtn.Add_Click({ $script:startupColumns = $this.Content })
	if ($startupColumns -eq $i) { $columnRdBtn.IsChecked = $true } else { $columnRdBtn.IsChecked = $false }
	$startupColumnsStackPanel.Children.Add($columnRdBtn) | Out-Null
}

## DEFAULT/SAVE SETTINGS
########################

$defaultSwitchButton = $window.FindName("defaultSwitchButton")
$defaultSwitchButton.Add_Click({
	# Load default settings
	. "$settingsPath\Settings-Default.ps1"
	
	# Update switches
	$keysSwitch.IsChecked = if ($saveEncryptionKeys -eq $true) { $true } else { $false }
	$restartSwitch.IsChecked = if ($launchOnRestart -eq $true) { $true } else { $false }
	$tooltipSwitch.IsChecked = if ($showTooltips -eq $true) { $true } else { $false }
	$hiddenSwitch.IsChecked = if ($showHiddenPlugins -eq $true) { $true } else { $false }
	$additionalSwitch.IsChecked = if ($showAdditionalPlugins -eq $true) { $true } else { $false }
	$debugSwitch.IsChecked = if ($debugMode -eq $true) { $true } else { $false }
	$startupColumnsStackPanel.Children | Where-Object { $_ -is [System.Windows.Controls.RadioButton] } | ForEach-Object { $_.IsChecked = ($_.Tag -eq $startupColumns) }
})

$saveSwitchButton = $window.FindName("saveSwitchButton")
$saveSwitchButton.Add_Click({
	$scriptContents = @(
		"`$saveEncryptionKeys = $" + $saveEncryptionKeys.ToString().ToLower()
		"`$launchOnRestart = $" + $launchOnRestart.ToString().ToLower()
		"`$showTooltips = $" + $showTooltips.ToString().ToLower()
		"`$showHiddenPlugins = $" + $showHiddenPlugins.ToString().ToLower()
		"`$showAdditionalPlugins = $" + $showAdditionalPlugins.ToString().ToLower()
		"`$debugMode = $" + $debugMode.ToString().ToLower()
		"`$startupColumns = " + $startupColumns
	)
	
	$customSettingsPath = Join-Path $settingsPath "Settings-Custom.ps1"
	Set-Content -Path $customSettingsPath -Value $scriptContents
})

#############################
####  COLORS STACKPANEL  ####
#############################

foreach ($theme in $themes.GetEnumerator()) {
	$button = New-Object System.Windows.Controls.Button
	$button.Width = 83
	$button.Margin = 5
	$button.Tag = $theme.Value
	$button.Background = "Transparent"
	$button.Style = $window.Resources["RoundedButton"]
	$button.Add_Click({
		$selectedTheme = $_.Source.Tag
		$selectedThemeName = $_.Source.Content.Children[0].Text
		
		# Save theme
		Set-Content -Path $savedThemePath -Value "`$savedTheme = `"$selectedThemeName`""
		
		foreach ($key in $selectedTheme.Keys) {
			$value = $selectedTheme[$key]
			New-Variable -Name $key -Value $value -Scope Global -Force
		}
		
		# Update resources dynamically based on their type
		foreach ($resName in $window.Resources.Keys) {
			# Check if the resource key matches a global variable
			if (Get-Variable -Name $resName -Scope Global -ErrorAction SilentlyContinue) {
				$globalValue = (Get-Variable -Name $resName -Scope Global).Value

				# Determine the type of the resource and update accordingly
				$resource = $window.Resources[$resName]
				if ($resource -is [System.Windows.Media.SolidColorBrush]) {
					$window.Resources[$resName] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString($globalValue))
				} elseif ($resource -is [System.Windows.Media.Color]) {
					$window.Resources[$resName] = [System.Windows.Media.ColorConverter]::ConvertFromString($globalValue)
				}
			}
		}
		
		$window.Resources["gradientStrength"] = $gradientStrength
		#$window.Resources["cornerStrength"] = [System.Windows.CornerRadius]($cornerStrength)
		#$window.Resources["cornerStrength1"] = New-Object System.Windows.CornerRadius($cornerStrength, $cornerStrength, 0, 0)
		#$window.Resources["cornerStrength2"] = New-Object System.Windows.CornerRadius(0, 0, $cornerStrength, $cornerStrength)
		
		Set-ResourcePath -ColorRole "Primary" -resourceMappings $primaryResources
		Set-ResourcePath -ColorRole "Background" -resourceMappings $backgroundResources
		Set-ResourcePath -ColorRole "Surface" -resourceMappings $surfaceResources
		Set-ResourcePath -ColorRole "Accent" -resourceMappings $accentResources
		Update-ExpandCollapseButton
	})
	
	$textBlock = New-Object System.Windows.Controls.TextBlock
	$textBlock.Height = 20
	$textBlock.Margin = 5
	$textBlock.Text = $theme.Name
	$textBlock.SetResourceReference([System.Windows.Controls.TextBlock]::ForegroundProperty, "surfaceText")
	$textBlock.Background = "Transparent"
	$textBlock.TextAlignment = "Center"
	$textBlock.TextWrapping = "Wrap"
	
	$border1 = New-Object System.Windows.Controls.Border
	$border1.Width = 15; $border1.Height = 15
	$border1.Margin = 1
	$border1.CornerRadius = "5,0,0,5"
	$border1.Background = $theme.Value.primaryBrush
	
	$border2 = New-Object System.Windows.Controls.Border
	$border2.Width = 15; $border2.Height = 15
	$border2.Margin = 1
	$border2.Background = $theme.Value.backgroundBrush
	
	$border3 = New-Object System.Windows.Controls.Border
	$border3.Width = 15; $border3.Height = 15
	$border3.Margin = 1
	$border3.Background = $theme.Value.surfaceBrush
	
	$border4 = New-Object System.Windows.Controls.Border
	$border4.Width = 15; $border4.Height = 15
	$border4.Margin = 1
	$border4.CornerRadius = "0,5,5,0"
	$border4.Background = $theme.Value.accentBrush
	
	$borderStackPanel = New-Object System.Windows.Controls.StackPanel
	$borderStackPanel.Orientation = "Horizontal"
	$borderStackPanel.HorizontalAlignment = "Center"
	$borderStackPanel.Margin = 5
	$borderStackPanel.AddChild($border1)
	$borderStackPanel.AddChild($border2)
	$borderStackPanel.AddChild($border3)
	$borderStackPanel.AddChild($border4)
	
	$stackPanel = New-Object System.Windows.Controls.StackPanel
	$stackPanel.AddChild($textBlock)
	$stackPanel.AddChild($borderStackPanel)
	$button.Content = $stackPanel
	
	$colorsPanel = $window.FindName("colorsPanel")
	$colorsPanel.AddChild($button)
}

#############################
####   PATH STACKPANEL   ####
#############################

$pathButton = $window.FindName("pathButton")
$pathButton.Add_Click({ Start-Process explorer $atomPath })

#############################
####  GITHUB STACKPANEL  ####
#############################

$githubLinkButton = $window.FindName("githubLinkButton")
$githubLinkButton.Add_Click({ [System.Windows.Forms.Clipboard]::SetText("https://github.com/SkylerWallace/ATOM") })

$githubLaunchButton = $window.FindName("githubLaunchButton")
$githubLaunchButton.Add_Click({ Start-Process "https://github.com/SkylerWallace/ATOM" })

$githubTextBox = $window.FindName("githubTextBox")
$githubTextBox.Text = "https://github.com/SkylerWallace/ATOM"

$window.ShowDialog() | Out-Null