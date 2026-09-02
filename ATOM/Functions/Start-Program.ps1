function Start-Program {
    <#
    .SYNOPSIS
    Starts or downloads a program using the specified configuration.

    .DESCRIPTION
    The `Start-Program` function manages program execution by:
    - Locating the program's executable based on configuration paths.
    - Downloading the program from a remote URL if it's not locally available.
    - Extracting the program if it's delivered as a compressed file.
    - Optionally starting the program after performing required setup.

    It supports custom configuration settings, including alternate paths, override logic, credentials, and post-installation actions.

    .PARAMETER DestinationPath
    Specifies the folder where the program’s files are located or where the downloaded zip will be extracted (e.g., 'C:\Programs\Autoruns'). Defaults to the program's configuration or '%temp%\<Program>'. Aliases: Path.

    .PARAMETER RelativePath
    Specifies the relative path to the executable within the destination folder (e.g., 'Autoruns64.exe').
    Wildcards are supported, including in nested versioned folders (e.g., 'ventoy-*\Ventoy2Disk.exe'). Mandatory.

    .PARAMETER Uri
    Specifies the fallback URL when Scoop is defined, or the primary URL otherwise. Optional. Aliases: Url.

    .PARAMETER Scoop
    Specifies a Scoop manifest in bucket/app form. Its current URL is attempted before Uri and its downloaded file is hash-verified.

    .PARAMETER ArgumentList
    A string of arguments to pass when starting the program executable. Optional.

    .PARAMETER ScriptBlock
    A scriptblock which overrides the function's default download & extraction logic.

    .PARAMETER DownloadOnly
    When specified, downloads the program to the specified DestinationPath but does not launch the program afterwards.

    .PARAMETER ProgressState
    Specifies a shared dictionary populated with live file-transfer progress by Copy-WebItem.

    .EXAMPLE
    Start-Program -DestinationPath C:\Programs\Autoruns -RelativePath \Autoruns64.exe -Uri https://download.sysinternals.com/files/Autoruns.zip

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    [System.IO.FileInfo]
    Returns a FileInfo object representing the program.
    
    .NOTES
    Author: Skyler Wallace
    Requires: Internet connectivity for downloading programs if program is not already downloaded.
    #>
    
    [CmdletBinding()]

    param (
        [Alias('Path')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$DestinationPath,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$RelativePath,

        [Alias('Url')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$Uri,

        [String]$Scoop,

        [String]$ArgumentList,

        [String]$UserAgent,

        [ScriptBlock]$ScriptBlock,

        [ScriptBlock]$VersionScriptBlock,

        [Switch]$DownloadOnly,

        [System.Collections.IDictionary]$ProgressState
    )

    begin {
        # Ensure dependent functions are available
        $functions = Get-Command -CommandType Function | Select-Object -Expand Name
        $dependencies = 'Copy-WebItem', 'Resolve-ScoopDownload', 'Copy-ProgramItem', 'Expand-With7z'
        $dependencies | ForEach-Object {
            if ($functions -notcontains $_) {
                $function = "$psScriptRoot\$_.ps1"
                if (Test-Path $function) { . $function }
                else { Write-Error "The $_ function is required but not found."; return }
            }
        }
    }

    process {
        $resolveProgramPath = {
            param ([String]$Root)

            @(Get-Item -Path (Join-Path $Root $RelativePath.TrimStart('\', '/')) -ErrorAction SilentlyContinue |
                Where-Object { !$_.PSIsContainer } |
                Sort-Object FullName -Descending |
                Select-Object -First 1).FullName
        }

        $localDestinationPath = $DestinationPath
        $tempDestinationPath = Join-Path $env:TEMP (Split-Path $DestinationPath -Leaf)
        $localPathPattern = Join-Path $localDestinationPath $RelativePath.TrimStart('\', '/')
        $tempPathPattern = Join-Path $tempDestinationPath $RelativePath.TrimStart('\', '/')
        $localExePath = & $resolveProgramPath $localDestinationPath
        $tempExePath = & $resolveProgramPath $tempDestinationPath
        $pathToCheck = 
        if ($DownloadOnly) { $localPathPattern }
        else { $tempPathPattern }

        # If -DownloadOnly parameter not used, download program to temp directory
        if (!$DownloadOnly) {
            $DestinationPath = $tempDestinationPath
        }

        # Reuse the same Scoop/fallback download behavior in default and custom handlers.
        $downloadParams = @{}
        if ($Uri) { $downloadParams.Uri = $Uri }
        if ($Scoop) { $downloadParams.Scoop = $Scoop }
        if ($UserAgent) { $downloadParams.UserAgent = $UserAgent }
        if ($ProgressState) { $downloadParams.ProgressState = $ProgressState }

        # Download program if not detected
        if (!$Uri -and !$Scoop -and !$ScriptBlock -and !$localExePath -and !$tempExePath) {
            Write-Error "The path '$pathToCheck' is not detected and neither Uri nor Scoop was passed to the function."
            return
        } elseif (($DownloadOnly -and !$ScriptBlock) -or (!$ScriptBlock -and !$localExePath -and !$tempExePath)) {
            Write-Verbose "The path '$localPathPattern' is not detected. Will download the configured program."
            $outfile = Copy-ProgramItem @downloadParams

            # Create parent directory if not detected
            if (!(Test-Path $DestinationPath)) {
                New-Item $DestinationPath -ItemType Directory -Force | Out-Null
            }

            # Extract/move file to proper path
            if ($outfile.FullName.EndsWith('.zip')) {
                Expand-Archive -Path $outfile -DestinationPath $DestinationPath -Force
                Remove-Item $outfile -Force
            } elseif ($outfile.FullName.EndsWith('.exe')) {
                Move-Item -Path $outfile -Destination $DestinationPath -Force
            } else {
                Expand-With7z -Path $outfile -DestinationPath $DestinationPath -Cleanup | Out-Null
            }

            # Verify file extracted to proper path
            $localExePath = & $resolveProgramPath $localDestinationPath
            $tempExePath = & $resolveProgramPath $tempDestinationPath
            if (!$localExePath -and !$tempExePath) {
                Write-Error "The path '$pathToCheck' is not detected. Verify the 'RelativePath' parameter is correct."
                return
            }
        } elseif ($ScriptBlock -and ($DownloadOnly -or (!$localExePath -and !$tempExePath))) {
            Write-Verbose "Parameter 'ScriptBlock' was specified. Overriding download logic using 'ScriptBlock'."
            & $ScriptBlock | Out-Null
            $localExePath = & $resolveProgramPath $localDestinationPath
            $tempExePath = & $resolveProgramPath $tempDestinationPath
        }

        # Start program
        if ($DownloadOnly) {
            $exePath = 
            if ($localExePath) { $localExePath }
            else {
                Write-Error "Failed to locate '$localExePath'."
                return
            }
        } else {
            $exePath = 
            if ($localExePath) { $localExePath }
            elseif ($tempExePath) { $tempExePath }
            else {
                Write-Error "Failed to locate '$localExePath' and/or '$tempExePath'."
                return
            }

            $processParams = @{
                FilePath = $exePath
                WorkingDirectory = Split-Path -Parent $exePath
            }

            if ($ArgumentList) {
                $processParams.ArgumentList = $ArgumentList
            }
    
            Start-Process @processParams
        }

        Get-Item $exePath
    }
}
