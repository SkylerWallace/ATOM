<#
.SYNOPSIS
Cleans selected temporary files, Windows cleanup categories, and the Recycle Bin.

.DESCRIPTION
Runs selected categories in the console with progress reporting by default.
Interactive opens a category selection window and scans reclaimable space in the background.
TemporaryFiles applies an age threshold. InternetCache has no age threshold.
RecycleBin empties the current account's Recycle Bin without an age threshold.
Servicing and additional cache categories use Windows' Disk Cleanup COM handlers, called directly
from this script. Does not launch cleanmgr.exe or change saved cleanup selections.
Windows determines which servicing packages and cache files are eligible for removal.

In Windows PE, MountOS must first mount the target Windows installation. Cleanup
uses its Windows temp folder and registered user profiles. Only TemporaryFiles and
InternetCache are supported in PE. Folder cleanup preserves linked directories
and ATOM working folders. Native handlers require an elevated, native-bitness
PowerShell process in running Windows and operate on the Windows volume.

.PARAMETER MinimumAgeDays
Minimum age in days for files in the TemporaryFiles category. Defaults to 7.
Both creation and last-write timestamps must be older than this threshold.
Does not apply to other categories. Native handlers use their own eligibility rules.

.PARAMETER Categories
Defaults to TemporaryFiles and InternetCache. Available categories:
TemporaryFiles, InternetCache, RecycleBin, WindowsUpdateCleanup,
DefenderAntivirus, WindowsUpgradeLogs, DownloadedProgramFiles, ErrorReports,
DirectXShaderCache, DeliveryOptimization, DeviceDriverPackages,
LanguageResourceFiles, Thumbnails.

InternetCache targets Windows' Internet cache, not other browsers' profile folders.
Shader caches and thumbnails are rebuilt when needed. Package cleanup can remove
rollback resources; it is opt-in and may require a restart. Unavailable handlers
are reported as NeedsAttention, not replaced with direct folder deletion.

.PARAMETER Preview
Implies command-line mode. Reports eligible files or native estimates without deleting files or
emptying the Recycle Bin. Native scans can take time, particularly update cleanup.

.PARAMETER CommandLine
Explicitly selects the default console mode. Overrides Interactive.

.PARAMETER Interactive
Opens the category selection window. ATOM supplies this switch when launching the plugin.
Preview and NonInteractive override this switch to keep automation in console mode.

.PARAMETER NonInteractive
Implies command-line mode, skips confirmation, and returns a structured workflow result.

.INPUTS
None. This script does not accept pipeline input.

.OUTPUTS
PSCustomObject when NonInteractive is specified; JSON in command-line mode.
The interactive window displays results without writing pipeline output.
Top-level file and byte totals cover direct file cleanup only. Native handler
tasks report EligibleBytes and ReportedBytesRemoved when available; these are not
file-by-file verification. Recycle Bin previews query the Windows shell for item and byte counts.

.EXAMPLE
& '.\Temp Cleanup.ps1' -Interactive
Opens the category selection window and scans reclaimable space.

.EXAMPLE
& '.\Temp Cleanup.ps1' -CommandLine -Categories TemporaryFiles,WindowsUpgradeLogs
Confirms once, then cleans the selected categories with console progress.

.EXAMPLE
& '.\Temp Cleanup.ps1' -Preview
Previews the default categories without deleting files.

.EXAMPLE
& '.\Temp Cleanup.ps1' -Categories TemporaryFiles -MinimumAgeDays 14 -NonInteractive
Cleans temporary files older than fourteen days and returns a structured result.

.EXAMPLE
& '.\Temp Cleanup.ps1' -CommandLine -Categories RecycleBin
Requests confirmation before emptying the current account's Recycle Bin.

.EXAMPLE
& '.\Temp Cleanup.ps1' -Categories WindowsUpdateCleanup,DefenderAntivirus -Preview
Scans the selected Windows cleanup handlers without removing their files.

.NOTES
Storage varies between Windows versions. Native handler registrations are under:
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
Folder/FileList values describe generic cleaners; COM handlers can determine their
targets dynamically. The category map below uses those handlers rather than
treating the following locations as unconditional deletion targets.

WindowsUpdateCleanup: superseded components in the Windows component store
(%SystemRoot%\WinSxS); uses Update Cleanup. Never deletes WinSxS directly.

DefenderAntivirus: the Windows Defender registration targets LocalCopy and Support
under %ProgramData%\Microsoft\Windows Defender on current Windows installations.
Does not manually remove definitions, quarantine, or the Defender platform.

WindowsUpgradeLogs: contents of %SystemRoot%\Panther and the Windows volume's
$WINDOWS.~BT\Sources\Panther, including setup diagnostic support files.
Retains directories; refuses cleanup while Windows Setup runs. Preview measures
file sizes without requiring exclusive access. Locked/protected files may remain.

DownloadedProgramFiles: legacy downloaded ActiveX/Java program cache, traditionally
%SystemRoot%\Downloaded Program Files. This is not the user's Downloads folder.

InternetCache: the current account's registered InternetCache special folder,
typically %LocalAppData%\Microsoft\Windows\INetCache. PE maps that profile path.

ErrorReports: Windows Error Reporting Files, Feedback Hub Archive log files, and
Diagnostic Data Viewer database files. Current registrations target
%ProgramData%\Microsoft\Windows\WER, Microsoft\Diagnosis\FeedbackArchive, and
Microsoft\Diagnosis\EventTranscript respectively (last two under %ProgramData%).

DirectXShaderCache: D3D Shader Cache determines eligible shader caches; there is
no fixed Folder list in its registration. Does not sweep vendor driver folders.

DeliveryOptimization: Delivery Optimization Files manages its download cache.
The cache location can be configured; do not assume a fixed ServiceProfiles path.

DeviceDriverPackages: Device Driver Packages chooses obsolete driver packages.
Never deletes %SystemRoot%\System32\DriverStore\FileRepository directly.

