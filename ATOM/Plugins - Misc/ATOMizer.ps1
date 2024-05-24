param([string]$atomHost)

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.IO.Compression.Filesystem

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Where { $_.Name -ne "atomHost" } | Select -Expand Name

# Declaring relative paths needed for rest of script
$scriptPath = $MyInvocation.MyCommand.Path
$atomPath = if (($atomHost -eq "") -or ($atomHost -eq $null)) { $scriptPath | Split-Path | Split-Path }
			else { $scriptPath | Split-Path }
$dependenciesPath = Join-Path $atomPath "Dependencies"
$fontsPath = Join-Path $dependenciesPath "Fonts"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$modulePath = Join-Path $dependenciesPath "ATOM-Module.ps1"
$themesPath = Join-Path $settingsPath "Themes.ps1"
$savedThemePath = Join-Path $settingsPath "SavedTheme.ps1"

# Import ATOM core resources
. (Join-Path $dependenciesPath "ATOM-Module.ps1")

# If not running from ATOM temp, copy to temp and run from there
if (($atomPath | Split-Path) -ne $atomTemp) {
	$atomizerCopyPath = Join-Path $atomTemp "ATOMizer"
	$dependenciesCopyPath = Join-Path $atomizerCopyPath "Dependencies"
	$fontsCopyPath = Join-Path $dependenciesCopyPath "Fonts"
	$iconsCopyPath = Join-Path $dependenciesCopyPath "Icons"
	$settingsCopyPath = Join-Path $dependenciesCopyPath "Settings"
	
	# Remove ATOMizer from ATOM temp if it's already there
	if (Test-Path $atomizerCopyPath) {
		Remove-Item $atomizerCopyPath -Recurse
	}
	
	# Create directories in ATOM temp
	New-Item -ItemType Directory -Path $atomizerCopyPath | Out-Null
	New-Item -ItemType Directory -Path $dependenciesCopyPath | Out-Null
	New-Item -ItemType Directory -Path $fontsCopyPath | Out-Null
	New-Item -ItemType Directory -Path $iconsCopyPath | Out-Null
	New-Item -ItemType Directory -Path $settingsCopyPath | Out-Null
	New-Item -ItemType Directory -Path "$iconsCopyPath\Plugins" | Out-Null
	
	# Copy ATOMizer resources to ATOM temp
	Copy-Item $scriptPath -Destination $atomizerCopyPath
	Copy-Item $modulePath -Destination $dependenciesCopyPath
	Copy-Item $themesPath -Destination $settingsCopyPath
	Copy-Item $savedThemePath -Destination $settingsCopyPath
	Copy-Item "$fontsPath\OpenSans-Regular.ttf" -Destination $fontsCopyPath
	Copy-Item "$iconsPath\Plugins\ATOMizer.png" -Destination "$iconsCopyPath\Plugins\ATOMizer.png"
	Copy-Item "$iconsPath\Minimize (Light).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Minimize (Dark).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Refresh (Light).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Refresh (Dark).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Close (Light).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Close (Dark).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Download (Light).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Download (Dark).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Browse (Light).png" -Destination $iconsCopyPath
	Copy-Item "$iconsPath\Browse (Dark).png" -Destination $iconsCopyPath

	$scriptPath = Join-Path $atomizerCopyPath "ATOMizer.ps1"
	Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -AtomHost `"$atomPath`"" -Wait
	Remove-Item $atomizerCopyPath -Recurse -Force
	exit
}

# Make sure variables are passed by called script
if (!($atomHost) -or !($atomTemp)) {
	[System.Windows.MessageBox]::Show("ATOMizer cannot run without the following variables being passed to it:`n`n 1. atomHost`n 2. atomTemp", 'ATOMizer Error', 'OK', 'Warning')
	exit
}

