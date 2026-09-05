function Expand-With7z {
    <#
    .SYNOPSIS
    Extracts archives using an existing or bootstrapped copy of 7-Zip.

    .DESCRIPTION
    Uses ATOM's portable 7-Zip or an installed copy, downloading the official bootstrap helper if neither is available. Supports pipeline input, post-extraction actions, and archive cleanup. Does not change antivirus settings.

    .PARAMETER Path
    Input archive path. Accepts pipeline strings or objects with a Path property.

    .PARAMETER DestinationPath
    Extraction directory. Defaults to a directory beside the archive named without its extension. A trailing backslash appends the archive name to the supplied directory.

    .PARAMETER UseConsole
    Uses the lightweight 7zr.exe when bootstrapping instead of downloading the full 7-Zip installer. Existing 7z.exe copies still take priority. Requires an archive format supported by 7zr.exe.

    .PARAMETER Cleanup
    Removes the input archive after successful extraction and post-processing.

    .PARAMETER NoClobber
    Skips existing destination files instead of overwriting them.

    .PARAMETER ScriptBlock
    Runs after successful extraction and before cleanup. The current archive and output directory are available as $Path and $extractDestination.

    .PARAMETER SevenZipPath
    Explicit path to an existing 7z.exe. Overrides automatic discovery; a missing file fails without bootstrapping.

    .EXAMPLE
    Expand-With7z -Path 'C:\Temp\example.zip' -DestinationPath 'C:\Temp\unpacked'

    Extracts into the specified directory using an existing or bootstrapped 7-Zip.

    .EXAMPLE
    Expand-With7z -Path 'C:\Temp\example.7z' -UseConsole -Cleanup

    Extracts into the example directory beside the archive, then removes the archive. Uses the lightweight helper if bootstrapping is needed.

    .EXAMPLE
    'C:\Temp\first.zip', 'C:\Temp\second.zip' | Expand-With7z -DestinationPath 'C:\Output\' -NoClobber

    Extracts into separate first and second directories without replacing existing files.

    .EXAMPLE
    Expand-With7z -Path 'C:\Temp\example.zip' -SevenZipPath 'C:\Tools\7-Zip\7z.exe' -Verbose

    Uses the specified executable without automatic discovery or bootstrapping.

    .INPUTS
    System.String. Archive paths, or objects with a Path property.

    .OUTPUTS
    System.IO.DirectoryInfo. The extraction directory for each archive, plus any output from ScriptBlock.

    .NOTES
    Author: Skyler Wallace
    Full bootstrapping requires internet access and uses the x64 installer. Bootstrap files are removed on setup failure or normal completion; failed extraction can leave temporary files. Shared executables are never removed.

    .LINK
    https://www.7-zip.org/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [String]$Path,
        [Parameter(Position = 1)]
        [String]$DestinationPath,
        [Switch]$UseConsole,
        [Switch]$Cleanup,
        [Switch]$NoClobber,
        [ScriptBlock]$ScriptBlock,
        [String]$SevenZipPath
    )

    begin {
        $bootstrapPath = $null
        $candidates = @()
        if ($SevenZipPath) {
            $candidates = @($SevenZipPath)
        } else {
            $programsVariable = Get-Variable -Name programsPath -ErrorAction SilentlyContinue
            $portableRoot = if ($programsVariable -and $programsVariable.Value) {
                [String]$programsVariable.Value
            } else {
                Join-Path $PSScriptRoot '..\..\Programs'
            }
            $candidates += Join-Path $portableRoot '7-Zip\7z.exe'
            foreach ($installRoot in @($env:ProgramW6432, $env:ProgramFiles, ${env:ProgramFiles(x86)})) {
                if ($installRoot) { $candidates += Join-Path $installRoot '7-Zip\7z.exe' }
            }
        }
        $sevenZipExe = $null
        foreach ($candidate in $candidates) {
            if ([IO.File]::Exists($candidate)) {
                $sevenZipExe = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($candidate)
                break
            }
        }
        if (!$sevenZipExe -and $SevenZipPath) { throw 'The specified 7-Zip executable was not found.' }
        if (!$sevenZipExe) {
            $bootstrapPath = Join-Path ([IO.Path]::GetTempPath()) ('ATOM-7Zip-' + [Guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $bootstrapPath -ErrorAction Stop | Out-Null
            try {
                $sevenZipExe = Join-Path $bootstrapPath '7zr.exe'
                Invoke-WebRequest -Uri 'https://www.7-zip.org/a/7zr.exe' -OutFile $sevenZipExe -UseBasicParsing -ErrorAction Stop
                if (!$UseConsole) {
                    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/ip7z/7zip/releases/latest' -ErrorAction Stop
                    $installerUri = @($release.assets.browser_download_url | Where-Object { $_.EndsWith('-x64.exe') })
                    if ($installerUri.Count -ne 1) { throw 'Could not resolve the 7-Zip installer.' }
                    $installerPath = Join-Path $bootstrapPath '7-Zip.exe'
                    Invoke-WebRequest -Uri $installerUri[0] -OutFile $installerPath -UseBasicParsing -ErrorAction Stop
                    $bootstrapProcess = Start-Process -FilePath $sevenZipExe -ArgumentList "x `"$installerPath`" -o`"$bootstrapPath`" -y" -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
                    if ($bootstrapProcess.ExitCode -ne 0) { throw "7-Zip setup failed (exit $($bootstrapProcess.ExitCode))." }
                    $sevenZipExe = Join-Path $bootstrapPath '7z.exe'
                    if (![IO.File]::Exists($sevenZipExe)) { throw '7-Zip setup did not produce 7z.exe.' }
                }
            } catch {
                Write-Verbose "7-Zip bootstrap failed: $($_.Exception.Message)"
                Remove-Item -LiteralPath $bootstrapPath -Recurse -Force -ErrorAction SilentlyContinue
                throw '7-Zip setup failed. Check antivirus history or verbose logs.'
            }
        }
        Write-Verbose "Using 7-Zip: $sevenZipExe"
    }

    process {
        # Keep the requested destination unchanged between pipeline inputs.
        $extractDestination = $DestinationPath
        if (!$extractDestination) {
            $extractDestination = Join-Path (Split-Path $Path) ([IO.Path]::GetFileNameWithoutExtension($Path))
        } elseif ($extractDestination.EndsWith('\')) {
            $extractDestination = Join-Path $extractDestination ([IO.Path]::GetFileNameWithoutExtension($Path))
        }
        $overwriteOption = if ($NoClobber) { '-aos' } else { '-aoa' }
        try {
            $process = Start-Process -FilePath $sevenZipExe -ArgumentList "x `"$Path`" -o`"$extractDestination`" -y $overwriteOption" -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
        } catch {
            Write-Verbose "7-Zip launch failed: $($_.Exception.Message)"
            $launchException = $_.Exception
            while ($launchException) {
                if ($launchException -is [ComponentModel.Win32Exception] -and $launchException.NativeErrorCode -in 225, 226) {
                    throw '7-Zip blocked by antivirus. Check Protection History.'
                }
                $launchException = $launchException.InnerException
            }
            throw '7-Zip could not start. Use verbose logging for details.'
        }
        if ($process.ExitCode -ne 0) {
            throw "7-Zip extraction failed (exit $($process.ExitCode))."
        }
        if ($ScriptBlock) { Invoke-Command -ScriptBlock $ScriptBlock -NoNewScope }
        if ($Cleanup) { Remove-Item -LiteralPath $Path -Force -ErrorAction Stop }
        Get-Item -LiteralPath $extractDestination -ErrorAction Stop
    }

    end {
        if ($bootstrapPath) {
            Remove-Item -LiteralPath $bootstrapPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
