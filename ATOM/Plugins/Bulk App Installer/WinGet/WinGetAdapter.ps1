<#
.SYNOPSIS
Loads the bundled WinGet progress adapter, or rebuilds it for maintainers.
.DESCRIPTION
Bulk App Installer prefers the cached Microsoft.WinGet.Client module, then this
adapter, then WinGet CLI with queue-level progress. Loading only extracts and
checks the ZIP before loading its compiled DLL; it never compiles source or
fetches build dependencies. Installation requests are not retried through
another progress backend once submitted.

Build mode requires Windows PowerShell 5.1 and downloads official Microsoft
WinGet Client and Windows SDK Contracts packages into the ignored
Programs/Development/WinGetBuild directory. SDK Contracts are compilation-only.
Microsoft activation DLL signatures are checked before bundling. The ZIP includes
x64, x86 and ARM64 helpers, metadata, checksums, and Microsoft license notices.
.EXAMPLE
& './WinGetAdapter.ps1' -CachePath 'D:/ATOM/Programs/Bulk App Installer/WinGet'
.EXAMPLE
& "$env:WINDIR/System32/WindowsPowerShell/v1.0/powershell.exe" -NoProfile -ExecutionPolicy Bypass -File 'ATOM/Plugins/Bulk App Installer/WinGet/WinGetAdapter.ps1' -Build
Rebuild after editing the embedded C# source below.
.LINK
https://github.com/microsoft/winget-cli
.LINK
https://github.com/microsoft/winget-cli/blob/master/LICENSE
#>
[CmdletBinding(DefaultParameterSetName = 'Load')]
param (
    [Parameter(Mandatory, ParameterSetName = 'Load')]
    [string]$CachePath,

    [Parameter(Mandatory, ParameterSetName = 'Build')]
    [switch]$Build,

    [Parameter(ParameterSetName = 'Build')]
    [string]$WinGetVersion = '1.29.380',

    [Parameter(ParameterSetName = 'Build')]
    [string]$SdkVersion = '10.0.26100.9169'
)

