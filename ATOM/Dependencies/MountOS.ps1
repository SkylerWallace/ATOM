Add-Type -AssemblyName PresentationFramework

$dependenciesPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"

# Import custom window resources and color theming
$dictionaryPath = Join-Path $dependenciesPath "ResourceDictionary.ps1"
. $dictionaryPath

[xml]$xaml = @"
<Window 
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="MountOS"
	Background="Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	WindowStartupLocation="CenterScreen"
	Width="450" SizeToContent="Height"
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
				<Label Content="ATOM PE MountOS" Foreground="{DynamicResource primaryText}" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" Margin="10,0,0,0"/>
				<Button x:Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0"/>
			</Grid>
			
			<Grid Grid.Row="1">
				<StackPanel>
					<Label Content="Windows Installation:" Foreground="{DynamicResource surfaceText}" Margin="5,10,10,0"/>
					<Border MaxHeight="100" Style="{StaticResource CustomBorder}" Margin="10,0,10,5">
						<ScrollViewer x:Name="ScrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
							<ListBox Name="driveList" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderThickness="0" Margin="4"/>
						</ScrollViewer>
					</Border>
					<Label Name="encryptionLabel" Content="Encryption Key:" Foreground="{DynamicResource surfaceText}" Margin="5,5,10,0"/>
					
					<Grid Margin="10,0,10,5">
						<Grid.ColumnDefinitions>
							<ColumnDefinition Width="*"/>
							<ColumnDefinition Width="Auto"/>					
						</Grid.ColumnDefinitions>
						<TextBox Name="encryptionBox" Grid.Column="0" Height="25" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" VerticalContentAlignment="Center" MaxLength="55" Padding="5"/>
						<Button Name="importButton" Grid.Column="1" Content="Import" Style="{StaticResource RoundedButton}" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10,0,0,0" ToolTip="Imports recent key (requires ATOM run in OS)"/>
					</Grid>
					
					<Border Height="100" Style="{StaticResource CustomBorder}" Margin="10,5,10,5">
						<ScrollViewer x:Name="ScrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
							<TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" TextWrapping="Wrap" Padding="5"/>
						</ScrollViewer>
					</Border>
						
					<Button Name="runButton" Content="Continue" Style="{StaticResource RoundedButton}" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="10,5,10,10"/>
				</StackPanel>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$closeButton = $window.FindName("closeButton")
$listBox = $window.FindName("driveList")
$encryptionLabel = $window.FindName("encryptionLabel")
$encryptionBox = $window.FindName("encryptionBox")
$importButton = $window.FindName("importButton")
$scrollViewer = $window.FindName("ScrollViewer0")
$outputBox = $window.FindName("outputBox")
$runButton = $window.FindName("runButton")

# Set icon sources
$primaryResources = @{
	"closeButton" = "Close"
}

Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources


$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"
$fontFamily = New-Object Windows.Media.FontFamily "file:///$fontPath#Open Sans"
$window.FontFamily = $fontFamily

