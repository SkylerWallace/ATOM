# Import default settings & themes
. "$configPath\Settings.ps1"

# Load user settings
if (Test-Path "$configPath\SettingsUser.ps1") {
    . "$configPath\SettingsUser.ps1"
    foreach ($key in $userAtomSettings.GetEnumerator()) {
        if ($atomSettings.Contains($key.Key)) {
            $atomSettings[$key.Key].Value = $key.Value.Value
        }
    }
    if ($userAtomSettings.Contains('TextScaling') -and !$userAtomSettings.Contains('UIScaling')) {
        $atomSettings.UIScaling.Value = [Double]$userAtomSettings.TextScaling.Value
    }
}

# Import themes
. "$configPath\Themes.ps1"

# Create variables for each value in selected theme's hashtable
$themes[$atomSettings.Theme.Value].GetEnumerator() | ForEach-Object {
    New-Variable -Name $_.Name -Value $_.Value -Scope Global
}

# Import functions from WPF folder
Get-ChildItem "$psScriptRoot\WPF" -Include *.ps1 -Recurse | ForEach-Object {
    . $_.FullName
}

# Add click event for listbox items
Update-TypeData -TypeName System.Windows.Controls.ListBoxItem -MemberType ScriptMethod -MemberName Add_MouseClick -Value {
    param([ScriptBlock]$Action)

    $this | Add-Member -MemberType NoteProperty -Name MouseClickAction -Value $Action -Force
    $this | Add-Member -MemberType NoteProperty -Name MouseClickPressed -Value $false -Force

    $this.Add_PreviewMouseLeftButtonDown({
        $this.MouseClickPressed = $true
    })

    $this.Add_MouseLeave({
        if ([System.Windows.Input.Mouse]::LeftButton -eq [System.Windows.Input.MouseButtonState]::Pressed) {
            $this.MouseClickPressed = $false
        }
    })

    $this.Add_MouseLeftButtonUp({
        if (!$this.MouseClickPressed) { return }

        $this.MouseClickPressed = $false
        & $this.MouseClickAction $this
    })
}

# Declare resource dictionary
$iconDictionaryUri = [System.Uri]::new((Resolve-Path "$resourcesPath\Icons\Common.xaml").Path).AbsoluteUri
$resourceDictionary = @"
<ResourceDictionary
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <ResourceDictionary.MergedDictionaries>
        <ResourceDictionary Source="$iconDictionaryUri"/>
    </ResourceDictionary.MergedDictionaries>

<Color x:Key="primaryColor">$primaryColor</Color>
<SolidColorBrush x:Key="primaryBrush" Color="$primaryBrush"/>
<Color x:Key="primaryGrad0">$primaryGrad0</Color>
<Color x:Key="primaryGrad1">$primaryGrad1</Color>
<SolidColorBrush x:Key="primaryHighlight" Color="$primaryHighlight"/>
<SolidColorBrush x:Key="primaryText" Color="$primaryText"/>

<Color x:Key="backgroundColor">$backgroundColor</Color>
<SolidColorBrush x:Key="backgroundBrush" Color="$backgroundBrush"/>
<Color x:Key="backgroundGrad0">$backgroundGrad0</Color>
<Color x:Key="backgroundGrad1">$backgroundGrad1</Color>
<SolidColorBrush x:Key="backgroundHighlight" Color="$backgroundHighlight"/>
<SolidColorBrush x:Key="backgroundText" Color="$backgroundText"/>

<Color x:Key="surfaceColor">$surfaceColor</Color>
<SolidColorBrush x:Key="surfaceBrush" Color="$surfaceBrush"/>
<Color x:Key="surfaceGrad0">$surfaceGrad0</Color>
<Color x:Key="surfaceGrad1">$surfaceGrad1</Color>
<SolidColorBrush x:Key="surfaceHighlight" Color="$surfaceHighlight"/>
<SolidColorBrush x:Key="surfaceText" Color="$surfaceText"/>

<Color x:Key="accentColor">$accentColor</Color>
<SolidColorBrush x:Key="accentBrush" Color="$accentBrush"/>

<SolidColorBrush x:Key="accentHighlight" Color="$accentHighlight"/>
<SolidColorBrush x:Key="accentText" Color="$accentText"/>

<x:Double x:Key="uiScale">$($atomSettings.UIScaling.Value)</x:Double>
<ScaleTransform x:Key="uiScaleTransform" ScaleX="{DynamicResource uiScale}" ScaleY="{DynamicResource uiScale}"/>
<x:Double x:Key="gradientStrength">$gradientStrength</x:Double>
<x:Double x:Key="shadowBlur">$shadowBlur</x:Double>
<x:Double x:Key="shadowDepth">$shadowDepth</x:Double>
<CornerRadius x:Key="cornerStrength">$cornerStrength</CornerRadius>
<CornerRadius x:Key="cornerStrength1">$cornerStrength,$cornerStrength,0,0</CornerRadius>
<CornerRadius x:Key="cornerStrength2">0,0,$cornerStrength,$cornerStrength</CornerRadius>