[xml]$xaml = @"
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="ATOMizer"
	Background="Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	WindowStartupLocation="CenterScreen"
	Width="600" Height="400"
	MinWidth="600" MinHeight="300"
	MaxWidth="800" MaxHeight="800"
	UseLayoutRounding="True"
	RenderOptions.BitmapScalingMode="HighQuality">

	<Window.Resources>
		$resourceDictionary
	</Window.Resources>
	
	<WindowChrome.WindowChrome>
		<WindowChrome CaptionHeight="0" CornerRadius="10"/>
	</WindowChrome.WindowChrome>
	
	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource backgroundBrush}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="Auto"/>
				<RowDefinition Height="Auto"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
				<Image Name="logo" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,0,0"/>
				<TextBlock Text="ATOMizer" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="60,0,0,0"/>
				<Button Name="refreshButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,80,0" ToolTip="Refresh drive list"/>
				<Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
				<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			
			<Grid Grid.Row="1" Margin="10,10,10,5">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="4*"/>
					<ColumnDefinition Width="6*"/>
				</Grid.ColumnDefinitions>
				
				<StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
					<RadioButton Name="rbATOM" Content="ATOM" Width="70" FontWeight="Bold" VerticalContentAlignment="Center" GroupName="UpdateOption" IsChecked="True" Margin="0,0,10,0" ToolTip="Deletes then updates ATOM"/>
					<RadioButton Name="rbMerge" Content="Merge" Width="75" FontWeight="Bold" VerticalContentAlignment="Center" GroupName="UpdateOption" Margin="0,0,10,0" ToolTip="Merges selected file"/>
					<RadioButton Name="rbFormat" Content="Format" Width="80" FontWeight="Bold" VerticalContentAlignment="Center" GroupName="UpdateOption" Margin="0,0,10,0" ToolTip="Formats drive to FAT32 and merges selected file"/>
				</StackPanel>
				<TextBox Grid.Column="1" Name="txtDriveName" Text="Type drive name here..." Height="20" Foreground="Transparent" Background="Transparent" HorizontalAlignment="Stretch" VerticalAlignment="Center" HorizontalContentAlignment="Left" VerticalContentAlignment="Center" Margin="10,0,10,0" MaxLength="11" IsEnabled="False"/>
			</Grid>
			
			<Grid Grid.Row="2" Margin="10,5,10,10">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="4*"/>
					<ColumnDefinition Width="6*"/>
				</Grid.ColumnDefinitions>
				
				<StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
					<Button Name="btnDownload" Width="110" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" BorderThickness="0" Style="{StaticResource RoundedButton}" Margin="0,0,10,0" ToolTip="Download file from Github">
						<StackPanel Orientation="Horizontal">
							<Image Name="downloadImage" Width="16" Height="16" Margin="0,0,5,0"/>
							<TextBlock Text="Download" VerticalAlignment="Center"/>
						</StackPanel>
					</Button>
					<Button Name="btnBrowse" Width="110" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" BorderThickness="0" Style="{StaticResource RoundedButton}" ToolTip="Browse for local file">
						<StackPanel Orientation="Horizontal">
							<Image Name="browseImage" Width="16" Height="16" Margin="0,0,5,0"/>
							<TextBlock Text="Browse" VerticalAlignment="Center"/>
						</StackPanel>
					</Button>
				</StackPanel>
				<Label Grid.Column="1" Name="lblSelectedZip" Content="No file selected" Foreground="{DynamicResource surfaceText}" Margin="10,0,0,0"/>
			</Grid>
			
			<Grid Grid.Row="3" Margin="10,0,10,0">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="4*"/>
					<ColumnDefinition Width="6*"/>
				</Grid.ColumnDefinitions>
				<Border Grid.Column="0" Style="{StaticResource CustomBorder}" Margin="0,0,0,0">
					<ScrollViewer Name="scrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<ListBox Name="lbDrives" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderThickness="0" SelectionMode="Extended" Margin="5"/>
					</ScrollViewer>
				</Border>
				<Border Grid.Column="1" Style="{StaticResource CustomBorder}" Margin="10,0,0,0">
					<ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<TextBlock Name="outputBox" TextWrapping="Wrap" Foreground="{DynamicResource surfaceText}" Margin="5" Padding="5"/>
					</ScrollViewer>
				</Border>
			</Grid>
			<Button Name="btnUpdate" Content="Perform Update" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" BorderThickness="0" Grid.Row="4" Margin="10,10,10,10" Style="{StaticResource RoundedButton}"/>
		</Grid>
	</Border>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign variables to elements in XAML
