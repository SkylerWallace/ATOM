$version = "v2.8"
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

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
	
		<SolidColorBrush x:Key="primaryColor" Color="#E37222"/>
		<SolidColorBrush x:Key="primaryText" Color="Black"/>
		<SolidColorBrush x:Key="primaryHighlight" Color="#80FFFFFF"/>
		
		<SolidColorBrush x:Key="secondaryColor1" Color="#49494A"/>
		<SolidColorBrush x:Key="secondaryColor2" Color="#272728"/>
		<SolidColorBrush x:Key="secondaryText" Color="White"/>
		<SolidColorBrush x:Key="secondaryHighlight" Color="#80FFFFFF"/>
		
		<SolidColorBrush x:Key="accentColor" Color="#C3C4C4"/>
		<SolidColorBrush x:Key="accentText" Color="Black"/>
		<SolidColorBrush x:Key="accentHighlight" Color="#80FFFFFF"/>
	
		<Style x:Key="CustomThumb" TargetType="{x:Type Thumb}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Thumb}">
						<Border Background="{DynamicResource accentColor}" CornerRadius="3" Margin="0,10,10,10"/>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>

		<Style x:Key="CustomScrollBar" TargetType="{x:Type ScrollBar}">
			<Setter Property="Width" Value="10"/>
			<Setter Property="Background" Value="Transparent"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ScrollBar}">
						<Grid>
							<Rectangle Width="5" Fill="{DynamicResource accentHighlight}" RadiusX="3" RadiusY="3" Margin="0,10,10,10"/>
							<Track x:Name="PART_Track" IsDirectionReversed="True">
								<Track.Thumb>
									<Thumb Style="{StaticResource CustomThumb}"/>
								</Track.Thumb>
							</Track>
						</Grid>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>

		<Style x:Key="CustomScrollViewerStyle" TargetType="{x:Type ScrollViewer}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ScrollViewer}">
						<Grid>
							<Grid.ColumnDefinitions>
								<ColumnDefinition Width="*"/>
								<ColumnDefinition Width="Auto"/>
							</Grid.ColumnDefinitions>
							<ScrollContentPresenter Grid.Column="0"/>
							<ScrollBar x:Name="PART_VerticalScrollBar" Grid.Column="1" Orientation="Vertical" Style="{StaticResource CustomScrollBar}" Maximum="{TemplateBinding ScrollableHeight}" Value="{TemplateBinding VerticalOffset}" ViewportSize="{TemplateBinding ViewportHeight}"/>
						</Grid>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style x:Key="RoundHoverButtonStyle" TargetType="{x:Type Button}">
			<Setter Property="Background" Value="Transparent"/>
			<Setter Property="BorderBrush" Value="Transparent"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Grid>
							<Ellipse x:Name="circle" Fill="Transparent" Width="{TemplateBinding Width}" Height="{TemplateBinding Height}"/>
							<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="2.5"/>
						</Grid>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter TargetName="circle" Property="Fill">
									<Setter.Value>
										<SolidColorBrush Color="#80FFFFFF"/>
									</Setter.Value>
								</Setter>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style x:Key="RoundedButton" TargetType="{x:Type Button}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5">
							<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
						</Border>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter TargetName="border" Property="Background" Value="{DynamicResource secondaryHighlight}"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style x:Key="CustomListBoxItemStyle" TargetType="{x:Type ListBoxItem}">
			<Setter Property="Foreground" Value="White"/>
			<Setter Property="Margin" Value="0.5"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ListBoxItem}">
						<Border Background="{TemplateBinding Background}"
								BorderBrush="{TemplateBinding BorderBrush}"
								BorderThickness="{TemplateBinding BorderThickness}"
								Margin="{TemplateBinding Margin}"
								CornerRadius="5">
							<ContentPresenter/>
						</Border>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter Property="Background" Value="{DynamicResource secondaryHighlight}"/>
								<Setter Property="BorderThickness" Value="1"/>
								<Setter Property="BorderBrush" Value="{DynamicResource secondaryHighlight}"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style TargetType="ToggleButton">
			<Setter Property="Width" Value="40"/>
			<Setter Property="Height" Value="20"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ToggleButton}">
						<Border x:Name="border" Background="{DynamicResource secondaryColor2}" CornerRadius="10">
							<Ellipse x:Name="ellipse" Width="15" Height="15" Fill="{DynamicResource primaryText}" HorizontalAlignment="Left" Margin="2.5"/>
						</Border>
						<ControlTemplate.Triggers>
							<Trigger Property="IsChecked" Value="True">
								<Setter TargetName="ellipse" Property="HorizontalAlignment" Value="Right"/>
								<Setter TargetName="border" Property="Background" Value="{DynamicResource primaryColor}"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style TargetType="RadioButton">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type RadioButton}">
						<BulletDecorator Background="Transparent" Cursor="Hand">
							<BulletDecorator.Bullet>
								<Grid Height="15" Width="15">
									<Ellipse Name="RadioOuter" Fill="Transparent" Stroke="{DynamicResource secondaryText}" StrokeThickness="2" Opacity="0.5"/>
									<Ellipse Name="RadioInner" Fill="{DynamicResource primaryColor}" Visibility="Hidden" Margin="4"/>
								</Grid>
							</BulletDecorator.Bullet>
							<TextBlock Margin="5,0,0,0" Foreground="{DynamicResource secondaryText}" FontSize="12">
								<ContentPresenter/>
							</TextBlock>
						</BulletDecorator>
						<ControlTemplate.Triggers>
							<Trigger Property="IsChecked" Value="true">
								<Setter TargetName="RadioOuter" Property="Opacity" Value="1.0"/>
								<Setter TargetName="RadioOuter" Property="Stroke" Value="{DynamicResource primaryColor}"/>
								<Setter TargetName="RadioInner" Property="Visibility" Value="Visible"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
	</Window.Resources>

	<WindowChrome.WindowChrome>
		<WindowChrome CaptionHeight="0" CornerRadius="10"/>
	</WindowChrome.WindowChrome>

	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource secondaryColor2}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="70"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryColor}" CornerRadius="5,5,0,0"/>
				<Grid>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width="*"/>
						<ColumnDefinition Width="Auto"/>
					</Grid.ColumnDefinitions>
					
					<Grid Grid.Column="0" Margin="10,10,5,10">
						<Image x:Name="logo" Width="130" Height="60" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5,5,0,0"/>
						<Button x:Name="superSecretButton" Width="6" Height="6" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Left" Margin="129,23,0,0"/>
					</Grid>
					
					<Grid Grid.Column="1" Margin="5,10,10,10">
						<Button x:Name="peButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,80,0"/>
						<Button x:Name="refreshButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,40,0" ToolTip="Reload Plugins"/>
						<Button x:Name="settingsButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,0,0" ToolTip="Settings"/>
						<Button x:Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,80,0" ToolTip="Minimize"/>
						<Button x:Name="columnButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,40,0"/>
						<Button x:Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,0,0" ToolTip="Close"/>
					</Grid>
				</Grid>
			</Grid>
			<ScrollViewer x:Name="scrollViewer" Grid.Row="1" VerticalScrollBarVisibility="Visible" Style="{StaticResource CustomScrollViewerStyle}">
				<WrapPanel x:Name="pluginStackPanel" Orientation="Horizontal" Margin="10,0,0,10"/>
			</ScrollViewer>
			<Grid Grid.Row="2" Margin="10,0,10,10">
				<Rectangle Height="20" Fill="{DynamicResource accentColor}" RadiusX="5" RadiusY="5"/>
				<Grid>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width="*"/>
						<ColumnDefinition Width="Auto"/>
					</Grid.ColumnDefinitions>
					
					<TextBlock x:Name="statusBarStatus" Grid.Column="0" Foreground="{DynamicResource accentText}" FontSize="10" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,5,0"/>
					<TextBlock x:Name="statusBarVersion" Grid.Column="1" Foreground="{DynamicResource accentText}" FontSize="10" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5,0,10,0"/>
				</Grid>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

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
$pluginStackPanel = $window.FindName("pluginStackPanel")
$statusBarStatus = $window.FindName("statusBarStatus")
$statusBarVersion = $window.FindName("statusBarVersion")
$statusBarVersion.Text = "$version"

