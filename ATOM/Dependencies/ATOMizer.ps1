# Launch: Hidden

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$scriptDriveLetter = Split-Path $MyInvocation.MyCommand.Path -Qualifier
$preAtomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$atomPath = Split-Path $MyInvocation.MyCommand.Path -Parent
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"

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

function AddDrivesToList {
	param(
		[Parameter(Mandatory=$true)]
		$DriveList
	)

	$drives = Get-Volume | Where-Object { $_.DriveType -eq "Removable" } | Sort-Object -Property DriveLetter

	foreach ($drive in $drives) {
		$driveLetter = $drive.DriveLetter
		$driveLabel = $drive.FileSystemLabel
		
		$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
		$listBoxItem.Content = "$($driveLetter):\$($driveLabel)"
		$listBoxItem.Foreground = $surfaceText
		$listBoxItem.Style = $window.FindResource("CustomListBoxItem")
		$DriveList.Items.Add($listBoxItem)
	}
	
	$DriveList.AddHandler([System.Windows.Controls.ListBoxItem]::MouseLeftButtonDownEvent, [System.Windows.RoutedEventHandler]{
		param($sender, $e)
		$item = $sender.Source
		if ($DriveList.SelectedItems -contains $item.Content) {
			$DriveList.SelectedItems.Remove($item.Content)
		} else {
			$DriveList.SelectedItems.Add($item.Content)
		}
		$e.Handled = $true
	})
}

AddDrivesToList -DriveList $lbDrives | Out-Null

$btnDownload.Add_Click({
	$downloadURL = "https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip"
	$downloadPath = Join-Path $preAtomPath "ATOM-Latest.zip"
	
	Create-Runspace -ScriptBlock {
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke([action]{ $outputBox.Text += "$Text`r`n"; $scrollToEnd }, "Render")
		}
		
		Write-OutputBox "Downloading latest ATOM, please wait..."
		$ProgressPreference = 'SilentlyContinue'
		Invoke-RestMethod -Uri $downloadURL -OutFile $downloadPath
		Write-OutputBox "Latest ATOM successfully downloaded."
	}
	
	$selectedZip = $downloadPath
	$lblSelectedZip.Content = $selectedZip
})

$btnBrowse.Add_Click({
	$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$openFileDialog.Filter = "Zip and ISO files (*.zip, *.iso)|*.zip;*.iso"

	if ($openFileDialog.ShowDialog() -eq "OK") {
		$selectedZip = $openFileDialog.FileName
		$lblSelectedZip.Content = $selectedZip
	}
})

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
	$lbDrives.Items.Clear()
	Spin-RefreshButton
	AddDrivesToList -DriveList $lbDrives
})
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })

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

