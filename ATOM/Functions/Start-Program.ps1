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
    Specifies the relative path to the executable within the destination folder (e.g., 'Autoruns64.exe'). Mandatory.

    .PARAMETER Uri
    Specifies the URL to download the program if the executable is not found. Optional. Aliases: Url.

    .PARAMETER ArgumentList
    A string of arguments to pass when starting the program executable. Optional.

    .PARAMETER ScriptBlock
    A scriptblock which overrides the function's default download & extraction logic.

    .PARAMETER DownloadOnly
    When specified, downloads the program to the specified DestinationPath but does not launch the program afterwards.

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
        [Alias('Path')][Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$destinationPath,
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$relativePath,
        [Alias('Url')][Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]$uri,
        [String]$argumentList,
        [String]$userAgent,
        [ScriptBlock]$scriptBlock,
        [Switch]$downloadOnly
    )

    begin {
        # Ensure dependent functions are available
        $functions = Get-Command -CommandType Function | Select-Object -Expand Name
        $dependencies = 'Copy-WebItem', 'Expand-With7z'
        $dependencies | ForEach-Object {
            if ($functions -notcontains $_) {
                $function = "$psScriptRoot\$_.ps1"
                if (Test-Path $function) { . $function }
                else { Write-Error "The $_ function is required but not found."; return }
            }
        }
    }

    process {
        $localExePath = Join-Path $destinationPath $relativePath
        $tempExePath = Join-Path "$env:TEMP\$(Split-Path $destinationPath -Leaf)" $relativePath
        $pathToCheck = 
        if ($downloadOnly) { $localExePath }
        else { $tempExePath }

        # If -DownloadOnly parameter not used, download program to temp directory
        if (!$downloadOnly) {
            $destinationPath = Join-Path $env:TEMP (Split-Path $destinationPath -Leaf)
        }

        # Download program if not detected
        if (!$uri -and ((Test-Path $localExePath, $tempExePath) -notcontains $true)) {
            Write-Error "The path '$pathToCheck' is not detected and parameter 'Uri' was not passed to function. Please pass 'Uri' parameter to function."
            return
        } elseif (($downloadOnly -and !$scriptBlock) -or (!$scriptBlock -and (Test-Path $localExePath, $tempExePath) -notcontains $true)) {
            Write-Verbose "The path '$localExePath' is not detected. Will download program from '$uri'."
            $downloadParams = @{ Uri = $uri }
            if ($userAgent) { $downloadParams.UserAgent = $userAgent }
            $outfile = Copy-WebItem @downloadParams

            # Create parent directory if not detected
            if (!(Test-Path $destinationPath)) {
                New-Item $destinationPath -ItemType Directory -Force
            }

            # Extract/move file to proper path
            if ($outfile.FullName.EndsWith('.zip')) {
                Expand-Archive -Path $outfile -DestinationPath $destinationPath -Force
                Remove-Item $outfile -Force
            } elseif ($outfile.FullName.EndsWith('.exe')) {
                Move-Item -Path $outfile -Destination $destinationPath -Force
            } else {
                Expand-With7z -Path $outfile -DestinationPath $destinationPath -Cleanup
            }

            # Verify file extracted to proper path
            if ((Test-Path $localExePath, $tempExePath) -notcontains $true) {
                Write-Error "The path '$pathToCheck' is not detected. Verify the 'RelativePath' parameter is correct."
                return
            }
        } elseif ($scriptBlock -and ($downloadOnly -or (Test-Path $localExePath, $tempExePath) -notcontains $true)) {
            Write-Verbose "Parameter 'ScriptBlock' was specified. Overriding download logic using 'ScriptBlock'."
            & $scriptBlock
        }

        # Start program
        if ($downloadOnly) {
            $exePath = 
            if (Test-Path $localExePath) { $localExePath }
            else {
                Write-Error "Failed to locate '$localExePath'."
                return
            }
        } else {
            $exePath = 
            if (Test-Path $localExePath) { $localExePath }
            elseif (Test-Path $tempExePath) { $tempExePath }
            else {
                Write-Error "Failed to locate '$localExePath' and/or '$tempExePath'."
                return
            }

            $processParams = @{ FilePath = "`"$exePath`"" }

            if ($argumentList) {
                $processParams.ArgumentList = $argumentList
            }
    
            Start-Process @processParams
        }

        Get-Item $exePath
    }
}