# Load settings, color theming, & quips
$defaultSettingsConfig = Join-Path $settingsPath "Settings-Default.ps1"
$settingsConfig = Join-Path $settingsPath "Settings-Custom.ps1"
. $defaultSettingsConfig
. $settingsConfig

$defaultColorsPath = Join-Path $settingsPath "Colors-Default.ps1"
$colorsPath = Join-Path $settingsPath "Colors-Custom.ps1"
. $defaultColorsPath
. $colorsPath

$quipPath = Join-Path $dependenciesPath "Quippy.ps1"
. $quipPath

$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"
$fontFamily = New-Object Windows.Media.FontFamily "file:///$fontPath#Open Sans"
$window.FontFamily = $fontFamily

function Set-ButtonIcon ($button, $iconName) {
	$uri = New-Object System.Uri (Join-Path $iconsPath "$iconName.png")
	$img = New-Object System.Windows.Media.Imaging.BitmapImage $uri
	$button.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img }
}

if ($primaryIcons -eq "Light") {
	$logo.Source = Join-Path $iconsPath "ATOM Logo (Light).png"
	$peButton1 = "MountOS (Light)"
	$peButton2 = "Reboot2PE (Light)"
	$buttons = @{ "Settings (Light)" = $settingsButton; "Refresh (Light)" = $refreshButton; "Minimize (Light)" = $minimizeButton; "Close (Light)" = $closeButton }
} else {
	$logo.Source = Join-Path $iconsPath "ATOM Logo (Dark).png"
	$peButton1 = "MountOS (Dark)"
	$peButton2 = "Reboot2PE (Dark)"
	$buttons = @{ "Settings (Dark)" = $settingsButton; "Refresh (Dark)" = $refreshButton; "Minimize (Dark)" = $minimizeButton; "Close (Dark)" = $closeButton }
}