$logo = $window.FindName("logo")
$rbATOM = $window.FindName("rbATOM")
$rbMerge = $window.FindName("rbMerge")
$rbFormat = $window.FindName("rbFormat")
$txtDriveName = $window.FindName("txtDriveName")
$btnDownload = $window.FindName("btnDownload")
$downloadImage = $window.FindName("downloadImage")
$btnBrowse = $window.FindName("btnBrowse")
$browseImage = $window.FindName("browseImage")
$lblSelectedZip = $window.FindName("lblSelectedZip")
$lbDrives = $window.FindName("lbDrives")
$btnUpdate = $window.FindName("btnUpdate")
$outputBox = $window.FindName("outputBox")
$refreshButton = $window.FindName("refreshButton")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")

$logo.Source = Join-Path $iconsPath "Plugins\ATOMizer.png"

# Set icon sources
$primaryResources = @{
	"refreshButton" = "Refresh"
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

$accentResources = @{
	"downloadImage" = "Download"
	"browseImage" = "Browse"
}

Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources
Set-ResourceIcons -iconCategory "Accent" -resourceMappings $accentResources

0..1 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }

# Function to detect all drives and add to drivesList listbox
function Detect-Drives {
	# Clear drives from listbox
	$lbDrives.Items.Clear()
	
	# Get all removable drives
	$drives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Sort-Object -Property DeviceID
	
	# Add all removable drives to listbox
	foreach ($drive in $drives) {
		$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
		$listBoxItem.Content = "$($drive.DeviceID)\ [$($drive.VolumeName)]"
		$listBoxItem.Foreground = $surfaceText
		$listBoxItem.Style = $window.FindResource("CustomListBoxItem")
		$lbDrives.Items.Add($listBoxItem)
	}
}

Detect-Drives | Out-Null

# Window dragging event handler
$window.Add_MouseLeftButtonDown({
	$this.DragMove()
	$request = New-Object System.Windows.Input.TraversalRequest([System.Windows.Input.FocusNavigationDirection]::Next)
	$window.MoveFocus($request)
})

# Title bar buttons event handlers
$refreshButton.Add_Click({
	Spin-RefreshButton
	Detect-Drives
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })

# Radio button event handlers
$rbATOM.Add_Click({ 
	$btnDownload.isEnabled = $true
	$btnDownload.Opacity = 1.0
	$txtDriveName.isEnabled = $false
	$txtDriveName.Foreground = "Transparent"
})

$rbMerge.Add_Click({
	$btnDownload.isEnabled = $false
	$btnDownload.Opacity = 0.25
	$txtDriveName.isEnabled = $false
	$txtDriveName.Foreground = "Transparent"
})

$rbFormat.Add_Click({
	$btnDownload.isEnabled = $false
	$btnDownload.Opacity = 0.25
	$txtDriveName.isEnabled = $true
	$txtDriveName.Foreground = $surfaceText
})

# Drive name textbox event handlers
$txtDriveName.Add_GotFocus({
	if ($txtDriveName.Text -eq "Type drive name here...") {
		$txtDriveName.Clear()
	}
})

$txtDriveName.Add_LostFocus({
	if ($txtDriveName.Text -eq "") {
		$txtDriveName.Text = "Type drive name here..."
	}
})

$txtDriveName.Add_PreviewTextInput({
	$pattern = '[\*\?\/\\|,;:\+=<>\[\]"\.]'
	if ($_.Text -match $pattern) { $_.Handled = $true }
})

# Download button event handler
$btnDownload.Add_Click({
	$downloadUrl = "https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip"
	$script:downloadPath = Join-Path $atomTemp "ATOM-Latest.zip"
	
	Create-Runspace -ScriptBlock {
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke([action]{ $outputBox.Text += "$Text`r`n"; $scrollToEnd }, "Render")
		}
		
		Write-OutputBox "Downloading latest ATOM, please wait..."
		
		try {
			# Attempt to download latest stable ATOM build
			$progressPreference = "SilentlyContinue"
			Invoke-RestMethod -Uri $downloadUrl -OutFile $downloadPath
			Write-OutputBox "Latest ATOM successfully downloaded."
			
			# Update selected file
			$window.Dispatcher.Invoke([action]{ $selectedZip = $downloadPath; $lblSelectedZip.Content = $selectedZip })
		} catch {
			Write-OutputBox "Failed to download latest ATOM."
		}
	}
})

