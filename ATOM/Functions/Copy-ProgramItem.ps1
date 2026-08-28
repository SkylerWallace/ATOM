function Copy-ProgramItem {
    <#
    .SYNOPSIS
    Downloads a configured program using Scoop metadata with URL fallback.

    .DESCRIPTION
    Resolves a current Scoop download when Scoop is specified, downloads it
    through Copy-WebItem, and verifies the manifest hash. If Scoop resolution,
    downloading, or verification fails, Uri is attempted as a fallback.

    The returned FileInfo includes DownloadSource, DownloadVersion, ResolvedUri,
    ScoopManifest, HashVerified, UsedFallback, and FallbackReason properties.

    .PARAMETER Scoop
    Scoop manifest identifier in bucket/app form.

    .PARAMETER Uri
    Fallback URL when Scoop is specified, or the primary URL otherwise.

    .OUTPUTS
    System.IO.FileInfo with additional download metadata properties.
    #>

    [CmdletBinding()]

    param (
        [Alias('Url')]
        [String]$Uri,
        [ValidatePattern('^[^/]+/[^/]+$')]
        [String]$Scoop,
        [ValidateSet('32bit', '64bit', 'arm64')]
        [String]$Architecture = '64bit',
        [String]$OutFile,
        [String]$UserAgent,
        [System.Collections.IDictionary]$ProgressState
    )

    $functions = Get-Command -CommandType Function | Select-Object -ExpandProperty Name
    foreach ($dependency in 'Copy-WebItem', 'Resolve-ScoopDownload') {
        if ($functions -notcontains $dependency) {
            $functionPath = Join-Path $PSScriptRoot "$dependency.ps1"
            if (Test-Path -LiteralPath $functionPath) { . $functionPath }
            else { throw "The $dependency function is required but was not found." }
        }
    }

    $candidates = @()
    $fallbackReason = $null

    if ($Scoop) {
        try {
            $scoopDownloads = @(Resolve-ScoopDownload -Scoop $Scoop -Architecture $Architecture)
            if ($scoopDownloads.Count -ne 1) {
                throw "Scoop manifest '$Scoop' contains $($scoopDownloads.Count) downloads; this program requires custom download handling."
            }

            $candidates += $scoopDownloads[0]
        } catch {
            $fallbackReason = $_.Exception.Message
            Write-Verbose "Scoop resolution failed for '$Scoop': $fallbackReason"
        }
    }

    if ($Uri) {
        $candidates += [PSCustomObject]@{
            Source        = if ($Scoop) { 'Fallback' } else { 'Configured' }
            Scoop         = $Scoop
            Version       = $null
            Uri           = $Uri
            FileName      = $null
            HasRenameHint = $false
            Hash          = $null
        }
    }

    if ($candidates.Count -eq 0) {
        if ($fallbackReason) { throw $fallbackReason }
        throw 'No Scoop manifest or configured download URL was provided.'
    }

    $failureMessages = @()

    foreach ($candidate in $candidates) {
        try {
            if ($ProgressState) {
                $ProgressState.Source = $candidate.Source
                $ProgressState.Version = $candidate.Version
                $ProgressState.ResolvedUri = $candidate.Uri
                $ProgressState.ScoopManifest = $candidate.Scoop
                $ProgressState.HashVerified = $false
                $ProgressState.UsedFallback = $candidate.Source -eq 'Fallback'
                $ProgressState.FallbackReason = $fallbackReason
            }

            $downloadUri = $candidate.Uri
            $sourceForgeDownload = $downloadUri -match '(?:downloads\.)?sourceforge\.net/projects?/(?<Project>[^/]+)/(?:files/)?(?<File>.*?)(?:$|/download|\?)'
            if ($sourceForgeDownload) {
                $downloadUri = "https://downloads.sourceforge.net/project/$($matches.Project)/$($matches.File)"
            }

            $copyParams = @{ Uri = $downloadUri }
            if ($UserAgent) { $copyParams.UserAgent = $UserAgent }
            elseif ($sourceForgeDownload) { $copyParams.UserAgent = 'Wget/1.21.4' }
            if ($ProgressState) { $copyParams.ProgressState = $ProgressState }

            if ($OutFile) {
                $copyParams.OutFile =
                    if (($OutFile.EndsWith('\') -or $OutFile.EndsWith('/')) -and $candidate.FileName) {
                        Join-Path $OutFile $candidate.FileName
                    } else {
                        $OutFile
                    }
            } elseif ($candidate.HasRenameHint) {
                $defaultDirectory = if ($atomTemp) { $atomTemp } else { [IO.Path]::GetTempPath() }
                $copyParams.OutFile = Join-Path $defaultDirectory $candidate.FileName
            }

            $file = Copy-WebItem @copyParams

            if ($candidate.Source -eq 'Scoop') {
                if ($ProgressState) {
                    $ProgressState.Status = 'Verifying'
                    $ProgressState.LastUpdated = [DateTime]::UtcNow
                }
                if (!$candidate.Hash -or $candidate.Hash -isnot [String]) {
                    Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
                    throw "Scoop manifest '$Scoop' does not contain a supported hash."
                }

                $expectedHash = [String]$candidate.Hash
                $algorithm = 'SHA256'

                if ($expectedHash -match '^(?<Algorithm>md5|sha1|sha256|sha384|sha512):(?<Hash>[a-fA-F0-9]+)$') {
                    $algorithm = $matches.Algorithm.ToUpperInvariant()
                    $expectedHash = $matches.Hash
                }

                $actualHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm $algorithm).Hash
                if (![String]::Equals($actualHash, $expectedHash, [StringComparison]::OrdinalIgnoreCase)) {
                    Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
                    throw "Hash verification failed for '$($candidate.Uri)'."
                }

                if ($ProgressState) {
                    $ProgressState.HashVerified = $true
                    $ProgressState.Status = 'Completed'
                    $ProgressState.LastUpdated = [DateTime]::UtcNow
                }
            }

            $file | Add-Member -MemberType NoteProperty -Name DownloadSource -Value $candidate.Source -Force
            $file | Add-Member -MemberType NoteProperty -Name DownloadVersion -Value $candidate.Version -Force
            $file | Add-Member -MemberType NoteProperty -Name ResolvedUri -Value $candidate.Uri -Force
            $file | Add-Member -MemberType NoteProperty -Name ScoopManifest -Value $candidate.Scoop -Force
            $file | Add-Member -MemberType NoteProperty -Name HashVerified -Value ($candidate.Source -eq 'Scoop') -Force
            $file | Add-Member -MemberType NoteProperty -Name UsedFallback -Value ($candidate.Source -eq 'Fallback') -Force
            $file | Add-Member -MemberType NoteProperty -Name FallbackReason -Value $fallbackReason -Force

            return $file
        } catch {
            $message = $_.Exception.Message
            $failureMessages += "$($candidate.Source): $message"

            if ($candidate.Source -eq 'Scoop') {
                $fallbackReason = $message
                Write-Verbose "Scoop download failed for '$Scoop': $message"
                continue
            }
        }
    }

    if ($ProgressState) {
        $ProgressState.Status = 'Failed'
        $ProgressState.IsCompleted = $true
        $ProgressState.Error = $failureMessages -join ' | '
        $ProgressState.LastUpdated = [DateTime]::UtcNow
    }

    throw ($failureMessages -join ' | ')
}
