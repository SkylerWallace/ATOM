Add-Type -AssemblyName PresentationFramework

# Import module(s)
Import-Module "$psScriptRoot\..\..\Functions\AtomModule.psm1" -Function Get-ShadowCopies -Variable *
Import-Module "$psScriptRoot\..\..\Functions\AtomWpfModule.psm1"

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="RegRestore"
    Background="Transparent"
    AllowsTransparency="True"
    WindowStyle="None"
    Width="600" SizeToContent="Height"
    UseLayoutRounding="True"
    RenderOptions.BitmapScalingMode="HighQuality">
    
    <Window.Resources>
        $resourceDictionary
    </Window.Resources>
    
    <WindowChrome.WindowChrome>
        <WindowChrome ResizeBorderThickness="0" CaptionHeight="0" CornerRadius="{DynamicResource cornerStrength}"/>
    </WindowChrome.WindowChrome>

    <Border BorderBrush="Transparent" BorderThickness="0" Background="{DynamicResource backgroundBrush}" CornerRadius="5">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="60"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Grid Grid.Row="0">
                <Border Background="{DynamicResource primaryBrush}" CornerRadius="5,5,0,0"/>
                <Image Width="40" Height="40" Source="$resourcesPath\Icons\Plugins\RegRestore.png" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="15,0,0,0"/>
                <TextBlock Text="RegRestore" FontSize="20" FontWeight="Bold" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="60,0,0,0"/>
                <Button Name="minimizeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,45,0" ToolTip="Minimize"/>
                <Button Name="closeButton" Width="20" Height="20" Style="{StaticResource RoundHoverButtonStyle}" HorizontalAlignment="Right" Margin="0,0,10,0" ToolTip="Close"/>
            </Grid>

            <Grid Grid.Row="1" Margin="5,5,5,0">
                <StackPanel>
                    <TextBlock Text="Select a restore point:" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="5"/>
                    <Border Style="{StaticResource CustomBorder}" Height="120" Margin="5">
                        <ScrollViewer Name="scrollViewer1" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                            <DataGrid Name="dataGrid" Background="Transparent" Foreground="{DynamicResource surfaceText}" Width="Auto" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" HorizontalScrollBarVisibility="Hidden" AutoGenerateColumns="False" SelectionMode="Single" SelectionUnit="FullRow" CanUserAddRows="False" GridLinesVisibility="None" HeadersVisibility="None" ClipToBounds="False" BorderThickness="0" Margin="5">

                                <DataGrid.RowStyle>
                                    <Style TargetType="DataGridRow">
                                        <Setter Property="BorderThickness" Value="0"/>
                                        <Setter Property="BorderBrush" Value="Transparent"/>
                                        <Setter Property="Background" Value="Transparent"/>
                                        <Setter Property="Margin" Value="5"/>
                                        <Setter Property="IsSelected" Value="False"/>
                                        <Setter Property="Selector.IsSelected" Value="False"/>
                                        <Setter Property="Template">
                                            <Setter.Value>
                                                <ControlTemplate TargetType="{x:Type DataGridRow}">
                                                    <Border Name="DGR_Border" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}" SnapsToDevicePixels="True" CornerRadius="5">
                                                        <SelectiveScrollingGrid>
                                                            <SelectiveScrollingGrid.ColumnDefinitions>
                                                                <ColumnDefinition Width="Auto"/>
                                                                <ColumnDefinition Width="*"/>
                                                            </SelectiveScrollingGrid.ColumnDefinitions>
                                                            <SelectiveScrollingGrid.RowDefinitions>
                                                                <RowDefinition Height="*"/>
                                                                <RowDefinition Height="Auto"/>
                                                            </SelectiveScrollingGrid.RowDefinitions>
                                                            <DataGridCellsPresenter Grid.Column="1" ItemsPanel="{TemplateBinding ItemsPanel}" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}"/>
                                                            <DataGridDetailsPresenter Grid.Column="1" Grid.Row="1" SelectiveScrollingGrid.SelectiveScrollingOrientation="{Binding AreRowDetailsFrozen, ConverterParameter={x:Static SelectiveScrollingOrientation.Vertical}, Converter={x:Static DataGrid.RowDetailsScrollingConverter}, RelativeSource={RelativeSource AncestorType={x:Type DataGrid}}}" Visibility="{TemplateBinding DetailsVisibility}"/>
                                                            <DataGridRowHeader Grid.RowSpan="2" SelectiveScrollingGrid.SelectiveScrollingOrientation="Vertical" Visibility="{Binding HeadersVisibility, ConverterParameter={x:Static DataGridHeadersVisibility.Row}, Converter={x:Static DataGrid.HeadersVisibilityConverter}, RelativeSource={RelativeSource AncestorType={x:Type DataGrid}}}"/>
                                                        </SelectiveScrollingGrid>
                                                    </Border>
                                                </ControlTemplate>
                                            </Setter.Value>
                                        </Setter>
                                        <Style.Triggers>
                                            <Trigger Property="IsMouseOver" Value="True">
                                                <Setter Property="Background" Value="{DynamicResource surfaceBrush}"/>
                                            </Trigger>
                                            <Trigger Property="IsSelected" Value="True">
                                                <Setter Property="Background" Value="{DynamicResource surfaceHighlight}"/>
                                            </Trigger>
                                        </Style.Triggers>
                                    </Style>
                                </DataGrid.RowStyle>
                                
                                <DataGrid.CellStyle>
                                    <Style TargetType="DataGridCell">
                                        <Setter Property="Padding" Value="5"/>
                                        <Setter Property="Foreground" Value="{DynamicResource surfaceText}"/>
                                        <Setter Property="Template">
                                            <Setter.Value>
                                                <ControlTemplate TargetType="{x:Type DataGridCell}">
                                                    <Border Padding="{TemplateBinding Padding}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}" SnapsToDevicePixels="True">
                                                        <ContentPresenter SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}"/>
                                                    </Border>
                                                </ControlTemplate>
                                            </Setter.Value>
                                        </Setter>
                                        <Style.Triggers>
                                            <Trigger Property="IsSelected" Value="True">
                                                <Setter Property="Background" Value="Transparent"/>
                                                <Setter Property="BorderBrush" Value="Transparent"/>
                                            </Trigger>
                                        </Style.Triggers>
                                    </Style>
                                </DataGrid.CellStyle>
                                
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="Drive" Binding="{Binding Drive}" Width="40" IsReadOnly="True">
                                        <DataGridTextColumn.ElementStyle>
                                            <Style TargetType="TextBlock">
                                                <Setter Property="HorizontalAlignment" Value="Left"/>
                                                <Setter Property="VerticalAlignment" Value="Center"/>
                                                <Setter Property="TextWrapping" Value="Wrap"/>
                                            </Style>
                                        </DataGridTextColumn.ElementStyle>
                                        <DataGridTextColumn.EditingElementStyle>
                                            <Style TargetType="TextBox">
                                                <Setter Property="Foreground" Value="{DynamicResource surfaceText}"/>
                                                <Setter Property="Background" Value="{DynamicResource surfaceBrush}"/>
                                                <Setter Property="BorderThickness" Value="0"/>
                                            </Style>
                                        </DataGridTextColumn.EditingElementStyle>
                                    </DataGridTextColumn>
                                    
                                    <DataGridTextColumn Header="Date" Binding="{Binding Date}" Width="160" IsReadOnly="True">
                                        <DataGridTextColumn.ElementStyle>
                                            <Style TargetType="TextBlock">
                                                <Setter Property="HorizontalAlignment" Value="Left"/>
                                                <Setter Property="VerticalAlignment" Value="Center"/>
                                                <Setter Property="TextWrapping" Value="Wrap"/>
                                            </Style>
                                        </DataGridTextColumn.ElementStyle>
                                    </DataGridTextColumn>

                                    <DataGridTextColumn Header="Path" Binding="{Binding Path}" Width="*" IsReadOnly="True">
                                        <DataGridTextColumn.ElementStyle>
                                            <Style TargetType="TextBlock">
                                                <Setter Property="HorizontalAlignment" Value="Left"/>
                                                <Setter Property="VerticalAlignment" Value="Center"/>
                                                <Setter Property="TextWrapping" Value="Wrap"/>
                                            </Style>
                                        </DataGridTextColumn.ElementStyle>
                                        <DataGridTextColumn.EditingElementStyle>
                                            <Style TargetType="TextBox">
                                                <Setter Property="Foreground" Value="{DynamicResource surfaceText}"/>
                                                <Setter Property="Background" Value="{DynamicResource surfaceBrush}"/>
                                                <Setter Property="BorderThickness" Value="0"/>
                                            </Style>
                                        </DataGridTextColumn.EditingElementStyle>
                                    </DataGridTextColumn>
                                </DataGrid.Columns>
                            </DataGrid>
                        </ScrollViewer>
                    </Border>
                </StackPanel>
            </Grid>

            <Grid Grid.Row="2" Margin="5">
                <StackPanel>
                    <TextBlock Text="Results:" VerticalAlignment="Center" HorizontalAlignment="Left" Foreground="{DynamicResource primaryText}" Margin="5"/>
                    <Border Style="{StaticResource CustomBorder}" Height="120" Margin="5">
                        <ScrollViewer Name="scrollViewer2" VerticalScrollBarVisibility="Auto" Style="{StaticResource CustomScrollViewerStyle}">
                            <TextBlock Name="outputBox" Foreground="{DynamicResource surfaceText}" HorizontalAlignment="Stretch" TextWrapping="Wrap" VerticalAlignment="Stretch" Padding="10"/>
                        </ScrollViewer>
                    </Border>
                </StackPanel>
            </Grid>

            <Grid Grid.Row="3" Margin="5,0,5,5">
                <Button Name="runButton" Content="Rollback" Background="{DynamicResource accentBrush}" Foreground="{DynamicResource accentText}" Margin="5" Style="{StaticResource RoundedButton}"/>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# Load XAML