<FontFamily x:Key="OpenSansFontFamily">file:///"$resourcesPath\Fonts\OpenSans-Regular.ttf"#Open Sans</FontFamily>

<Style TargetType="Window">
    <Setter Property="FontFamily" Value="{StaticResource OpenSansFontFamily}"/>
</Style>

<Style x:Key="CustomBorder" TargetType="{x:Type Border}">
    <Setter Property="CornerRadius" Value="{DynamicResource cornerStrength}"/>
    <Setter Property="Background">
        <Setter.Value>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                <GradientStop Color="{DynamicResource surfaceGrad0}" Offset="0"/>
                <GradientStop Color="{DynamicResource surfaceGrad1}" Offset="{DynamicResource gradientStrength}"/>
            </LinearGradientBrush>
        </Setter.Value>
    </Setter>
    <Setter Property="Effect">
        <Setter.Value>
            <DropShadowEffect Color="Black" Opacity="0.2" BlurRadius="{DynamicResource shadowBlur}" ShadowDepth="{DynamicResource shadowDepth}"/>
        </Setter.Value>
    </Setter>
</Style>

<Style TargetType="CheckBox">
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type CheckBox}">
                <Grid Background="Transparent">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="Auto"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <ContentControl Name="Icon" Width="20" Height="20" Foreground="{DynamicResource surfaceText}" Style="{StaticResource VectorIconStyle}" Content="{StaticResource CheckboxOutlineIcon}"/>
                    <ContentPresenter Grid.Column="1" Margin="5,0,0,0" VerticalAlignment="Center"/>
                </Grid>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsChecked" Value="True">
                        <Setter TargetName="Icon" Property="Content" Value="{StaticResource CheckboxIcon}"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="CustomContextMenu" TargetType="{x:Type ContextMenu}">
    <Setter Property="LayoutTransform" Value="{StaticResource uiScaleTransform}"/>

    <Setter Property="SnapsToDevicePixels" Value="True"/>
    <Setter Property="OverridesDefaultStyle" Value="True"/>
    <Setter Property="Grid.IsSharedSizeScope" Value="True"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type ContextMenu}">
                <Border Name="Border" Background="{TemplateBinding Background}" CornerRadius="8" Padding="5">
                    <StackPanel IsItemsHost="True" KeyboardNavigation.DirectionalNavigation="Cycle"/>
                </Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="CustomContextMenuItem" TargetType="{x:Type MenuItem}">
    <Setter Property="Foreground" Value="{DynamicResource accentText}"/>
    <Setter Property="Background" Value="Transparent"/>
    <Setter Property="Padding" Value="8,6"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type MenuItem}">
                <Border Name="ItemBorder" Background="{TemplateBinding Background}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="22"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <ContentPresenter ContentSource="Icon" Width="16" Height="16" HorizontalAlignment="Left" VerticalAlignment="Center"/>
                        <ContentPresenter Grid.Column="1" ContentSource="Header" RecognizesAccessKey="True" VerticalAlignment="Center"/>
                    </Grid>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="ItemBorder" Property="Background" Value="{DynamicResource accentHighlight}"/>
                    </Trigger>
                    <Trigger Property="IsHighlighted" Value="True">
                        <Setter TargetName="ItemBorder" Property="Background" Value="{DynamicResource accentHighlight}"/>
                    </Trigger>
                    <Trigger Property="IsKeyboardFocusWithin" Value="True">
                        <Setter TargetName="ItemBorder" Property="Background" Value="{DynamicResource accentHighlight}"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="CustomContextMenuHeader" TargetType="{x:Type MenuItem}">
    <Setter Property="Foreground" Value="{DynamicResource accentText}"/>
    <Setter Property="Focusable" Value="False"/>
    <Setter Property="IsHitTestVisible" Value="False"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type MenuItem}">
                <Border Padding="8,5,8,5">
                    <ContentPresenter ContentSource="Header" VerticalAlignment="Center"/>
                </Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="CustomContextMenuSeparator" TargetType="{x:Type Separator}">
    <Setter Property="Background" Value="{DynamicResource surfaceText}"/>
    <Setter Property="Height" Value="1"/>
    <Setter Property="Margin" Value="8,3,8,4"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type Separator}">
                <Border Background="{TemplateBinding Background}" Height="{TemplateBinding Height}"/>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="CustomListBoxItem" TargetType="{x:Type ListBoxItem}">
    <Setter Property="Foreground" Value="White"/>
    <Setter Property="Margin" Value="0.5"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type ListBoxItem}">
                <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Margin="{TemplateBinding Margin}" CornerRadius="{DynamicResource cornerStrength}">
                    <ContentPresenter/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter Property="Background" Value="{DynamicResource surfaceHighlight}"/>
                        <Setter Property="BorderThickness" Value="1"/>
                        <Setter Property="BorderBrush" Value="{DynamicResource surfaceHighlight}"/>
                    </Trigger>
                    <Trigger Property="IsSelected" Value="True">
                        <Setter Property="Background" Value="{DynamicResource surfaceHighlight}"/>
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
                <Border BorderThickness="0" CornerRadius="5" Padding="5"> 
                    <Border.Background>
                        <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                            <GradientStop Color="{DynamicResource surfaceGrad0}" Offset="0"/>
                            <GradientStop Color="{DynamicResource surfaceGrad1}" Offset="{DynamicResource gradientStrength}"/>
                        </LinearGradientBrush>
                    </Border.Background>
                    <Border.Effect>
                        <DropShadowEffect Color="Black" Opacity="0.2" BlurRadius="{DynamicResource shadowBlur}" ShadowDepth="{DynamicResource shadowDepth}"/>
                    </Border.Effect>
                    <ScrollViewer Focusable="False">
                        <StackPanel IsItemsHost="True"/>
                    </ScrollViewer>
                </Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="CustomThumb" TargetType="{x:Type Thumb}">
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type Thumb}">
                <Border Background="{DynamicResource accentBrush}" CornerRadius="3" Margin="0,10,10,10"/>
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
                <Grid Name="GridRoot">
                    <Rectangle Width="5" Fill="{DynamicResource backgroundHighlight}" RadiusX="3" RadiusY="3" Margin="0,10,10,10"/>
                    <Track Name="PART_Track" IsDirectionReversed="True">
                        <Track.Thumb>
                            <Thumb Name="Thumb" Style="{StaticResource CustomThumb}"/>
                        </Track.Thumb>
                        <Track.IncreaseRepeatButton>
                            <RepeatButton Name="PageUp" Command="ScrollBar.PageDownCommand" Opacity="0" Focusable="False"/>
                        </Track.IncreaseRepeatButton>
                        <Track.DecreaseRepeatButton>
                        `<RepeatButton Name="PageDown" Command="ScrollBar.PageUpCommand" Opacity="0" Focusable="False"/>
                        </Track.DecreaseRepeatButton>
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
                    <ScrollBar Name="PART_VerticalScrollBar" Grid.Column="1" Orientation="Vertical" Style="{StaticResource CustomScrollBar}" Maximum="{TemplateBinding ScrollableHeight}" Value="{TemplateBinding VerticalOffset}" ViewportSize="{TemplateBinding ViewportHeight}"/>
                </Grid>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style TargetType="ListBoxItem">
    <Setter Property="Foreground" Value="White"/>
    <Setter Property="Margin" Value="0.5"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type ListBoxItem}">
                <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Margin="{TemplateBinding Margin}" CornerRadius="{DynamicResource cornerStrength}">
                    <ContentPresenter/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter Property="Background" Value="{DynamicResource surfaceHighlight}"/>
                        <Setter Property="BorderThickness" Value="1"/>
                        <Setter Property="BorderBrush" Value="{DynamicResource surfaceHighlight}"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style TargetType="ProgressBar">
    <Setter Property="Background" Value="{DynamicResource primaryBrush}"/>
    <Setter Property="Foreground" Value="{DynamicResource primaryBrush}"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type ProgressBar}">
                <Grid>
                    <Border x:Name="PART_Track" Background="{TemplateBinding Background}" Opacity="0.36" CornerRadius="10"/>
                    <Border x:Name="PART_Indicator" Background="{TemplateBinding Foreground}" HorizontalAlignment="Left" BorderThickness="0" CornerRadius="10"/>
                </Grid>
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
                            <Ellipse Name="RadioOuter" Fill="Transparent" Stroke="{DynamicResource accentBrush}" StrokeThickness="2"/>
                            <Ellipse Name="RadioInner" Fill="{DynamicResource accentBrush}" Visibility="Hidden" Margin="4"/>
                        </Grid>
                    </BulletDecorator.Bullet>
                    <TextBlock Name="TextBlock" Margin="5,0,0,0" Foreground="{DynamicResource surfaceText}" FontSize="12">

                        <ContentPresenter/>
                    </TextBlock>
                </BulletDecorator>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsChecked" Value="true">
                        <Setter TargetName="RadioOuter" Property="Opacity" Value="1.0"/>
                        <Setter TargetName="RadioInner" Property="Visibility" Value="Visible"/>
                        <Setter TargetName="TextBlock" Property="Opacity" Value="1.0"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="RoundedButton" TargetType="{x:Type Button}">
    <Setter Property="HorizontalContentAlignment" Value="Center"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type Button}">
                <Border Name="Border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="{DynamicResource cornerStrength}" Padding="2.5">
                    <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="Border" Property="Background" Value="{DynamicResource surfaceHighlight}"/>
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
                <Border Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="5,5,0,0">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="border" Property="Background" Value="{DynamicResource surfaceHighlight}"/>
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
                <Border Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="0" CornerRadius="0,0,5,5">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="border" Property="Background" Value="{DynamicResource surfaceHighlight}"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style x:Key="RoundHoverButtonStyle" TargetType="{x:Type Button}">
    <Setter Property="Background" Value="{DynamicResource primaryHighlight}"/>
    <Setter Property="BorderBrush" Value="Transparent"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type Button}">
                <Grid>
                    <Ellipse Name="Circle" Fill="Transparent" Width="{TemplateBinding Width}" Height="{TemplateBinding Height}"/>
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="2.5"/>
                </Grid>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="Circle" Property="Fill" Value="{Binding Background, RelativeSource={RelativeSource TemplatedParent}}"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style TargetType="Slider">
    <Setter Property="MinHeight" Value="25"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="Slider">
                <Grid Background="Transparent" MinHeight="25">
                    <Track x:Name="PART_Track" Height="17" VerticalAlignment="Center">
                        <Track.DecreaseRepeatButton>
                            <RepeatButton Command="Slider.DecreaseLarge" Background="{DynamicResource primaryBrush}" Margin="0,0,-8.5,0">
                                <RepeatButton.Template>
                                    <ControlTemplate TargetType="RepeatButton">
                                        <Border Background="{TemplateBinding Background}" Height="8" CornerRadius="4" VerticalAlignment="Center"/>
                                    </ControlTemplate>
                                </RepeatButton.Template>
                            </RepeatButton>
                        </Track.DecreaseRepeatButton>
                        <Track.IncreaseRepeatButton>
                            <RepeatButton Command="Slider.IncreaseLarge" Background="{DynamicResource backgroundBrush}" Margin="-8.5,0,0,0">
                                <RepeatButton.Template>
                                    <ControlTemplate TargetType="RepeatButton">
                                        <Border Background="{TemplateBinding Background}" Height="8" CornerRadius="4" VerticalAlignment="Center"/>
                                    </ControlTemplate>
                                </RepeatButton.Template>
                            </RepeatButton>
                        </Track.IncreaseRepeatButton>
                        <Track.Thumb>
                            <Thumb Width="17" Height="17">
                                <Thumb.Template>
                                    <ControlTemplate TargetType="Thumb">
                                        <Ellipse Fill="{DynamicResource primaryBrush}"/>
                                    </ControlTemplate>
                                </Thumb.Template>
                            </Thumb>
                        </Track.Thumb>
                    </Track>
                </Grid>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>
<Style TargetType="TextBox">
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="TextBox">
                <Border Background="{TemplateBinding Background}" CornerRadius="{DynamicResource cornerStrength}">
                    <ScrollViewer Margin="0" Name="PART_ContentHost"/>
                </Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style TargetType="ToggleButton">
    <Setter Property="Width" Value="40"/>
    <Setter Property="Height" Value="20"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type ToggleButton}">
                <Border Name="Border" Background="{DynamicResource surfaceHighlight}" CornerRadius="10">
                    <Ellipse Name="Ellipse" Width="15" Height="15" Fill="{DynamicResource primaryText}" HorizontalAlignment="Left" Margin="2.5"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsChecked" Value="True">
                        <Setter TargetName="Border" Property="Background" Value="{DynamicResource primaryBrush}"/>
                        <Setter TargetName="Ellipse" Property="HorizontalAlignment" Value="Right"/>
                    </Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>

<Style TargetType="ToolTip">
    <Setter Property="LayoutTransform" Value="{StaticResource uiScaleTransform}"/>

    <Setter Property="Background" Value="{DynamicResource accentBrush}"/>
    <Setter Property="Foreground" Value="{DynamicResource accentText}"/>
    <Setter Property="Template">
        <Setter.Value>
            <ControlTemplate TargetType="{x:Type ToolTip}">
                <Border Background="{TemplateBinding Background}" CornerRadius="{DynamicResource cornerStrength}" Padding="5">
                    <ContentPresenter Content="{TemplateBinding Content}"/>
                </Border>
            </ControlTemplate>
        </Setter.Value>
    </Setter>
</Style>
</ResourceDictionary>
"@

Export-ModuleMember -Function *
Export-ModuleMember -Variable *