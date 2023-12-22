# Launch: Hidden

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

[xml]$xaml = @"
<Window
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	Title="ATOM Palette"
	Background="Transparent"
	AllowsTransparency="True"
	WindowStyle="None"
	SizeToContent="WidthAndHeight"
	WindowStartupLocation="CenterScreen"
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
	
		<Style x:Key="RoundedButton" TargetType="{x:Type Button}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5">
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
		
		<Style x:Key="RoundedTopButton" TargetType="{x:Type Button}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5,5,0,0">
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
		
		<Style x:Key="RoundedBottomButton" TargetType="{x:Type Button}">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Button}">
						<Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="0,0,5,5">
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
		
		<Style TargetType="Slider">
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="Slider">
						<Border Height="5" Background="Transparent" BorderBrush="Transparent" BorderThickness="0" CornerRadius="2.5">
							<Track Name="PART_Track">
								<Track.DecreaseRepeatButton>
									<RepeatButton Height="10" Command="Slider.DecreaseLarge" Background="{DynamicResource primaryColor}">
										<RepeatButton.Template>
											<ControlTemplate TargetType="RepeatButton">
												<Border Background="{TemplateBinding Background}"/>
											</ControlTemplate>
										</RepeatButton.Template>
									</RepeatButton>
								</Track.DecreaseRepeatButton>
								<Track.IncreaseRepeatButton>
									<RepeatButton Height="10" Command="Slider.IncreaseLarge" Background="{DynamicResource secondaryColor2}">
										<RepeatButton.Template>
											<ControlTemplate TargetType="RepeatButton">
												<Border Background="{TemplateBinding Background}"/>
											</ControlTemplate>
										</RepeatButton.Template>
									</RepeatButton>
								</Track.IncreaseRepeatButton>
								<Track.Thumb>
									<Thumb>
										<Thumb.Template>
											<ControlTemplate TargetType="Thumb">
												<Ellipse Width="15" Height="15" Fill="{DynamicResource primaryColor}" Margin="-10 -10"/>
											</ControlTemplate>
										</Thumb.Template>
									</Thumb>
								</Track.Thumb>
							</Track>
						</Border>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>

	</Window.Resources>
	
	<WindowChrome.WindowChrome>
		<WindowChrome ResizeBorderThickness="0" CaptionHeight="0" CornerRadius="10"/>
	</WindowChrome.WindowChrome>
	
	<Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource secondaryColor2}" CornerRadius="5">
		<Grid>
			<Grid.RowDefinitions>
				<RowDefinition Height="60"/>
				<RowDefinition Height="*"/>
				<RowDefinition Height="Auto"/>
			</Grid.RowDefinitions>
			
			<Grid Grid.Row="0">
				<Border Background="{DynamicResource primaryColor}" CornerRadius="5,5,0,0"/>
				<Image Name="logo" Width="40" Height="40" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="10,0,0,0"/>
				<TextBlock Text="ATOM Palette" Foreground="{DynamicResource primaryText}" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" HorizontalAlignment="Left" Margin="60,0,0,0"/>
				<Button Name="closeButton" Width="20" Height="20" HorizontalAlignment="Right" Style="{StaticResource RoundHoverButtonStyle}" Margin="0,0,10,0" ToolTip="Close"/>
			</Grid>
			
			<Grid Grid.Row="1" Margin="5">
				<Border Background="{DynamicResource secondaryColor1}" BorderBrush="Transparent" BorderThickness="0" CornerRadius="5" Margin="5">
					<StackPanel HorizontalAlignment="Center" Margin="5">
					
						<StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
						
							<Button Name="primaryButton" Background="Transparent" BorderBrush="Transparent" Width="100" Margin="5" Style="{StaticResource RoundedButton}">
								<StackPanel>
									<StackPanel Orientation="Horizontal">
										<TextBlock Text="Primary" Foreground="{DynamicResource secondaryText}" Margin="5"/>
										<Ellipse Name="primaryEllipse" Width="15" Height="15" Fill="Red" Stroke="{DynamicResource secondaryText}" Margin="5"/>
									</StackPanel>
									<TextBlock Name="primaryHex" Foreground="{DynamicResource secondaryText}" HorizontalAlignment="Center" Margin="5,0,5,5"/>
								</StackPanel>
							</Button>
							
							<Button Name="secondaryButton" Background="Transparent" BorderBrush="Transparent" Width="100" Margin="5" Style="{StaticResource RoundedButton}">
								<StackPanel>
									<StackPanel Orientation="Horizontal">
										<TextBlock Text="Secondary" Foreground="{DynamicResource secondaryText}" Margin="5"/>
										<Ellipse Name="secondaryEllipse" Width="15" Height="15" Fill="Red" Stroke="{DynamicResource secondaryText}" Margin="5"/>
									</StackPanel>
									<TextBlock Name="secondaryHex" Foreground="{DynamicResource secondaryText}" HorizontalAlignment="Center"/>
								</StackPanel>
							</Button>
							
							<Button Name="accentButton" Background="Transparent" BorderBrush="Transparent" Width="100" Margin="5" Style="{StaticResource RoundedButton}">
								<StackPanel>
									<StackPanel Orientation="Horizontal">
										<TextBlock Text="Accent" Foreground="{DynamicResource secondaryText}" Margin="5"/>
										<Ellipse Name="accentEllipse" Width="15" Height="15" Fill="Red" Stroke="{DynamicResource secondaryText}" Margin="5"/>
									</StackPanel>
									<TextBlock Name="accentHex" Foreground="{DynamicResource secondaryText}" HorizontalAlignment="Center"/>
								</StackPanel>
							</Button>
							
						</StackPanel>
						
						<StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,5,10,5">
							<TextBlock Text="R:" Width="30" Foreground="{DynamicResource secondaryText}" TextAlignment="Left" VerticalAlignment="Center"/>
							<Slider Name="redSlider" Width="180" Height="20" Orientation="Horizontal" VerticalAlignment="Center" Minimum="0" Maximum="255" TickFrequency="1"/>
							<TextBox Name="redTextBox" Width="60" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" TextAlignment="Right" VerticalAlignment="Center" Margin="10,0,0,0" Padding="5,2,5,2"/>
							<StackPanel Margin="10,0,0,0">
								<Button Name="rUpButton" Content="▲" FontSize="5" Width="15" Height="10" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedTopButton}"/>
								<Button Name="rDownButton" Content="▼" FontSize="5" Width="15" Height="10" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedBottomButton}"/>
							</StackPanel>
						</StackPanel>
						
						<StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,5,10,5">
							<TextBlock Text="G:" Width="30" Foreground="{DynamicResource secondaryText}" VerticalAlignment="Center"/>
							<Slider Name="greenSlider" Width="180" Height="20" Orientation="Horizontal" VerticalAlignment="Center" Minimum="0" Maximum="255" TickFrequency="1"/>
							<TextBox Name="greenTextBox" Width="60" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" TextAlignment="Right" VerticalAlignment="Center" Margin="10,0,0,0" Padding="5,2,5,2"/>
							<StackPanel Margin="10,0,0,0">
								<Button Name="gUpButton" Content="▲" FontSize="5" Width="15" Height="10" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedTopButton}"/>
								<Button Name="gDownButton" Content="▼" FontSize="5" Width="15" Height="10" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedBottomButton}"/>
							</StackPanel>
						</StackPanel>
						
						<StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,5,10,5">
							<TextBlock Text="B:" Width="30" Foreground="{DynamicResource secondaryText}" VerticalAlignment="Center"/>
							<Slider Name="blueSlider" Width="180" Height="20" Orientation="Horizontal" VerticalAlignment="Center" Minimum="0" Maximum="255" TickFrequency="1"/>
							<TextBox Name="blueTextBox" Width="60" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" TextAlignment="Right" VerticalAlignment="Center" Margin="10,0,0,0" Padding="5,2,5,2"/>
							<StackPanel Margin="10,0,0,0">
								<Button Name="bUpButton" Content="▲" FontSize="5" Width="15" Height="10" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedTopButton}"/>
								<Button Name="bDownButton" Content="▼" FontSize="5" Width="15" Height="10" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedBottomButton}"/>
							</StackPanel>
						</StackPanel>
						
						<StackPanel Orientation="Horizontal" HorizontalAlignment="Center" Margin="10,5,10,5">
							<TextBlock Text="Hex:" Width="30" Foreground="{DynamicResource secondaryText}" VerticalAlignment="Center"/>
							<TextBox Name="hexTextBox" Width="250" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" TextAlignment="Right" MaxLength="6" VerticalAlignment="Center" Margin="0,0,25,0" Padding="5,2,5,2"/>
						</StackPanel>
						
					</StackPanel>
				</Border>
			</Grid>
			
			<Grid Grid.Row="2">
				<StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
					<Button Name="defaultColorsButton" Content="Restore Default Colors" Width="165" Height="20" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedButton}" Margin="10,0,5,10"/>
					<Button Name="setColorsButton" Content="Save Colors" Width="160" Height="20" Background="{DynamicResource accentColor}" Foreground="{DynamicResource accentText}" Style="{StaticResource RoundedButton}" Margin="10,0,10,10"/>
				</StackPanel>
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