$window = [Windows.Markup.XamlReader]::Parse($xaml)

# Assign variables to elements in XAML
$minimizeButton = $window.FindName('minimizeButton')
$closeButton    = $window.FindName('closeButton')
$dataGrid       = $window.FindName('dataGrid')
$outputBox      = $window.FindName('outputBox')
$runButton      = $window.FindName('runButton')

# Set icon sources
$primaryResources = @{
    "minimizeButton"    = "Minimize"
    "closeButton"       = "Close"
}

Set-ResourcePath -ColorRole Primary -ResourceMappings $primaryResources

# Set variale gridContents as the 
$gridContents = New-Object 'System.Collections.ObjectModel.ObservableCollection[System.Object]'
$dataGrid.ItemsSource = $gridContents

$shadows = Get-ShadowCopies

$shadows | ForEach-Object {
    $shadow = $_.Path
    $hives = 'DEFAULT', 'SAM', 'SECURITY', 'SOFTWARE', 'SYSTEM'
    
    # Add shadow copy to datagrid if all relevant registry hives are detected
    if (($hives | ForEach-Object { Test-Path $shadow\Windows\System32\config\$_ }) -notcontains $false) {
        $gridContents.Add($_)
    }
}

function Backup-Hives {
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('[A-Za-z]:\\')]
        [string]$driveLetter
    )

    $hives = 'DEFAULT', 'SAM', 'SECURITY', 'SOFTWARE', 'SYSTEM'

    $backupHives = @()

    $hives | ForEach-Object {
        $hiveDir = "$driveLetter\Windows\System32\config"
        $hive = "$hiveDir\$_"

        if (Test-Path $hive) {
            # Backup name of the file will append the date modified of the file
            $dateModified = Get-Item $hive | Select-Object LastWriteTime | Get-Date -Format yyyy-MM-dd_HHmmss
            $backupHive = $hive + ".$dateModified"

            # Increment new name if file name w/ new name is already detected
            $backupHiveVariable = $backupHive
            for ($i = 1; (Test-Path ($backupHive)); $i++) {
                $backupHive = $backupHiveVariable + "_$i"
            }

            # Backup file
            Copy-Item $hive -Destination $backupHive -Force

            # Test if backup was successful
            if (Test-Path $backupHive) {
                $backupHives += $backupHive
            } else {
                $failedBackup = $true
            }
        }
    }

    # Return true/false depending on if backup failed
    if ($failedBackup) {
        $backupHives | ForEach-Object {
            Remove-Item $_ -Force
        }

        return $false
    } else {
        return $true
    }
}

