<#
.SYNOPSIS
    Runs a portable ClamAV scan with optional quarantine.
.PARAMETER Interactive
    Opens the scan window used by the Plugins page.
.PARAMETER ScanType
    Quick scans the Windows folder. Deep scans its volume. In PE, both use
    the Windows installation selected by MountOS.
.PARAMETER Quarantine
    Moves detected files to ATOM's quarantine directory instead of deleting them.
.PARAMETER SkipUpdate
    Uses existing definitions without contacting the signature servers.
.PARAMETER LogDirectory
    Destination for reports. When omitted, creates a manual scan log directory.
.PARAMETER ScanState
    Shared workflow state used to stop the updater or scanner.
.EXAMPLE
    & '.\ClamAV.ps1' -ScanType Deep -SkipUpdate
#>
[CmdletBinding()]
param(
    [switch]$Interactive,
    [ValidateSet('Quick', 'Deep')][string]$ScanType = 'Quick',
    [switch]$SkipUpdate,
    [switch]$Quarantine,
    [string]$LogDirectory,
    [hashtable]$ScanState
)

. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function Start-Program, Invoke-AtomAntivirusScan, Get-AtomWorkflowLogRoot -Feature Catalog

function Show-ClamAVWindow {
    param([string]$PluginPath, [string]$ScanType, [switch]$SkipUpdate, [switch]$Quarantine)

    $content = @'
<Grid Margin="10">
 <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
 <Border Style="{StaticResource CustomBorder}" Padding="5" Margin="0,0,0,10">
  <StackPanel>
   <TextBlock Text="Scan options" FontSize="18" FontWeight="SemiBold" Foreground="{DynamicResource surfaceText}" Margin="0,0,0,10"/>
   <StackPanel Name="Options" Margin="0,0,0,5"/>
  </StackPanel>
 </Border>
 <Border Grid.Row="1" Style="{StaticResource CustomOutputBorder}" Margin="0,0,0,5">
  <ScrollViewer Name="OutputScroll" Style="{StaticResource CustomScrollViewerStyle}" VerticalScrollBarVisibility="Visible" HorizontalScrollBarVisibility="Disabled">
   <TextBlock Name="Output" Padding="10" TextWrapping="Wrap" Foreground="{DynamicResource surfaceText}" Text="Ready to scan."/>
  </ScrollViewer>
 </Border>
 <WrapPanel Grid.Row="2" HorizontalAlignment="Center">
  <Button Name="Start" Content="Start scan" Width="120" Height="30" Margin="5,5,5,0" Style="{StaticResource RoundedButton}" Background="{DynamicResource controlBrush}" Foreground="{DynamicResource controlText}"/>
  <Button Name="Stop" Content="Stop scan" Width="120" Height="30" Margin="5,5,5,0" IsEnabled="False" Style="{StaticResource RoundedButton}" Background="{DynamicResource surfaceBrush}" Foreground="{DynamicResource surfaceText}"/>
  <Button Name="Reports" Content="Open reports" Width="120" Height="30" Margin="5,5,5,0" IsEnabled="False" Style="{StaticResource RoundedButton}" Background="{DynamicResource surfaceBrush}" Foreground="{DynamicResource surfaceText}"/>
 </WrapPanel>
</Grid>
'@
    $window = New-AtomWindow -Title 'ClamAV' -IconPath (Join-Path (Split-Path $PluginPath) '../Resources/Icons/Program Icons/ClamAV.png') -ContentXaml $content -Width 560 -Height 560 -MinWidth 450 -MinHeight 400
    $options = $window.FindName('Options')
    $quickItem = New-ListBoxControlItem -ControlType RadioButton -Text 'Quick - Windows folder'
    $deepItem = New-ListBoxControlItem -ControlType RadioButton -Text 'Deep - entire Windows drive'
    $updateItem = New-ListBoxControlItem -ControlType CheckBox -Text 'Update definitions before scanning'
    $quarantineItem = New-ListBoxControlItem -ControlType CheckBox -Text 'Quarantine detected files'
    $quarantineControl = $quarantineItem.Control
    $quarantineControl.IsChecked = [bool]$Quarantine
    foreach ($item in @($quickItem, $deepItem, $updateItem, $quarantineItem)) {
        $item.MinHeight = 30
        $item.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
        [void]$options.Children.Add($item)
    }
    $quick = $quickItem.Control; $deep = $deepItem.Control; $update = $updateItem.Control
    $quick.GroupName = 'ClamAVScanType'; $deep.GroupName = 'ClamAVScanType'
    $start = $window.FindName('Start'); $stop = $window.FindName('Stop'); $reports = $window.FindName('Reports')
    $output = $window.FindName('Output')
    $quick.IsChecked = $ScanType -ne 'Deep'; $deep.IsChecked = $ScanType -eq 'Deep'; $update.IsChecked = !$SkipUpdate
    $state = @{ Worker=$null; Handle=$null; Shared=$null; LogDirectory=$null; Closing=$false }
    $timer = [Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $start.Add_Click({
        try {
            $state.LogDirectory = Join-Path (Get-AtomWorkflowLogRoot) ('ClamAV-' + [Guid]::NewGuid().ToString('N'))
            [void][IO.Directory]::CreateDirectory($state.LogDirectory)
            $state.Shared = [hashtable]::Synchronized(@{ StopRequested=$false; CanStopScan=$false; StatusText='Preparing scan...' })
            $state.Worker = [PowerShell]::Create()
            [void]$state.Worker.AddScript('param($plugin, $type, $skip, $logs, $shared, $quarantine) & $plugin -ScanType $type -SkipUpdate:$skip -LogDirectory $logs -ScanState $shared -Quarantine:$quarantine')
            [void]$state.Worker.AddArgument($PluginPath).AddArgument($(if ($deep.IsChecked) { 'Deep' } else { 'Quick' })).AddArgument(!$update.IsChecked).AddArgument($state.LogDirectory).AddArgument($state.Shared).AddArgument([bool]$quarantineControl.IsChecked)
            $state.Handle = $state.Worker.BeginInvoke()
            $start.IsEnabled=$false; $options.IsEnabled=$false
            $stop.IsEnabled=$true; $reports.IsEnabled=$true
            $output.Text="Preparing scan...`nReports: $($state.LogDirectory)"
            $timer.Start()
        } catch {
            $output.Text=$_.Exception.Message
            if ($state.Worker) { $state.Worker.Dispose(); $state.Worker=$null }
        }
    })
    $stop.Add_Click({ $state.Shared.StopRequested=$true; $stop.IsEnabled=$false; $output.Text='Stopping scan (waiting for any download to finish)...' })
    $reports.Add_Click({ Start-Process -FilePath 'explorer.exe' -ArgumentList ('"{0}"' -f $state.LogDirectory) })
    $timer.Add_Tick({
        if (!$state.Handle.IsCompleted) {
            if (!$state.Shared.StopRequested) {
                $text = "$($state.Shared.StatusText)`nReports: $($state.LogDirectory)"
                foreach ($name in 'update-output.txt','update-errors.txt','scan.log','scan-errors.txt') {
                    $path = Join-Path $state.LogDirectory $name
                    if (Test-Path -LiteralPath $path) {
                        $tail = Get-Content -LiteralPath $path -Tail 12 -ErrorAction SilentlyContinue
                        if ($tail) { $text += "`n`n" + ($tail -join "`n") }
                    }
                }
                $output.Text=$text
            }
            return
        }
        $timer.Stop()
        try {
            $results = @($state.Worker.EndInvoke($state.Handle))
            $result = $results | Where-Object { $_.Status -and $_.Summary } | Select-Object -Last 1
            if (!$result) { throw ($state.Worker.Streams.Error | Out-String) }
            $output.Text = "$($result.Status): $($result.Summary)`n`nReports: $($state.LogDirectory)"
        } catch { $output.Text=$_.Exception.Message }
        finally {
            $state.Worker.Dispose(); $state.Worker=$null; $state.Handle=$null
            $stop.IsEnabled=$false; $start.IsEnabled=$true
            $options.IsEnabled=$true
            $reports.IsEnabled=Test-Path -LiteralPath $state.LogDirectory
        }
        if ($state.Closing) { $window.Close() }
    })
    $window.Add_Closing({
        param($sender,$eventArgs)
        if ($state.Worker) {
            $eventArgs.Cancel=$true; $state.Closing=$true; $state.Shared.StopRequested=$true
            $stop.IsEnabled=$false; $output.Text='Stopping scan before closing...'
        }
    })
    try { $window.ShowDialog() | Out-Null }
    finally { $timer.Stop() }
}

if ($Interactive) {
    . "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function New-AtomWindow, New-ListBoxControlItem -Feature Wpf
    $guiQuarantine = if ($PSBoundParameters.ContainsKey('Quarantine')) { [bool]$Quarantine } else { $true }
    Show-ClamAVWindow -PluginPath $PSCommandPath -ScanType $ScanType -SkipUpdate:$SkipUpdate -Quarantine:$guiQuarantine
    return
}

if (!$LogDirectory) {
    $LogDirectory = Join-Path (Get-AtomWorkflowLogRoot) ('ClamAV-' + [Guid]::NewGuid().ToString('N'))
}
$program = $programs.ClamAV.ProgramInfo.Clone()
$executable = Get-Item -Path (Join-Path $program.DestinationPath $program.RelativePath) -ErrorAction SilentlyContinue |
    Sort-Object { [version]$_.VersionInfo.FileVersion } -Descending | Select-Object -First 1 -ExpandProperty FullName
if (!$executable -and !($ScanState -and $ScanState.StopRequested)) {
    if ($ScanState) { $ScanState.StatusText = 'Downloading ClamAV...' }
    $program.DownloadOnly = $true
    $executable = (Start-Program @program -ErrorAction Stop).FullName
}

Invoke-AtomAntivirusScan -Scanner ClamAV -ScanType $ScanType -Executable $executable -LogDirectory $LogDirectory -ScanState $ScanState -SkipUpdate:$SkipUpdate -Quarantine:$Quarantine
