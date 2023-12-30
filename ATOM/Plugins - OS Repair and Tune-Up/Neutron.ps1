## Launch: Hidden

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing

[xml]$xaml = @"
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="Neutron"
	WindowStartupLocation="CenterScreen"
	WindowStyle="None"
	AllowsTransparency="True"
	Background="Transparent"
	Width="800" Height="800"
	MinWidth="800" MinHeight="600"
	MaxWidth="800" MaxHeight="1000"
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
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5" Padding="2.5">
							<ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
						</Border>
						<ControlTemplate.Triggers>
							<Trigger Property="IsMouseOver" Value="True">
								<Setter TargetName="border" Property="Background" Value="{DynamicResource secondaryHighlight}"/>
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
								<Setter Property="Background" Value="#80FFFFFF"/>
								<Setter Property="BorderThickness" Value="1"/>
								<Setter Property="BorderBrush" Value="#80FFFFFF"/>
							</Trigger>
							<Trigger Property="IsSelected" Value="True">
								<Setter Property="Background" Value="#737474"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style x:Key="CustomListBoxStyle" TargetType="{x:Type ListBox}">
			<Setter Property="BorderBrush" Value="Transparent"/>
			<Setter Property="Background" Value="Transparent"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type ListBox}">
						<Border Background="{TemplateBinding Background}"
								BorderBrush="{TemplateBinding BorderBrush}"
								BorderThickness="1"
								CornerRadius="5"
								Padding="5"> 
							<ScrollViewer Focusable="false">
								<StackPanel IsItemsHost="True"/>
							</ScrollViewer>
						</Border>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		
		<Style x:Key="CustomCheckBoxStyle" TargetType="{x:Type CheckBox}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type CheckBox}">
						<Grid>
							<Grid.ColumnDefinitions>
								<ColumnDefinition Width="Auto"/>
								<ColumnDefinition Width="*"/>
							</Grid.ColumnDefinitions>
							<Image x:Name="PART_Image" Width="20" Height="20"/>
							<ContentPresenter Grid.Column="1" Margin="5,0,0,0" VerticalAlignment="Center"/>
						</Grid>
						<ControlTemplate.Triggers>
							<Trigger Property="IsChecked" Value="True">
								<Setter TargetName="PART_Image" Property="Source" Value="{DynamicResource CheckedImage}"/>
							</Trigger>
							<Trigger Property="IsChecked" Value="False">
								<Setter TargetName="PART_Image" Property="Source" Value="{DynamicResource UncheckedImage}"/>
							</Trigger>
						</ControlTemplate.Triggers>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>

	</Window.Resources>
	
	<WindowChrome.WindowChrome>
		<WindowChrome CaptionHeight="0" CornerRadius="10"/>
	</WindowChrome.WindowChrome>
	
	<Border BorderBrush="Transparent" BorderThickness="1" Background="{DynamicResource secondaryColor2}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryColor}" CornerRadius="5,5,0,0"/>
				<Image Name="logo1" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
				<Image Name="logo2" Width="130" Height="130" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="60,5,0,0"/>
				<Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
				<Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			
			<Grid Grid.Row="1" Margin="0">
				<Grid.ColumnDefinitions>
					<ColumnDefinition Width="*"/>
					<ColumnDefinition Width="*"/>
					<ColumnDefinition Width="*"/>
				</Grid.ColumnDefinitions>
				
				<ScrollViewer Name="scrollViewer0" Grid.Column="0" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
					<StackPanel Margin="10,10,10,0">
						<Label Content="Customizations" Foreground="{DynamicResource secondaryText}" FontWeight="Bold"/>
						<Border Background="{DynamicResource secondaryColor1}" CornerRadius="5">
							<ListBox Name="customizationPanel" Background="Transparent" Foreground="{DynamicResource secondaryText}" BorderThickness="0" Padding="5"/>
						</Border>
						<Label Content="Timezone" Foreground="{DynamicResource secondaryText}" FontWeight="Bold" Margin="0,5,0,0"/>
						<Border Background="{DynamicResource secondaryColor1}" CornerRadius="5" Margin="0" Padding="5">
							<StackPanel Name="timezonePanel"/>
						</Border>
						<Label Content="Shortcuts" Foreground="{DynamicResource secondaryText}" FontWeight="Bold" Margin="0,5,0,0"/>
						<StackPanel Name="shortcutPanel"/>
					</StackPanel>
				</ScrollViewer>
				
				<ScrollViewer Name="scrollViewer1" Grid.Column="1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
					<StackPanel Name="installPanel" Margin="0,10,10,5"/>
				</ScrollViewer>
				
				<Border Grid.Column="2" CornerRadius="5" Background="{DynamicResource secondaryColor1}" Margin="0,10,10,10">
					<ScrollViewer Name="scrollViewer2" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
						<TextBlock Name="outputBox" Foreground="{DynamicResource secondaryText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
					</ScrollViewer>
				</Border>
			</Grid>
			
			<Grid Grid.Row="2">
				<Button Name="runButton" Content="Run" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Margin="10,0,10,10" Style="{StaticResource RoundedButton}"/>
			</Grid>
			
		</Grid>
	</Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$iconsPath = Join-Path $dependenciesPath "Icons"