$runButton.Add_Click({
    # Get info from selected shadow copy
    $drive = $dataGrid.SelectedItems | Select-Object -Expand Drive
    $path = $dataGrid.SelectedItems | Select-Object -Expand Path

    # Backup hives
    if (Backup-Hives -DriveLetter $drive) {
        $outputBox.Text += "Hives backed up successfully.`n"
    } else {
        $outputBox.Text += "Failed to backup hives.`n"
        return
    }

    $hives = 'DEFAULT', 'SAM', 'SECURITY', 'SOFTWARE', 'SYSTEM'

    # Restore hives from selected shadow copy
    $hives | ForEach-Object {
        $shadowHive = $path + "Windows\System32\config\$_"
        $destination = $drive + 'Windows\System32\config'
        
        Remove-Item $destination\$_
        Copy-Item $shadowHive -Destination $destination -Force
    }

    # Run bcdboot to restore boot files
    $bcdbootProcess = Start-Process bcdboot -ArgumentList 'C:\Windows' -Wait -PassThru -NoNewWindow

    if ($bcdbootProcess.ExitCode -eq 0) {
        $outputBox.Text += "Boot files restored.`n`n"
    } else {
        $outputBox.Text += "Failed to restore boot files.`n`n"
    }
})


# Make scrollviewer work with scrollwheel
1..2 | ForEach-Object {
    $window.FindName("scrollViewer$_").AddHandler([System.Windows.UIElement]::MouseWheelEvent, [System.Windows.Input.MouseWheelEventHandler]{
        param($sender, $e)
        $sender.ScrollToVerticalOffset($sender.VerticalOffset - $e.Delta)
    }, $true)
}

# UI event handlers
$minimizeButton.Add_Click({ $window.WindowState = 'Minimized' })
$closeButton.Add_Click({ $window.Close() })
$window.Add_MouseLeftButtonDown({ $this.DragMove() })

$window.ShowDialog() | Out-Null

<#
New-Item -ItemType SymbolicLink -Path 'C:\Shadows' -Target ''
(Get-Item 'C:\Shadows').Delete()
#>