if (!$Build) {
    if (('Atom.WinGet.PackageAdapter' -as [type]) -and [Atom.WinGet.NativeInterop]::Initialized) { return }
    $bundle = Join-Path $PSScriptRoot 'WinGetAdapter.zip'
    $version = (Get-FileHash -LiteralPath $bundle -Algorithm SHA256).Hash.Substring(0,16)
    $cache = Join-Path $CachePath $version
    if (![IO.File]::Exists((Join-Path $cache 'manifest.json'))) {
        Expand-Archive -LiteralPath $bundle -DestinationPath $cache -Force -ErrorAction Stop
    }
    $architecture = [Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture.ToString().ToLowerInvariant()
    $manifest = Get-Content -LiteralPath (Join-Path $cache 'manifest.json') -Raw | ConvertFrom-Json
    foreach ($file in 'WinGetAdapter.dll', "$architecture/Microsoft.Management.Deployment.winmd", "$architecture/winrtact.dll") {
        $entry = $manifest.Files | Where-Object Path -eq $file
        if (!$entry -or (Get-FileHash -LiteralPath (Join-Path $cache $file) -Algorithm SHA256).Hash -ne $entry.SHA256) {
            throw "WinGet adapter file is missing or corrupt: $file"
        }
    }
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $null = [Reflection.Assembly]::LoadFrom((Join-Path $cache 'WinGetAdapter.dll'))
    [Atom.WinGet.NativeInterop]::Initialize((Join-Path $cache $architecture))
    # Upstream disables progress callbacks on older ARM64 Windows builds to avoid a marshaling crash.
    [Atom.WinGet.NativeInterop]::EnableProgress = $architecture -ne 'arm64' -or [Environment]::OSVersion.Version.Build -ge 26068
    return
}

$adapterSource = @'
using System;
using System.Collections.Concurrent;
using Microsoft.Management.Deployment;

namespace Atom.WinGet
{
    public sealed class ProgressUpdate
    {
        public string State;
        public double Percent;
        public ulong BytesDownloaded;
        public ulong BytesRequired;
    }

    public sealed class OperationResult
    {
        public string Status;
        public int ErrorCode;
        public uint InstallerErrorCode;
        public bool RebootRequired;
        public bool InstallationStarted;
        public string Message;
        public bool Succeeded { get { return Status == "Ok"; } }
        public bool HashMismatch { get { return ErrorCode == -1978335215; } }
    }

    public sealed class PackageAdapter
    {
        public readonly ConcurrentQueue<ProgressUpdate> Progress = new ConcurrentQueue<ProgressUpdate>();
        public readonly OperationResult Result = new OperationResult();
        private volatile bool complete;
        private volatile bool cancellationRequested;
        public bool Complete { get { return complete; } }
        public void Cancel() { cancellationRequested = true; }

        private static T Create<T>(string clsid, string iid)
        {
            return (T)NativeInterop.Activate(clsid, iid);
        }

        public void Download(string id, string directory) { Start(id, directory, false, false); }
        public void Install(string id, bool prepareOnly) { Start(id, null, true, prepareOnly); }

        private void Start(string id, string directory, bool install, bool prepareOnly)
        {
            System.Threading.ThreadPool.QueueUserWorkItem(delegate {
                try { Execute(id, directory, install, prepareOnly); }
                catch (Exception error) {
                    Result.Status = error is OperationCanceledException ? "Cancelled" : "Error";
                    Result.Message = error.ToString();
                    Result.ErrorCode = error.HResult;
                }
                finally { complete = true; }
            });
        }

        private void Wait(Windows.Foundation.IAsyncInfo operation)
        {
            while (operation.Status == Windows.Foundation.AsyncStatus.Started) {
                if (cancellationRequested) { operation.Cancel(); throw new OperationCanceledException(); }
                System.Threading.Thread.Sleep(50);
            }
            if (cancellationRequested) throw new OperationCanceledException();
        }

        private void Execute(string id, string directory, bool install, bool prepareOnly)
        {
            var manager = Create<PackageManager>("C53A4F16-787E-42A4-B304-29EFFB4BF597", "B375E3B9-F2E0-5C93-87A7-B67497F7E593");
            NativeInterop.AllowForeground(manager);
            var connectOperation = manager.GetPackageCatalogByName("winget").ConnectAsync();
            Wait(connectOperation);
            var connection = connectOperation.GetResults();
            if (connection.Status != ConnectResultStatus.Ok) throw new Exception("Catalog connection: " + connection.Status);
            var filter = Create<PackageMatchFilter>("D02C9DAF-99DC-429C-B503-4E504E4AB000", "D981ECA3-4DE5-5AD7-967A-698C7D60FC3B");
            filter.Field = PackageMatchField.Id;
            filter.Option = PackageFieldMatchOption.EqualsCaseInsensitive;
            filter.Value = id;
            var find = Create<FindPackagesOptions>("572DED96-9C60-4526-8F92-EE7D91D38C1A", "A5270EDD-7DA7-57A3-BACE-F2593553561F");
            find.Filters.Add(filter);
            var matches = connection.PackageCatalog.FindPackages(find);
            if (matches.Status != FindPackagesResultStatus.Ok || matches.Matches.Count != 1)
                throw new Exception("Expected one package match; found " + matches.Matches.Count + " (status: " + matches.Status + ").");
            var package = matches.Matches[0].CatalogPackage;

            if (install) {
                var options = Create<InstallOptions>("1095F097-EB96-453B-B4E6-1613637F3B14", "6EE9DB69-AB48-5E72-A474-33A924CD23B3");
                options.PackageInstallMode = PackageInstallMode.Default;
                options.AllowHashMismatch = false;
                options.AcceptPackageAgreements = true;
                if (prepareOnly) {
                    Result.Status = package.DefaultInstallVersion != null && package.DefaultInstallVersion.HasApplicableInstaller(options) ? "Prepared" : "NoApplicableInstaller";
                    Result.Message = "Mode=" + options.PackageInstallMode + "; AllowHashMismatch=" + options.AllowHashMismatch + "; AcceptPackageAgreements=" + options.AcceptPackageAgreements + "; SkipDependencies=" + options.SkipDependencies;
                    return;
                }
                if (cancellationRequested) throw new OperationCanceledException();
                Result.InstallationStarted = true;
                var operation = manager.InstallPackageAsync(package, options);
                if (NativeInterop.EnableProgress) operation.Progress = (sender, progress) => Progress.Enqueue(new ProgressUpdate {
                    State = progress.State.ToString(),
                    Percent = progress.State == PackageInstallProgressState.Downloading && progress.BytesRequired > 0 ? progress.DownloadProgress * 100 : -1,
                    BytesDownloaded = progress.BytesDownloaded, BytesRequired = progress.BytesRequired
                });
                Wait(operation);
                var result = operation.GetResults();
                Result.Status = result.Status.ToString();
                Result.ErrorCode = result.ExtendedErrorCode == null ? 0 : result.ExtendedErrorCode.HResult;
                Result.InstallerErrorCode = result.InstallerErrorCode;
                Result.RebootRequired = result.RebootRequired;
            } else {
                var options = Create<DownloadOptions>("4CBABE76-7322-4BE4-9CEA-2589A80682DC", "94C92C4B-43F5-5CA3-BBBE-9F432C9546BC");
                options.DownloadDirectory = directory;
                options.SkipDependencies = true;
                options.AcceptPackageAgreements = true;
                options.AllowHashMismatch = false;
                var operation = manager.DownloadPackageAsync(package, options);
                if (NativeInterop.EnableProgress) operation.Progress = (sender, progress) => Progress.Enqueue(new ProgressUpdate {
                    State = progress.State.ToString(), Percent = progress.BytesRequired > 0 ? progress.DownloadProgress * 100 : -1,
                    BytesDownloaded = progress.BytesDownloaded, BytesRequired = progress.BytesRequired
                });
                Wait(operation);
                var result = operation.GetResults();
                Result.Status = result.Status.ToString();
                Result.ErrorCode = result.ExtendedErrorCode == null ? 0 : result.ExtendedErrorCode.HResult;
            }
        }
    }
}
'@

$nativeSource = @'
using System;
using System.Runtime.InteropServices;
namespace Atom.WinGet
{
    public static class NativeInterop
    {
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern IntPtr LoadLibrary(string path);
        [DllImport("winrtact.dll", EntryPoint = "WinGetServerManualActivation_CreateInstance", ExactSpelling = true)]
        private static extern int ManualActivation([In, MarshalAs(UnmanagedType.LPStruct)] Guid clsid, [In, MarshalAs(UnmanagedType.LPStruct)] Guid iid, uint flags, [MarshalAs(UnmanagedType.IUnknown)] out object instance);
        [DllImport("ole32.dll")]
        private static extern int CoInitializeEx(IntPtr reserved, uint mode);
        [DllImport("ole32.dll")]
        private static extern void CoUninitialize();
        [DllImport("ole32.dll", ExactSpelling = true)]
        private static extern int CoAllowSetForegroundWindow([MarshalAs(UnmanagedType.IUnknown)] object instance, IntPtr reserved);
        public static void AllowForeground(object manager) { CoAllowSetForegroundWindow(manager, IntPtr.Zero); }
        public static bool EnableProgress = true;
        public static bool Initialized { get; private set; }
        public static object Activate(string classId, string interfaceId)
        {
            var clsid = new Guid(classId);
            var admin = new System.Security.Principal.WindowsPrincipal(System.Security.Principal.WindowsIdentity.GetCurrent()).IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);
            if (!admin) return Activator.CreateInstance(Type.GetTypeFromCLSID(clsid));
            var iid = new Guid(interfaceId);
            object instance;
            int initialized = CoInitializeEx(IntPtr.Zero, 0);
            try {
                int error = ManualActivation(clsid, iid, 0, out instance);
                if (error < 0) Marshal.ThrowExceptionForHR(error);
                return instance;
            } finally { if (initialized >= 0) CoUninitialize(); }
        }
        [DllImport("winrtact.dll", EntryPoint = "winrtact_Initialize", ExactSpelling = true)]
        private static extern void InitializeNative();
        public static void Initialize(string directory)
        {
            if (LoadLibrary(System.IO.Path.Combine(directory, "winrtact.dll")) == IntPtr.Zero)
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
            InitializeNative();
            Initialized = true;
        }
    }

}
'@