$neutronDependencies = Join-Path $dependenciesPath "Neutron"
$programIcons = Join-Path $neutronDependencies "Icons"
$neutronCustomizations = Join-Path $neutronDependencies "Customizations"
$neutronShortcuts = Join-Path $neutronDependencies "Shortcuts"
$neutronPanels = Join-Path $neutronDependencies "Panels"
$neutronFunctions = Join-Path $neutronDependencies "Functions"
$hashtable = Join-Path $neutronDependencies "Programs.ps1"

$logo1 = $window.FindName("logo1")
$logo2 = $window.FindName("logo2")
$minimizeButton = $window.FindName("minimizeButton")
$closeButton = $window.FindName("closeButton")
$runButton = $window.Findname('runButton')
$customizationPanel = $window.FindName('customizationPanel')
$timezonePanel = $window.FindName('timezonePanel')
$shortcutPanel = $window.FindName('shortcutPanel')
$installPanel = $window.FindName('installPanel')
$outputBox = $window.FindName('outputBox')

$colorsPath = Join-Path $dependenciesPath "Colors-Custom.ps1"
. $colorsPath

$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"
$fontFamily = New-Object Windows.Media.FontFamily "file:///$fontPath#Open Sans"
$window.FontFamily = $fontFamily

$logo1.Source = Join-Path $iconsPath "Plugins\Neutron.png"
$logo2.Source = Join-Path $iconsPath "Neutron.png"

if ($secondaryIcons -eq "Light") {
	$checkedImagePath = Join-Path $iconsPath "Checkbox - Checked (Light).png"
	$uncheckedImagePath = Join-Path $iconsPath "Checkbox - Unchecked (Light).png"
} else {
	$checkedImagePath = Join-Path $iconsPath "Checkbox - Checked (Dark).png"
	$uncheckedImagePath = Join-Path $iconsPath "Checkbox - Unchecked (Dark).png"
}

$checkedImage = New-Object -TypeName System.Windows.Media.Imaging.BitmapImage -ArgumentList (New-Object -TypeName System.Uri -ArgumentList $checkedImagePath)
$uncheckedImage = New-Object -TypeName System.Windows.Media.Imaging.BitmapImage -ArgumentList (New-Object -TypeName System.Uri -ArgumentList $uncheckedImagePath)
$window.Resources.Add("CheckedImage", $checkedImage)
$window.Resources.Add("UncheckedImage", $uncheckedImage)

if ($primaryIcons -eq "Light") {
	$buttons = @{ "Minimize (Light)" = $minimizeButton; "Close (Light)" = $closeButton }
} else {
	$buttons = @{ "Minimize (Dark)" = $minimizeButton; "Close (Dark)" = $closeButton }
}

$buttons.GetEnumerator() | %{
	$uri = New-Object System.Uri (Join-Path $iconsPath "$($_.Key).png")
	$img = New-Object System.Windows.Media.Imaging.BitmapImage $uri
	$_.Value.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img }
}

