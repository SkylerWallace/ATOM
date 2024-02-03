$themesPath = Join-Path $settingsPath "Themes.ps1"
. $themesPath

# Select the "Default" theme
$selectedTheme =
	if ($themes[$savedTheme]) { $themes[$savedTheme] }
	else { $themes[0] }

# Iterate through the selected theme and create variables
foreach ($key in $selectedTheme.Keys) {
	New-Variable -Name $key -Value $selectedTheme[$key] -Scope Global
}

# Function for setting icon paths
function Set-ResourceIcons {
	param ([string]$iconCategory, [hashtable]$resourceMappings)

	$theme = switch ($iconCategory) {
		"Primary" { $primaryIcons }
		"Background" { $backgroundIcons }
		"Surface" { $surfaceIcons }
		"Accent" { $accentIcons }
		default { $surfaceIcons }
	}

	foreach ($resourceName in $resourceMappings.Keys) {
		$resource = $window.FindName($resourceName)

		$imagePath = Join-Path $iconsPath ($resourceMappings[$resourceName] + " ($theme).png")
		$uri = New-Object System.Uri $imagePath
		$img = New-Object System.Windows.Media.Imaging.BitmapImage $uri

		if ($resource -is [System.Windows.Controls.Button]) {
			$resource.Content = New-Object System.Windows.Controls.Image -Property @{ Source = $img }
		} elseif ($resource -is [System.Windows.Controls.Image]) {
			$resource.Source = $img
		} else {
			$window.Resources.Add($resourceName, $img)
		}
	}
}

# Set font Path
$fontPath = Join-Path $dependenciesPath "Fonts\OpenSans-Regular.ttf"

# Declare resource dictionary
$resourceDictionary =
"
<Color x:Key='primaryColor'>$primaryColor</Color>
<SolidColorBrush x:Key='primaryBrush' Color='$primaryBrush'/>
<Color x:Key='primaryGrad0'>$primaryGrad0</Color>
<Color x:Key='primaryGrad1'>$primaryGrad1</Color>
<SolidColorBrush x:Key='primaryHighlight' Color='$primaryHighlight'/>
<SolidColorBrush x:Key='primaryText' Color='$primaryText'/>

<Color x:Key='backgroundColor'>$backgroundColor</Color>
<SolidColorBrush x:Key='backgroundBrush' Color='$backgroundBrush'/>
<Color x:Key='backgroundGrad0'>$backgroundGrad0</Color>
<Color x:Key='backgroundGrad1'>$backgroundGrad1</Color>
<SolidColorBrush x:Key='backgroundHighlight' Color='$backgroundHighlight'/>
<SolidColorBrush x:Key='backgroundText' Color='$backgroundText'/>

<Color x:Key='surfaceColor'>$surfaceColor</Color>
<SolidColorBrush x:Key='surfaceBrush' Color='$surfaceBrush'/>
<Color x:Key='surfaceGrad0'>$surfaceGrad0</Color>
<Color x:Key='surfaceGrad1'>$surfaceGrad1</Color>
<SolidColorBrush x:Key='surfaceHighlight' Color='$surfaceHighlight'/>
<SolidColorBrush x:Key='surfaceText' Color='$surfaceText'/>

<Color x:Key='accentColor'>$accentColor</Color>
<SolidColorBrush x:Key='accentBrush' Color='$accentBrush'/>

<SolidColorBrush x:Key='accentHighlight' Color='$accentHighlight'/>
<SolidColorBrush x:Key='accentText' Color='$accentText'/>

<x:Double x:Key='gradientStrength'>$gradientStrength</x:Double>
<x:Double x:Key='shadowBlur'>$shadowBlur</x:Double>
<x:Double x:Key='shadowDepth'>$shadowDepth</x:Double>
<CornerRadius x:Key='cornerStrength'>$cornerStrength</CornerRadius>
<CornerRadius x:Key='cornerStrength1'>$cornerStrength,$cornerStrength,0,0</CornerRadius>
<CornerRadius x:Key='cornerStrength2'>0,0,$cornerStrength,$cornerStrength</CornerRadius>

