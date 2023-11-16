Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window 
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="MountOS"
	Background = "Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	WindowStartupLocation="CenterScreen"
	SizeToContent="Height" Width="450"
	RenderOptions.BitmapScalingMode="HighQuality">
	
	<Window.Resources>
	
		<Style x:Key="CustomThumb" TargetType="{x:Type Thumb}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Thumb}">
						<Border Background="#C3C4C4" CornerRadius="3" Margin="0,10,10,10"/>
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
							<Rectangle Width="5" Fill="Black" RadiusX="3" RadiusY="3" Margin="0,10,10,10"/>
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
	
		<Style TargetType="TextBox">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="TextBox">
						<Border Background="{TemplateBinding Background}"
								CornerRadius="5">
							<ScrollViewer Margin="0" x:Name="PART_ContentHost"/>
						</Border>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style TargetType="Button">
			<Setter Property="Background" Value="White"/>
			<Setter Property="BorderBrush" Value="White"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5" Padding="5">
							<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
						</Border>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter TargetName="border" Property="Background" Value="LightGray"/>
							</Trigger>
						</ControlTemplate.Triggers>
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
							<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
						</Grid>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter TargetName="circle" Property="Fill">
									<Setter.Value>
										<SolidColorBrush Color="White" Opacity="0.5"/>
									</Setter.Value>
								</Setter>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style TargetType="ListBoxItem">
			<Setter Property="Foreground" Value="White"/>
			<Setter Property="Margin" Value="1"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ListBoxItem}">
						<Border Background="{TemplateBinding Background}"
								BorderBrush="{TemplateBinding BorderBrush}"
								BorderThickness="0"
								Margin="{TemplateBinding Margin}"
								Padding="10,5,10,5"
								CornerRadius="5">
							<ContentPresenter/>
						</Border>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter Property="Background" Value="#80FFFFFF"/>
							</Trigger>
							<Trigger Property="IsSelected" Value="True">
								<Setter Property="Background" Value="#737474"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
	
	</Window.Resources>
	
	<WindowChrome.WindowChrome>
		<WindowChrome ResizeBorderThickness="0"/>
	</WindowChrome.WindowChrome>
	
	<Border BorderBrush="Transparent" BorderThickness="0" Background="#272728" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			
			<Grid Grid.Row="0">
				<Border Background="#E37222" CornerRadius="5,5,0,0"/>
				<Label Content="ATOM PE MountOS" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" Margin="10,0,0,0"/>
				<Button x:Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0"/>
			</Grid>
			
			<Grid Grid.Row="1">
				<StackPanel>
					<Label Content="Windows Installation:" Foreground="White" Margin="5,10,10,0"/>
					<Border MaxHeight="100" Background="#49494A" CornerRadius="5" Margin="10,0,10,5">
						<ScrollViewer x:Name="ScrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
							<ListBox Name="driveList" Background="Transparent" Foreground="White" BorderThickness="0" Margin="4"/>
						</ScrollViewer>
					</Border>
					<Label Name="encryptionLabel" Content="Encryption Key:" Foreground="White" Margin="5,5,10,0"/>
					
					<Grid Margin="10,0,10,5">
						<Grid.ColumnDefinitions>
							<ColumnDefinition Width="*"/>
							<ColumnDefinition Width="Auto"/>					
						</Grid.ColumnDefinitions>
						<TextBox Name="encryptionBox" Grid.Column="0" Height="25" Background="White" Foreground="Black" VerticalContentAlignment="Center" IsEnabled="False" MaxLength="55"/>
						<Button Name="importButton" Grid.Column="1" Content="Import" Margin="10,0,0,0" Padding="5,0,5,0" ToolTip="Imports recent key (requires ATOM run in OS)"/>
					</Grid>
					
					<Border Height="100" Background="#49494A" CornerRadius="5" Margin="10,5,10,5">
						<ScrollViewer x:Name="ScrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
							<TextBlock Name="outputBox" Foreground="White" TextWrapping="Wrap" Padding="5"/>
						</ScrollViewer>
					</Border>
						
					<Button Name="runButton" Content="Continue" Margin="10,5,10,10"/>
				</StackPanel>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$dependenciesPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iconsPath = Join-Path $dependenciesPath "Icons"

$closeButton = $window.FindName("closeButton")
$listBox = $window.FindName("driveList")
$encryptionLabel = $window.FindName("encryptionLabel")
$encryptionBox = $window.FindName("encryptionBox")
$importButton = $window.FindName("importButton")
$scrollViewer = $window.FindName("ScrollViewer0")
$outputBox = $window.FindName("outputBox")
$runButton = $window.FindName("runButton")

$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"
$fontFamily = New-Object Windows.Media.FontFamily "file:///$fontPath#Open Sans"
$window.FontFamily = $fontFamily

$buttons = @{ "Close"=$closeButton }
$buttons.GetEnumerator() | %{
	$uri = New-Object System.Uri (Join-Path $iconsPath "$($_.Key).png")
	$img = New-Object System.Windows.Media.Imaging.BitmapImage $uri
	$_.Value.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img }
}

0..1 | % { $window.FindName("ScrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }

$closeButton.Add_Click({
	$window.Close()
})

$clearBCD = Join-Path $dependenciesPath "ClearBCD.ps1"
Start-Process powershell -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$clearBCD`""

function Update-BitLockerKeyBoxStatus {
	$selectedDrive = $listBox.SelectedItem.Substring(0,2)

	$isEncrypted = $driveStatuses | Where-Object { $_.Drive -eq $selectedDrive -and ($_.Status -eq "Encrypted" -or $_.Status -eq "Encrypted but Locked") }

	if ($isEncrypted) {
		$encryptionLabel.Foreground = 'White'
		$encryptionBox.IsEnabled = $true
		$encryptionBox.Background = 'White'
		$encryptionBox.Foreground = 'Black'
		$importButton.IsEnabled = $true
		$importButton.Background = "White"
		$importButton.Foreground = "Black"
	} else {
		$encryptionLabel.Foreground = 'Gray'
		$encryptionBox.IsEnabled = $false
		$encryptionBox.Background = '#49494A'
		$encryptionBox.Foreground = 'Gray'
		$encryptionBox.Clear()
		$importButton.IsEnabled = $false
		$importButton.Background = "#49494A"
		$importButton.Foreground = "Gray"
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
			$listBox.Items.Add($label) | Out-Null
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