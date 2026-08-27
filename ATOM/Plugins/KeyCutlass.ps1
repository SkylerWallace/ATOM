Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Import module(s)
Import-Module "$psScriptRoot\..\Functions\AtomModule.psm1" -Variable *
Import-Module "$psScriptRoot\..\Functions\AtomWpfModule.psm1"

$contentXaml = @"
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="0"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
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
"@

$windowParameters = @{
    Title         = 'KeyCutlass'
    IconPath      = "$resourcesPath\Icons\Program Icons\KeyCutlass.png"
    ContentXaml   = $contentXaml
    MinWidth      = 200
    MinHeight     = 0
    SizeToContent = 'WidthAndHeight'
}
$window = New-AtomWindow @windowParameters

# Assign variables to elements in XAML
$keysPanel        = $window.FindName('keysPanel')
$visibilityButton = $window.FindName('visibilityButton')

# Set icon sources
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
    $button.Content = New-VectorIcon -Window $window -Icon LinkIcon
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

$window.ShowDialog() | Out-Null
