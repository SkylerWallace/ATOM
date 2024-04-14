# Launch: Hidden

Add-Type -AssemblyName PresentationFramework

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$preAtomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path | Split-Path
$programsPath = Join-Path $preAtomPath "Programs"
$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$pluginsIconsPath = Join-Path $iconsPath "Plugins"
$hashtable = Join-Path $dependenciesPath "Programs-Hashtable.ps1"
. $hashtable

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
	Title="ATOM Store"
	Background="Transparent"
	WindowStyle="None"
	AllowsTransparency="True"
	Width="600" Height="600"
	MinWidth="400" MinHeight="400"
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
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
		
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
				<Image Name="logo" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,0,0"/>
				<TextBlock Text="ATOM Store" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="60,0,0,0"/>
				<Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
				<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			
			<Grid Grid.Row="1">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="*"/>
					<ColumnDefinition Width="*"/>
				</Grid.ColumnDefinitions>
			
				<Border Grid.Column="0" Style="{StaticResource CustomBorder}" Margin="10,10,5,0">
					<ScrollViewer Name="scrollViewer0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<ListBox Name="programsListBox" Background="Transparent" Foreground="{DynamicResource surfaceText}" BorderThickness="0" HorizontalAlignment="Stretch" Margin="10,10,0,10"/>
					</ScrollViewer>
				</Border>
				
				<Border Grid.Column="1" Style="{StaticResource CustomBorder}" Margin="5,10,10,0">
					<ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
					</ScrollViewer>
				</Border>
			</Grid>
			
			<Button Name="installButton" Grid.Row="2" Content="Install Program(s)" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" BorderThickness="0" Margin="10" Style="{StaticResource RoundedButton}"/>
		</Grid>
	</Border>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Assign variables to elements in XAML
$logo = $window.FindName("logo")
$programsListBox = $Window.FindName("programsListBox")
$outputBox = $window.FindName("outputBox")
$installButton = $Window.FindName("installButton")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")

$logo.Source = Join-Path $iconsPath "Plugins\ATOM Store.png"

# Set icon sources
$primaryResources = @{
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

$surfaceResources = @{
	"checkedImage" = "Checkbox - Checked"
	"uncheckedImage" = "Checkbox - Unchecked"
}

Set-ResourceIcons -iconCategory "Primary" -resourceMappings $primaryResources
Set-ResourceIcons -iconCategory "Surface" -resourceMappings $surfaceResources


0..1 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

foreach ($program in $programsInfo.Keys) {
	$checkbox = New-Object System.Windows.Controls.CheckBox
	$checkbox.Foreground = $surfaceText
	$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]

	$iconPath = Join-Path $pluginsIconsPath "$program.png"
	$iconExists = Test-Path $iconPath
	if (!$iconExists) {
		$firstLetter = $program.Substring(0,1)
		$iconPath = if ($firstLetter -match "^[A-Z]") { Join-Path $iconsPath "\Default\Default$firstLetter.png" }
					else { Join-Path $iconsPath "\Default\Default.png" }
	}
	
	$image = New-Object System.Windows.Controls.Image
	$image.Source = $iconPath
	$image.Width = 16
	$image.Height = 16
	$image.Margin = "0,0,5,0"

	$textBlock = New-Object System.Windows.Controls.TextBlock
	$textBlock.Text = $program
	$textBlock.Foreground = $surfaceText
	$textBlock.VerticalAlignment = "Center"
	
	$stackPanel = New-Object System.Windows.Controls.StackPanel
	$stackPanel.Orientation = "Horizontal"
	$stackPanel.Children.Add($checkbox) | Out-Null
	$stackPanel.Children.Add($image) | Out-Null
	$stackPanel.Children.Add($textBlock) | Out-Null
	
	$listBoxItem = New-Object System.Windows.Controls.ListBoxItem
	$listBoxItem.Content = $stackPanel
	$listBoxItem.Tag = $checkBox
	
	$programPath = Join-Path $programsPath ($programsInfo[$program].ProgramFolder + "\" + $programsInfo[$program].ExeName)
	if (Test-Path $programPath) {
		$checkbox.IsEnabled = $false
		$stackPanel.Opacity = "0.25"
	} else {
		$listBoxItem.Add_MouseUp({ $this.Tag.IsChecked = !$this.Tag.IsChecked })
	}
	
	$programsListBox.Items.Add($listBoxItem) | Out-Null
}

$installButton.Add_Click({
	$scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
	
	$listBoxItems = $programsListBox.Items
	$checkedItems = @()
	foreach ($listboxItem in $programsListBox.Items) {
 		$stackPanel = $listBoxItem.Content
		$checkBox = $stackPanel.Children[0]
		if ($checkBox.IsChecked) {
			$textBlock = $stackPanel.Children[2]
			$checkedItems += $textBlock.Text
		}
	}
	
	$credentials = @{}
	foreach ($item in $checkedItems) {
		if ($programsInfo[$item].Credential) {
			$userName = $programsInfo[$item].UserName
			$credentials[$item] = Get-Credential -Message "Please enter your password for $item" -UserName $userName
		}
	}

	Create-Runspace -ScriptBlock  {
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke([action]{ $outputBox.Text += "$Text`r`n"; $scrollToEnd }, "Render")
		}
		
		$installButton.Dispatcher.Invoke([action]{ $installButton.Content = "Running..."; $installButton.IsEnabled = $false }, "Render")
		
		. $hashtable
		
		function Install-PortableProgram {
			param (
				[Parameter(Mandatory=$true)]
				[string]$programKey
			)

			$downloadPath = Join-Path $env:TEMP ($programKey + ".zip")
			$extractionPath = Join-Path $programsPath $programsInfo[$programKey].ProgramFolder
			$progressPreference = "SilentlyContinue"
			
			if ($programsInfo[$programKey].Override -ne $null) {
				& $programsInfo[$programKey].Override
				return
			}
			
			if ($programsInfo[$programKey].Credential) {
				$credential = $credentials[$programKey]
				$downloadURL = $programsInfo[$programKey].DownloadUrl
				Invoke-RestMethod -Uri $downloadURL -Headers @{"X-Requested-With" = "XMLHttpRequest"} -Credential $credential -OutFile $downloadPath
			} else {
				Invoke-WebRequest $programsInfo[$programKey].DownloadUrl -OutFile $downloadPath
			}
			
			Expand-Archive -Path $downloadPath -DestinationPath $extractionPath -Force
			Remove-Item -Path $downloadPath -Force
			
			if ($programsInfo[$programKey].PostInstall -ne $null) {
				& $programsInfo[$programKey].PostInstall
			}
		}
		
		if (!(Test-Path $programsPath)) { New-Item -Path $programsPath -ItemType Directory -Force }
		
		foreach ($programKey in $checkedItems) {
			Write-OutputBox "$($programKey):"
			Write-OutputBox "- Downloading"
			
			try {
				Install-PortableProgram -programKey $programKey
				Write-OutputBox "- Installed"
			} 
			catch {
				Write-OutputBox "- An error occurred. Verify internet connection, valid download URL, and credentials if applicable."
			}
			Write-OutputBox ""
		}
		
		<#
		$installButton.Dispatcher.Invoke([action]{
			foreach ($item in $programsListBox.Items) {
				if ($item.IsEnabled) {
					$item.IsChecked = $false
					$checkedItems = @()
				}
			}
		}, "Render")
		#>
		
		$installButton.Dispatcher.Invoke([action]{ $installButton.Content = "Run"; $installButton.IsEnabled = $true }, "Render")
	}
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
