# Launch: Hidden

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Declaring relative paths needed for rest of script
$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"

# Import custom window resources and color theming
$dictionaryPath = Join-Path $dependenciesPath "ResourceDictionary.ps1"
. $dictionaryPath

[xml]$xaml = @"
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="KeyCutlass"
	Background="Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	MinWidth="200" SizeToContent="WidthAndHeight"
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
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
				<Image Name="logo" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
				<TextBlock Text="KeyCutlass" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="60,0,0,0"/>
				<Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
				<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			<Grid Grid.Row="1" Margin="5,5,5,0">
				<TextBlock Text="Product keys may not be accurate!" Foreground="{DynamicResource backgroundText}" VerticalAlignment="Center" HorizontalAlignment="Left" Margin="10,5,5,5"/>
			</Grid>
			<Grid Grid.Row="2" Margin="5,5,5,0">
				<Border Style="{StaticResource CustomBorder}" Margin="5" Padding="5">
					<StackPanel Name="keysPanel"/>
				</Border>
			</Grid>
			<Grid Grid.Row="3" Margin="5,0,5,5">
				<Button Name="visibilityButton" Content="Show Product Keys" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedButton}" Margin="5" Padding="5" ToolTip="Keep these secret!"/>
			</Grid>
		</Grid>
	</Border>
</Window>
"@

# Load XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign variables to elements in XAML
$logo = $window.FindName("logo")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")
$keysPanel = $window.FindName("keysPanel")
$visibilityButton = $window.FindName("visibilityButton")

$logo.Source = Join-Path $iconsPath "Plugins\KeyCutlass.png"