0..1 | % { $window.FindName("ScrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }

$closeButton.Add_Click({ $window.Close() })

$clearBCD = Join-Path $dependenciesPath "ClearBCD.ps1"
Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$clearBCD`""

function Update-BitLockerKeyBoxStatus {
	$selectedDrive = $listBox.SelectedItem.Substring(0,2)

	$isEncrypted = $driveStatuses | Where-Object { $_.Drive -eq $selectedDrive -and ($_.Status -eq "Encrypted" -or $_.Status -eq "Encrypted but Locked") }

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

function Check-WindowsPaths {
	$listBox.Items.Clear()

	$validDriveLetters = [char[]](65..87)
	$driveStatuses = @()

	$encryptableVolumes = Get-CimInstance -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -ClassName Win32_EncryptableVolume

	Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -and $_.DeviceID[0] -in $validDriveLetters } | ForEach-Object {
		$mountPoint = $_.DeviceID
		$status = switch ($encryptableVolumes | Where-Object { $_.DriveLetter -eq $mountPoint } | Select-Object -ExpandProperty ProtectionStatus) {
			0 { "Not Encrypted" }
			1 { "Encrypted but Locked" }
			2 { "Encrypted" }
			default { "Unknown" }
		}

		$driveStatuses += [PSCustomObject]@{
			Drive  = $mountPoint
			Status = $status
		}
		
		if ((Test-Path "${mountPoint}\Windows") -or ($status -eq "Encrypted" -or $status -eq "Encrypted but Locked")) {
			$label = "${mountPoint}\Windows"
			if ($status -eq "Encrypted" -or $status -eq "Encrypted but Locked") {
				$label = "$label [Encrypted]"
			}
			$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
			$listBoxItem.Content = $label
			$listBoxItem.Foreground = $surfaceText
			$listBoxItem.Style = $window.FindResource("CustomListBoxItem")
			$listBox.Items.Add($listBoxItem) | Out-Null
		}
	}
	
	$listBox.SelectedIndex = 0	
	Update-BitLockerKeyBoxStatus
}

Check-WindowsPaths

$encryptionBox.Add_PreviewTextInput({
	if ($encryptionBox.Text.Length -ge 55) { $_.Handled = $true; return }
	if ($_.Text -match '^\d$') {
		if (($encryptionBox.Text.Length + 1) % 7 -eq 0) {
			$encryptionBox.Text = $encryptionBox.Text.Insert($encryptionBox.Text.Length, "-")
			$encryptionBox.CaretIndex = $encryptionBox.Text.Length # Set cursor to end
		}
	} else { $_.Handled = $true }
})

$listBox.Add_SelectionChanged({
	Update-BitLockerKeyBoxStatus
})

$importButton.Add_Click({
	$latestFile = Get-ChildItem -Path "Y:\ATOM\Logs" -Filter "EncryptionKey-*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if ($latestFile) {
		$key = Get-Content -Path $latestFile.FullName -Raw
		$encryptionBox.Text = $key.Trim()
	} else {
		Write-OutputBox "No encryption key file found!"
	}
})

$runButton.Add_Click({
	$selectedPath = $listBox.SelectedItem.Split(" ")[0]
	$selectedDrive = $listBox.SelectedItem.Substring(0,2)
	$driveEncrypted = $encryptionBox.IsEnabled
	$keyValid = $encryptionBox.Text.Length -eq 55
	$encryptionKey = $encryptionBox.Text
	$scrollToEnd = $window.FindName("ScrollViewer1").ScrollToEnd()
	
	$runspace = [runspacefactory]::CreateRunspace()
	$runspace.ApartmentState = "STA"
	$runspace.ThreadOptions = "ReuseThread"
	$runspace.Open()

	$runspace.SessionStateProxy.SetVariable('encryptionBox', $encryptionBox)
	$runspace.SessionStateProxy.SetVariable('listBox', $listBox)
	$runspace.SessionStateProxy.SetVariable('outputBox', $outputBox)
	$runspace.SessionStateProxy.SetVariable('selectedPath', $selectedPath)
	$runspace.SessionStateProxy.SetVariable('selectedDrive', $selectedDrive)
	$runspace.SessionStateProxy.SetVariable('driveEncrypted', $driveEncrypted)
	$runspace.SessionStateProxy.SetVariable('keyValid', $keyValid)
	$runspace.SessionStateProxy.SetVariable('encryptionKey', $encryptionKey)
	$runspace.SessionStateProxy.SetVariable('scrollToEnd', $scrollToEnd)

	$powershell = [powershell]::Create().AddScript({
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke(
				[action]{$outputBox.Text += "$Text`r`n"
				$scrollToEnd},
				[System.Windows.Threading.DispatcherPriority]::Render
			)
		}

		# Checking EncryptionBox
		if ($driveEncrypted -and $keyValid) {
			Manage-BDE -Unlock $selectedDrive -RecoveryPassword $encryptionKey
		}
		
		function Load-RegHives {
			$hives = @{
				"SAM"		= "RemoteOS-HKLM-SAM";
				"SECURITY"	= "RemoteOS-HKLM-SECURITY";
				"SOFTWARE"	= "RemoteOS-HKLM-SOFTWARE";
				"SYSTEM"	= "RemoteOS-HKLM-SYSTEM";
			}

			foreach ($hive in $hives.GetEnumerator()) {
				$hivePath = Join-Path $selectedPath "System32\config\$($hive.Key)"
				if (Test-Path $hivePath) {
					try {
						reg load "HKLM\$($hive.Value)" $hivePath
						Write-OutputBox "$($hive.Value) loaded from $hivePath"
					} catch {
						Write-OutputBox "$($hive.Value) failed to load from $hivePath"
					}
				} else {
					Write-OutputBox "File not found: $hivePath"
				}
			}
		}
		
		Load-RegHives
		
		Write-OutputBox "Finished mounting OS!"
		Start-Sleep -Seconds 3
		$currentPID = [System.Diagnostics.Process]::GetCurrentProcess().Id
		Stop-Process -Id $currentPID -Force
	})
	$powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
})

# Handle window dragging
$window.Add_MouseLeftButtonDown({$this.DragMove()})

$window.ShowDialog() | Out-Null