param (
    [String]$DestinationPath,
    [String]$AtomRoot,
    [System.Collections.IDictionary]$ProgressState,
    [Switch]$ResolveVersionOnly
)

function Write-AtomPeFileAtomic {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [String]$Path,
        [Parameter(Mandatory)] [AllowEmptyString()] [String]$Content,
        [Text.Encoding]$Encoding = [Text.UTF8Encoding]::new($false)
    )

    $path = [IO.Path]::GetFullPath($Path)
    $parent = Split-Path -Parent $path
    if (!(Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -Path $parent -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }
    $temporaryPath = Join-Path $parent ('.{0}.{1}.tmp' -f [IO.Path]::GetFileName($path), [Guid]::NewGuid().ToString('N'))
    try {
        [IO.File]::WriteAllText($temporaryPath, $Content, $Encoding)
        Move-Item -LiteralPath $temporaryPath -Destination $path -Force -ErrorAction Stop
    } finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
        }
    }
}







function Expand-AtomPeComponents {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$ResourcePath,

        [Parameter(Mandatory)]
        [Object]$Resources,

        [System.Collections.IDictionary]$ProgressState
    )

    $resourcePath = [IO.Path]::GetFullPath($ResourcePath)
        $version = $Resources.Version
        $targetRoot = Join-Path $resourcePath "PortableTools\$version"
        $kitRoot = Join-Path $targetRoot 'Windows Kits\10\Assessment and Deployment Kit'
        $adkInstallerRoot = Join-Path $resourcePath 'Cache\Offline\ADK\Installers'
        $winPeInstallerRoot = Join-Path $resourcePath 'Cache\Offline\WinPE-Addon\Installers'
        $packages = @(
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Kits Configuration Installer-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Windows Deployment Tools Environment-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Windows Deployment Tools-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Windows Deployment Image Servicing and Management Tools (DesktopEditions)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Windows Deployment Image Servicing and Management Tools (OnecoreUAP)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'BCD and Boot-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Oscdimg (DesktopEditions)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Oscdimg (OnecoreUAP)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $adkInstallerRoot; Name = 'Windows Deployment Customizations-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $winPeInstallerRoot; Name = 'Kits Configuration Installer-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $winPeInstallerRoot; Name = 'Windows PE Scripts-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $winPeInstallerRoot; Name = 'Windows PE Boot Files (DesktopEditions)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $winPeInstallerRoot; Name = 'Windows PE Boot Files (OnecoreUAP)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $winPeInstallerRoot; Name = 'Windows PE wims (DesktopEditions)-x86_en-us.msi' }
            [PSCustomObject]@{ Root = $winPeInstallerRoot; Name = 'Windows PE Optional Packages (DesktopEditions)-x86_en-us.msi' }
        )
        New-Item -Path $targetRoot -ItemType Directory -Force -ErrorAction Stop | Out-Null
        $logRoot = Join-Path $targetRoot 'Extraction Logs'
        New-Item -Path $logRoot -ItemType Directory -Force -ErrorAction Stop | Out-Null
        $packageIndex = 0
        foreach ($package in $packages) {
            $packageIndex++
            $msi = Join-Path $package.Root $package.Name
            if (!(Test-Path -LiteralPath $msi -PathType Leaf)) { throw "Required offline package is missing: '$msi'." }
            $signature = Get-AuthenticodeSignature -LiteralPath $msi
            if ($signature.Status -ne [Management.Automation.SignatureStatus]::Valid -or
                $signature.SignerCertificate.Subject -notmatch '(?i)(?:^|,)\s*O=Microsoft Corporation(?:,|$)') {
                throw "Microsoft signature verification failed for '$msi'."
            }
            if ($ProgressState) {
                $ProgressState.Status = "Extracting $($package.Name)"
                $ProgressState.TotalBytes = $null
                $ProgressState.PercentComplete = 30 + [Math]::Round(30 * $packageIndex / $packages.Count)
            }
            $log = Join-Path $logRoot (($package.Name -replace '[^A-Za-z0-9.-]', '_') + '.log')
            $process = Start-Process msiexec.exe -ArgumentList @('/a', ('"{0}"' -f $msi), '/qn', ('TARGETDIR="{0}"' -f $targetRoot), '/norestart', '/l*v', ('"{0}"' -f $log)) `
                -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop
            if ($process.ExitCode -notin 0, 3010) { throw "Package extraction failed for '$($package.Name)' with exit code $($process.ExitCode)." }
        }
    $requiredTools = @(
        'Deployment Tools\amd64\Oscdimg\oscdimg.exe'
        'Windows Preinstallation Environment\amd64\en-us\winpe.wim'
        'Windows Preinstallation Environment\amd64\Media\Boot\boot.sdi'
    )
    foreach ($relativePath in $requiredTools) {
        if (!(Test-Path -LiteralPath (Join-Path $kitRoot $relativePath) -PathType Leaf)) {
            throw "Portable preparation completed, but '$relativePath' was not found."
        }
    }
    $metadata = [ordered]@{
        Version       = $version
        RootPath      = $targetRoot
        KitRoot       = $kitRoot
    }
    [PSCustomObject]$metadata
}

function New-AtomWindowsPeImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$ResourcePath,

        [Parameter(Mandatory)]
        [String]$AtomRoot,

        [Parameter(Mandatory)]
        [Object]$Tools,

        [System.Collections.IDictionary]$ProgressState
    )

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    if (!([Security.Principal.WindowsPrincipal]::new($identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        throw 'Building the Windows PE image requires administrator access.'
    }

    $resourcePath = [IO.Path]::GetFullPath($ResourcePath)
    $atomRoot = [IO.Path]::GetFullPath($AtomRoot)
    $tools = $Tools
    foreach ($required in 'ATOM.bat', 'ATOM\ATOM.ps1', 'Programs\PowerShell Core_x64\powershell.exe') {
        if (!(Test-Path -LiteralPath (Join-Path $atomRoot $required) -PathType Leaf)) { throw "ATOM is missing '$required'. Download PowerShell Core in Download Mode before building the image." }
    }

    $peRoot = Join-Path $tools.KitRoot 'Windows Preinstallation Environment\amd64'
    $sourceWim = Join-Path $peRoot 'en-us\winpe.wim'
    $sourceMedia = Join-Path $peRoot 'Media'
    $startupScript = @'
@echo off
setlocal EnableExtensions
set "ATOM_LOG=%SystemRoot%\Temp\ATOM-PE-Startup.log"
echo Searching for the ATOM drive...>"%ATOM_LOG%"
for /l %%R in (1,1,20) do (
  for %%D in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do (
    if exist "%%D:\ATOM.bat" if exist "%%D:\ATOM\ATOM.ps1" (
      if exist "%%D:\Programs\PowerShell Core_x64\powershell.exe" (
        set "ATOM_DRIVE=%%D:"
        goto :found
      )
    )
  )
  >nul 2>&1 ping -n 2 127.0.0.1
)
echo ATOM was not found. Keep this window open for troubleshooting.>>"%ATOM_LOG%"
echo ATOM was not found on a tagged drive.
echo.
type "%ATOM_LOG%"
echo.
echo The startup command prompt will remain open for troubleshooting.
cmd.exe /k
exit /b 1
:found
echo Found ATOM on %ATOM_DRIVE%.>>"%ATOM_LOG%"
if not exist "%ATOM_DRIVE%\ATOM\Logs" mkdir "%ATOM_DRIVE%\ATOM\Logs" >nul 2>&1
copy /y "%ATOM_LOG%" "%ATOM_DRIVE%\ATOM\Logs\Windows PE Startup.log" >nul 2>&1
echo Launching ATOM asynchronously in a persistent command shell...>>"%ATOM_LOG%"
start "ATOM" /D "%ATOM_DRIVE%\" cmd.exe /d /k ATOM.bat
set "ATOM_START_CODE=%ERRORLEVEL%"
echo START returned exit code %ATOM_START_CODE%.>>"%ATOM_LOG%"
copy /y "%ATOM_LOG%" "%ATOM_DRIVE%\ATOM\Logs\Windows PE Startup.log" >nul 2>&1
echo.
echo ==================== ATOM Windows PE startup log ====================
type "%ATOM_LOG%"
echo ====================================================================
echo.
echo ATOM was launched in a separate command shell.
echo Press any key only when you are ready to enter the PE troubleshooting prompt.
echo Log: %ATOM_DRIVE%\ATOM\Logs\Windows PE Startup.log
pause >nul
cmd.exe /k
'@
    $sha256 = [Security.Cryptography.SHA256]::Create()
    try { $startupHash = ([BitConverter]::ToString($sha256.ComputeHash([Text.Encoding]::UTF8.GetBytes($startupScript)))).Replace('-', '') } finally { $sha256.Dispose() }
    $sourceHash = (Get-FileHash -LiteralPath $sourceWim -Algorithm SHA256).Hash
    $workRoot = Join-Path ([IO.Path]::GetTempPath()) "ATOM-WinPE-$([Guid]::NewGuid().ToString('N'))"
    $mountPath = Join-Path $workRoot 'Mount'
    $workingWim = Join-Path $workRoot 'boot.wim'
    $targetRoot = Join-Path (Join-Path $resourcePath 'Media') $tools.Version
    $targetMedia = Join-Path $targetRoot 'Media'
    $dism = Join-Path $env:SystemRoot 'System32\dism.exe'
    $mounted = $false
    function Invoke-AtomDism([String[]]$Arguments) {
        & $dism @Arguments
        if ($LASTEXITCODE -ne 0) { throw "DISM failed with exit code $LASTEXITCODE." }
    }
    try {
        New-Item -Path $mountPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Copy-Item -LiteralPath $sourceWim -Destination $workingWim -Force -ErrorAction Stop
        Invoke-AtomDism @('/Mount-Image', "/ImageFile:$workingWim", '/Index:1', "/MountDir:$mountPath", '/Optimize')
        $mounted = $true

        # Add Microsoft WinPE optional components in dependency order. PowerShell
        # Core remains ATOM's host, while these packages provide the underlying
        # WMI, storage, BitLocker, scripting, HTA, and desktop compatibility APIs.
        $optionalComponentRoot = Join-Path $peRoot 'WinPE_OCs'
        $optionalComponents = @(
            'WinPE-WMI.cab'
            'en-us\WinPE-WMI_en-us.cab'
            'WinPE-SecureStartup.cab'
            'en-us\WinPE-SecureStartup_en-us.cab'
            'WinPE-NetFx.cab'
            'en-us\WinPE-NetFx_en-us.cab'
            'WinPE-Scripting.cab'
            'en-us\WinPE-Scripting_en-us.cab'
            'WinPE-PowerShell.cab'
            'en-us\WinPE-PowerShell_en-us.cab'
            'WinPE-StorageWMI.cab'
            'en-us\WinPE-StorageWMI_en-us.cab'
            'WinPE-HTA.cab'
            'en-us\WinPE-HTA_en-us.cab'
        )
        $optionalComponentPaths = foreach ($relativePath in $optionalComponents) {
            $componentPath = Join-Path $optionalComponentRoot $relativePath
            if (!(Test-Path -LiteralPath $componentPath -PathType Leaf)) {
                throw "Required WinPE optional component '$relativePath' was not found."
            }
            $componentPath
        }
        if ($ProgressState) {
            $ProgressState.Status = 'Adding Windows PE optional components'
            $ProgressState.PercentComplete = 62
        }
        $addPackageArguments = @('/Add-Package', "/Image:$mountPath") + @(
            $optionalComponentPaths | ForEach-Object { "/PackagePath:$_" }
        )
        Invoke-AtomDism $addPackageArguments

        $system32 = Join-Path $mountPath 'Windows\System32'
        # Some valuable portable utilities import desktop compatibility DLLs
        # that Microsoft omits from every WinPE optional component. Use only
        # host files from the same Windows build as the selected WinPE release.
        $peBuild = ([Version]$tools.Version).Build
        $compatibilityFiles = @()
        foreach ($compatibilityDll in 'shfolder.dll', 'rstrtmgr.dll', 'ddraw.dll', 'msi.dll') {
            $sourceDll = Join-Path $env:SystemRoot "System32\$compatibilityDll"
            if (!(Test-Path -LiteralPath $sourceDll -PathType Leaf)) { continue }
            $fileVersion = (Get-Item -LiteralPath $sourceDll).VersionInfo.FileVersion
            $sourceBuild = if ($fileVersion -match '^\d+\.\d+\.(\d+)\.') { [Int32]$Matches[1] } else { 0 }
            if ($sourceBuild -eq $peBuild) {
                Copy-Item -LiteralPath $sourceDll -Destination (Join-Path $system32 $compatibilityDll) -Force -ErrorAction Stop
                $compatibilityFiles += [ordered]@{
                    Name = $compatibilityDll
                    Version = $fileVersion
                    Sha256 = (Get-FileHash -LiteralPath $sourceDll -Algorithm SHA256).Hash
                }
            }
        }
        Write-AtomPeFileAtomic -Path (Join-Path $system32 'StartAtom.cmd') -Content $startupScript -Encoding ([Text.ASCIIEncoding]::new())
        $startnetPath = Join-Path $system32 'startnet.cmd'
        $startnet = if (Test-Path -LiteralPath $startnetPath) { Get-Content -LiteralPath $startnetPath -Raw } else { "wpeinit`r`n" }
        if ($startnet -notmatch '(?im)^\s*call\s+%SystemRoot%\\System32\\StartAtom\.cmd\s*$') {
            $startnet = $startnet.TrimEnd() + "`r`ncall %SystemRoot%\System32\StartAtom.cmd`r`n"
            Write-AtomPeFileAtomic -Path $startnetPath -Content $startnet -Encoding ([Text.ASCIIEncoding]::new())
        }
        Invoke-AtomDism @('/Unmount-Image', "/MountDir:$mountPath", '/Commit')
        $mounted = $false

        if (Test-Path -LiteralPath $targetRoot) { Remove-Item -LiteralPath $targetRoot -Recurse -Force -ErrorAction Stop }
        New-Item -Path $targetMedia -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Copy-Item -Path (Join-Path $sourceMedia '*') -Destination $targetMedia -Recurse -Force -ErrorAction Stop
        New-Item -Path (Join-Path $targetMedia 'sources') -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Copy-Item -LiteralPath $workingWim -Destination (Join-Path $targetRoot 'ATOM-Base.wim') -Force -ErrorAction Stop
        Copy-Item -LiteralPath $workingWim -Destination (Join-Path $targetMedia 'sources\boot.wim') -Force -ErrorAction Stop
        $imageHash = (Get-FileHash -LiteralPath (Join-Path $targetRoot 'ATOM-Base.wim') -Algorithm SHA256).Hash
        $metadata = [ordered]@{ Version=$tools.Version; Prepared=(Get-Date).ToUniversalTime().ToString('o'); SourceWimHash=$sourceHash; StartupHash=$startupHash; ImageSha256=$imageHash }
        Write-AtomPeFileAtomic -Path (Join-Path $targetRoot 'atom-pe-image.json') -Content ($metadata | ConvertTo-Json)
        return [PSCustomObject]@{
            Version = $tools.Version
            RootPath = $targetRoot
            ImagePath = Join-Path $targetRoot 'ATOM-Base.wim'
            MediaRoot = $targetMedia
            SourceWimHash = $sourceHash
            StartupHash = $startupHash
            CompatibilityFiles = $compatibilityFiles
        }
    } finally {
        if ($mounted) { & $dism '/Unmount-Image' "/MountDir:$mountPath" '/Discard' | Out-Null }
        if (Test-Path -LiteralPath $workRoot) { Remove-Item -LiteralPath $workRoot -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function New-AtomWindowsPeIso {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [Object]$Image,
        [Parameter(Mandatory)] [Object]$Tools,
        [Switch]$Force
    )

    $image = $Image
    $tools = $Tools

    $oscdimgRoot = Join-Path $tools.KitRoot 'Deployment Tools\amd64\Oscdimg'
    $oscdimg = Join-Path $oscdimgRoot 'oscdimg.exe'
    $biosBoot = Join-Path $oscdimgRoot 'etfsboot.com'
    $uefiBoot = Join-Path $oscdimgRoot 'efisys.bin'
    foreach ($path in $oscdimg,$biosBoot,$uefiBoot) {
        if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required ISO component '$path' was not found." }
    }

    $isoPath = Join-Path $image.RootPath "ATOM-WindowsPE-$($image.Version).iso"
    if ((Test-Path -LiteralPath $isoPath -PathType Leaf) -and !$Force) { return Get-Item -LiteralPath $isoPath }
    $temporaryIso = Join-Path $image.RootPath ".$([IO.Path]::GetFileNameWithoutExtension($isoPath)).$([Guid]::NewGuid().ToString('N')).iso"
    try {
        # PowerShell passes this as one argument, so embedded command-shell quotes
        # would become literal characters and break OSCDIMG's boot-file paths.
        $bootData = "-bootdata:2#p0,e,b$biosBoot#pEF,e,b$uefiBoot"
        $savedErrorActionPreference = $ErrorActionPreference
        $hasNativePreference = Test-Path Variable:PSNativeCommandUseErrorActionPreference
        if ($hasNativePreference) { $savedNativePreference = $PSNativeCommandUseErrorActionPreference }
        try {
            # OSCDIMG writes ordinary progress (including "0% complete") to a
            # native stream that PowerShell 7 can promote to an ErrorRecord.
            # Its process exit code and output file are the authoritative result.
            $ErrorActionPreference = 'Continue'
            if ($hasNativePreference) { $PSNativeCommandUseErrorActionPreference = $false }
            & $oscdimg $bootData '-u1' '-udfver102' '-m' '-o' $image.MediaRoot $temporaryIso 2>&1 | Out-Null
            $oscdimgExitCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $savedErrorActionPreference
            if ($hasNativePreference) { $PSNativeCommandUseErrorActionPreference = $savedNativePreference }
        }
        if ($oscdimgExitCode -ne 0 -or !(Test-Path -LiteralPath $temporaryIso -PathType Leaf)) { throw "OSCDIMG failed with exit code $oscdimgExitCode." }
        Move-Item -LiteralPath $temporaryIso -Destination $isoPath -Force -ErrorAction Stop
        return Get-Item -LiteralPath $isoPath
    } finally {
        if (Test-Path -LiteralPath $temporaryIso) { Remove-Item -LiteralPath $temporaryIso -Force -ErrorAction SilentlyContinue }
    }
}

function Resolve-WindowsPeResources {
    <#
    .SYNOPSIS
    Resolves Microsoft's current mainstream AMD64 ADK and WinPE installers.

    .DESCRIPTION
    Reads Microsoft's maintained ADK download page, ignores architecture-
    specific Arm64-only releases, and returns the highest compatible version
    that publishes both the ADK and matching WinPE add-on bootstrap links.
    #>
    [CmdletBinding()]
    param (
        [String]$SourceUri = 'https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install'
    )

    try {
        $response = Invoke-WebRequest -Uri $SourceUri -UseBasicParsing -ErrorAction Stop
    } catch {
        throw "Unable to read Microsoft's ADK download page: $($_.Exception.Message)"
    }

    $sections = [regex]::Matches(
        $response.Content,
        '(?is)<h2[^>]*>\s*Download the ADK\s+(?<Version>10\.1\.\d+(?:\.\d+)?)[^<]*</h2>(?<Body>.*?)(?=<h2|$)'
    )
    $candidates = foreach ($section in $sections) {
        $bodyText = [Net.WebUtility]::HtmlDecode(([regex]::Replace($section.Groups['Body'].Value, '<[^>]+>', ' ')))
        if ($bodyText -match '(?i)supports?\s+(?:the following OS release:\s*)?Windows 11[^.]*Arm64' -or
            $bodyText -match '(?i)26H\d+\s+Arm64') {
            continue
        }

        $links = [regex]::Matches($section.Groups['Body'].Value, '(?is)<a\s+[^>]*href="(?<Href>[^"]+)"[^>]*>(?<Text>.*?)</a>')
        $adkLink = $links | Where-Object {
            ([regex]::Replace($_.Groups['Text'].Value, '<[^>]+>', ' ') -match '(?i)^\s*Download (?:the )?(?:Windows )?ADK\b') -and
            ([regex]::Replace($_.Groups['Text'].Value, '<[^>]+>', ' ') -notmatch '(?i)Windows PE')
        } | Select-Object -First 1
        $winPeLink = $links | Where-Object {
            [regex]::Replace($_.Groups['Text'].Value, '<[^>]+>', ' ') -match '(?i)Download the Windows PE add-on'
        } | Select-Object -First 1
        if (!$adkLink -or !$winPeLink) { continue }

        [PSCustomObject]@{
            Version  = [Version]$section.Groups['Version'].Value
            AdkUri   = [Net.WebUtility]::HtmlDecode($adkLink.Groups['Href'].Value)
            WinPeUri = [Net.WebUtility]::HtmlDecode($winPeLink.Groups['Href'].Value)
        }
    }

    $selected = $candidates | Sort-Object Version -Descending | Select-Object -First 1
    if (!$selected) {
        throw "Microsoft's ADK download page did not contain a compatible ADK and WinPE add-on pair."
    }

    [PSCustomObject]@{
        Version   = $selected.Version.ToString()
        AdkUri    = $selected.AdkUri
        WinPeUri  = $selected.WinPeUri
        SourceUri = $SourceUri
        Resolved  = [DateTime]::UtcNow.ToString('o')
    }
}

function Save-WindowsPeOfflineLayouts {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$ResourcePath,

        [Parameter(Mandatory)]
        [Object]$Resources,

        [System.Collections.IDictionary]$ProgressState
    )

    $resourcePath = [IO.Path]::GetFullPath($ResourcePath)
    $definitions = @(
        [ordered]@{ Name = 'Windows ADK'; Bootstrap = 'Cache\adksetup.exe'; Destination = 'Cache\Offline\ADK' }
        [ordered]@{ Name = 'Windows PE add-on'; Bootstrap = 'Cache\adkwinpesetup.exe'; Destination = 'Cache\Offline\WinPE-Addon' }
    )
    $results = foreach ($definition in $definitions) {
        $bootstrap = Join-Path $resourcePath $definition.Bootstrap
        $destination = Join-Path $resourcePath $definition.Destination
        if (!(Test-Path -LiteralPath $bootstrap -PathType Leaf)) { throw "Missing bootstrap installer: '$bootstrap'." }
        $signature = Get-AuthenticodeSignature -LiteralPath $bootstrap
        if ($signature.Status -ne [Management.Automation.SignatureStatus]::Valid -or
            $signature.SignerCertificate.Subject -notmatch '(?i)(?:^|,)\s*O=Microsoft Corporation(?:,|$)') {
            throw "Microsoft signature verification failed for '$bootstrap'."
        }
        $manifestPath = Join-Path $destination 'UserExperienceManifest.xml'
        $layoutVersion = if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
            try { ([xml](Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop)).UserExperienceManifest.Settings.ProductVersion } catch { $null }
        }
        $complete = (Test-Path -LiteralPath (Join-Path $destination 'Installers') -PathType Container) -and
            $layoutVersion -eq $Resources.Version
        if (!$complete) {
            if (Test-Path -LiteralPath $destination) {
                throw "The cached $($definition.Name) layout is version '$layoutVersion', but version '$($Resources.Version)' is required."
            }
            if ($ProgressState) { $ProgressState.Status = "Downloading $($definition.Name) offline packages" }
            New-Item -Path $destination -ItemType Directory -Force -ErrorAction Stop | Out-Null
            $process = Start-Process -FilePath $bootstrap -ArgumentList @('/quiet', '/layout', ('"{0}"' -f $destination)) `
                -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop
            if ($process.ExitCode -notin 0, 3010) {
                throw "$($definition.Name) offline download failed with exit code $($process.ExitCode)."
            }
        }
        [ordered]@{ Name = $definition.Name; Path = $destination }
    }

    $metadata = [ordered]@{
        Schema    = 1
        Version   = $Resources.Version
        Downloaded= [DateTime]::UtcNow.ToString('o')
        Layouts   = @($results)
    }
    [PSCustomObject]$metadata
}