# Set icon sources
$primaryResources = @{
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $primaryResources

function Add-ProductKey {
	param (
		[Parameter(Mandatory=$true)]
		[string]$keyName,
		[string]$keyValue
	)
	
	$nameTextBlock = New-Object System.Windows.Controls.TextBlock
	$nameTextBlock.Text = $keyName
	$nameTextBlock.Foreground = $surfaceText
	$nameTextBlock.Width = 180
	$nameTextBlock.Margin = "5"
	$nameTextBlock.VerticalAlignment = "Center"
	
	$valueTextBox = New-Object System.Windows.Controls.TextBox
	$valueTextBox.Text = $keyValue
	$valueTextBox.FontFamily = "Consolas"
	$valueTextBox.Width = 200
	$valueTextBox.TextWrapping = "Wrap"
	$valueTextBox.Foreground = $surfaceText
	$valueTextBox.Background = "Transparent"
	$valueTextBox.VerticalAlignment = "Center"
	$valueTextBox.Visibility = "Hidden"
	$valueTextBox.IsReadOnly = "True"
	$valueTextBox.Margin = "5"
	
	$button = New-Object System.Windows.Controls.Button
	$button.Width = 20; $button.Height = 20
	$button.Margin = 5
	$button.Style = $window.FindResource("RoundHoverButtonStyle")
	$button.Tag = $valueTextBox.Text
	$button.ToolTip = "Copy key to clipboard"
	$button.Content =
		if ($surfaceIcons -eq "Light") {
			New-Object System.Windows.Controls.Image -Property @{ Source = Join-Path $iconsPath "Link (Light).png" }
		} elseif ($surfaceIcons -eq "Dark") {
			New-Object System.Windows.Controls.Image -Property @{ Source = Join-Path $iconsPath "Link (Dark).png" }
		}
	$button.Add_Click({
		$key = $this.Tag
		[System.Windows.Forms.Clipboard]::SetText($key)
	})
	
	$stackPanel = New-Object System.Windows.Controls.StackPanel
	$stackPanel.Orientation = "Horizontal"
	$stackPanel.Children.Add($nameTextBlock) | Out-Null
	$stackPanel.Children.Add($valueTextBox) | Out-Null
	$stackPanel.Children.Add($button) | Out-Null
	
	$keysPanel.Children.Add($stackPanel) | Out-Null
}

# Function to decode product key from the registry
function Get-ProductKey {
	param (
		[Parameter(Mandatory=$true)]
		[byte[]]$key
	)
	
	$keyOutput = ""
	$keyOffset = 52
	
	$isWin8 = ([System.Math]::Truncate($key[66] / 6)) -band 1
	$key[66] = ($key[66] -band 0xF7) -bor (($isWin8 -band 2) * 4)
	$i = 24
	$maps = "BCDFGHJKMPQRTVWXY2346789"
	
	do {
		$current= 0
		$j = 14
		
		do {
			$current = $current* 256
			$current = $key[$j + $keyOffset] + $current
			$key[$j + $keyOffset] = [System.Math]::Truncate($current / 24 )
			$current = $current % 24
			$j--
		} while ($j -ge 0)
		
		$i--
		$keyOutput = $maps.Substring($current, 1) + $keyOutput
		$last = $current
	} while ($i -ge 0)
	
	if ($isWin8 -eq 1) {
		$keypart1 = $keyOutput.Substring(1, $last)
		$insert = "N"
		$keyOutput = $keyOutput.Replace($keypart1, $keypart1 + $insert)
		if ($last -eq 0) { $keyOutput = $insert + $keyOutput }
	}
	
	if ($keyOutput.Length -eq 26) {
		$result = [String]::Format("{0}-{1}-{2}-{3}-{4}",
		$keyOutput.Substring(1, 5),
		$keyOutput.Substring(6, 5),
		$keyOutput.Substring(11,5),
		$keyOutput.Substring(16,5),
		$keyOutput.Substring(21,5))
	} else {
		$keyOutput
	}
	
	return $result
}

# Get embedded product key
$embeddedKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
if ($embeddedKey) {
	Add-ProductKey -KeyName "BIOS Embedded Key" -KeyValue $embeddedKey
}

# Get correct registry hive
$softwareHive = "HKLM:\SOFTWARE"
if (Test-Path "HKLM:\RemoteOS-HKLM-SOFTWARE") {
	$softwareHive = "HKLM:\RemoteOS-HKLM-SOFTWARE"
}

# Get software key
$keyData = (Get-ItemProperty -Path "$softwareHive\Microsoft\Windows NT\CurrentVersion").DigitalProductId
$softwareKey = Get-ProductKey $keyData
if ($softwareKey) {
	$softwareKeyVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
	Add-ProductKey -KeyName $softwareKeyVersion -KeyValue $softwareKey
}

# Get default key 1
$keyData = (Get-ItemProperty -Path "$softwareHive\Microsoft\Windows NT\CurrentVersion\DefaultProductKey").DigitalProductId
$defaultKey1 = Get-ProductKey $keyData
if ($defaultKey1) {
	$defaultKeyVersion1 = (Get-ItemProperty -Path "$softwareHive\Microsoft\Windows NT\CurrentVersion").ProductName + " (Default 1)"
	Add-ProductKey -KeyName $defaultKeyVersion1 -KeyValue $defaultKey1
}

# Get default key 2
$keyData = (Get-ItemProperty -Path "$softwareHive\Microsoft\Windows NT\CurrentVersion\DefaultProductKey2").DigitalProductId
$defaultKey2 = Get-ProductKey $keyData
if ($defaultKey2) {
	$defaultKeyVersion2 = (Get-ItemProperty -Path "$softwareHive\Microsoft\Windows NT\CurrentVersion").ProductName + " (Default 2)"
	Add-ProductKey -KeyName $defaultKeyVersion2 -KeyValue $defaultKey2
}

<#
# Get Office keys
$officeVersions = 12..16
foreach ($version in $officeVersions) {
	$versionExists = Test-Path "HKLM:\SOFTWARE\Microsoft\Office\$version.0\Registration"
	if ($versionExists) {
		$officeVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Office\$version.0\Registration").ProductName
		$keyData = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Office\$version.0\Registration").DigitalProductId
		$officeKey = Get-ProductKey $keyData
		Add-ProductKey -KeyName $officeVersion -KeyValue $officeKey
	}
}
#>

# Get encryption key
$onlineOS = (Get-WmiObject -Class Win32_OperatingSystem).SystemDrive
$encryptionKey = (manage-bde -protectors -get $onlineOS | Select-String -Pattern '\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}-\d{6}').Matches.Value
if ($encryptionKey) {
	Add-ProductKey -KeyName "Encryption Key" -KeyValue $encryptionKey
}

# Make product keys visible
$visibilityButton.Add_Click({
	foreach ($child in $keysPanel.Children) {
		foreach ($subChild in $child.Children) {
			if ($subChild -is [System.Windows.Controls.TextBox]) {
				$subChild.Visibility = "Visible"
			}
		}
	}
})

$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

$window.ShowDialog() | Out-Null