$btnUpdate.Add_Click({
	$selectedZip = $lblSelectedZip.Content
	$selectedDrives = @($lbDrives.SelectedItems)
	$selectedDrivesAmount= $selectedDrives.Count
	$isATOM = [bool]$rbATOM.IsChecked
	$isFormat = [bool]$rbFormat.IsChecked
	$driveName = $txtDriveName.Text
	$downloadPath = Join-Path $preAtomPath "ATOM-Latest.zip"
	$scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()

	Create-Runspace -ScriptBlock {
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke([action]{ $outputBox.Text += "$Text`r`n"; $scrollToEnd }, "Render")
		}
		
		$btnUpdate.Dispatcher.Invoke([action]{ $btnUpdate.Content = "Running..."; $btnUpdate.IsEnabled = $false }, "Render")
		
		if ($selectedZip -eq "No file selected") {
			Write-OutputBox "Please select a zip file first."
			$btnUpdate.Dispatcher.Invoke([action]{ $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }, "Render")
			return
		}

		if ($selectedDrivesAmount -eq 0) {
			Write-OutputBox "Please select at least one drive."
			$btnUpdate.Dispatcher.Invoke([action]{ $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }, "Render")
			return
		}
		
		if ($isFormat -and $driveName -eq "Type drive name here...") {
			Write-OutputBox "Please enter a drive name..."
			$btnUpdate.Dispatcher.Invoke([action]{ $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }, "Render")
			return
		}

		Write-OutputBox "Updating drives...`n"
		
		$driveLetters = $selectedDrives | ForEach-Object {
			if ($_ -match '([A-Za-z]:\\)') {
				$matches[1]
			}
		}
		
		function Update-Drives {
			param(
				[string]$zipFile,
				[string[]]$drives,
				[bool]$isATOM,
				[bool]$isFormat
			)

			$shell = New-Object -ComObject Shell.Application
			$fileExtension = [System.IO.Path]::GetExtension($selectedZip)

			foreach ($drive in $drives) {
				$driveLetter = $drive[0]
				$driveInfo = Get-Volume -DriveLetter $driveLetter
				Write-OutputBox "$($driveLetter):\"
				if(($isFormat -or $isATOM) -and ($drives -like "$scriptDriveLetter*")) {
					taskkill /fi "WindowTitle eq ATOM *" /f
				}
				if ($isFormat) {
					$diskNumber = (Get-Partition -DriveLetter $driveLetter).DiskNumber
					Clear-Disk -Number $diskNumber -RemoveData -Confirm:$false
					$partitionSize = if ($driveInfo.Size -gt 32GB) {
						32GB
						Write-OutputBox "- Drive partition is > 32GB"
						Write-OutputBox "  Overriding paritition size to 32GB"
						} else {$driveInfo.Size}
					$partition = New-Partition -DiskNumber $diskNumber -Size $partitionSize -DriveLetter $driveLetter
					Format-Volume -Partition $partition -FileSystem FAT32 -NewFileSystemLabel $driveName -Confirm:$false
					Write-OutputBox "- Formatted"
				} elseif ($isATOM) {
					if ((Test-Path "$drive\ATOM.bat") -or (Test-Path "$drive\ATOM")) {
						Remove-Item "$drive\ATOM.bat" -Force -ErrorAction Ignore
						Remove-Item "$drive\ATOM" -Recurse -Force -ErrorAction Ignore
						Write-OutputBox "- Removed old ATOM installation"
					}
				}

				if ($fileExtension -eq ".zip") {
					$destination = $drive
					$zip = $shell.NameSpace($zipFile)
					$folder = $shell.NameSpace($destination)

					Write-OutputBox "- Updating"
					$folder.CopyHere($zip.Items(), 20)
				} elseif ($fileExtension -eq ".iso") {
					$isoMount = Mount-DiskImage -ImagePath $selectedZip -PassThru
					$isoDriveLetter = ($isoMount | Get-Volume).DriveLetter
					$isoContentPath = $isoDriveLetter + ":\*"
					
					Write-OutputBox "- Updating"
					Copy-Item -Path $isoContentPath -Destination $drive -Recurse -Force
					
					Dismount-DiskImage -ImagePath $selectedZip
				}
				
				Write-OutputBox "- Completed`n"
			}
		}
		
		try {
			Update-Drives -zipFile $selectedZip -drives $driveLetters -isATOM $isATOM -isFormat $isFormat
			Write-OutputBox "Update(s) completed."
		} catch {
			Write-OutputBox "An error occurred: $_`n"
		}
		
		if (Test-Path $downloadPath) {
			Remove-Item $downloadPath -Recurse -Force
			Write-OutputBox "Removed downloaded ATOM."
		}
		
		$btnUpdate.Dispatcher.Invoke([action]{ $btnUpdate.Content = "Perform Update"; $btnUpdate.IsEnabled = $true }, "Render")
	}
})

$window.Add_MouseLeftButtonDown({
	$this.DragMove()
	$request = New-Object System.Windows.Input.TraversalRequest([System.Windows.Input.FocusNavigationDirection]::Next)
	$window.MoveFocus($request)
})

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