$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -ne 'Desktop') { throw 'Build using Windows PowerShell 5.1.' }
$buildPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../../Programs/Development/WinGetBuild'))
[void][IO.Directory]::CreateDirectory($buildPath)
foreach ($package in @(
    @{ Name = 'Client'; Url = "https://www.powershellgallery.com/api/v2/package/Microsoft.WinGet.Client/$WinGetVersion" },
    @{ Name = 'Contracts'; Url = "https://api.nuget.org/v3-flatcontainer/microsoft.windows.sdk.contracts/$SdkVersion/microsoft.windows.sdk.contracts.$SdkVersion.nupkg" }
)) {
    $directory = Join-Path $buildPath "$($package.Name)-$(if ($package.Name -eq 'Client') { $WinGetVersion } else { $SdkVersion })"
    if (![IO.Directory]::Exists($directory)) {
        $zip = "$directory.zip"
        Invoke-WebRequest -Uri $package.Url -OutFile $zip -UseBasicParsing -UserAgent 'PowerShellGet/2.2.5'
        Expand-Archive -LiteralPath $zip -DestinationPath $directory
    }
    if ($package.Name -eq 'Client') { $client = $directory } else { $contracts = $directory }
}
$stage = Join-Path $buildPath ('Stage-' + [Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($stage)
[IO.File]::WriteAllText((Join-Path $stage 'WinGetAdapter.cs'), $adapterSource)
[IO.File]::WriteAllText((Join-Path $stage 'NativeInterop.cs'), $nativeSource)
$framework = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
$metadata = Join-Path $client 'net48/SharedDependencies/x64/Microsoft.Management.Deployment.winmd'
$runtime = Join-Path $framework 'System.Runtime.WindowsRuntime.dll'
$facade = (Get-ChildItem "$env:WINDIR/Microsoft.NET/assembly/GAC_MSIL/System.Runtime" -Recurse -Filter System.Runtime.dll | Select-Object -First 1).FullName
$interop = (Get-ChildItem "$env:WINDIR/Microsoft.NET/assembly/GAC_MSIL/System.Runtime.InteropServices.WindowsRuntime" -Recurse -Filter System.Runtime.InteropServices.WindowsRuntime.dll | Select-Object -First 1).FullName
$foundation = Join-Path $contracts 'ref/netstandard2.0/Windows.Foundation.FoundationContract.winmd'
$dll = Join-Path $stage 'WinGetAdapter.dll'
& (Join-Path $framework 'csc.exe') /nologo /target:library "/out:$dll" "/reference:$metadata" "/reference:$runtime" /reference:System.Core.dll "/reference:$foundation" "/reference:$facade" "/reference:$interop" (Join-Path $stage 'WinGetAdapter.cs') (Join-Path $stage 'NativeInterop.cs')
if ($LASTEXITCODE -ne 0) { throw 'WinGet adapter compilation failed.' }
foreach ($architecture in 'x64','x86','arm64') {
    $target = Join-Path $stage $architecture
    [void][IO.Directory]::CreateDirectory($target)
    foreach ($name in 'Microsoft.Management.Deployment.winmd','winrtact.dll') {
        Copy-Item -LiteralPath (Join-Path $client "net48/SharedDependencies/$architecture/$name") -Destination $target
    }
    $signature = Get-AuthenticodeSignature -LiteralPath (Join-Path $target 'winrtact.dll')
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'O=Microsoft Corporation') {
        throw "Microsoft activation DLL signature validation failed: $architecture"
    }
}
$response = Invoke-WebRequest "https://raw.githubusercontent.com/microsoft/winget-cli/v$WinGetVersion/LICENSE" -UseBasicParsing
$license = if ($response.Content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($response.Content) } else { $response.Content }
[IO.File]::WriteAllText((Join-Path $stage 'LICENSE-Microsoft-WinGet.txt'), $license)
Copy-Item -LiteralPath (Join-Path $client 'NOTICE.txt') -Destination $stage
$files = @(Get-ChildItem -LiteralPath $stage -Recurse -File | Where-Object Extension -ne '.cs' | ForEach-Object {
    @{ Path = $_.FullName.Substring($stage.Length+1).Replace('\','/'); SHA256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
})
@{ WinGetVersion = $WinGetVersion; Files = $files } | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $stage 'manifest.json')
Compress-Archive -Path @((Get-ChildItem -LiteralPath $stage | Where-Object Extension -ne '.cs').FullName) -DestinationPath (Join-Path $PSScriptRoot 'WinGetAdapter.zip') -Force
Get-Item (Join-Path $PSScriptRoot 'WinGetAdapter.zip') | Select-Object Name,Length

