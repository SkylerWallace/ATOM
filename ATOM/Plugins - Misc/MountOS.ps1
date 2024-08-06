Add-Type -AssemblyName PresentationFramework

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$atomPath = $MyInvocation.MyCommand.Definition | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$peDependencies = Join-Path $dependenciesPath "PE"
$logsPath = Join-Path $dependenciesPath "Logs"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"

# Import ATOM core resources
. (Join-Path $dependenciesPath "ATOM-Module.ps1")

$xaml = @"
<Window 
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="MountOS"
	Background="Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	WindowStartupLocation="CenterScreen"
	SizeToContent="WidthAndHeight"
	UseLayoutRounding="True"
	RenderOptions.BitmapScalingMode="HighQuality">
	
	<Window.Resources>
		$resourceDictionary
	</Window.Resources>
	
	<WindowChrome.WindowChrome>
		<WindowChrome ResizeBorderThickness="0" CaptionHeight="0" CornerRadius="10"/>
	</WindowChrome.WindowChrome>
	
	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource backgroundBrush}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
				<Label Content="MountOS" Foreground="{DynamicResource primaryText}" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" Margin="10,0,0,0"/>
				<Button Name="refreshButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,40,0" ToolTip="Refresh drive list"/>
				<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			
			<Grid Grid.Row="1">
				<StackPanel>
					<Label Content="Windows Installation:" Foreground="{DynamicResource surfaceText}" Margin="5,10,10,0"/>
					<Border MaxHeight="100" Style="{StaticResource CustomBorder}" Margin="10,0,10,5">
						<ScrollViewer Name="scrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
							<ListBox Name="driveList" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderThickness="0" Margin="4"/>
						</ScrollViewer>
					</Border>
					<Label Name="encryptionLabel" Content="Encryption Key:" Foreground="{DynamicResource surfaceText}" Margin="5,5,10,0"/>
					
					<Grid Margin="10,0,10,5">
						<Grid.ColumnDefinitions>
							<ColumnDefinition Width="*"/>
							<ColumnDefinition Width="Auto"/>					
						</Grid.ColumnDefinitions>
						<TextBox Name="encryptionBox" Grid.Column="0" Width="380" Height="25" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" VerticalContentAlignment="Center" FontFamily="Consolas" MaxLength="55" Padding="5"/>
						<Button Name="importButton" Grid.Column="1" Content="Import" Width="60" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedButton}" Margin="10,0,0,0" ToolTip="Imports recent key (requires ATOM run in OS)"/>
					</Grid>
					
					<Border Height="100" Style="{StaticResource CustomBorder}" Margin="10,5,10,5">
						<ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
							<TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" TextWrapping="Wrap" Padding="5"/>
						</ScrollViewer>
					</Border>
						
					<Button Name="runButton" Content="Continue" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedButton}" Margin="10,5,10,10"/>
				</StackPanel>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$refreshButton = $window.FindName("refreshButton")
$closeButton = $window.FindName("closeButton")
$driveList = $window.FindName("driveList")
$encryptionLabel = $window.FindName("encryptionLabel")
$encryptionBox = $window.FindName("encryptionBox")
$importButton = $window.FindName("importButton")
$outputBox = $window.FindName("outputBox")
$runButton = $window.FindName("runButton")

# Set icon sources
$primaryResources = @{
	"refreshButton" = "Refresh"
	"closeButton" = "Close"
}

Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources

# UI event handlers
0..1 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

