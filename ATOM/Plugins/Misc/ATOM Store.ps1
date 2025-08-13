Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\..\Functions\AtomModule.psm1"
Import-Module "$psScriptRoot\..\..\Functions\AtomWpfModule.psm1"

# Get program params
$hashtable = "$atomPath\Config\ProgramsParams.ps1"
. $hashtable

#. $functionsPath\Invoke-Runspace.ps1

$xaml = @"
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
				<Image Width="40" Height="40" Source="$resourcesPath\Icons\Plugins\ATOM Store.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,0,0"/>
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
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$programsListBox	= $Window.FindName('programsListBox')
$outputBox			= $window.FindName('outputBox')
$installButton		= $Window.FindName('installButton')
$minimizeButton		= $window.FindName('minimizeButton')
$closeButton		= $window.FindName('closeButton')

# Set icon sources
$primaryResources = @{
	"minimizeButton" = "Minimize"
	"closeButton" = "Close"
}

$surfaceResources = @{
	"checkedImage" = "Checkbox - Checked"
	"uncheckedImage" = "Checkbox - Unchecked"
}

Set-ResourcePath -ColorRole Primary -ResourceMappings $primaryResources
Set-ResourcePath -ColorRole Surface -ResourceMappings $surfaceResources

# Event handlers
0..1 | ForEach-Object { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

# Add 'select all' Checkbox
$programsCheckbox = New-ListBoxControlItem -ControlType CheckBox -Text 'Select All' -TextForeground $surfaceText -ImageSource $iconPath
$programsListBox.Items.Add($programsCheckbox) | Out-Null
$programsCheckbox.Control.Add_Checked({
    $programsListBox.Items | Select-Object -Skip 1 | Where-Object { $_.Control.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $true }
})
$programsCheckbox.Control.Add_Unchecked({
    $programsListBox.Items | Select-Object -Skip 1 | Where-Object { $_.Control.IsEnabled } | ForEach-Object { $_.Control.IsChecked = $false }
})

# Add all programs to listbox
foreach ($program in $programsInfo.Keys) {
	$checkbox = New-Object System.Windows.Controls.CheckBox
	$checkbox.Foreground = $surfaceText

	$iconPath = "$resourcesPath\Icons\Plugins\$program.png"
	
	if (!(Test-Path $iconPath)) {
		$firstLetter = $program.Substring(0,1)
		$iconPath =
			if ($firstLetter -match "^[A-Z]") { "$resourcesPath\Icons\Default\$firstLetter.png" }
			else { "$resourcesPath\Icons\Default\#.png" }
	}

	$listBoxItem = New-ListBoxControlItem -ControlType CheckBox -Text $program -TextForeground $surfaceText -ImageSource $iconPath -Tag $program, $installPrograms.$category.$program
	
	$programPath = Join-Path $programsPath ($programsInfo[$program].ProgramFolder + "\" + $programsInfo[$program].ExeName)
	if (Test-Path $programPath) {
		$listBoxItem.IsEnabled = $false
		$listBoxItem.Opacity = 0.44
	} else {
		$listBoxItem.Control.Add_MouseUp({ $this.Tag.IsChecked = !$this.Tag.IsChecked })
	}

	$programsListBox.Items.Add($listBoxItem) | Out-Null
}

$installButton.Add_Click({
	$script:scrollToEnd = $window.FindName("scrollViewer1").ScrollToEnd()
	
	# Get list of checked items
	$script:checkedItems = @()
	foreach ($item in $programsListBox.Items.Content | Select-Object -Skip 1) {
		$checkBox = $item.Children[0].IsChecked
		if (!($checkBox)) { continue }
		$script:checkedItems += $item.Children[2].Text
	}

	Invoke-Runspace -ScriptBlock  {
		# Disable update button while runspace is running
		Invoke-Ui { $installButton.Content = "Running..."; $installButton.IsEnabled = $false }

		# Import hashtable
		. $hashtable

		# Import Start-Program function
		. $atomPath\Functions\Start-Program.ps1
		
		# Create programs folder if not detected
		if (!(Test-Path $programsPath)) { New-Item -Path $programsPath -ItemType Directory -Force }
		
		# Function to disable checkbox
		function Uncheck-Checkbox {
			Invoke-Ui {
				foreach ($item in $programsListBox.Items | Select-Object -Skip 1) {
					if ($program -ne $item.Content.Children[2].Text) {
						continue
					}
					
					$item.Opacity = 0.44
					$item.Content.Children[0].IsChecked = $false
					$item.Content.Children[0].IsEnabled = $false
				}
			}
		}
		
		# Install programs
		foreach ($program in $checkedItems) {
			Write-Host "$($program):"
			Write-Host "- Downloading"
			
			try {
				Start-Program $program
				Write-Host "- Installed"
				Uncheck-Checkbox
			} catch {
				Write-Host "- An error occurred. Verify internet connection, valid download URL, and credentials if applicable."
			} finally { Write-Host "" }
		}
		
		Write-Host "ATOM Store completed."
		
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

Set-WindowSize

$window.ShowDialog() | Out-Null