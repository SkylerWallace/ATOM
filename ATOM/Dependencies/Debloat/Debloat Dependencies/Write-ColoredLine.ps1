function Write-ColoredLine {
	param (
		[string]$Text,
		[ConsoleColor]$ForegroundColor = [ConsoleColor]::White
	)
	Write-Host -NoNewline "|" -ForegroundColor White
	Write-Host -NoNewline " $Text" -ForegroundColor $ForegroundColor
	Write-Host " |" -ForegroundColor White
}