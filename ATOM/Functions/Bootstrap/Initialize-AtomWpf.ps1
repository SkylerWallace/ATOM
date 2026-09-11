# Import default settings & themes
. "$configPath\Settings.ps1"

# Load user settings
if (Test-Path "$configPath\SettingsUser.ps1") {
    . "$configPath\SettingsUser.ps1"
    # Legacy names are read only for migration; new saves use ThemeGraphic.
    if (!$userAtomSettings.Contains('ThemeGraphic')) {
        if ($userAtomSettings.Contains('ThemeMotif')) {
            $atomSettings.ThemeGraphic.Value = $userAtomSettings.ThemeMotif.Value
        } elseif ($userAtomSettings.Contains('ShowThemeMotifs')) {
            $atomSettings.ThemeGraphic.Value = if ($userAtomSettings.ShowThemeMotifs.Value) { 'Automatic' } else { 'Disabled' }
        }
    }
    foreach ($key in $userAtomSettings.GetEnumerator()) {
        if ($atomSettings.Contains($key.Key)) {
            $atomSettings[$key.Key].Value = $key.Value.Value
        }
    }
    if ($userAtomSettings.Contains('TextScaling') -and !$userAtomSettings.Contains('UIScaling')) {
        $atomSettings.UIScaling.Value = [Double]$userAtomSettings.TextScaling.Value
    }
}

$updateChannelSetting = $atomSettings['UpdateChannel']
if ($updateChannelSetting -isnot [Collections.IDictionary] -or !$updateChannelSetting.Contains('Value')) {
    $legacyUpdateChannel = [String]$updateChannelSetting
    $atomSettings['UpdateChannel'] = [ordered]@{
        Value = if ($legacyUpdateChannel -in 'main', 'dev') { $legacyUpdateChannel } else { 'main' }
        RestoreDefault = $false
    }
} elseif ($updateChannelSetting['Value'] -notin 'main', 'dev') {
    $updateChannelSetting['Value'] = 'main'
}

# Frozen bitmap sources can be populated by background STA workers and safely
# reused by UI-thread callers such as context menus.
$ImageCache = [Hashtable]::Synchronized(@{})

# Import themes
. "$configPath\Themes.ps1"

# Create variables for each value in selected theme's hashtable
$selectedTheme = $themes[$atomSettings.Theme.Value]
if (!$selectedTheme) {
    $atomSettings.Theme.Value = 'Atomic'
    $selectedTheme = $themes.Atomic
}
$selectedTheme.GetEnumerator() | ForEach-Object {
    Set-Variable -Name $_.Name -Value $_.Value -Scope Global -Force
}
$controlBrush = if ($selectedTheme.Contains('controlBrush')) { $selectedTheme.controlBrush } else { $selectedTheme.primaryBrush }
Set-Variable -Name controlBrush -Value $controlBrush -Scope Global -Force
$controlText = if ($selectedTheme.Contains('controlText')) { $selectedTheme.controlText } else { $selectedTheme.primaryText }
Set-Variable -Name controlText -Value $controlText -Scope Global -Force

Get-AtomThemeShadowResources -Theme $themes[$atomSettings.Theme.Value] -Defaults $themeShadowDefaults | ForEach-Object {
    $_.GetEnumerator() | ForEach-Object {
        New-Variable -Name $_.Key -Value $_.Value -Scope Local -Force
    }
}

$atomControlStyles = [IO.File]::ReadAllText((Join-Path $resourcesPath 'Styles/Controls.xaml'))

# Declare resource dictionary
$iconDictionaryUri = [System.Uri]::new((Resolve-Path "$resourcesPath\Icons\Common.xaml").Path).AbsoluteUri
$windowFontResources = if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') {
    # WinPE's reduced font stack can fail-fast while WPF measures a TextBox
    # backed by an external font file. Use WPF's built-in default, as ATOM v2.12 did.
    ''
} else {
@"
<FontFamily x:Key="OpenSansFontFamily">file:///"$resourcesPath\Fonts\OpenSans-Regular.ttf"#Open Sans</FontFamily>

<Style TargetType="Window">
    <Setter Property="FontFamily" Value="{StaticResource OpenSansFontFamily}"/>
</Style>
"@
}

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
<SolidColorBrush x:Key="controlBrush" Color="$controlBrush"/>
<SolidColorBrush x:Key="controlText" Color="$controlText"/>

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
<Color x:Key="shadowColor">$shadowColor</Color>
<x:Double x:Key="shadowOpacity">$shadowOpacity</x:Double>
<x:Double x:Key="shadowDirection">$shadowDirection</x:Double>
<x:Double x:Key="shadowBlur">$shadowBlur</x:Double>
<x:Double x:Key="shadowDepth">$shadowDepth</x:Double>
<CornerRadius x:Key="cornerStrength">$cornerStrength</CornerRadius>
<CornerRadius x:Key="cornerStrength1">$cornerStrength,$cornerStrength,0,0</CornerRadius>
<CornerRadius x:Key="cornerStrength2">0,0,$cornerStrength,$cornerStrength</CornerRadius>
<RadialGradientBrush x:Key="surfacePanelBrush" Center="0.16,0.10" GradientOrigin="0.02,0.02" RadiusX="{DynamicResource gradientStrength}" RadiusY="1.1" ColorInterpolationMode="ScRgbLinearInterpolation">
    <GradientStop Color="{DynamicResource surfaceGrad0}" Offset="0"/>
    <GradientStop Color="{DynamicResource surfaceColor}" Offset="0.55"/>
    <GradientStop Color="{DynamicResource surfaceGrad1}" Offset="1"/>
</RadialGradientBrush>

<RadialGradientBrush x:Key="surfaceListBrush" Center="0.5,0" GradientOrigin="0.5,-0.2" RadiusX="0.9" RadiusY="{DynamicResource gradientStrength}" ColorInterpolationMode="ScRgbLinearInterpolation">
    <GradientStop Color="{DynamicResource surfaceGrad0}" Offset="0"/>
    <GradientStop Color="{DynamicResource surfaceColor}" Offset="0.5"/>
    <GradientStop Color="{DynamicResource surfaceGrad1}" Offset="1"/>
</RadialGradientBrush>

$windowFontResources

$atomControlStyles
</ResourceDictionary>
"@

