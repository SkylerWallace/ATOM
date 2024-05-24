Add-Type -AssemblyName PresentationFramework

# Declaring initial variables, needed for runspace function
$initialVariables = Get-Variable | Select-Object -ExpandProperty Name

# Declaring relative paths needed for rest of script
$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$programsPath = Join-Path ($atomPath | Split-Path) "Programs"
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$settingsPath = Join-Path $dependenciesPath "Settings"
$pluginsIconsPath = Join-Path $iconsPath "Plugins"
$hashtable = Join-Path $dependenciesPath "Programs-Hashtable.ps1"
. $hashtable

# Import ATOM core resources
. (Join-Path $dependenciesPath "ATOM-Module.ps1")

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

Set-ResourceIcons -IconCategory "Primary" -ResourceMappings $primaryResources
Set-ResourceIcons -IconCategory "Surface" -ResourceMappings $surfaceResources

# Event handlers
0..1 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

# Add 'select all' Checkbox
$programsCheckbox = New-Object System.Windows.Controls.CheckBox
$programsCheckbox.Content = "Select all"
$programsCheckbox.Foreground = $surfaceText
$programsCheckbox.Style = $window.Resources["CustomCheckBoxStyle"]
$programsListBox.Items.Add($programsCheckbox) | Out-Null

$programsCheckbox.Add_Checked({
	foreach ($item in $programsListBox.Items | Select -Skip 1) {
		if ($item.Content.Children[0].IsEnabled) {
			$item.Content.Children[0].IsChecked = $true
		}
	}
})

$programsCheckbox.Add_Unchecked({
	foreach ($item in $programsListBox.Items | Select -Skip 1) {
		if ($item.Content.Children[0].IsEnabled) {
			$item.Content.Children[0].IsChecked = $false
		}
	}
})


# Add all programs to listbox
foreach ($program in $programsInfo.Keys) {
	$checkbox = New-Object System.Windows.Controls.CheckBox
	$checkbox.Foreground = $surfaceText
	$checkbox.Style = $window.Resources["CustomCheckBoxStyle"]

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
		$stackPanel.Opacity = 0.44
	} else {
		$listBoxItem.Add_MouseUp({ $this.Tag.IsChecked = !$this.Tag.IsChecked })
	}
	
	$programsListBox.Items.Add($listBoxItem) | Out-Null
}

$installButton.Add_Click({
	$scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
	
	# Get list of checked items
	$checkedItems = @()
	foreach ($item in $programsListBox.Items.Content | Select -Skip 1) {
		$checkBox = $item.Children[0].IsChecked
		if (!($checkBox)) { continue }
		$checkedItems += $item.Children[2].Text
	}
	
	# Store hashtable for credentials
	$credentials = @{}
	foreach ($item in $checkedItems) {
		if ($programsInfo[$item].Credential) {
			$userName = $programsInfo[$item].UserName
			$credentials[$item] = Get-Credential -Message "Please enter your password for $item" -UserName $userName
		}
	}

	Create-Runspace -ScriptBlock  {
		# Disable update button while runspace is running
		Invoke-Ui { $installButton.Content = "Running..."; $installButton.IsEnabled = $false }
		
		# Import hashtable
		. $hashtable
		
		# Create programs folder if not detected
		if (!(Test-Path $programsPath)) { New-Item -Path $programsPath -ItemType Directory -Force }
		
		# Function to disable checkbox
		function Uncheck-Checkbox {
			Invoke-Ui {
				foreach ($item in $programsListBox.Items | Select -Skip 1) {
					if ($programKey -ne $item.Content.Children[2].Text) {
						continue
					}
					
					$item.Opacity = 0.44
					$item.Content.Children[0].IsChecked = $false
					$item.Content.Children[0].IsEnabled = $false
				}
			}
		}
		
		# Install programs
		foreach ($programKey in $checkedItems) {
			Write-OutputBox "$($programKey):"
			Write-OutputBox "- Downloading"
			
			try {
				$downloadPath = Join-Path $env:TEMP ($programKey + ".zip")
				$extractionPath = Join-Path $programsPath $programsInfo[$programKey].ProgramFolder
				$progressPreference = "SilentlyContinue"
				
				# Use override logic if specified by hashtable key
				if ($programsInfo[$programKey].Override -ne $null) {
					& $programsInfo[$programKey].Override
					Uncheck-Checkbox
					Write-OutputBox "- Installed"
					continue
				}
				
				# Download w/ credentials if specified by hashtable key
				if ($programsInfo[$programKey].Credential) {
					$credential = $credentials[$programKey]
					$downloadURL = $programsInfo[$programKey].DownloadUrl
					Invoke-RestMethod -Uri $downloadURL -Headers @{"X-Requested-With" = "XMLHttpRequest"} -Credential $credential -OutFile $downloadPath
				} else {
					Invoke-WebRequest $programsInfo[$programKey].DownloadUrl -OutFile $downloadPath
				}
				
				# Extract zip to programs folder
				Expand-Archive -Path $downloadPath -DestinationPath $extractionPath -Force
				Remove-Item -Path $downloadPath -Force
				
				# Run post-installation logic if specified by hashtable key
				if ($programsInfo[$programKey].PostInstall -ne $null) {
					& $programsInfo[$programKey].PostInstall
				}
				
				Uncheck-Checkbox
				Write-OutputBox "- Installed"
			} catch {
				Write-OutputBox "- An error occurred. Verify internet connection, valid download URL, and credentials if applicable."
			} finally { Write-OutputBox "" }
		}
		
		Write-OutputBox "ATOM Store completed."
		
		# Re-enable run button & uncheck 'select all' checkbox if checked
		Invoke-Ui {
			$installButton.Content = "Run"
			$installButton.IsEnabled = $true
			if ($programsCheckbox.IsChecked) {
				$programsCheckbox.IsChecked = $false
			}
		}
	}
})

Adjust-WindowSize

$window.ShowDialog() | Out-Null