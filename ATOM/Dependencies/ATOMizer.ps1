# Launch: Hidden

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

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
	MinWidth="420" MinHeight="250"
	MaxWidth="750" MaxHeight="600"
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
		
		<Style x:Key="RoundedButton" TargetType="{x:Type Button}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5">
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
										<SolidColorBrush Color="#80FFFFFF"/>
									</Setter.Value>
								</Setter>
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
									<Border Name="RadioOuter" Background="Transparent" BorderBrush="{DynamicResource secondaryText}" BorderThickness="2" CornerRadius="2.5"/>
									<Border CornerRadius="1" Margin="4" Name="RadioMark" Background="{DynamicResource secondaryText}" Visibility="Hidden"/>
								</Grid>
							</BulletDecorator.Bullet>
							<TextBlock Margin="5,0,0,0" Foreground="{DynamicResource secondaryText}" FontSize="12">
								<ContentPresenter/>
							</TextBlock>
						</BulletDecorator>
						<ControlTemplate.Triggers>
							<Trigger Property="IsChecked" Value="true">
								<Setter TargetName="RadioMark" Property="Visibility" Value="Visible"/>
								<Setter TargetName="RadioOuter" Property="BorderBrush" Value="{DynamicResource secondaryText}"/>
							</Trigger>
						</ControlTemplate.Triggers>
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
		
		<Style TargetType="ListBoxItem">
			<Setter Property="Foreground" Value="{DynamicResource secondaryText}"/>
			<Setter Property="Margin" Value="1"/>
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
	
	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource secondaryColor2}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="Auto"/>
				<RowDefinition Height="Auto"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryColor}" CornerRadius="5,5,0,0"/>
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
					<RadioButton Name="rbATOM" Content="ATOM" Width="70" Background="{DynamicResource secondaryText}" Foreground="{DynamicResource secondaryText}" FontWeight="Bold" VerticalContentAlignment="Center" GroupName="UpdateOption" IsChecked="True" Margin="0,0,10,0" ToolTip="Deletes then updates ATOM"/>
					<RadioButton Name="rbMerge" Content="Merge" Width="75" Background="{DynamicResource secondaryText}" Foreground="{DynamicResource secondaryText}" FontWeight="Bold" VerticalContentAlignment="Center" GroupName="UpdateOption" Margin="0,0,10,0" ToolTip="Merges selected file"/>
					<RadioButton Name="rbFormat" Content="Format" Width="80" Background="{DynamicResource secondaryText}" Foreground="{DynamicResource secondaryText}" FontWeight="Bold" VerticalContentAlignment="Center" GroupName="UpdateOption" Margin="0,0,10,0" ToolTip="Formats drive to FAT32 and merges selected file"/>
				</StackPanel>
				<TextBox Grid.Column="1" Name="txtDriveName" Text="Type drive name here..." Height="20" Foreground="Transparent" Background="Transparent" HorizontalAlignment="Stretch" VerticalAlignment="Center" HorizontalContentAlignment="Left" VerticalContentAlignment="Center" Margin="10,0,10,0" MaxLength="11" IsEnabled="False"/>
			</Grid>
			
			<Grid Grid.Row="2" Margin="10,5,10,10">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="4*"/>
					<ColumnDefinition Width="6*"/>
				</Grid.ColumnDefinitions>
				
				<StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
					<Button Name="btnDownload" Width="110" Height="20" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" BorderThickness="0" Style="{StaticResource RoundedButton}" Margin="0,0,10,0" ToolTip="Download file from Github">
						<StackPanel Orientation="Horizontal">
							<Image Name="downloadIcon" Width="16" Height="16" Margin="0,0,5,0"/>
							<TextBlock Text="Download" VerticalAlignment="Center"/>
						</StackPanel>
					</Button>
					<Button Name="btnBrowse" Width="110" Height="20" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" BorderThickness="0" Style="{StaticResource RoundedButton}" ToolTip="Browse for local file">
						<StackPanel Orientation="Horizontal">
							<Image Name="browseIcon" Width="16" Height="16" Margin="0,0,5,0"/>
							<TextBlock Text="Browse" VerticalAlignment="Center"/>
						</StackPanel>
					</Button>
				</StackPanel>
				<Label Grid.Column="1" Name="lblSelectedZip" Content="No file selected" Foreground="{DynamicResource secondaryText}" Margin="10,0,0,0"/>
			</Grid>
			
			<Grid Grid.Row="3" Margin="10,0,10,0">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="4*"/>
					<ColumnDefinition Width="6*"/>
				</Grid.ColumnDefinitions>
				<Border CornerRadius="5" Background="{DynamicResource secondaryColor1}" Margin="0,0,0,0">
					<ScrollViewer Name="scrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<ListBox Name="lbDrives" Background="Transparent" Foreground="{DynamicResource secondaryText}" BorderThickness="0" SelectionMode="Extended" Margin="5"/>
					</ScrollViewer>
				</Border>
				<Border Grid.Column="1" CornerRadius="5" Background="{DynamicResource secondaryColor1}" Margin="10,0,0,0">
					<ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<TextBlock Name="outputBox" TextWrapping="Wrap" Foreground="{DynamicResource secondaryText}" Margin="5" Padding="5"/>
					</ScrollViewer>
				</Border>
			</Grid>
			<Button Name="btnUpdate" Content="Perform Update" Height="20" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" BorderThickness="0" Grid.Row="4" Margin="10,10,10,10" Style="{StaticResource RoundedButton}"/>
		</Grid>
	</Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$scriptDriveLetter = Split-Path $MyInvocation.MyCommand.Path -Qualifier
$preAtomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$atomPath = Split-Path $MyInvocation.MyCommand.Path -Parent
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"

$logo = $window.FindName("logo")
$rbATOM = $window.FindName("rbATOM")
$rbMerge = $window.FindName("rbMerge")
$rbFormat = $window.FindName("rbFormat")
$txtDriveName = $window.FindName("txtDriveName")
$btnDownload = $window.FindName("btnDownload")
$downloadIcon = $window.FindName("downloadIcon")
$btnBrowse = $window.FindName("btnBrowse")
$browseIcon = $window.FindName("browseIcon")
$lblSelectedZip = $window.FindName("lblSelectedZip")
$lbDrives = $window.FindName("lbDrives")
$btnUpdate = $window.FindName("btnUpdate")
$outputBox = $window.FindName("outputBox")
$refreshButton = $window.FindName("refreshButton")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")

$colorsPath = Join-Path $dependenciesPath "Colors-Custom.ps1"
. $colorsPath

$logo.Source = Join-Path $iconsPath "Plugins\ATOMizer.png"

$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"
$fontFamily = New-Object Windows.Media.FontFamily "file:///$fontPath#Open Sans"
$window.FontFamily = $fontFamily

if ($accentIcons -eq "Light") {
	$downloadIcon.Source = Join-Path $iconsPath "Download (Light).png"
	$browseIcon.Source = Join-Path $iconsPath "Browse (Light).png"
} else {
	$downloadIcon.Source = Join-Path $iconsPath "Download (Dark).png"
	$browseIcon.Source = Join-Path $iconsPath "Browse (Dark).png"
}

if ($primaryIcons -eq "Light") {
	$buttons = @{ "Refresh (Light)" = $refreshButton; "Minimize (Light)" = $minimizeButton; "Close (Light)" = $closeButton }
} else {
	$buttons = @{ "Refresh (Dark)" = $refreshButton; "Minimize (Dark)" = $minimizeButton; "Close (Dark)" = $closeButton }
}

$buttons.GetEnumerator() | %{
	$uri = New-Object System.Uri (Join-Path $iconsPath "$($_.Key).png")
	$img = New-Object System.Windows.Media.Imaging.BitmapImage $uri
	$_.Value.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img }
}

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
		$DriveList.Items.Add("$($driveLetter):\$($driveLabel)")
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

function Initialize-Runspace {
	param($variablesToInject)

	$runspace = [runspacefactory]::CreateRunspace()
	$runspace.ApartmentState = "STA"
	$runspace.ThreadOptions = "ReuseThread"
	$runspace.Open()

	$variablesToInject.GetEnumerator() | ForEach-Object { $runspace.SessionStateProxy.SetVariable($_.Key, $_.Value) }
	
	$ps = [powershell]::Create()
	$ps.Runspace = $runspace
	$null = $ps.AddScript({
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke(
				[action]{$outputBox.Text += "$Text`r`n"; $scrollToEnd},
				[System.Windows.Threading.DispatcherPriority]::Render
			)
		}
	}).Invoke()

	return $runspace
}

$btnDownload.Add_Click({
	$downloadURL = "https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip"
	$downloadPath = Join-Path $preAtomPath "ATOM-Latest.zip"
	
	$variablesToInject = @{
		'downloadPath'	= $downloadPath;
		'downloadURL'	= $downloadURL;
		'outputBox'		= $outputBox
	}
	
	$runspace = Initialize-Runspace -VariablesToInject $variablesToInject
	
	$powershell = [powershell]::Create().AddScript({
		Write-OutputBox "Downloading latest ATOM, please wait..."
		$ProgressPreference = 'SilentlyContinue'
		Invoke-RestMethod -Uri $downloadURL -OutFile $downloadPath
		Write-OutputBox "Latest ATOM successfully downloaded."
	})
	$powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
	
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
	$txtDriveName.Foreground = $secondaryText
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
	$scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
	
	$variablesToInject = @{
		'outputBox'				= $outputBox;
		'selectedZip'			= $selectedZip;
		'selectedDrives'		= $selectedDrives;
		'selectedDrivesAmount'	= $selectedDrivesAmount;
		'isATOM'				= $isATOM;
		'isFormat'				= $isFormat;
		'driveName'				= $driveName
		'drives'				= $drives;
		'downloadPath'			= $downloadPath;
		'scriptDriveLetter'		= $scriptDriveLetter
	}

	$runspace = Initialize-Runspace -VariablesToInject $variablesToInject
	
	$powershell = [powershell]::Create().AddScript({
		if ($selectedZip -eq "No file selected") {
			Write-OutputBox "Please select a zip file first."
			return
		}

		if ($selectedDrivesAmount -eq 0) {
			Write-OutputBox "Please select at least one drive."
			return
		}
		
		if ($isFormat -and $driveName -eq "Type drive name here...") {
			Write-OutputBox "Please enter a drive name..."
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
	})
	$powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
})

$window.Add_MouseLeftButtonDown({
	$this.DragMove()
	$request = New-Object System.Windows.Input.TraversalRequest([System.Windows.Input.FocusNavigationDirection]::Next)
	$window.MoveFocus($request)
})

$window.ShowDialog() | Out-Null