function Save-WindowsPeResources {
    <#
    .SYNOPSIS
    Downloads and verifies the Microsoft bootstrap resources used for WinPE.

    .DESCRIPTION
    Resolves a matching ADK/WinPE pair from Microsoft Learn, downloads each
    named resource, validates its Microsoft Authenticode signature, and writes
    a metadata manifest. The named Downloads collection avoids the ambiguity
    of treating multiple unrelated URLs as one program download.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$DestinationPath,

        [System.Collections.IDictionary]$ProgressState
    )

    foreach ($functionName in 'Copy-WebItem') {
        if (!(Get-Command $functionName -CommandType Function -ErrorAction SilentlyContinue)) {
            . (Join-Path $script:AtomPeGlobalFunctionRoot "$functionName.ps1")
        }
    }

    $destinationPath = [IO.Path]::GetFullPath($DestinationPath)
    $cachePath = Join-Path $destinationPath 'Cache'
    if (!(Test-Path -LiteralPath $cachePath -PathType Container)) {
        New-Item -Path $cachePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    if ($ProgressState) { $ProgressState.Status = 'Resolving Microsoft resources' }
    $resolved = Resolve-WindowsPeResources -ErrorAction Stop
    $downloads = @(
        [ordered]@{ Name = 'Windows ADK';      Uri = $resolved.AdkUri;   FileName = 'adksetup.exe' }
        [ordered]@{ Name = 'Windows PE add-on'; Uri = $resolved.WinPeUri; FileName = 'adkwinpesetup.exe' }
    )

    $downloadedResources = foreach ($download in $downloads) {
        if ($ProgressState) { $ProgressState.Status = "Downloading $($download.Name)" }
        $file = Copy-WebItem -Uri $download.Uri -OutFile (Join-Path $cachePath $download.FileName) -ProgressState $ProgressState -ErrorAction Stop
        $signature = Get-AuthenticodeSignature -LiteralPath $file.FullName
        if ($signature.Status -ne [Management.Automation.SignatureStatus]::Valid -or
            $signature.SignerCertificate.Subject -notmatch '(?i)(?:^|,)\s*O=Microsoft Corporation(?:,|$)') {
            Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
            throw "Microsoft signature verification failed for '$($download.FileName)': $($signature.StatusMessage)"
        }

        [ordered]@{
            Name     = $download.Name
            FileName = $download.FileName
            Uri      = $download.Uri
            Bytes    = $file.Length
            Sha256   = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            Signer   = $signature.SignerCertificate.Subject
        }
    }

    $metadata = [ordered]@{
        Schema    = 1
        Version   = $resolved.Version
        Resolved  = $resolved.Resolved
        SourceUri = $resolved.SourceUri
        Downloads = @($downloadedResources)
    }
    if ($ProgressState) {
        $ProgressState.Status = 'Microsoft bootstrap files ready'
        $ProgressState.Version = $resolved.Version
    }
    [PSCustomObject]$metadata
}