LanguageResourceFiles: Language Pack selects unused language resources through
Windows servicing. No fixed folder list; installed language folders are retained
or removed according to the handler's eligibility decisions.

RecycleBin: Clear-RecycleBin empties the current account's bins across drives.
The per-volume $Recycle.Bin directories are not manually traversed.

TemporaryFiles: current account temp and %SystemRoot%\Temp; offline Windows temp
and registered user AppData\Local\Temp folders in PE. Only this category uses
MinimumAgeDays. Does not sweep Windows\Logs or general application folders.

Thumbnails: *.db directly inside %LocalAppData%\Microsoft\Windows\Explorer.
Includes thumbnail and icon cache databases; does not recurse into subdirectories.
Preview includes locked databases. Cleanup leaves files it cannot open exclusively
and reports them; does not terminate Explorer to release locks.

.LINK
https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr

.LINK
https://learn.microsoft.com/en-us/windows/win32/lwef/disk-cleanup

.LINK
https://learn.microsoft.com/en-us/windows/win32/api/emptyvc/nn-emptyvc-iemptyvolumecache

.LINK
https://learn.microsoft.com/en-us/windows/deployment/upgrade/log-files
#>
[CmdletBinding()]
param(
    [ValidateRange(1, 3650)]
    [Int]$MinimumAgeDays = 7,

    [ValidateSet('TemporaryFiles', 'InternetCache', 'RecycleBin', 'WindowsUpdateCleanup',
        'DefenderAntivirus', 'WindowsUpgradeLogs', 'DownloadedProgramFiles',
        'ErrorReports', 'DirectXShaderCache', 'DeliveryOptimization',
        'DeviceDriverPackages', 'LanguageResourceFiles', 'Thumbnails')]
    [String[]]$Categories = @('TemporaryFiles', 'InternetCache'),
    [switch]$CommandLine,
    [switch]$Interactive,
    [switch]$Preview,
    [switch]$NonInteractive
)

function Get-AtomCleanupDescriptions {
    if (!('AtomCleanup.ResourceText' -as [type])) {
        Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;
namespace AtomCleanup {
    public static class ResourceText {
        [DllImport("shlwapi.dll", CharSet=CharSet.Unicode)]
        private static extern int SHLoadIndirectString(string source, StringBuilder output, uint length, IntPtr reserved);
        public static string Resolve(string source) {
            if (!source.StartsWith("@")) return source;
            StringBuilder output = new StringBuilder(4096);
            return SHLoadIndirectString(source, output, (uint)output.Capacity, IntPtr.Zero) == 0 ? output.ToString() : null;
        }
    }
}
"@
    }

    $definitions = @{
        WindowsUpdateCleanup = @('Update Cleanup', 'Windows keeps copies of all installed updates from Windows Update, even after installing newer versions of updates. Windows Update cleanup deletes or compresses older versions of updates that are no longer needed and taking up space. You might need to restart your computer.')
        DefenderAntivirus = @('Windows Defender', 'Non critical files used by Microsoft Defender Antivirus.')
        WindowsUpgradeLogs = @('Windows Upgrade Log Files', 'Windows upgrade log files contain information that can help identify and troubleshoot problems that occur during Windows installation, upgrade, or servicing. Deleting these files can make it difficult to troubleshoot installation issues.')
        DownloadedProgramFiles = @('Downloaded Program Files', 'Downloaded Program Files are ActiveX controls and Java applets downloaded automatically from the Internet when you view certain pages. They are temporarily stored in the Downloaded Program Files folder on your hard disk.')
        InternetCache = @('Internet Cache Files', 'The Temporary Internet Files folder contains Web pages stored on your hard disk for quick viewing. Your personalized settings for Web pages will be left intact.')
        ErrorReports = @('Windows Error Reporting Files', 'Files created by Windows Error Reporting and feedback diagnostics.')
        DirectXShaderCache = @('D3D Shader Cache', 'Clean up files created by the graphics system which can speed up application load time and improve responsiveness. They will be re-generated as needed.')
        DeliveryOptimization = @('Delivery Optimization Files', 'Delivery Optimization files are files that were previously downloaded to your computer and can be deleted if currently unused by the Delivery Optimization service.')
        DeviceDriverPackages = @('Device Driver Packages', 'Windows keeps copies of all previously installed device driver packages from Windows Update and other sources even after installing newer versions of drivers. This task will remove older versions of drivers that are no longer needed. The most current version of each driver package will be kept.')
        LanguageResourceFiles = @('Language Pack', 'This operation will remove unused language resource files, including keyboards and speech.')
        RecycleBin = @('Recycle Bin', 'The Recycle Bin contains files you have deleted from your computer. These files are not permanently removed until you empty the Recycle Bin.')
        TemporaryFiles = @('Temporary Files', 'Apps can store temporary information in specific folders. These can be cleaned up manually if the app does not do it automatically.')
        Thumbnails = @('Thumbnail Cache', 'Windows keeps a copy of all of your picture, video, and document thumbnails so they can be displayed quickly when you open a folder. If you delete these thumbnails, they will be automatically recreated as needed.')
    }

    $descriptions = @{}
    foreach ($id in $definitions.Keys) {
        $definition = $definitions[$id]
        $descriptions[$id] = $definition[1]
        $key = $null
        try {
            $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$($definition[0])")
            if ($key) {
                $source = [string]$key.GetValue('Description')
                if ($source) {
                    $resolved = [AtomCleanup.ResourceText]::Resolve($source)
                    if (![string]::IsNullOrWhiteSpace($resolved)) {
                        $descriptions[$id] = $resolved.Trim()
                    }
                }
            }
        }
        catch {
            # Use the English text when the Windows resource is unavailable, including PE.
        }
        finally {
            if ($key) { $key.Dispose() }
        }
    }
    $descriptions
}