$logo = $window.FindName('logo')
$closeButton = $window.FindName('closeButton')
$primaryButton = $window.FindName('primaryButton')
$secondaryButton = $window.FindName('secondaryButton')
$accentButton = $window.FindName('accentButton')
$primaryEllipse = $window.FindName('primaryEllipse')
$secondaryEllipse = $window.FindName('secondaryEllipse')
$accentEllipse = $window.FindName('accentEllipse')
$primaryHex = $window.FindName('primaryHex')
$secondaryHex = $window.FindName('secondaryHex')
$accentHex = $window.FindName('accentHex')
$redSlider = $window.FindName('redSlider')
$greenSlider = $window.FindName('greenSlider')
$blueSlider = $window.FindName('blueSlider')
$redTextBox = $window.FindName('redTextBox')
$greenTextBox = $window.FindName('greenTextBox')
$blueTextBox = $window.FindName('blueTextBox')
$hexTextBox = $window.FindName('hexTextBox')
$rUpButton = $window.FindName('rUpButton')
$rDownButton = $window.FindName('rDownButton')
$gUpButton = $window.FindName('gUpButton')
$gDownButton = $window.FindName('gDownButton')
$bUpButton = $window.FindName('bUpButton')
$bDownButton = $window.FindName('bDownButton')
$defaultColorsButton = $window.FindName('defaultColorsButton')
$setColorsButton = $window.FindName('setColorsButton')

