if ((Test-Path -Path "C:\Program Files\Online Services") -or (Test-Path -Path "C:\Program Files (x86)\Online Services")) {
	Remove-Item -Force -Path "C:\Program Files\Online Services" -Recurse
	Remove-Item -Force -Path "C:\Program Files (x86)\Online Services" -Recurse
	Write-Host "Removed Online Services apps." -ForegroundColor Cyan
	}
else {
	Write-Host "Online Services apps not detected." -ForegroundColor DarkGray
}

$lnkFiles = @(
	@("Adobe Offers.lnk"),
	@("Amazon.com.lnk"),
	@("Booking.com.lnk"),
	@("LastPass.lnk")
)

foreach ($lnkFile in $lnkFiles) {
	$lnkPath = Join-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\" "$lnkFile"
	if (Test-Path -Path $lnkPath)
	{
		Remove-Item -Force -Path $lnkPath
		Write-Host "Removed $lnkFile." -ForegroundColor Cyan
	}
}