# Browse button event handler
$btnBrowse.Add_Click({
	$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$openFileDialog.Filter = "Zip and ISO files (*.zip, *.iso)|*.zip;*.iso"

	if ($openFileDialog.ShowDialog() -eq "OK") {
		$selectedZip = $openFileDialog.FileName
		$lblSelectedZip.Content = $selectedZip
	}
})

# Drive update button event handler
$btnUpdate.Add_Click({
	$selectedZip = $lblSelectedZip.Content
	$selectedDrives = $lbDrives.SelectedItems.Content.Substring(0,3)
	$selectedDrivesAmount= $selectedDrives.Count
	$isAtom = [bool]$rbATOM.IsChecked
	$isFormat = [bool]$rbFormat.IsChecked
	$driveName = $txtDriveName.Text
	$scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
	
	# Clear OutputBox
	$outputBox.Text = ""
	
	Create-Runspace -ScriptBlock {
		# Function to assist aborting runspace
		function Abort-Runspace {
			Write-OutputBox "Aborting process."
			Invoke-Ui { $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }
		}
		
		# Disable update button while runspace is running
		Invoke-Ui { $btnUpdate.Content = "Running..."; $btnUpdate.IsEnabled = $false }
		
		# Early exit if no selected file
		if ($selectedZip -eq "No file selected") {
			Write-OutputBox "Please select a zip file first."
			Invoke-Ui { $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }
			return
		}
		
		# Early exit if no selected drives
		if ($selectedDrivesAmount -eq 0) {
			Write-OutputBox "Please select at least one drive."
			Invoke-Ui { $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }
			return
		}
		
		# Early exit if formatting & user has not entered a drive name
		if ($isFormat -and $driveName -eq "Type drive name here...") {
			Write-OutputBox "Please enter a drive name..."
			Invoke-Ui { $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }
			return
		}
		
		# Terminate processes running from ATOM if replacing ATOM or formatting
		if (($isAtom -or $isFormat) -and ($atomHost.Substring(0,3) -in $selectedDrives)) {
			$searchedPath = $(
			if ($isAtom) { $atomHost }
			elseif ($isFormat) { Split-Path $atomHost -Qualifier }) -replace '\\', '\\'
			
			$processes = Get-WmiObject -Class Win32_Process -Filter "commandline like '%$searchedPath%' OR executablepath like '%$searchedPath%'"
			$processes | ForEach-Object {
				# Skip processes needed to run ATOMizer
				if ($_.CommandLine -like "*ATOMizer.ps1*") {
					return
				}
				
				# Kill process
				Stop-Process -Id $_.ProcessId
			}
		}
		
		# Mount if selected file is ISO
		$zipName = ([System.IO.FileInfo]$selectedZip).BaseName
		if ($selectedZip.EndsWith(".iso")) {
			try {
				$errorActionPreference = "Stop"
				$isoMount = Mount-DiskImage -ImagePath $selectedZip -PassThru
				$extractPath = ($isoMount | Get-Volume).DriveLetter + ":"
				if (!(Test-Path $extractPath)) { throw }
				Write-OutputBox "Mounted $zipName to $extractPath"
			} catch {
				Write-OutputBox "Failed to mount $zipName"
				Dismount-DiskImage -ImagePath $selectedZip
				Abort-Runspace
				return
			} finally { $errorActionPreference = "Continue" }
		}
		
		# Extract if selected file is zip
		elseif ($selectedZip.EndsWith(".zip")) {
			$extractPath = Join-Path $atomTemp $zipName
			[System.IO.Compression.ZipFile]::ExtractToDirectory($selectedZip, $extractPath)
			Write-OutputBox "Unzipped $zipName"
		}
		
		# Sanity check
		if ($extractPath -eq $null) {
			Write-OutputBox "Something really bad happened..."
			Abort-Runspace
			return
		}
		
		# Start timer
		$timer = [Diagnostics.Stopwatch]::StartNew()
		
		Write-OutputBox "Updating drives...`n"

		foreach ($drive in $selectedDrives) {
			Write-OutputBox $drive
			
			# If ATOM option selected, remove old ATOM
			if ($isAtom -and (Test-Path "$($drive)ATOM")) {
				Remove-Item "$($drive)ATOM.bat" -Force -ErrorAction Ignore
				Remove-Item "$($drive)ATOM" -Recurse -Force -ErrorAction Ignore
				Write-OutputBox "- Removed old ATOM installation"
			}
			
			# If Format option selected, format drive
			elseif ($isFormat) {
				# Determine drive info
				$diskNumber = (Get-Partition -DriveLetter $drive[0]).DiskNumber
				$driveSize = (Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $drive.Substring(0,2) } | Select -Expand Size)
				
				# Sanity check
				if (($diskNumber -eq $null) -or ($driveSize -eq 0) -or ($driveSize -eq $null)) {
					Write-OutputBox "- Drive details cannot be detemined."
					Write-OutputBox "  Aborting drive."
					return
				}
				
				# Clear disk
				Write-OutputBox "- Formatting"
				Clear-Disk -Number $diskNumber -RemoveData -Confirm:$false
				
				# Override partition size if greater than 32GB
				if ($driveSize -le 32GB) {
					$partitionSize = $driveSize
				} else {
					$partitionSize = 32GB
					Write-OutputBox "- Drive partition is > 32GB"
					Write-OutputBox "  Overriding paritition size to 32GB"
				}
				
				# Format drive
				$partition = New-Partition -DiskNumber $diskNumber -Size $partitionSize -DriveLetter $drive[0]
				Format-Volume -Partition $partition -FileSystem FAT32 -NewFileSystemLabel $driveName -Confirm:$false
			}
			
			Write-OutputBox "- Updating"
			
			# Copying files
			$speedFile = Join-Path $atomTemp "speed.txt"
			$roboArgs = @("`"$extractPath`"", "$drive", "/E", "/COPYALL", "/R:0", "/W:0", "/NFL", "/NDL", "/NJH", "/NC", "/NS", "/NP")
			Start-Process -FilePath robocopy -ArgumentList $roboArgs -RedirectStandardOutput $speedFile -NoNewWindow -Wait
			$speed = ((Get-Content $speedFile | Select-String "Bytes/sec" -Context 0,1).Line.Split(' ')[-2] -replace '[^\d.]', '') / 1MB
			
			Write-OutputBox "- Completed: $([int]$speed) MB/s`n"
		}
		
		# Remove downloaded ATOM if detected
		if (Test-Path $downloadPath) {
			Remove-Item $downloadPath -Recurse -Force
			if (!(Test-Path $downloadPath)) { Write-OutputBox "Removed downloaded ATOM." }
		}
		
		# If zip used, delete extracted zip
		if ($selectedZip.EndsWith(".zip")) {
			Remove-Item $extractPath -Recurse -Force
			if (!(Test-Path $extractPath)) { Write-OutputBox "Removed extracted zip." }
		}
		
		# If ISO used, dismount disk
		elseif ($selectedZip.EndsWith(".iso")) {
			try {
				$errorActionPreference = "Stop"
				Dismount-DiskImage -ImagePath $selectedZip
				Write-OutputBox "Unmounted $zipName from $extractPath"
			} catch {
				Write-OutputBox "FAILED TO UNMOUNT $zipName FROM $extractPath"
				Write-OutputBox "YOU MAY NEED TO MANUALLY EJECT VIRTUAL DISK."
			} finally { $errorActionPreference = "Continue" }
		}
		
		# Success message
		$timer.Stop()
		Write-OutputBox "Time: $([int]$timer.Elapsed.TotalSeconds) seconds"
		Write-OutputBox "Update(s) completed."
		
		# Re-enable run button
		Invoke-Ui { $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }
	}
})

Adjust-WindowSize

$window.ShowDialog() | Out-Null