$buttons.GetEnumerator() | %{ Set-ButtonIcon $_.Value $_.Key }

$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$pePath = Join-Path $drivePath "sources\boot.wim"
$peOnDrive = Test-Path $pePath
if ($inPE) {
	Set-ButtonIcon $peButton $peButton1
	$peButton.ToolTip = "Launch MountOS"
	
	$peButton.Add_Click({
		$mountOS = Join-Path $dependenciesPath "MountOS.ps1"
		Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$mountOS`""
	})
} elseif ($peOnDrive) {
	Set-ButtonIcon $peButton $peButton2
	$peButton.ToolTip = "Reboot to PE"
	
	$peButton.Add_Click({
		$boot2PE = Join-Path $dependenciesPath "Boot2PE.bat"
		Start-Process cmd.exe -WindowStyle Hidden -ArgumentList "/c `"$boot2PE`""
	})
} else {
	Set-ButtonIcon $peButton $peButton2
	$peButton.isEnabled = $false
	$peButton.Opacity = 0.5
}

if ($saveEncryptionKeys -and !$inPE) {
	# Output BitLocker key to text file in log path
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

function Load-Scripts {
	$pluginStackPanel.Children.Clear()
	
	if ($showAdditionalPlugins) {
		$pluginFolders = Get-ChildItem -Path $atomPath -Directory | Where-Object { $_.Name -like "Plugins -*" -or $_.Name -eq "Additional Plugins" } | Sort-Object Name
	} else {
		$pluginFolders = Get-ChildItem -Path $atomPath -Directory | Where-Object { $_.Name -like "Plugins -*" } | Sort-Object Name
		$categoryNames = @("Additional Plugins")
	}
	
	$categoryNames += $pluginFolders | ForEach-Object { $_.Name } | Sort-Object -Unique
	
	foreach ($pluginFolder in $pluginFolders) {
		$header = $pluginFolder.Name -replace '^Plugins - ',''
		$grid = New-Object System.Windows.Controls.Grid
		$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
		$grid.RowDefinitions.Add((New-Object System.Windows.Controls.RowDefinition))
		$grid.Margin = "0,0,10,0"
		
		$textBlock = New-Object System.Windows.Controls.TextBlock
		$textBlock.Text = $header
		$textBlock.Foreground = $secondaryText
		$textBlock.FontSize = 14
		$textBlock.Margin = "0,10,0,0"
		$textBlock.VerticalAlignment = [System.Windows.VerticalAlignment]::Bottom
		$grid.Children.Add($textBlock) | Out-Null

		$border = New-Object System.Windows.Controls.Border
		$border.Background = $secondaryColor1
		$border.CornerRadius = 5
		$border.Margin = "0,5,0,0"
		$border.SetValue([System.Windows.Controls.Grid]::RowProperty, 1)

		$listBox = New-Object System.Windows.Controls.ListBox
		$listBox.Background = "Transparent"
		$listBox.Foreground = $secondaryText
		$listBox.BorderThickness = 0
		$listBox.Margin = 5
		$listBox.Padding = 0
		$listBox.Width = 200
		$listBox.Tag = $categoryNames

		$border.Child = $listBox
		
		$grid.Children.Add($border) | Out-Null
		$grid.RowDefinitions[0].Height = [System.Windows.GridLength]::new(30)
		$pluginStackPanel.Children.Add($grid) | Out-Null
		
		$files = Get-ChildItem -Path $pluginFolder.FullName -Include *.ps1, *.bat, *.exe, *.lnk -Recurse | Sort-Object Name
		
		foreach ($file in $files) {
			$nameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
			$iconPath = Join-Path $pluginsIconsPath "$nameWithoutExtension.png"
			$iconExists = Test-Path $iconPath
			if (!$iconExists) {
				$firstLetter = $nameWithoutExtension.Substring(0,1)
				$iconPath = if ($firstLetter -match "^[A-Z]") { Join-Path $iconsPath "\Default\Default$firstLetter.png" }
							else { Join-Path $iconsPath "\Default\Default.png" }
			}
			
			$image = New-Object System.Windows.Controls.Image
			$image.Source = New-Object System.Windows.Media.Imaging.BitmapImage (New-Object System.Uri $iconPath)
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
			$listBoxItem.Foreground = $secondaryText
			$listBoxItem.Content = $stackPanel	
			
			$listBoxItem.Add_MouseDoubleClick({
				$selectedFile = $_.Source.Tag
				if ($selectedFile -match '\.ps1$') {
					if ((Get-Content $selectedFile -First 1) -eq "# Launch: Hidden") {
						Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$selectedFile`""
					} else {
						Start-Process powershell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "`"$selectedFile`""
					}
				} elseif ($selectedFile -match '\.bat$') {
					if ((Get-Content $selectedFile -First 1) -eq "REM Launch: Hidden") {
						Start-Process cmd.exe -WindowStyle Hidden -ArgumentList "/c `"$selectedFile`""
					} else {
						Start-Process -FilePath "`"$selectedFile`""
					}
				} elseif ($selectedFile -match '\.exe$' -or $selectedFile -match '\.lnk$') {
					Start-Process -FilePath "`"$selectedFile`""
				}
				$nameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($selectedFile)
				$statusBarStatus.Text = "Running $nameWithoutExtension"
			})
			
			$listBoxItem.Add_MouseRightButtonUp({
				$contextMenu = New-Object System.Windows.Controls.ContextMenu
				$categories = $this.Parent.Tag
				$selectedFile = $_.Source.Tag
				
				foreach ($category in $categories) {
					$menuItem = New-Object System.Windows.Controls.MenuItem
					$menuItem.Header = "Move to " + ($category -replace '^Plugins - ', '')
					$menuItem.Tag = @{ "File" = $selectedFile; "Category" = $category }
					
					$menuItem.Add_Click({
						$selectedFile = $this.Tag["File"]
						$selectedCategory = $this.Tag["Category"]
						$destinationPath = Join-Path $atomPath $selectedCategory
						
						Move-Item -LiteralPath $selectedFile -Destination $destinationPath
						Load-Scripts
					})
					
					$contextMenu.Items.Add($menuItem)
				}
				
				$contextMenu.IsOpen = $true
			})
			
			$listBoxItem.Style = $window.FindResource("CustomListBoxItemStyle")
			$listBox.Items.Add($listBoxItem) | Out-Null
		}
	}
}

Load-Scripts

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
	Load-Scripts
	$window.SizeToContent = 'Height'
})

$settingsScript = Join-Path $atomPath "ATOM-Settings.ps1"
. $settingsScript

$settingsButton.Add_Click({
	$pluginStackPanel.Children.Clear()
	$scrollViewer.Content = $settingsStackPanel
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })

function Update-ExpandCollapseButton {
	if ($window.Width -gt 257 -and $window.Width -le 469) {
		$columnButton.ToolTip = "One-Column View"
		if ($primaryIcons -eq "Light") {
			Set-ButtonIcon $columnButton "Column-1 (Light)"
		} else {
			Set-ButtonIcon $columnButton "Column-1 (Dark)"
		}
	} else {
		$columnButton.ToolTip = "Two-Column View"
		if ($primaryIcons -eq "Light") {
			Set-ButtonIcon $columnButton "Column-2 (Light)"
		} else {
			Set-ButtonIcon $columnButton "Column-2 (Dark)"
		}
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
	$children = $pluginStackPanel.Children | ForEach-Object { $_ }
	$pluginStackPanel.Children.Clear()
	if ($window.Width -gt 257 -and $window.Width -le 469) { $window.Width = 255 } else { $window.Width = 469 }
	$children | ForEach-Object { $pluginStackPanel.Children.Add($_) }
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