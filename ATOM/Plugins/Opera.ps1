Import-Module $psScriptRoot\..\Functions\AtomModule.psm1 -Function Start-Program -Variable *
$program = @{} + $programs.Opera.ProgramInfo
if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') {
    $profilePath = Join-Path $program.DestinationPath 'profile'
    $logPath = Join-Path $program.DestinationPath 'opera-pe.log'
    $program.ArgumentList = "--user-data-dir=`"$profilePath`" --no-sandbox --disable-gpu-sandbox --use-angle=swiftshader --enable-unsafe-swiftshader --disable-breakpad --no-first-run --enable-logging --log-file=`"$logPath`" --v=1"
}
Start-Program @program