$colorsPath = Join-Path $dependenciesPath "Colors-Custom.ps1"
. $colorsPath
$primaryHex.Text = $primaryColor.Replace("#", "")
$secondaryHex.Text = $secondaryColor1.Replace("#", "")
$accentHex.Text = $accentColor.Replace("#", "")
$primaryEllipse.Fill = $primaryColor
$secondaryEllipse.Fill = $secondaryColor1
$accentEllipse.Fill = $accentColor

$logo.Source = Join-Path $iconsPath "Plugins\ATOM Palette.png"

function Set-ButtonIcon ($button, $iconName) {
	$uri = New-Object System.Uri (Join-Path $iconsPath "$iconName.png")
	$img = New-Object System.Windows.Media.Imaging.BitmapImage $uri
	$button.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img }
}

if ($primaryIcons -eq "Light") {
	$buttons = @{ "Close (Light)" = $closeButton }
} else {
	$buttons = @{ "Close (Dark)" = $closeButton }
}

$buttons.GetEnumerator() | %{ Set-ButtonIcon $_.Value $_.Key }

$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"
$fontFamily = New-Object Windows.Media.FontFamily "file:///$fontPath#Open Sans"
$window.FontFamily = $fontFamily

$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({$this.DragMove()})

function Validate-TextBoxInput([System.Windows.Controls.TextBox]$textBox) {
	if ($textBox.Text -match '^\d+$') {
		$value = [Math]::Min([int]$textBox.Text, 255)
		$textBox.Text = $value.ToString()
		return $value
	} else {
		$textBox.Text = "0"
		return 0
	}
}

function Update-Color {
	param([int]$RValue, [int]$GValue, [int]$BValue)

	$color = [System.Windows.Media.Color]::FromRgb($RValue, $GValue, $BValue)
	$hexValue = $color.ToString().Substring(3)
	$hexTextBox.Text = $hexValue

	$script:currentColorEllipse.Fill = [System.Windows.Media.SolidColorBrush]::new($color)
	$script:currentColorHexText.Text = $hexValue
}

function Update-TextBoxColor {
	$RValue = Validate-TextBoxInput $redTextBox
	$GValue = Validate-TextBoxInput $greenTextBox
	$BValue = Validate-TextBoxInput $blueTextBox

	Update-Color $RValue $GValue $BValue
}

function Update-SliderColor {
	$RValue = [Math]::Round($redSlider.Value)
	$GValue = [Math]::Round($greenSlider.Value)
	$BValue = [Math]::Round($blueSlider.Value)

	$redTextBox.Text = $RValue.ToString()
	$greenTextBox.Text = $GValue.ToString()
	$blueTextBox.Text = $BValue.ToString()

	Update-Color $RValue $GValue $BValue
}

$redSlider.Add_ValueChanged({ Update-SliderColor })
$greenSlider.Add_ValueChanged({ Update-SliderColor })
$blueSlider.Add_ValueChanged({ Update-SliderColor })

