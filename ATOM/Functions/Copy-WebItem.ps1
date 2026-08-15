function Copy-WebItem {
    <#
    .SYNOPSIS
    Downloads a file from a specified URL and displays a progress bar.

    .DESCRIPTION
    The `Copy-WebItem` function downloads a file from a specified URL to a target file path. It supports custom HTTP headers, progress reporting, and an option to prevent overwriting existing files.

    .PARAMETER Uri
    Specifies the URL to download the file. Alias: 'Url'.

    .PARAMETER OutFile
    Specifies the path where the downloaded file will be saved. If not specified, the file will be saved in the current directory with a name derived from the response or URL. Optional.

    .PARAMETER Headers
    Specifies a hashtable of custom headers to include in the HTTP request. Useful for providing authentication tokens or other headers required by the server. Optional.

    .PARAMETER UserAgent
    Specifies a user agent string for the web request. The default user agent is `Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) Gecko/20100401 Firefox/4.0`.

    .PARAMETER Force
    Creates the parent directory of the specified output file if it does not exist. Without this parameter, an error is generated if the parent directory does not exist.

    .PARAMETER NoClobber
    Prevents overwriting an existing file at the specified path, regardless of its size.

    .PARAMETER NoProgress
    Suppresses the download progress bar. External progress tracking through ProgressState remains active.

    .PARAMETER ProgressState
    Specifies a dictionary that receives live download state. Use a synchronized hashtable when the download runs in another runspace so the calling thread can safely read properties such as TotalBytes, DownloadedBytes, PercentComplete, BytesPerSecond, and EstimatedTimeRemaining.

    .PARAMETER Asynchronous
    Starts the download in a background runspace and immediately returns an asynchronous result. Use its ProgressState property to monitor the download. Call Wait(), Stop(), or Dispose() to release the runspace. Alias: Async.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" -OutFile "C:\Users\Owner\Downloads\file.zip"
    Downloads the file from the specified URL and saves it to `C:\Users\Owner\Downloads\file.zip`.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" -NoClobber
    Attempts to download the file, but reports an error if the target file already exists.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" -Headers @{ Authorization = "Bearer token123" }
    Downloads the file from the specified URL, including a custom Authorization header in the HTTP request.

    .EXAMPLE
    "https://example.com/file1.zip","https://example.com/file2.zip" | Copy-WebItem -OutFile "C:\Temp\" -Force
    Downloads multiple files from the pipeline and saves them to `C:\Temp\`, creating the directory if not present, using their original file names.

    .EXAMPLE
    Copy-WebItem -Uri "https://example.com/file.zip" | Expand-Archive
    Downloads the file from the specified URL and then extracts the contents of the zip.

    .EXAMPLE
    $progress = [hashtable]::Synchronized(@{})
    Copy-WebItem -Uri "https://example.com/file.zip" -ProgressState $progress
    Populates $progress with live download information. Run Copy-WebItem in a runspace to poll the synchronized hashtable asynchronously from another thread.

    .EXAMPLE
    $download = Copy-WebItem -Uri "https://example.com/file.zip" -Async
    $download.ProgressState.PercentComplete
    $download.Wait()
    Starts the download asynchronously, reads its progress, and waits for the downloaded FileInfo result.

    .OUTPUTS
    [System.IO.FileInfo]
    Returns a FileInfo object for a synchronous download.

    [CopyWebItem.AsyncResult]
    Returns an asynchronous result when Asynchronous is specified. Call Wait() once to retrieve the downloaded FileInfo object.
    
    .NOTES
    Author: Skyler Wallace
    Requires: Internet connection to download files.
    #>

    [CmdletBinding(SupportsShouldProcess)]

    param (
        [Alias('Url')][Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [String]$Uri,
        [Parameter(Position = 1)]
        [String]$OutFile,
        [Hashtable]$Headers = $null,
        [String]$UserAgent,
        [PsCredential]$Credential = $null,
        [Switch]$Force,
        [Switch]$NoClobber,
        [Switch]$NoProgress,
        [System.Collections.IDictionary]$ProgressState,
        [Alias('Async')]
        [Switch]$Asynchronous
    )

    begin {
        # Load System.Net.Http assembly if not already loaded
        Add-Type -AssemblyName System.Net.Http

        # Load Utility Module if PSUserAgent class is undefined
        if (!('Microsoft.PowerShell.Commands.PSUserAgent' -as [type])) {
            Write-Verbose "Microsoft.PowerShell.Commands.PSUserAgent class undefined, loading Microsoft.PowerShell.Utility module."
            Import-Module Microsoft.PowerShell.Utility
        }
    }

    process {
        if ($Asynchronous) {
            $asyncParameters = @{}
            $PSBoundParameters.GetEnumerator() | Where-Object Key -ne 'Asynchronous' | ForEach-Object { $asyncParameters[$_.Key] = $_.Value }
            if (!$asyncParameters.ContainsKey('ProgressState')) { $asyncParameters.ProgressState = [hashtable]::Synchronized(@{}) }
            elseif ($asyncParameters.ProgressState -is [hashtable] -and !$asyncParameters.ProgressState.IsSynchronized) { $asyncParameters.ProgressState = [hashtable]::Synchronized($asyncParameters.ProgressState) }
            if (!$asyncParameters.ContainsKey('NoProgress')) { $asyncParameters.NoProgress = $true }

            $powershell = [powershell]::Create()
            $null = $powershell.AddScript({
                param($definition, $parameters)
                Set-Item Function:\Copy-WebItem ([scriptblock]::Create($definition))
                Copy-WebItem @parameters
            }).AddArgument($MyInvocation.MyCommand.Definition).AddArgument($asyncParameters)
            $handle = $powershell.BeginInvoke()

            $result = [pscustomobject]@{ PSTypeName = 'CopyWebItem.AsyncResult'; PowerShell = $powershell; Handle = $handle; ProgressState = $asyncParameters.ProgressState }
            $result | Add-Member ScriptProperty IsCompleted { $this.Handle.IsCompleted }
            $result | Add-Member ScriptMethod Wait { try { $this.PowerShell.EndInvoke($this.Handle) } finally { $this.PowerShell.Dispose() } }
            $result | Add-Member ScriptMethod Stop { try { $this.PowerShell.Stop() } finally { $this.ProgressState.Status = 'Stopped'; $this.ProgressState.IsCompleted = $true; $this.PowerShell.Dispose() } }
            $result | Add-Member ScriptMethod Dispose { $this.PowerShell.Dispose() }
            return $result
        }

        if ($ProgressState) {
            $ProgressState.Uri = $Uri
            $ProgressState.ResponseUri = $null
            $ProgressState.Destination = $null
            $ProgressState.FileName = $null
            $ProgressState.Status = 'Connecting'
            $ProgressState.TotalBytes = $null
            $ProgressState.TotalMegabytes = $null
            $ProgressState.DownloadedBytes = 0L
            $ProgressState.DownloadedMegabytes = 0.0
            $ProgressState.PercentComplete = $null
            $ProgressState.BytesPerSecond = 0.0
            $ProgressState.MegabytesPerSecond = 0.0
            $ProgressState.Elapsed = [TimeSpan]::Zero
            $ProgressState.EstimatedTimeRemaining = $null
            $ProgressState.IsCompleted = $false
            $ProgressState.Error = $null
            $ProgressState.DownloadHash = $null
            $ProgressState.LastUpdated = [DateTime]::UtcNow
        }

        # Set UserAgent to FireFox if undefined
        if (!$UserAgent) {
            Write-Verbose "UserAgent parameter undefined, setting to FireFox."
            $UserAgent = 
                if ('Microsoft.PowerShell.Commands.PSUserAgent' -as [type]) { [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox }
                else { 'Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) Gecko/20100401 Firefox/4.0' }
        }

        if (!$PSCmdlet.ShouldProcess($Uri, 'Download')) {
            if ($ProgressState) {
                $ProgressState.Status = if ($WhatIfPreference) { 'Skipped' } else { 'Cancelled' }
                $ProgressState.IsCompleted = $true
                $ProgressState.LastUpdated = [DateTime]::UtcNow
            }
            return
        }

        # Create HTTP client
        try {
            $handler = [System.Net.Http.HttpClientHandler]::new()

            if ($Credential) {
                $handler.Credentials = $Credential.GetNetworkCredential()
            }

            $httpClient = [System.Net.Http.HttpClient]::new($handler)
            $httpClient.DefaultRequestHeaders.UserAgent.ParseAdd($UserAgent)

            # Add custom headers
            if ($Headers) {
                foreach ($header in $Headers.GetEnumerator()) {
                    $httpClient.DefaultRequestHeaders.TryAddWithoutValidation($header.Key,[string]$header.Value) | Out-Null
                }
            }

            # Send GET request, returning as soon as headers arrive
            Write-Verbose "Requesting download information from $Uri"

            $requestUri = [System.Uri]::new($Uri)
            $response = $httpClient.GetAsync($requestUri,[System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()

            if (!$response.IsSuccessStatusCode) {
                throw "HTTP request failed with status code $([int]$response.StatusCode) ($($response.StatusCode))."
            }

            # Get file size
            $fileSizeBytes = $response.Content.Headers.ContentLength
            $fileSizeMb = 
                if ($fileSizeBytes) { [math]::Round($fileSizeBytes / 1MB, 1) }
                else { $null }

            if ($ProgressState) {
                $ProgressState.ResponseUri = $response.RequestMessage.RequestUri.AbsoluteUri
                $ProgressState.TotalBytes = $fileSizeBytes
                $ProgressState.TotalMegabytes = $fileSizeMb
                $ProgressState.LastUpdated = [DateTime]::UtcNow
            }

            # Get filename (ContentDisposition)
            $fileName = $null # fileName persists through process block

            if ($response.Content.Headers.ContentDisposition) {
                $contentDisposition = $response.Content.Headers.ContentDisposition

                $fileName = 
                    if ($contentDisposition.FileNameStar) { $contentDisposition.FileNameStar }
                    elseif ($contentDisposition.FileName) { $contentDisposition.FileName }

                if ($fileName) {
                    $fileName = $fileName.Trim('"')
                }
            }

            # Get filename (AbsolutePath)
            if (!$fileName) {
                $responseUri = $response.RequestMessage.RequestUri

                if ($responseUri.AbsolutePath) {
                    $fileName = [System.IO.Path]::GetFileName($responseUri.AbsolutePath)
                }
            }

            # Get filename (couldn't gather from response)
            if (!$fileName) {
                $fileName = Split-Path $Uri -Leaf
            }

            # Change OutFile param to Destination variable so piping multiple URLs doesn't break
            $destination = 
                if (!$OutFile) { Join-Path (Get-Location) $fileName }
                elseif ($OutFile.EndsWith('\')) { Join-Path $OutFile $fileName }
                else { $OutFile }

            Write-Verbose "Destination file: $destination"

            if ($ProgressState) {
                $ProgressState.Destination = $destination
                $ProgressState.FileName = $fileName
                $ProgressState.Status = 'Downloading'
                $ProgressState.LastUpdated = [DateTime]::UtcNow
            }

            # Verify parent directory exists
            $parentDirectory = Split-Path $destination -Parent

            if (!(Test-Path $parentDirectory -PathType Container)) {
                if ($Force) {
                    Write-Verbose "Creating parent directory '$parentDirectory'."
                    New-Item -Path $parentDirectory -ItemType Directory -Force | Out-Null
                } else {
                    throw "The parent directory '$parentDirectory' does not exist. Specify -Force to create it."
                }
            }

            # NoClobber, override existing file behavior
            $existingFile = if (Test-Path $destination -PathType Leaf) {
                Get-Item $destination
            }

            if ($existingFile) {
                if ($NoClobber) {
                    if ($ProgressState) {
                        $ProgressState.Status = 'Skipped'
                        $ProgressState.IsCompleted = $true
                        $ProgressState.Error = "The file '$destination' already exists."
                        $ProgressState.LastUpdated = [DateTime]::UtcNow
                    }

                    $errRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.IO.IOException]::new("The file '$destination' already exists."),
                        'NoClobber',
                        [System.Management.Automation.ErrorCategory]::ResourceExists,
                        $destination
                    )

                    $errRecord.CategoryInfo.Activity = $MyInvocation.MyCommand.Name
                    Write-Error $errRecord
                    return
                }

                Write-Verbose "Overwriting '$destination' with download."
            }

            # Stream download directly to disk
            Write-Verbose "Downloading from $Uri"

            $responseStream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()

            $targetStream = [System.IO.FileStream]::new(
                $destination,
                [System.IO.FileMode]::Create,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::None,
                64KB,
                [System.IO.FileOptions]::SequentialScan
            )

            $buffer = New-Object byte[] 64KB
            $downloadedBytes = 0
            $downloadedMb = 0

            # Exponential moving average (EMA) for speed
            $emaAlpha = 0.125
            $emaBytesPerSecond = $null

            # Start timer for download
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            # Progress update tracking
            $lastProgressUpdate = $stopwatch.Elapsed
            $lastProgressBytes = 0

            while ($true) {
                $bytesRead = $responseStream.Read($buffer, 0, $buffer.Length)

                if ($bytesRead -le 0) { break }

                $targetStream.Write($buffer, 0, $bytesRead)

                $downloadedBytes += $bytesRead
                $downloadedMb = [math]::Round($downloadedBytes / 1MB, 1)

                # Update progress approximately every 500ms
                $elapsedSinceProgress = ($stopwatch.Elapsed - $lastProgressUpdate).TotalSeconds
                if ($elapsedSinceProgress -lt 0.5) { continue }

                # Calculate current speed since previous update
                $bytesSinceProgress = $downloadedBytes - $lastProgressBytes
                $bytesPerSecond = $bytesSinceProgress / $elapsedSinceProgress
                $speedMb = [math]::Round($bytesPerSecond / 1MB, 1)
                
                # Update exponential moving average (EMA)
                $emaBytesPerSecond = 
                    if ($null -eq $emaBytesPerSecond) { $bytesPerSecond }
                    else { ($bytesPerSecond * $emaAlpha) + ($emaBytesPerSecond * (1 - $emaAlpha)) }

                # Calculate estimated time remaining
                $estimatedTimeRemaining =
                    if ($fileSizeBytes -and $emaBytesPerSecond -gt 0) {
                        [TimeSpan]::FromSeconds([math]::Max(0, ($fileSizeBytes - $downloadedBytes) / $emaBytesPerSecond))
                    }
                $etaText = if ($estimatedTimeRemaining) { $estimatedTimeRemaining.ToString('hh\:mm\:ss') } else { '--:--:--' }

                # Format elapsed time
                $elapsedText = $stopwatch.Elapsed.ToString('hh\:mm\:ss')

                $percentComplete = if ($fileSizeBytes) {
                    [math]::Min(100, [math]::Round(($downloadedBytes / $fileSizeBytes) * 100, 2))
                }

                if ($ProgressState) {
                    $ProgressState.DownloadedBytes = $downloadedBytes
                    $ProgressState.DownloadedMegabytes = $downloadedMb
                    $ProgressState.PercentComplete = $percentComplete
                    $ProgressState.BytesPerSecond = [math]::Round($emaBytesPerSecond, 2)
                    $ProgressState.MegabytesPerSecond = [math]::Round($emaBytesPerSecond / 1MB, 2)
                    $ProgressState.Elapsed = $stopwatch.Elapsed
                    $ProgressState.EstimatedTimeRemaining = $estimatedTimeRemaining
                    $ProgressState.LastUpdated = [DateTime]::UtcNow
                }

                if (!$NoProgress) {
                    $progressParams = @{
                        Activity = (Split-Path $destination -Leaf)
                        Status = 'Downloading...'
                        CurrentOperation = "Time $elapsedText | ETA $etaText | Progress $downloadedMb$(if ($fileSizeBytes) { " / $fileSizeMb" }) MB | Rate $speedMb MB/s"
                        PercentComplete = if ($null -ne $percentComplete) { $percentComplete } else { -1 }
                    }

                    Write-Progress @progressParams
                }

                $lastProgressUpdate = $stopwatch.Elapsed
                $lastProgressBytes = $downloadedBytes
            }

            $stopwatch.Stop()

            if ($ProgressState) {
                $ProgressState.DownloadedBytes = $downloadedBytes
                $ProgressState.DownloadedMegabytes = $downloadedMb
                $ProgressState.PercentComplete = if ($fileSizeBytes) { 100.0 } else { $null }
                $ProgressState.Elapsed = $stopwatch.Elapsed
                $ProgressState.EstimatedTimeRemaining = [TimeSpan]::Zero
                $ProgressState.Status = 'Completed'
                $ProgressState.IsCompleted = $true
                $ProgressState.LastUpdated = [DateTime]::UtcNow
            }

            # Final progress update
            if (!$NoProgress) {
                $progressParams = @{
                    Activity = (Split-Path $destination -Leaf)
                    Status = 'Downloading...'
                    Completed = $true
                    CurrentOperation = "$downloadedMb MB | $($stopwatch.Elapsed.ToString('hh\:mm\:ss'))"
                    PercentComplete = if ($fileSizeBytes) { 100 } else { -1 }
                }

                Write-Progress @progressParams
            }
        } catch {
            if ($ProgressState) {
                $ProgressState.Status = 'Failed'
                $ProgressState.IsCompleted = $true
                $ProgressState.Error = $_.Exception.Message
                $ProgressState.LastUpdated = [DateTime]::UtcNow
            }

            throw
        } finally {
            # Cleanup
            if ($targetStream) { $targetStream.Flush(); $targetStream.Dispose() }
            if ($responseStream) { $responseStream.Dispose() }
            if ($response) {$response.Dispose()}
            if ($httpClient) {$httpClient.Dispose()}
        }

        if ($ProgressState -and $ProgressState.TrackHash -and (Test-Path -LiteralPath $destination -PathType Leaf)) {
            $ProgressState.Status = 'Hashing'
            $ProgressState.LastUpdated = [DateTime]::UtcNow
            $ProgressState.DownloadHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
            $ProgressState.Status = 'Completed'
            $ProgressState.LastUpdated = [DateTime]::UtcNow
        }

        # Return [System.IO.FileInfo] object
        Get-Item $destination
    }
}