<FontFamily x:Key='OpenSansFontFamily'>file:///$fontPath#Open Sans</FontFamily>

<Style TargetType='Window'>
	<Setter Property='FontFamily' Value='{StaticResource OpenSansFontFamily}'/>
</Style>

<Style x:Key='CustomBorder' TargetType='{x:Type Border}'>
	<Setter Property='CornerRadius' Value='{DynamicResource cornerStrength}'/>
	<Setter Property='Background'>
		<Setter.Value>
			<LinearGradientBrush StartPoint='0,0' EndPoint='1,1'>
				<GradientStop Color='{DynamicResource surfaceGrad0}' Offset='0'/>
				<GradientStop Color='{DynamicResource surfaceGrad1}' Offset='{DynamicResource gradientStrength}'/>
			</LinearGradientBrush>
		</Setter.Value>
	</Setter>	
	<Setter Property='Effect'>
		<Setter.Value>
			<DropShadowEffect Color='Black' Opacity='0.2' BlurRadius='{DynamicResource shadowBlur}' ShadowDepth='{DynamicResource shadowDepth}'/>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomCheckBoxStyle' TargetType='{x:Type CheckBox}'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type CheckBox}'>
				<Grid>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width='Auto'/>
						<ColumnDefinition Width='*'/>
					</Grid.ColumnDefinitions>
					<Image Name='Image' Width='20' Height='20'/>
					<ContentPresenter Grid.Column='1' Margin='5,0,0,0' VerticalAlignment='Center'/>
				</Grid>
				<ControlTemplate.Triggers>
					<Trigger Property='IsChecked' Value='True'>
						<Setter TargetName='Image' Property='Source' Value='{DynamicResource checkedImage}'/>
					</Trigger>
					<Trigger Property='IsChecked' Value='False'>
						<Setter TargetName='Image' Property='Source' Value='{DynamicResource uncheckedImage}'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomContextMenu' TargetType='{x:Type ContextMenu}'>
	<Setter Property='SnapsToDevicePixels' Value='True'/>
	<Setter Property='OverridesDefaultStyle' Value='True'/>
	<Setter Property='Grid.IsSharedSizeScope' Value='True'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ContextMenu}'>
				<Border Name='Border' Background='{TemplateBinding Background}' CornerRadius='8' Padding='5'>
					<StackPanel IsItemsHost='True' KeyboardNavigation.DirectionalNavigation='Cycle'/>
				</Border>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomListBoxItem' TargetType='{x:Type ListBoxItem}'>
	<Setter Property='Foreground' Value='White'/>
	<Setter Property='Margin' Value='0.5'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ListBoxItem}'>
				<Border Background='{TemplateBinding Background}' BorderBrush='{TemplateBinding BorderBrush}' BorderThickness='{TemplateBinding BorderThickness}' Margin='{TemplateBinding Margin}' CornerRadius='{DynamicResource cornerStrength}'>
					<ContentPresenter/>
				</Border>
				<ControlTemplate.Triggers>
					<Trigger Property='IsMouseOver' Value='True'>
						<Setter Property='Background' Value='{DynamicResource surfaceHighlight}'/>
						<Setter Property='BorderThickness' Value='1'/>
						<Setter Property='BorderBrush' Value='{DynamicResource surfaceHighlight}'/>
					</Trigger>
					<Trigger Property='IsSelected' Value='True'>
						<Setter Property='Background' Value='{DynamicResource surfaceHighlight}'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomListBoxStyle' TargetType='{x:Type ListBox}'>
	<Setter Property='BorderBrush' Value='Transparent'/>
	<Setter Property='Background' Value='Transparent'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ListBox}'>
				<Border BorderThickness='0' CornerRadius='5' Padding='5'> 
					<Border.Background>
						<LinearGradientBrush StartPoint='0,0' EndPoint='1,1'>
							<GradientStop Color='{DynamicResource surfaceGrad0}' Offset='0'/>
							<GradientStop Color='{DynamicResource surfaceGrad1}' Offset='{DynamicResource gradientStrength}'/>
						</LinearGradientBrush>
					</Border.Background>
					<Border.Effect>
						<DropShadowEffect Color='Black' Opacity='0.2' BlurRadius='{DynamicResource shadowBlur}' ShadowDepth='{DynamicResource shadowDepth}'/>
					</Border.Effect>
					<ScrollViewer Focusable='False'>
						<StackPanel IsItemsHost='True'/>
					</ScrollViewer>
				</Border>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomThumb' TargetType='{x:Type Thumb}'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type Thumb}'>
				<Border Background='{DynamicResource accentBrush}' CornerRadius='3' Margin='0,10,10,10'/>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomScrollBar' TargetType='{x:Type ScrollBar}'>
	<Setter Property='Width' Value='10'/>
	<Setter Property='Background' Value='Transparent'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ScrollBar}'>
				<Grid>
					<Rectangle Width='5' Fill='{DynamicResource backgroundHighlight}' RadiusX='3' RadiusY='3' Margin='0,10,10,10'/>
					<Track Name='PART_Track' IsDirectionReversed='True'>
						<Track.Thumb>
							<Thumb Style='{StaticResource CustomThumb}'/>
						</Track.Thumb>
					</Track>
				</Grid>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='CustomScrollViewerStyle' TargetType='{x:Type ScrollViewer}'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ScrollViewer}'>
				<Grid>
					<Grid.ColumnDefinitions>
						<ColumnDefinition Width='*'/>
						<ColumnDefinition Width='Auto'/>
					</Grid.ColumnDefinitions>
					<ScrollContentPresenter Grid.Column='0'/>
					<ScrollBar Name='PART_VerticalScrollBar' Grid.Column='1' Orientation='Vertical' Style='{StaticResource CustomScrollBar}' Maximum='{TemplateBinding ScrollableHeight}' Value='{TemplateBinding VerticalOffset}' ViewportSize='{TemplateBinding ViewportHeight}'/>
				</Grid>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style TargetType='ListBoxItem'>
	<Setter Property='Foreground' Value='White'/>
	<Setter Property='Margin' Value='0.5'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ListBoxItem}'>
				<Border Background='{TemplateBinding Background}' BorderBrush='{TemplateBinding BorderBrush}' BorderThickness='{TemplateBinding BorderThickness}' Margin='{TemplateBinding Margin}' CornerRadius='{DynamicResource cornerStrength}'>
					<ContentPresenter/>
				</Border>
				<ControlTemplate.Triggers>
					<Trigger Property='IsMouseOver' Value='True'>
						<Setter Property='Background' Value='{DynamicResource surfaceHighlight}'/>
						<Setter Property='BorderThickness' Value='1'/>
						<Setter Property='BorderBrush' Value='{DynamicResource surfaceHighlight}'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style TargetType='RadioButton'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type RadioButton}'>
				<BulletDecorator Background='Transparent' Cursor='Hand'>
					<BulletDecorator.Bullet>
						<Grid Height='15' Width='15'>
							<Ellipse Name='RadioOuter' Fill='Transparent' Stroke='{DynamicResource surfaceHighlight}' StrokeThickness='2' Opacity='0.5'/>
							<Ellipse Name='RadioInner' Fill='{DynamicResource accentBrush}' Visibility='Hidden' Margin='4'/>
						</Grid>
					</BulletDecorator.Bullet>
					<TextBlock Name='TextBlock' Margin='5,0,0,0' Foreground='{DynamicResource surfaceHighlight}' FontSize='12'>
						<ContentPresenter/>
					</TextBlock>
				</BulletDecorator>
				<ControlTemplate.Triggers>
					<Trigger Property='IsChecked' Value='true'>
						<Setter TargetName='RadioOuter' Property='Opacity' Value='1.0'/>
						<Setter TargetName='RadioOuter' Property='Stroke' Value='{DynamicResource accentBrush}'/>
						<Setter TargetName='RadioInner' Property='Visibility' Value='Visible'/>
						<Setter TargetName='TextBlock' Property='Foreground' Value='{DynamicResource surfaceText}'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='RoundedButton' TargetType='{x:Type Button}'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type Button}'>
				<Border Name='Border' Background='{TemplateBinding Background}' BorderBrush='{TemplateBinding BorderBrush}' BorderThickness='0' CornerRadius='{DynamicResource cornerStrength}' Padding='2.5'>
					<ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center'/>
				</Border>
				<ControlTemplate.Triggers>
					<Trigger Property='IsMouseOver' Value='True'>
						<Setter TargetName='Border' Property='Background' Value='{DynamicResource surfaceHighlight}'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style x:Key='RoundHoverButtonStyle' TargetType='{x:Type Button}'>
	<Setter Property='Background' Value='Transparent'/>
	<Setter Property='BorderBrush' Value='Transparent'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type Button}'>
				<Grid>
					<Ellipse Name='Circle' Fill='Transparent' Width='{TemplateBinding Width}' Height='{TemplateBinding Height}'/>
					<ContentPresenter HorizontalAlignment='Center' VerticalAlignment='Center' Margin='2.5'/>
				</Grid>
				<ControlTemplate.Triggers>
					<Trigger Property='IsMouseOver' Value='True'>
						<Setter TargetName='Circle' Property='Fill' Value='{DynamicResource primaryHighlight}'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style TargetType='Slider'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='Slider'>
				<Border Height='5' Background='Transparent' BorderBrush='Transparent' BorderThickness='0' CornerRadius='2.5'>
					<Track>
						<Track.DecreaseRepeatButton>
							<RepeatButton Height='10' Command='Slider.DecreaseLarge' Background='{DynamicResource primaryBrush}'>
								<RepeatButton.Template>
									<ControlTemplate TargetType='RepeatButton'>
										<Border Background='{TemplateBinding Background}'/>
									</ControlTemplate>
								</RepeatButton.Template>
							</RepeatButton>
						</Track.DecreaseRepeatButton>
						<Track.IncreaseRepeatButton>
							<RepeatButton Height='10' Command='Slider.IncreaseLarge' Background='{DynamicResource backgroundBrush}'>
								<RepeatButton.Template>
									<ControlTemplate TargetType='RepeatButton'>
										<Border Background='{TemplateBinding Background}'/>
									</ControlTemplate>
								</RepeatButton.Template>
							</RepeatButton>
						</Track.IncreaseRepeatButton>
						<Track.Thumb>
							<Thumb>
								<Thumb.Template>
									<ControlTemplate TargetType='Thumb'>
										<Ellipse Width='15' Height='15' Fill='{DynamicResource primaryBrush}' Margin='-10 -10'/>
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