$redTextBox.Add_TextChanged({ Update-TextBoxColor })
$greenTextBox.Add_TextChanged({ Update-TextBoxColor })
$blueTextBox.Add_TextChanged({ Update-TextBoxColor })

function Update-HexColor {
	if ($hexTextBox.Text.Length -eq 6) {
		$color = [System.Windows.Media.ColorConverter]::ConvertFromString("#" + $hexTextBox.Text)
		$redSlider.Value = $color.R
		$greenSlider.Value = $color.G
		$blueSlider.Value = $color.B

		$redTextBox.Text = $color.R.ToString()
		$greenTextBox.Text = $color.G.ToString()
		$blueTextBox.Text = $color.B.ToString()

		$script:currentColorEllipse.Fill = [System.Windows.Media.SolidColorBrush]::new($color)
		$script:currentColorHexText.Text = $hexTextBox.Text
	}
}

Update-HexColor

$hexTextBox.Add_TextChanged({ Update-HexColor })

$hexTextBox.Add_PreviewTextInput({
	if (-not [System.Text.RegularExpressions.Regex]::IsMatch($_.Text, '^[0-9a-fA-F]+$')) {
		$_.Handled = $true
	}
})

$hexTextBox.AddHandler([Windows.DataObject]::PastingEvent, [Windows.DataObjectPastingEventHandler]{
	param($sender, $e)
	
	if ($e.SourceDataObject.GetDataPresent([Windows.DataFormats]::Text, $true)) {
		$pastedText = $e.SourceDataObject.GetData([Windows.DataFormats]::Text)
		$cleanedText = $pastedText -replace '[^0-9a-fA-F]', ''
		
		if ($cleanedText -match '^[0-9a-fA-F]{6}$') {
			$sender.Text = $cleanedText
		} else {
			$e.CancelCommand()
		}
	} else {
		$e.CancelCommand()
	}
})

function Select-Color {
	param([System.Windows.Shapes.Ellipse]$ellipse, [System.Windows.Controls.TextBlock]$hexTextBlock)

	$primaryButton.Background = "Transparent"
	$secondaryButton.Background = "Transparent"
	$accentButton.Background = "Transparent"

	$ellipse.Parent.Parent.Parent.Background = $secondaryColor2

	$script:currentColorEllipse = $ellipse
	$script:currentColorHexText = $hexTextBlock
	
	$hexTextBox.Text = $hexTextBlock.Text
	Update-HexColor $hexTextBlock.Text
}

$primaryButton.Add_Click({ Select-Color $primaryEllipse $primaryHex })
$secondaryButton.Add_Click({ Select-Color $secondaryEllipse $secondaryHex })
$accentButton.Add_Click({ Select-Color $accentEllipse $accentHex })

Select-Color $primaryEllipse $primaryHex

function Update-NumericValue {
	param(
		[Parameter(Mandatory=$true)]
		[System.Windows.Controls.TextBox]$textBox,
		
		[Parameter(Mandatory=$false)]
		[int]$Increment = 1
	)
	
	$textBox.Text = ([int]$textBox.Text + $Increment).ToString()
}

$rUpButton.Add_Click({ Update-NumericValue -TextBox $redTextBox -Increment 1 })
$rDownButton.Add_Click({ Update-NumericValue -TextBox $redTextBox -Increment -1 })
$gUpButton.Add_Click({ Update-NumericValue -TextBox $greenTextBox -Increment 1 })
$gDownButton.Add_Click({ Update-NumericValue -TextBox $greenTextBox -Increment -1 })
$bUpButton.Add_Click({ Update-NumericValue -TextBox $blueTextBox -Increment 1 })
$bDownButton.Add_Click({ Update-NumericValue -TextBox $blueTextBox -Increment -1 })

$defaultColorsButton.Add_Click({
	$colorsPath = Join-Path $dependenciesPath "Colors-Default.ps1"
	. $colorsPath
	$primaryHex.Text = $primaryColor.Replace("#", "")
	$secondaryHex.Text = $secondaryColor1.Replace("#", "")
	$accentHex.Text = $accentColor.Replace("#", "")
	$primaryEllipse.Fill = $primaryColor
	$secondaryEllipse.Fill = $secondaryColor1
	$accentEllipse.Fill = $accentColor
	
	Select-Color $accentEllipse $accentHex
	Select-Color $secondaryEllipse $secondaryHex
	Select-Color $primaryEllipse $primaryHex
})