# Run ClearBCD script
$clearBCD = Join-Path $peDependencies "ClearBCD.ps1"
Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$clearBCD`""

# Function for loading all detected Windows drives
function Check-WindowsPaths {
	# Temporarily suppress the driveList.Add_SelectionChanged event handler to prevent errors
	$script:supressSelectionChanged = $true
	
	# Clear all drives from drive list
	$driveList.Items.Clear()
	
	# Bound drives between A and W (PE usually binds to X or Y)
	$validDriveLetters = [char[]](65..87)
	
	# Initialize hashtable for storing drive info
	$script:driveStatuses = [ordered]@{}
	
	# Get encryption status of all encryptable volumes
	$encryptableVolumes = Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -ClassName Win32_EncryptableVolume
	
	# Iterate over all fixed and valid drives
	Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID[0] -in $validDriveLetters } | ForEach-Object {
		$mountPoint = $_.DeviceID
		$driveType = $_.DriveType
		$protectionStatus = switch ($encryptableVolumes | Where-Object { $_.DriveLetter -eq $mountPoint } | Select-Object -ExpandProperty ProtectionStatus) {
			0 { "Not Encrypted" }
			1 { "Encrypted" }
			2 { "Unknown" }
		}
		
		# Add drive info to hashtable
		$script:driveStatuses[$mountPoint] = @{
			Drive = $mountPoint
			DriveType = $driveType
			ProtectionStatus = $protectionStatus
		}
		
		# Early exit if Windows not detected and drive not encrypted
		if (!(Test-Path "${mountPoint}\Windows") -and !($protectionStatus -eq "Encrypted" -or $protectionStatus -eq "Unknown")) {
			return
		}
		
		# Add drive to driveList listbox
		$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
		$listBoxItem.Content = "${mountPoint}\Windows [$protectionStatus]"
		$listBoxItem.Foreground = $surfaceText
		$listBoxItem.Style = $window.FindResource("CustomListBoxItem")
		$driveList.Items.Add($listBoxItem) | Out-Null
	}
	
	# Select first drive in list
	$driveList.SelectedIndex = 0
	
	# Unsuppress the driveList.Add_SelectionChanged event handler
	$script:supressSelectionChanged = $false
}

Check-WindowsPaths

# Function to enable/disable encryption box depending on selected drive
function Update-EncryptionBoxStatus {
	$selectedDrive = $driveList.SelectedItem.Content.Substring(0,2)
	
	$driveInfo = $driveStatuses[$selectedDrive]
	$isEncrypted = $driveInfo.Drive -eq $selectedDrive -and ($driveInfo.ProtectionStatus -eq "Encrypted" -or $driveInfo.ProtectionStatus -eq "Unknown")
	
	if ($isEncrypted) {
		$encryptionBox.IsEnabled = $true
	} else {
		$encryptionLabel.Opacity = 0.2
		$encryptionBox.Opacity = 0.2
		$importButton.Opacity = 0.2
		$encryptionBox.IsEnabled = $false
		$encryptionBox.Clear()
		$importButton.IsEnabled = $false
	}
}

Update-EncryptionBoxStatus

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
	Check-WindowsPaths
	Update-EncryptionBoxStatus
})

# Automatically add -'s to encryption box
$encryptionBox.Add_PreviewTextInput({
	if ($encryptionBox.Text.Length -ge 55) { $_.Handled = $true; return }
	if ($_.Text -match '^\d$') {
		if (($encryptionBox.Text.Length + 1) % 7 -eq 0) {
			$encryptionBox.Text = $encryptionBox.Text.Insert($encryptionBox.Text.Length, "-")
			$encryptionBox.CaretIndex = $encryptionBox.Text.Length # Set cursor to end
		}
	} else { $_.Handled = $true }
})

# Update encryption box status whenever a drive is selected
$driveList.Add_SelectionChanged({
	if (!$script:supressSelectionChanged) {
		Update-EncryptionBoxStatus
	}
})

# When clicked, auto-fill encryption box with latest EncryptionKey file contents
$importButton.Add_Click({
	$latestFile = Get-ChildItem -Path $logsPath -Filter "EncryptionKey-*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if ($latestFile) {
		$key = Get-Content -Path $latestFile.FullName -Raw
		$encryptionBox.Text = $key.Trim()
	} else {
		Write-OutputBox "No encryption key file found!"
	}
})

$runButton.Add_Click({
	# Clear outputBox
	$outputBox.Text = ""
	
	$selectedPath = $driveList.SelectedItem.Content.Split(" ")[0]
	$selectedDrive = $driveList.SelectedItem.Content.Substring(0,2)
	$driveEncrypted = $encryptionBox.IsEnabled
	$keyValid = $encryptionBox.Text.Length -eq 55
	$encryptionKey = $encryptionBox.Text
	$scrollToEnd = $window.FindName("ScrollViewer1").ScrollToEnd()
	
	Create-Runspace -ScriptBlock {
		# Checking EncryptionBox
		if ($driveEncrypted -and $keyValid) {
			Manage-BDE -Unlock $selectedDrive -RecoveryPassword $encryptionKey
		}
		
		# Registry hives
		$hives = @{
			"SAM"		= "RemoteOS-HKLM-SAM"
			"SECURITY"	= "RemoteOS-HKLM-SECURITY"
			"SOFTWARE"	= "RemoteOS-HKLM-SOFTWARE"
			"SYSTEM"	= "RemoteOS-HKLM-SYSTEM"
		}
		
		# Mount each hive
		foreach ($hive in $hives.Keys) {
			$hivePath = Join-Path $selectedPath "System32\config\$($hive)"
			$hiveMount = $hives[$hive]
			
			# Early exit if registry hive not found
			if (!(Test-Path $hivePath)) {
				Write-OutputBox "File not found: $hivePath"
				continue
			}
			
			# Backup registry hives
			$hiveBackup = Join-Path $env:TEMP $hive
			Copy-Item $hivePath $hiveBackup -Force | Out-Null
			
			# Load registry hive
			reg load "HKLM\$($hiveMount)" $hivePath
			
			# Check if hive loaded
			if ($LASTEXITCODE -eq 0) {
				Write-OutputBox "$hiveMount loaded from:"
				Write-OutputBox "$hivePath"
			} else {
				$failedToMount = $true
				Write-OutputBox "Failed to load from $hivePath"
			}
		}
		
		# Failure message
		if ($failedToMount) {
			Write-OutputBox "`nFailed to mount OS!"
			Write-OutputBox "Please try again."
			return
		}
		
		# Create ATOM reg key if missing
		$atomRegKey = "HKLM:\SOFTWARE\ATOM"
		if (!(Test-Path $atomRegKey)) {
			New-Item -Path $atomRegKey
		}
		
		# Set mounted drive reg value
		Set-ItemProperty -Path $atomRegKey -Name "MountedDrive" -Type "String" -Value $selectedDrive
		
		# Success message
		Write-OutputBox "`nFinished mounting OS!"
		Start-Sleep -Seconds 5
		$currentPID = [System.Diagnostics.Process]::GetCurrentProcess().Id
		Stop-Process -Id $currentPID -Force
	}
})

$window.ShowDialog() | Out-Null