# Construct customization panel
$panelCustomizations = Join-Path $neutronPanels "Panel-Customizations.ps1"
. $panelCustomizations

# Construct timezone panel
$panelTimezones = Join-Path $neutronPanels "Panel-Timezones.ps1"
. $panelTimezones

# Construct shortcut panel
$panelShortcuts = Join-Path $neutronPanels "Panel-Shortcuts.ps1"
. $panelShortcuts

# Construct installer panel
$panelPrograms = Join-Path $neutronPanels "Panel-Programs.ps1"
. $panelPrograms

0..2 | % { $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{ param($sender, $e) $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta) }, $true) }
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

$runButton.Tooltip = "- Perform selected customizations `n- Set selected timezone`n- Install selected programs"
$runButton.Add_Click({
	$scrollToEnd = $window.FindName("scrollViewer2").ScrollToEnd()
	
	$runspace = [runspacefactory]::CreateRunspace()
	$runspace.ApartmentState = "STA"
	$runspace.ThreadOptions = "ReuseThread"
	$runspace.Open()
	
	<#
	$runspace.SessionStateProxy.SetVariable('customizationPanel', $customizationPanel)
	$runspace.SessionStateProxy.SetVariable('installPanel', $installPanel)
	#>
	
	$runspace.SessionStateProxy.SetVariable('outputBox', $outputBox)
	$runspace.SessionStateProxy.SetVariable('runButton', $runButton)
	$runspace.SessionStateProxy.SetVariable('hashtable', $hashtable)
	$runspace.SessionStateProxy.SetVariable('selectedScripts', $selectedScripts)
	$runspace.SessionStateProxy.SetVariable('radioButtons', $radioButtons)
	$runspace.SessionStateProxy.SetVariable('selectedInstallPrograms', $selectedInstallPrograms)
	$runspace.SessionStateProxy.SetVariable('neutronFunctions', $neutronFunctions)
	$runspace.SessionStateProxy.SetVariable('scrollToEnd', $scrollToEnd)
	
	$powershell = [powershell]::Create().AddScript({
		function Write-OutputBox {
			param([string]$Text)
			$outputBox.Dispatcher.Invoke([action]{ $outputBox.Text += "$Text`r`n"; $scrollToEnd }, "Render")
		}
		
		$runButton.Dispatcher.Invoke([action]{ $runButton.Content = "Running..."; $runButton.IsEnabled = $false }, "Render")
		
		Get-ChildItem -Path $neutronFunctions -Filter *.ps1 | ForEach-Object {
			Invoke-Expression -Command (Get-Content $_.FullName | Out-String)
		}
		
		# Run Customizations
		if ($selectedScripts -ne $null) { Write-OutputBox "Customizations:"; foreach ($script in $selectedScripts) { . $script }; Write-OutputBox "" }
		
		# Set Timezone
		Change-Timezone
		
		# Install Programs
		if ($selectedInstallPrograms -ne $null) { Install-Programs -selectedInstallPrograms $selectedInstallPrograms }
		
		<#
		$runButton.Dispatcher.Invoke([action]{
			foreach ($item in $customizationPanel.Items) {
				if ($item.IsEnabled) {
					$item.IsChecked = $false
					$selectedScripts.Remove($item.Tag) | Out-Null
				}
			}
		}, "Render")
		#>
		
		try {
			$outputText = $outputBox.Dispatcher.Invoke([Func[string]]{ $outputBox.Text })
			$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
			$logPath = Join-Path $env:TEMP "neutron-$dateTime.txt"
			$outputText | Out-File -FilePath $logPath
			Write-OutputBox "Log saved to $logPath"
		} catch {
			Write-OutputBox "Failed to save log"
		}
		
		Write-OutputBox "`nNeutron completed."
		
		$runButton.Dispatcher.Invoke([action]{ $runButton.Content = "Run"; $runButton.IsEnabled = $true }, "Render")
	})
	$powershell.Runspace = $runspace
	$null = $powershell.BeginInvoke()
})

# Finds the resolution of the primary display and the display scaling setting
# If the "effective" resolution will cause Neutron's window to clip, it will decrease the window size
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