function Show-AtomCleanupWindow {
    param([string]$ScriptPath, [int]$AgeDays)

    Add-Type -AssemblyName PresentationFramework
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Temp Cleanup" Width="650" Height="710" MinWidth="520" MinHeight="480" WindowStartupLocation="CenterScreen" FontFamily="Segoe UI" FontSize="14" Background="#F5F5F5">
 <Grid Margin="20">
  <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
  <TextBlock Margin="0,0,0,12" TextWrapping="Wrap" Text="Check categories to clean. Select a row to read its description. Sizes are estimates."/>
  <DataGrid Name="CategoriesGrid" Grid.Row="1" AutoGenerateColumns="False" CanUserAddRows="False" CanUserDeleteRows="False" CanUserSortColumns="False" HeadersVisibility="Column" RowHeaderWidth="0" SelectionMode="Single" Background="White">
   <DataGrid.Columns>
    <DataGridTemplateColumn Header="Clean" Width="60"><DataGridTemplateColumn.CellTemplate><DataTemplate><CheckBox HorizontalAlignment="Center" VerticalAlignment="Center" Margin="6" IsChecked="{Binding Selected, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" IsEnabled="{Binding Available}"/></DataTemplate></DataGridTemplateColumn.CellTemplate></DataGridTemplateColumn>
    <DataGridTextColumn Header="Category" Binding="{Binding Name}" IsReadOnly="True" Width="*"/>
    <DataGridTextColumn Header="Reclaimable" Binding="{Binding Size}" IsReadOnly="True" Width="120"/>
   </DataGrid.Columns>

  </DataGrid>
  <Border Grid.Row="2" Margin="0,10,0,0" Padding="10" BorderBrush="#D0D0D0" BorderThickness="1" Background="White">
   <ScrollViewer Height="105" VerticalScrollBarVisibility="Auto">
    <StackPanel>
     <TextBlock Text="{Binding SelectedItem.Description, ElementName=CategoriesGrid}" TextWrapping="Wrap"/>
    </StackPanel>
   </ScrollViewer>
  </Border>
  <TextBlock Name="Total" Grid.Row="3" FontWeight="SemiBold" Margin="0,12,0,8"/>
  <ProgressBar Name="Progress" Grid.Row="4" Height="16" Margin="0,0,0,8"/>
  <TextBlock Name="Status" Grid.Row="5" TextWrapping="Wrap" Margin="0,0,0,12"/>
  <Button Name="Clean" Grid.Row="6" Content="Start cleanup" HorizontalAlignment="Right" MinWidth="140" Padding="16,8" IsEnabled="False"/>
 </Grid>
</Window>
"@
    $window = [Windows.Markup.XamlReader]::Load([Xml.XmlNodeReader]::new($xaml))
    $grid = $window.FindName('CategoriesGrid')
    $total = $window.FindName('Total')
    $progress = $window.FindName('Progress')
    $status = $window.FindName('Status')
    $clean = $window.FindName('Clean')
    $names = [ordered]@{
        WindowsUpdateCleanup = 'Windows Update Cleanup'
        DefenderAntivirus = 'Microsoft Defender Antivirus'
        WindowsUpgradeLogs = 'Windows upgrade log files'
        DownloadedProgramFiles = 'Downloaded Program Files'
        InternetCache = 'Temporary Internet Files'
        ErrorReports = 'Windows error reports and feedback diagnostics'
        DirectXShaderCache = 'DirectX Shader Cache'
        DeliveryOptimization = 'Delivery Optimization Files'
        DeviceDriverPackages = 'Device driver packages'
        LanguageResourceFiles = 'Language Resource Files'
        RecycleBin = 'Recycle Bin'
        TemporaryFiles = 'Temporary files'
        Thumbnails = 'Thumbnails'
    }
    $descriptions = Get-AtomCleanupDescriptions
    $rows = [Collections.ObjectModel.ObservableCollection[object]]::new()
    foreach ($id in $names.Keys) {
        $rows.Add([pscustomobject]@{Id=$id;Name=$names[$id];Description=$descriptions[$id];Selected=$false;Available=$false;Bytes=$null;Size='Waiting';Detail='Waiting for scan.'})
    }
    $grid.ItemsSource = $rows
    $grid.SelectedIndex = 0
    $state = @{ Worker=$null; Handle=$null; Row=$null; Mode='Scan'; Pending=[Collections.Queue]::new(); Results=[Collections.Generic.List[object]]::new() }
    foreach ($row in $rows) { $state.Pending.Enqueue($row) }
    $timer = [Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(200)

    $tick = {
        try {
            if ($state.Worker -and $state.Handle.IsCompleted) {
                try {
                    $output = @($state.Worker.EndInvoke($state.Handle))
                    $result = $output | Where-Object { $_.Output -and $_.Status } | Select-Object -Last 1
                    if (!$result) {
                        if ($state.Worker.HadErrors) { throw ($state.Worker.Streams.Error | Out-String) }
                        throw 'Cleanup returned no result.'
                    }
                    $state.Results.Add($result)
                    $row = $state.Row
                    $row.Detail = ($result.Output.Tasks | ForEach-Object { if ($_.Summary) { $_.Summary }; $_.Errors }) -join "`n"
                    if ($state.Mode -eq 'Scan') {
                        $sizes = @($result.Output.Tasks | Where-Object { $null -ne $_.EligibleBytes })
                        $row.Available = $result.Status -eq 'Succeeded' -or ($sizes | Measure-Object EligibleBytes -Sum).Sum -gt 0
                        $row.Bytes = if ($sizes.Count -eq $result.Output.Tasks.Count) { [double](($sizes | Measure-Object EligibleBytes -Sum).Sum) } else { $null }
                        $row.Size = if (!$row.Available) { 'Unavailable' } elseif ($null -eq $row.Bytes) { 'Unknown' } else { '{0:N2} MB' -f ($row.Bytes / 1MB) }
                        if ($row.Available -and $result.Status -ne 'Succeeded') {
                            $row.Size += '*'
                            $row.Detail = "Partial scan: some files or handlers could not be assessed. Cleanup can process eligible files.`n" + $row.Detail
                        }
                        $row.Selected = $row.Available -and $row.Id -in @('TemporaryFiles','InternetCache')
                    }
                    else {
                        $row.Size = if ($result.Status -eq 'Succeeded') { 'Completed' } else { 'Needs attention' }
                        $row.Available = $false
                        $row.Selected = $false
                    }
                }
                catch {
                    $state.Row.Size = 'Unavailable'
                    $state.Row.Detail = $_.Exception.Message
                    $state.Row.Available = $false
                    $state.Row.Selected = $false
                }
                finally {
                    $state.Worker.Dispose()
                    $state.Worker = $null
                    $grid.Items.Refresh()
                }
            }
            if (!$state.Worker -and $state.Pending.Count) {
                $state.Row = $state.Pending.Dequeue()
                $state.Worker = [PowerShell]::Create()
                [void]$state.Worker.AddCommand($ScriptPath).AddParameter('CommandLine').AddParameter('NonInteractive').AddParameter('Categories', [string[]]@($state.Row.Id)).AddParameter('MinimumAgeDays', $AgeDays)
                if ($state.Mode -eq 'Scan') { [void]$state.Worker.AddParameter('Preview') }
                $state.Handle = $state.Worker.BeginInvoke()
                $status.Text = "$($state.Mode): $($state.Row.Name)"
            }
            $busy = $null -ne $state.Worker -or $state.Pending.Count -gt 0
            $progress.IsIndeterminate = $busy
            $selected = @($rows | Where-Object Selected)
            $bytes = ($selected | Measure-Object Bytes -Sum).Sum
            $unknown = @($selected | Where-Object { $null -eq $_.Bytes }).Count
            $total.Text = 'Selected estimate: {0:N2} MB{1}' -f ($bytes / 1MB), $(if ($unknown) { ' + unknown sizes' } else { '' })
            $clean.IsEnabled = !$busy -and $selected.Count -gt 0
            if (!$busy) {
                $grid.IsEnabled = $true
                $progress.Value = 100
                $status.Text = if ($state.Mode -eq 'Scan') { 'Scan complete. Review the categories, then start cleanup. System categories require running as administrator.' } else { 'Cleanup finished. Close and reopen to scan again.' }
            }
        }
        catch {
            $status.Text = $_.Exception.Message
            $timer.Stop()
            $clean.IsEnabled = $false
        }
    }
    $timer.Add_Tick($tick)
    $clean.Add_Click({
        if ([Windows.MessageBox]::Show($window, 'Permanently clean the selected categories? Upgrade diagnostics and rollback resources may be removed.', 'Confirm cleanup', 'YesNo', 'Warning') -ne 'Yes') { return }
        $state.Mode = 'Cleanup'
        $state.Results.Clear()
        foreach ($row in $rows) { if ($row.Selected -and $row.Available) { $state.Pending.Enqueue($row) } }
        $grid.IsEnabled = $false
        $clean.IsEnabled = $false
    })
    $window.Add_Closing({ param($sender, $eventArgs)
        if ($state.Worker -and !$state.Handle.IsCompleted) {
            $eventArgs.Cancel = $true
            $status.Text = 'Please wait for the current category to finish before closing.'
        }
    })
    try {
        $timer.Start()
        [void]$window.ShowDialog()
    }
    finally {
        $timer.Stop()
        if ($state.Worker) { $state.Worker.Dispose() }
        $window.Close()
    }
}

function Invoke-AtomCleanupHandler {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Handler,
        [Parameter(Mandatory)][string]$Category,
        [switch]$Preview
    )

    $task = [ordered]@{
        Category             = $Category
        Handler              = $Handler
        StartedUtc           = [datetime]::UtcNow.ToString('o')
        FinishedUtc          = $null
        Status               = 'NeedsAttention'
        EligibleBytes        = $null
        ReportedBytesRemoved = $null
        Summary              = $null
    }

    $key = $null

    try {
        $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$Handler")

        if (!$key) {
            throw "Windows does not have the '$Handler' cleanup handler installed."
        }

        if (!('AtomCleanup.NativeHandler' -as [type])) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace AtomCleanup
{
    [ComVisible(true), Guid("6E793361-73C6-11D0-8469-00AA00442901"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface ICallback
    {
        [PreserveSig] int ScanProgress(ulong used, uint flags, [MarshalAs(UnmanagedType.LPWStr)] string status);
        [PreserveSig] int PurgeProgress(ulong freed, ulong requested, uint flags, [MarshalAs(UnmanagedType.LPWStr)] string status);
    }

    [ComImport, Guid("8FCE5227-04DA-11d1-A004-00805F8ABE06"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface ICache
    {
        [PreserveSig] int Initialize(IntPtr key, [MarshalAs(UnmanagedType.LPWStr)] string volume, out IntPtr name, out IntPtr description, ref uint flags);
        [PreserveSig] int GetSpaceUsed(out ulong used, ICallback callback);
        [PreserveSig] int Purge(ulong requested, ICallback callback);
        [PreserveSig] int ShowProperties(IntPtr window);
        [PreserveSig] int Deactivate(out uint flags);
    }

    [ComImport, Guid("02b7e3ba-4db3-11d2-b2d9-00c04f8eec8c"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface ICache2
    {
        [PreserveSig] int Initialize(IntPtr key, [MarshalAs(UnmanagedType.LPWStr)] string volume, out IntPtr name, out IntPtr description, ref uint flags);
        [PreserveSig] int GetSpaceUsed(out ulong used, ICallback callback);
        [PreserveSig] int Purge(ulong requested, ICallback callback);
        [PreserveSig] int ShowProperties(IntPtr window);
        [PreserveSig] int Deactivate(out uint flags);
        [PreserveSig] int InitializeEx(IntPtr key, [MarshalAs(UnmanagedType.LPWStr)] string volume, [MarshalAs(UnmanagedType.LPWStr)] string keyName, out IntPtr name, out IntPtr description, out IntPtr button, ref uint flags);
    }

    [ComVisible(true), ClassInterface(ClassInterfaceType.None)]
    public sealed class Progress : ICallback
    {
        public ulong? Freed;
        public int ScanProgress(ulong used, uint flags, string status) { return 0; }
        public int PurgeProgress(ulong freed, ulong requested, uint flags, string status)
        {
            if (freed != ulong.MaxValue) Freed = freed;
            return 0;
        }
    }

    public sealed class Result
    {
        public ulong? EligibleBytes;
        public ulong? ReportedBytesRemoved;
        public bool Empty;
    }

    public static class NativeHandler
    {
        private static void RequireSuccess(int result, string operation)
        {
            if (result < 0) throw new COMException(operation + ": " + Marshal.GetExceptionForHR(result).Message, result);
            if (result != 0) throw new InvalidOperationException(operation + " did not complete successfully (HRESULT " + result + ").");
        }

        public static Result Run(Guid clsid, IntPtr key, string volume, string keyName, bool preview)
        {
            object instance = Activator.CreateInstance(Type.GetTypeFromCLSID(clsid, true));
            ICache cache = null;
            IntPtr name = IntPtr.Zero, description = IntPtr.Zero, button = IntPtr.Zero;
            bool initialized = false;

            try
            {
                cache = (ICache)instance;
                ICache2 extended = instance as ICache2;
                // SETTINGSMODE can delete during initialization, including during preview.
                uint flags = 0;
                int hr = extended == null
                    ? cache.Initialize(key, volume, out name, out description, ref flags)
                    : extended.InitializeEx(key, volume, keyName, out name, out description, out button, ref flags);
                initialized = hr >= 0;

                if (hr == 1) return new Result { Empty = true, EligibleBytes = 0 };
                RequireSuccess(hr, "Initialization");

                Progress callback = new Progress();
                ulong eligible;
                RequireSuccess(cache.GetSpaceUsed(out eligible, callback), "Scan");
                Result result = new Result { EligibleBytes = eligible == ulong.MaxValue ? (ulong?)null : eligible, Empty = eligible == 0 };

                if (!preview && !result.Empty)
                {
                    RequireSuccess(cache.Purge(ulong.MaxValue, callback), "Cleanup");
                    result.ReportedBytesRemoved = callback.Freed;
                }

                GC.KeepAlive(callback);
                return result;
            }
            finally
            {
                try
                {
                    if (initialized)
                    {
                        uint flags;
                        RequireSuccess(cache.Deactivate(out flags), "Handler shutdown");
                    }
                }
                finally
                {
                    if (name != IntPtr.Zero) Marshal.FreeCoTaskMem(name);
                    if (description != IntPtr.Zero) Marshal.FreeCoTaskMem(description);
                    if (button != IntPtr.Zero) Marshal.FreeCoTaskMem(button);
                    Marshal.FinalReleaseComObject(instance);
                }
            }
        }
    }
}
"@
        }

        $volume = [IO.Path]::GetPathRoot($env:SystemRoot).TrimEnd('\')
        $result = [AtomCleanup.NativeHandler]::Run([guid]$key.GetValue(''), $key.Handle.DangerousGetHandle(), $volume, $Handler, [bool]$Preview)
        $task.EligibleBytes = $result.EligibleBytes
        $task.ReportedBytesRemoved = $result.ReportedBytesRemoved
        $task.Status = 'Succeeded'
        $task.Summary = if ($result.Empty) {
            'Windows reports no eligible files.'
        }
        elseif ($Preview) {
            'Windows handler scan completed; nothing deleted. EligibleBytes is an estimate when available.'
        }
        else {
            'Windows handler completed cleanup. File counts are unavailable; reported bytes may be unavailable. Servicing cleanup may require a restart.'
        }
    }
    catch {
        $task.Summary = $_.Exception.Message
    }
    finally {
        if ($key) {
            $key.Dispose()
        }

        $task.FinishedUtc = [datetime]::UtcNow.ToString('o')
    }

    [pscustomobject]$task
}

function Clear-AtomTemporaryFiles {
    <#
    .SYNOPSIS
        Cleans files in selected temporary and cache directories.
    .DESCRIPTION
        Does not remove directories, follow reparse points, or clear the Recycle Bin.
        Preview counts eligible files without deleting them. Callers supply trusted
        roots. IgnoreAge disables the age filter for cache categories.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string[]]$Roots,
        [ValidateRange(1, 3650)]
        [Int]$MinimumAgeDays = 7,

        [string[]]$ExcludePaths = @(),
        [string[]]$FilePatterns = @('*'),
        [switch]$NoRecurse,
        [switch]$IncludeLockedInEstimate,
        [switch]$IgnoreAge,
        [switch]$Preview
    )
    $started = [datetime]::UtcNow
    $cutoff = $started.AddDays(-$MinimumAgeDays)
    $protected = @($env:USERPROFILE, $env:SystemRoot, $env:ProgramFiles) | Where-Object {
        $_
    }
    $normalized = @($Roots | ForEach-Object {
            if ([string]::IsNullOrWhiteSpace($_) -or ![IO.Path]::IsPathRooted($_)) {
                throw 'Cleanup roots must be absolute paths.'
            }
            $path = [IO.Path]::GetFullPath($_).TrimEnd('\')
            if ($path -eq [IO.Path]::GetPathRoot($path).TrimEnd('\') -or $protected -contains $path) {
                throw "Unsafe cleanup root: $path"
            }
            $path

        } | Select-Object -Unique)
    $excluded = @($ExcludePaths | ForEach-Object {
            [IO.Path]::GetFullPath($_).TrimEnd('\')
        })
    $results = [Collections.Generic.List[object]]::new()
    $progressClock = [Diagnostics.Stopwatch]::StartNew()
    foreach ($root in $normalized) {
        # Avoid counting the same files twice if roots overlap.
        if (@($normalized | Where-Object {
                    $_ -ne $root -and $root.StartsWith($_ + '\', [StringComparison]::OrdinalIgnoreCase)
                }).Count) {
            continue
        }
        $task = [ordered]@{
            Path               = $root
            StartedUtc         = [datetime]::UtcNow.ToString('o')
            FinishedUtc        = $null
            Status             = 'Succeeded'
            DeletedFiles       = 0
            EligibleFiles      = 0
            SkippedFiles       = 0
            SkippedDirectories = 0
            FailedItems        = 0
            BytesRemoved       = [long]0
            EligibleBytes      = [long]0
            Errors             = [Collections.Generic.List[string]]::new()
        }
        $pending = [Collections.Generic.Stack[string]]::new()
        $pending.Push($root)
        while ($pending.Count) {
            $directory = $pending.Pop()
            try {
                if (@($excluded | Where-Object {
                            $directory -eq $_ -or $directory.StartsWith($_ + '\', [StringComparison]::OrdinalIgnoreCase)
                        }).Count) {
                    $task.SkippedDirectories++
                    continue
                }
                # Check every ancestor, including the root: never traverse junctions.
                $ancestor = [IO.DirectoryInfo]::new($directory)
                $linked = $false
                while ($ancestor) {
                    if ($ancestor.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                        $linked = $true
                        break
                    }
                    $ancestor = $ancestor.Parent

                }
                if ($linked) {
                    $task.SkippedDirectories++
                    continue
                }
                if (![IO.Directory]::Exists($directory)) {
                    if ($directory -eq $root) {
                        $task.Status = 'Skipped'
                    }
                    continue

                }
                foreach ($entry in [IO.DirectoryInfo]::new($directory).GetFileSystemInfos()) {
                    if ($progressClock.ElapsedMilliseconds -ge 250) {
                        Write-Progress -Id 2 -ParentId 1 -Activity 'Processing files' -Status "$($task.EligibleFiles) eligible; $($task.DeletedFiles) removed - $directory"
                        $progressClock.Restart()
                    }
                    if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                        $task.SkippedDirectories++
                        continue
                    }
                    if ($entry -is [IO.DirectoryInfo]) {
                        if ($NoRecurse -or $entry.Name -like 'ATOM*') {
                            $task.SkippedDirectories++
                        }
                        else {
                            $pending.Push($entry.FullName)
                        }
                        continue

                    }
                    if (!@($FilePatterns | Where-Object { $entry.Name -like $_ }).Count -or (!$IgnoreAge -and ($entry.LastWriteTimeUtc -ge $cutoff -or $entry.CreationTimeUtc -ge $cutoff)) -or $entry.Name -like 'ATOM*') {
                        $task.SkippedFiles++
                        continue
                    }
                    try {
                        $length = $entry.Length
                        if ($Preview -and $IncludeLockedInEstimate) {
                            $task.EligibleFiles++
                            $task.EligibleBytes += $length
                            continue
                        }
                        # An exclusive open detects files currently held by another process.
                        $handle = [IO.File]::Open($entry.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
                        $handle.Dispose()
                        $task.EligibleFiles++
                        $task.EligibleBytes += $length
                        if (!$Preview) {
                            $entry.Delete()
                            $task.DeletedFiles++
                            $task.BytesRemoved += $length

                        }

                    }
                    catch {
                        $task.FailedItems++
                        if ($task.Errors.Count -lt 100) {
                            $task.Errors.Add("$($entry.FullName): $($_.Exception.Message)")
                        }

                    }

                }

            }
            catch {
                $task.FailedItems++
                if ($task.Errors.Count -lt 100) {
                    $task.Errors.Add("${directory}: $($_.Exception.Message)")
                }

            }

        }
        if ($task.FailedItems) {
            $task.Status = 'NeedsAttention'
        }
        $task.FinishedUtc = [datetime]::UtcNow.ToString('o')
        $results.Add([pscustomobject]$task)

    }
    Write-Progress -Id 2 -ParentId 1 -Activity 'Processing files' -Completed
    $deleted = [long](($results | Measure-Object DeletedFiles -Sum).Sum)
    $bytes = [long](($results | Measure-Object BytesRemoved -Sum).Sum)
    $failures = [int](($results | Measure-Object FailedItems -Sum).Sum)
    $eligible = [long](($results | Measure-Object EligibleFiles -Sum).Sum)
    [pscustomobject]@{
        Status   = $(if ($failures) {
                'NeedsAttention'
            }
            else {
                'Succeeded'
            })
        ExitCode = $null
        Summary  = $(if ($Preview) {
                "Preview: $eligible files eligible; nothing deleted."
            }
            else {
                "Removed $deleted files ($bytes bytes); $failures items could not be cleaned."
            })
        Output   = [pscustomobject]@{
            StartedUtc     = $started.ToString('o')
            FinishedUtc    = [datetime]::UtcNow.ToString('o')
            MinimumAgeDays = $(if ($IgnoreAge) {
                    $null
                }
                else {
                    $MinimumAgeDays
                })
            Preview        = [bool]$Preview
            TotalTasks     = $results.Count
            PassedTasks    = @($results | Where-Object Status -EQ 'Succeeded').Count
            AttentionTasks = @($results | Where-Object Status -EQ 'NeedsAttention').Count
            SkippedTasks   = @($results | Where-Object Status -EQ 'Skipped').Count
            DeletedFiles   = $deleted
            BytesRemoved   = $bytes
            FailedItems    = $failures
            Tasks          = @($results.ToArray())
        }

    }

}

$ErrorActionPreference = 'Stop'
if ($Interactive -and !$CommandLine -and !$NonInteractive -and !$Preview) {
    Show-AtomCleanupWindow -ScriptPath $PSCommandPath -AgeDays $MinimumAgeDays
    return
}

$inPE = Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT'
if (!$Categories.Count) {
    throw 'Select at least one cleanup category.'
}
if ('RecycleBin' -in $Categories) {
    if ($inPE) {
        throw 'Recycle Bin cleanup is supported only in running Windows; no cleanup was started.'
    }
    if (!$Preview -and !(Get-Command Clear-RecycleBin -ErrorAction SilentlyContinue)) {
        throw 'Clear-RecycleBin is unavailable; no cleanup was started.'
    }

}
$nativeCategories = [ordered]@{
    WindowsUpdateCleanup   = @('Update Cleanup')
    DefenderAntivirus      = @('Windows Defender')
    DownloadedProgramFiles = @('Downloaded Program Files')
    ErrorReports           = @('Windows Error Reporting Files', 'Feedback Hub Archive log files', 'Diagnostic Data Viewer database files')
    DirectXShaderCache     = @('D3D Shader Cache')
    DeliveryOptimization   = @('Delivery Optimization Files')
    DeviceDriverPackages   = @('Device Driver Packages')
    LanguageResourceFiles  = @('Language Pack')
}

$selectedNative = @($nativeCategories.Keys | Where-Object { $_ -in $Categories })

if ($selectedNative.Count) {
    if ($inPE) {
        throw 'Native Windows cleanup handlers are unavailable for offline PE targets. Select TemporaryFiles or InternetCache; no cleanup was started.'
    }

    if ([Environment]::Is64BitOperatingSystem -and ![Environment]::Is64BitProcess) {
        throw 'Run Temp Cleanup in 64-bit PowerShell to use Windows cleanup handlers; no cleanup was started.'
    }

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    try {
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw 'Run PowerShell as administrator to use Windows cleanup handlers; no cleanup was started.'
        }
    }
    finally {
        $identity.Dispose()
    }
}

$cacheRoots = @()
if ($inPE) {
    $mounted = (Get-ItemProperty 'HKLM:\SOFTWARE\ATOM' -Name MountedDrive -ErrorAction Stop).MountedDrive
    if ($mounted -notmatch '^[A-Za-z]:$' -or !(Test-Path 'HKLM:\RemoteOS-HKLM-SOFTWARE') -or !(Test-Path 'HKLM:\RemoteOS-HKLM-SYSTEM')) {
        throw 'Use MountOS to select and mount Windows before running Temp Cleanup.'

    }
    if ($mounted -eq [IO.Path]::GetPathRoot($env:SystemRoot).TrimEnd('\')) {
        throw 'The mounted target must not be the running PE drive.'
    }
    $offlineRoot = (Get-ItemProperty 'HKLM:\RemoteOS-HKLM-SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name SystemRoot -ErrorAction Stop).SystemRoot
    if ($offlineRoot -notmatch '^[A-Za-z]:\\[^\\]+') {
        throw 'Mounted Windows has an unsupported SystemRoot.'
    }
    $originalDrive = $offlineRoot.Substring(0, 2)
    $windowsPath = [IO.Path]::GetFullPath($mounted + $offlineRoot.Substring(2))
    if (!$windowsPath.StartsWith($mounted + '\', [StringComparison]::OrdinalIgnoreCase) -or !(Test-Path -LiteralPath (Join-Path $windowsPath 'System32/config/SYSTEM'))) {
        throw 'MountOS target is no longer available. Mount Windows again.'
    }
    $roots = @((Join-Path $windowsPath 'Temp'))
    foreach ($profile in Get-ChildItem 'HKLM:\RemoteOS-HKLM-SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -ErrorAction Stop) {
        if ($profile.PSChildName -notmatch '^S-1-(5-21|12-1)-') {
            continue
        }
        $path = [string]$profile.GetValue('ProfileImagePath', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        $path = $path.Replace('%SystemDrive%', $originalDrive)
        if (!$path.StartsWith($originalDrive + '\', [StringComparison]::OrdinalIgnoreCase)) {
            throw "Cannot safely map offline profile path '$path'. No cleanup was started."
        }
        $mapped = [IO.Path]::GetFullPath($mounted + $path.Substring(2))
        if (!$mapped.StartsWith($mounted + '\', [StringComparison]::OrdinalIgnoreCase)) {
            throw 'Offline profile escapes the mounted drive.'
        }
        $roots += Join-Path $mapped 'AppData/Local/Temp'
        $cacheRoots += Join-Path $mapped 'AppData/Local/Microsoft/Windows/INetCache'

    }

}
else {
    $roots = @([IO.Path]::GetTempPath(), (Join-Path $env:SystemRoot 'Temp'))
    $cache = [Environment]::GetFolderPath([Environment+SpecialFolder]::InternetCache)
    if ($cache) {
        $cacheRoots = @($cache)
    }

}
$targets = [ordered]@{
}
if ('TemporaryFiles' -in $Categories) {
    $targets.TemporaryFiles = $roots
}
if ('InternetCache' -in $Categories) {
    $targets.InternetCache = $cacheRoots
}
if ('WindowsUpgradeLogs' -in $Categories) {
    if ($inPE) {
        throw 'Upgrade log cleanup is supported in running Windows only; no cleanup was started.'
    }
    if (Get-Process -Name SetupHost, SetupPrep, setup -ErrorAction SilentlyContinue) {
        throw 'Windows Setup is running. Upgrade logs cannot be cleaned until setup finishes.'
    }
    $targets.WindowsUpgradeLogs = @(
        (Join-Path $env:SystemRoot 'Panther'),
        (Join-Path ([IO.Path]::GetPathRoot($env:SystemRoot)) '$WINDOWS.~BT\Sources\Panther')
    )
}
if ('Thumbnails' -in $Categories) {
    if ($inPE) {
        throw 'Thumbnail cleanup is supported in running Windows only; no cleanup was started.'
    }
    $targets.Thumbnails = @((Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Microsoft\Windows\Explorer'))
}
$exclusions = @([IO.Path]::GetFullPath("$PSScriptRoot/../.."))
if (!$NonInteractive -and !$Preview) {
    Write-Host ('Cleanup categories: ' + ($Categories -join ', '))
    Write-Host ('File targets: ' + (@($targets.Values | ForEach-Object {
                    $_
                }) -join ', '))
    if ('RecycleBin' -in $Categories) {
        Write-Host 'Recycle Bin: all contents for the current account, regardless of age.'
    }
    $answer = Read-Host 'Clean selected categories? Type YES to continue'
    if ($answer -cne 'YES') {
        return
    }

}
$tasks = [Collections.Generic.List[object]]::new()
$started = [datetime]::UtcNow.ToString('o')
$step = 0
$stepCount = $targets.Count + $selectedNative.Count + [int]('RecycleBin' -in $Categories)
foreach ($category in $targets.Keys) {
    Write-Progress -Id 1 -Activity 'Temp Cleanup' -Status $category -PercentComplete (100 * $step++ / $stepCount)
    if (!$targets[$category].Count) {
        $tasks.Add([pscustomobject]@{
                Category = $category
                Status   = 'Skipped'
                Summary  = 'No supported cache location is registered.'
            })
        continue

    }
    $patterns = if ($category -eq 'Thumbnails') { @('*.db') } else { @('*') }
    $r = Clear-AtomTemporaryFiles -Roots $targets[$category] -FilePatterns $patterns -NoRecurse:($category -eq 'Thumbnails') -IncludeLockedInEstimate:($category -in @('WindowsUpgradeLogs', 'Thumbnails')) -IgnoreAge:($category -ne 'TemporaryFiles') -MinimumAgeDays $MinimumAgeDays -ExcludePaths $exclusions -Preview:$Preview
    foreach ($task in $r.Output.Tasks) {
        $task | Add-Member NoteProperty Category $category
        $tasks.Add($task)
    }

}
if ('RecycleBin' -in $Categories) {
    Write-Progress -Id 1 -Activity 'Temp Cleanup' -Status 'Recycle Bin' -PercentComplete (100 * $step++ / $stepCount)
    $task = [pscustomobject]@{
        Category    = 'RecycleBin'
        StartedUtc  = [datetime]::UtcNow.ToString('o')
        FinishedUtc = $null
        Status      = 'Skipped'
        Summary     = 'Preview: would empty the current account Recycle Bin.'
        EligibleBytes = $null
        EligibleFiles = $null
    }
    if ($Preview) {
        try {
            if (!('AtomCleanup.RecycleQuery' -as [type])) {
                Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
namespace AtomCleanup {
    [StructLayout(LayoutKind.Sequential)]
    public struct RecycleInfo { public uint Size; public long Bytes; public long Items; }
    public static class RecycleQuery {
        [DllImport("shell32.dll", CharSet=CharSet.Unicode)]
        private static extern int SHQueryRecycleBinW(string root, ref RecycleInfo info);
        public static RecycleInfo Query() {
            RecycleInfo info = new RecycleInfo();
            info.Size = (uint)Marshal.SizeOf(typeof(RecycleInfo));
            Marshal.ThrowExceptionForHR(SHQueryRecycleBinW(null, ref info));
            return info;
        }
    }
}
"@
            }
            $info = [AtomCleanup.RecycleQuery]::Query()
            $task.EligibleBytes = $info.Bytes
            $task.EligibleFiles = $info.Items
            $task.Status = 'Succeeded'
        }
        catch {
            $task.Status = 'NeedsAttention'
            $task.Summary = $_.Exception.Message
        }
    }
    if (!$Preview) {
        try {
            Clear-RecycleBin -Force -ErrorAction Stop
            $task.Status = 'Succeeded'
            $task.Summary = 'Recycle Bin emptied; deleted file and byte counts are not exposed by this command.'
        }
        catch {
            $task.Status = 'NeedsAttention'
            $task.Summary = $_.Exception.Message
        }

    }
    $task.FinishedUtc = [datetime]::UtcNow.ToString('o')
    $tasks.Add($task)

}
foreach ($category in $selectedNative) {
    Write-Progress -Id 1 -Activity 'Temp Cleanup' -Status $category -PercentComplete (100 * $step++ / $stepCount)
    foreach ($handler in $nativeCategories[$category]) {
        $tasks.Add((Invoke-AtomCleanupHandler -Handler $handler -Category $category -Preview:$Preview))
    }
}

Write-Progress -Id 1 -Activity 'Temp Cleanup' -Completed
$files = @($tasks | Where-Object {
        $_.PSObject.Properties['DeletedFiles']
    })
$deleted = [long](($files | Measure-Object DeletedFiles -Sum).Sum)
$bytes = [long](($files | Measure-Object BytesRemoved -Sum).Sum)
$attention = @($tasks | Where-Object Status -EQ 'NeedsAttention').Count
$result = [pscustomobject]@{
    Status   = $(if ($attention) {
            'NeedsAttention'
        }
        else {
            'Succeeded'
        })
    ExitCode = $null
    Summary  = $(if ($Preview) {
            'Preview complete; nothing deleted.'
        }
        else {
            "Removed $deleted files ($bytes bytes) in file-based categories, excluding Windows handler and Recycle Bin cleanup; $attention tasks need attention."
        })
    Output   = [pscustomobject]@{
        StartedUtc     = $started
        FinishedUtc    = [datetime]::UtcNow.ToString('o')
        Categories     = $Categories
        Preview        = [bool]$Preview
        MinimumAgeDays = $MinimumAgeDays
        DeletedFiles   = $deleted
        BytesRemoved   = $bytes
        TotalTasks     = $tasks.Count
        PassedTasks    = @($tasks | Where-Object Status -EQ 'Succeeded').Count
        AttentionTasks = $attention
        SkippedTasks   = @($tasks | Where-Object Status -EQ 'Skipped').Count
        Tasks          = $tasks.ToArray()
    }

}
if ($NonInteractive) {
    $result
}
else {
    $result | ConvertTo-Json -Depth 8 | Write-Output
}