<Style TargetType='TextBox'>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='TextBox'>
				<Border Background='{TemplateBinding Background}' CornerRadius='{DynamicResource cornerStrength}'>
					<ScrollViewer Margin='0' Name='PART_ContentHost'/>
				</Border>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style TargetType='ToggleButton'>
	<Setter Property='Width' Value='40'/>
	<Setter Property='Height' Value='20'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ToggleButton}'>
				<Border Name='Border' Background='{DynamicResource surfaceHighlight}' CornerRadius='10'>
					<Ellipse Name='Ellipse' Width='15' Height='15' Fill='{DynamicResource primaryText}' HorizontalAlignment='Left' Margin='2.5'/>
				</Border>
				<ControlTemplate.Triggers>
					<Trigger Property='IsChecked' Value='True'>
						<Setter TargetName='Border' Property='Background' Value='{DynamicResource primaryBrush}'/>
						<Setter TargetName='Ellipse' Property='HorizontalAlignment' Value='Right'/>
					</Trigger>
				</ControlTemplate.Triggers>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>

<Style TargetType='ToolTip'>
	<Setter Property='Background' Value='{DynamicResource accentBrush}'/>
	<Setter Property='Foreground' Value='{DynamicResource accentText}'/>
	<Setter Property='Template'>
		<Setter.Value>
			<ControlTemplate TargetType='{x:Type ToolTip}'>
				<Border Background='{TemplateBinding Background}' CornerRadius='{DynamicResource cornerStrength}' Padding='5'>
					<ContentPresenter Content='{TemplateBinding Content}'/>
				</Border>
			</ControlTemplate>
		</Setter.Value>
	</Setter>
</Style>
"