$ErrorActionPreference = 'Stop'
$script:AtomPeGlobalFunctionRoot = Join-Path $PSScriptRoot '..\Functions'
if ($ResolveVersionOnly) {
    "$((Resolve-WindowsPeResources).Version)+atompe6"
    return
}
if (!$DestinationPath -or !$AtomRoot) { throw 'DestinationPath and AtomRoot are required when building Windows PE.' }
$destinationPath = [IO.Path]::GetFullPath($DestinationPath)
$atomRoot = [IO.Path]::GetFullPath($AtomRoot)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Windows PE creation requires ATOM to be running as administrator.'
}

function Set-AtomPePhase ([String]$Status, [Int32]$PercentComplete) {
    if ($ProgressState) {
        $ProgressState.Status = $Status
        $ProgressState.TotalBytes = $null
        $ProgressState.PercentComplete = $PercentComplete
        $ProgressState.LastUpdated = [DateTime]::UtcNow
    }
}

try {
    $portablePowerShell = Join-Path $atomRoot 'Programs\PowerShell Core_x64\powershell.exe'
    if (!(Test-Path -LiteralPath $portablePowerShell -PathType Leaf)) {
        Set-AtomPePhase 'Downloading required PowerShell Core dependency' 2
        if (!$programs -or !$programs['PowerShell Core']) {
            . (Join-Path $atomRoot 'ATOM\Config\Plugins.ps1')
        }
        . (Join-Path $script:AtomPeGlobalFunctionRoot 'Start-Program.ps1')
        $powerShellParams = $programs['PowerShell Core'].ProgramInfo
        Start-Program @powerShellParams -DownloadOnly -ProgressState $ProgressState | Out-Null
    }


    Set-AtomPePhase 'Resolving current Microsoft Windows PE release' 5
    $resources = Save-WindowsPeResources -DestinationPath $destinationPath -ProgressState $ProgressState

    Set-AtomPePhase 'Downloading Microsoft ADK and Windows PE packages' 12
    Save-WindowsPeOfflineLayouts -ResourcePath $destinationPath -Resources $resources -ProgressState $ProgressState | Out-Null
    $tools = Expand-AtomPeComponents -ResourcePath $destinationPath -Resources $resources -ProgressState $ProgressState

    Set-AtomPePhase 'Extracting Windows ADK and Windows PE components' 45
    Set-AtomPePhase 'Customizing the ATOM Windows PE image' 65
    $image = New-AtomWindowsPeImage -ResourcePath $destinationPath -AtomRoot $atomRoot -Tools $tools -ProgressState $ProgressState

    Set-AtomPePhase 'Creating BIOS and UEFI bootable ISO' 82
    $iso = New-AtomWindowsPeIso -Image $image -Tools $tools -Force
    $finalIso = Join-Path $destinationPath 'ATOM-PE.iso'
    Copy-Item -LiteralPath $iso.FullName -Destination $finalIso -Force

    Set-AtomPePhase 'Compacting regeneration components' 94
    $peRoot = Join-Path $tools.KitRoot 'Windows Preinstallation Environment\amd64'
    $oscdimgRoot = Join-Path $tools.KitRoot 'Deployment Tools\amd64\Oscdimg'
    Copy-Item -LiteralPath (Join-Path $peRoot 'en-us\winpe.wim') -Destination (Join-Path $destinationPath 'winpe.wim') -Force
    foreach ($file in 'oscdimg.exe','etfsboot.com','efisys.bin') {
        Copy-Item -LiteralPath (Join-Path $oscdimgRoot $file) -Destination (Join-Path $destinationPath $file) -Force
    }
    $mediaArchive = Join-Path $destinationPath 'media.zip'
    if (Test-Path -LiteralPath $mediaArchive) { Remove-Item -LiteralPath $mediaArchive -Force }
    Compress-Archive -Path (Join-Path $peRoot 'Media\*') -DestinationPath $mediaArchive -CompressionLevel Optimal

    $manifest = [ordered]@{
        Schema = 1
        Version = $image.Version
        CustomizationVersion = 6
        Created = [DateTime]::UtcNow.ToString('o')
        Iso = 'ATOM-PE.iso'
        IsoSha256 = (Get-FileHash -LiteralPath $finalIso -Algorithm SHA256).Hash
        MicrosoftSource = $resources.SourceUri
        CompatibilityFiles = $image.CompatibilityFiles
    }
    Write-AtomPeFileAtomic -Path (Join-Path $destinationPath 'atom-pe.json') -Content ($manifest | ConvertTo-Json -Depth 4)

    foreach ($obsolete in 'Cache','PortableTools','Media') {
        $obsoletePath = Join-Path $destinationPath $obsolete
        if (Test-Path -LiteralPath $obsoletePath) { Remove-Item -LiteralPath $obsoletePath -Recurse -Force -ErrorAction SilentlyContinue }
    }

    if ($ProgressState) {
        $ProgressState.Status = 'Windows PE ISO ready'
        $ProgressState.PercentComplete = 100
        $ProgressState.Version = "$($image.Version)+atompe6"
        $ProgressState.IsCompleted = $true
    }
    Get-Item -LiteralPath $finalIso
} catch {
    if ($ProgressState) {
        $ProgressState.Status = 'Failed'
        $ProgressState.Error = $_.Exception.Message
        $ProgressState.IsCompleted = $true
    }
    throw
}