$setColorsButton.Add_Click({
	$lightHighlight = "#40FFFFFF"
	$darkHighlight = "#40000000"
	
	function Get-TextColor {
		param (
			[string]$backgroundColor,
			[switch]$highlightColor
		)

		$r = [convert]::ToInt32($backgroundColor.Substring(1,2),16)
		$g = [convert]::ToInt32($backgroundColor.Substring(3,2),16)
		$b = [convert]::ToInt32($backgroundColor.Substring(5,2),16)

		$luminance = (0.299 * $r + 0.587 * $g + 0.114 * $b) / 255

		if ($highlightColor) {
			if ($luminance -gt 0.6) {
				return $darkHighlight
			} else {
				return $lightHighlight
			}
		} else {
			if ($luminance -gt 0.6) {
				return "Black"
			} else {
				return "White"
			}
		}
	}
	
	function Get-DarkerColor {
		param (
			[string]$foregroundColor
		)

		$diffR = 0x49 - 0x27
		$diffG = 0x49 - 0x27
		$diffB = 0x4A - 0x28

		$darkerR = [Math]::Max(0, [convert]::ToInt32($foregroundColor.Substring(1,2), 16) - $diffR)
		$darkerG = [Math]::Max(0, [convert]::ToInt32($foregroundColor.Substring(3,2), 16) - $diffG)
		$darkerB = [Math]::Max(0, [convert]::ToInt32($foregroundColor.Substring(5,2), 16) - $diffB)

		$darkerColor = "#{0:X2}{1:X2}{2:X2}" -f $darkerR, $darkerG, $darkerB

		return $darkerColor
	}

	
	$primaryColor = "#" + $primaryHex.Text
	$primaryText = Get-TextColor -backgroundColor $primaryColor
	$primaryHighlight = Get-TextColor -backgroundColor $primaryColor -highlightColor
	if ($primaryHighlight -eq $lightHighlight) {
		$primaryIcons = "Light"
	} elseif ($primaryHighlight -eq $darkHighlight) {
		$primaryIcons = "Dark"
	}
	
	$secondaryColor1 = "#" + $secondaryHex.Text
	$secondaryColor2 = Get-DarkerColor -foregroundColor $secondaryColor1
	$secondaryText = Get-TextColor -backgroundColor $secondaryColor1
	$secondaryHighlight = Get-TextColor -backgroundColor $secondaryColor1 -highlightColor
	if ($secondaryHighlight -eq $lightHighlight) {
		$secondaryIcons = "Light"
	} elseif ($secondaryHighlight -eq $darkHighlight) {
		$secondaryIcons = "Dark"
	}
	
	$accentColor = "#" + $accentHex.Text
	$accentText = Get-TextColor -backgroundColor $accentColor
	$accentHighlight = Get-TextColor -backgroundColor $accentColor -highlightColor
	if ($accentHighlight -eq $lightHighlight) {
		$accentIcons = "Light"
	} elseif ($accentHighlight -eq $darkHighlight) {
		$accentIcons = "Dark"
	}
	
	$scriptContents = @(
		"`$primaryColor = `"$primaryColor`""
		"`$primaryText = `"$primaryText`""
		"`$primaryHighlight = `"$primaryHighlight`""
		"`$primaryIcons = `"$primaryIcons`""
		""
		"`$secondaryColor1 = `"$secondaryColor1`""
		"`$secondaryColor2 = `"$secondaryColor2`""
		"`$secondaryText = `"$secondaryText`""
		"`$secondaryHighlight = `"$secondaryHighlight`""
		"`$secondaryIcons = `"$secondaryIcons`""
		""
		"`$accentColor = `"$accentColor`""
		"`$accentText = `"$accentText`""
		"`$accentHighlight = `"$accentHighlight`""
		"`$accentIcons = `"$accentIcons`""
		""
		"`$window.Resources[`"primaryColor`"].Color = `$primaryColor"
		"`$window.Resources[`"primaryText`"].Color = `$primaryText"
		"`$window.Resources[`"primaryHighlight`"].Color = `$primaryHighlight"
		""
		"`$window.Resources[`"secondaryColor1`"].Color = `$secondaryColor1"
		"`$window.Resources[`"secondaryColor2`"].Color = `$secondaryColor2"
		"`$window.Resources[`"secondaryText`"].Color = `$secondaryText"
		"`$window.Resources[`"secondaryHighlight`"].Color = `$secondaryHighlight"
		""
		"`$window.Resources[`"accentColor`"].Color = `$accentColor"
		"`$window.Resources[`"accentText`"].Color = `$accentText"
		"`$window.Resources[`"accentHighlight`"].Color = `$accentHighlight"
	)
	
	Set-Content -Path $colorsPath -Value $scriptContents
})

$window.ShowDialog() | Out-Null