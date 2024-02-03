$savedThemePath = Join-Path $settingsPath "SavedTheme.ps1"
. $savedThemePath

$themes = [ordered]@{
	"Atomic" = [ordered]@{
		primaryColor = "#E37222"
		primaryBrush = "#E37222"
		primaryGrad0 = "#E37222"
		primaryGrad1 = "#F59B2B"
		primaryHighlight = "#40FFFFFF"
		primaryText = "#DDFFFFFF"
		primaryIcons = "Light"
		
		backgroundColor = "#272728"
		backgroundBrush = "#272728"
		backgroundGrad0 = "#272728"
		backgroundGrad1 = "#272728"
		backgroundHighlight = "#40FFFFFF"
		backgroundText = "#DDFFFFFF"
		backgroundIcons = "Light"
		
		surfaceColor = "#49494A"
		surfaceBrush = "#49494A"
		surfaceGrad0 = "#2F2F30"
		surfaceGrad1 = "#49494A"
		surfaceHighlight = "#40FFFFFF"
		surfaceText = "#DDFFFFFF"
		surfaceIcons = "Light"
		
		accentColor = "#C3C4C4"
		accentBrush = "#C3C4C4"
		accentGrad0 = "#C3C4C4"
		accentGrad1 = "#C3C4C4"
		accentHighlight = "#40000000"
		accentText = "#DD000000"
		accentIcons = "Dark"
		
		gradientStrength = 1.5
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Beach" = [ordered]@{
		primaryColor = "#FF9F1C"
		primaryBrush = "#FF9F1C"
		primaryGrad0 = "#FF9F1C"
		primaryGrad1 = "#FF9F1C"
		primaryHighlight = "#40000000"
		primaryText = "#DD000000"
		primaryIcons = "Dark"
		
		backgroundColor = "#FFBF69"
		backgroundBrush = "#FFBF69"
		backgroundGrad0 = "#FFBF69"
		backgroundGrad1 = "#FFBF69"
		backgroundHighlight = "#40000000"
		backgroundText = "#DD000000"
		backgroundIcons = "Dark"
		
		surfaceColor = "#CBF3F0"
		surfaceBrush = "#CBF3F0"
		surfaceGrad0 = "#FFFFFF"
		surfaceGrad1 = "#CBF3F0"
		surfaceHighlight = "#40000000"
		surfaceText = "#DD000000"
		surfaceIcons = "Dark"
		
		accentColor = "#2EC4B6"
		accentBrush = "#2EC4B6"
		accentGrad0 = "#2EC4B6"
		accentGrad1 = "#2EC4B6"
		accentHighlight = "#40000000"
		accentText = "#DD000000"
		accentIcons = "Dark"

		gradientStrength = 2.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Holo" = [ordered]@{
		primaryColor = "#33B5E5"
		primaryBrush = "#33B5E5"
		primaryGrad0 = "#33B5E5"
		primaryGrad1 = "#33B5E5"
		primaryHighlight = "#40FFFFFF"
		primaryText = "#DDFFFFFF"
		primaryIcons = "Light"
		
		backgroundColor = "#272728"
		backgroundBrush = "#272728"
		backgroundGrad0 = "#000000"
		backgroundGrad1 = "#323232"
		backgroundHighlight = "#40FFFFFF"
		backgroundText = "#DDFFFFFF"
		backgroundIcons = "Light"
		
		surfaceColor = "#323232"
		surfaceBrush = "#323232"
		surfaceGrad0 = "#000000"
		surfaceGrad1 = "#323232"
		surfaceHighlight = "#40FFFFFF"
		surfaceText = "#DDFFFFFF"
		surfaceIcons = "Light"
		
		accentColor = "#33B5E5"
		accentBrush = "#33B5E5"
		accentGrad0 = "#33B5E5"
		accentGrad1 = "#33B5E5"
		accentHighlight = "#40FFFFFF"
		accentText = "#DDFFFFFF"
		accentIcons = "Light"
		
		gradientStrength = 1.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Modern" = [ordered]@{
		primaryColor = "#FFFFFF"
		primaryBrush = "#FFFFFF"
		primaryGrad0 = "#FFFFFF"
		primaryGrad1 = "#FFFFFF"
		primaryHighlight = "#40000000"
		primaryText = "#DD000000"
		primaryIcons = "Dark"
		
		backgroundColor = "#FFFFFF"
		backgroundBrush = "#FFFFFF"
		backgroundGrad0 = "#FFFFFF"
		backgroundGrad1 = "#FFFFFF"
		backgroundHighlight = "#40000000"
		backgroundText = "#DD000000"
		backgroundIcons = "Dark"
		
		surfaceColor = "#B0BEC5"
		surfaceBrush = "#B0BEC5"
		surfaceGrad0 = "#FFFFFF"
		surfaceGrad1 = "#B0BEC5"
		surfaceHighlight = "#40000000"
		surfaceText = "#DD000000"
		surfaceIcons = "Dark"
		
		accentColor = "#607D8B"
		accentBrush = "#607D8B"
		accentGrad0 = "#607D8B"
		accentGrad1 = "#607D8B"
		accentHighlight = "#40FFFFFF"
		accentText = "#DDFFFFFF"
		accentIcons = "Light"

		gradientStrength = 4.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Nautical" = [ordered]@{
		primaryColor = "#457B9D"
		primaryBrush = "#457B9D"
		primaryGrad0 = "#457B9D"
		primaryGrad1 = "#457B9D"
		primaryHighlight = "#40FFFFFF"
		primaryText = "#DDFFFFFF"
		primaryIcons = "Light"
		
		backgroundColor = "#E4F5F9"
		backgroundBrush = "#E4F5F9"
		backgroundGrad0 = "#E4F5F9"
		backgroundGrad1 = "#E4F5F9"
		backgroundHighlight = "#40000000"
		backgroundText = "#DD000000"
		backgroundIcons = "Dark"
		
		surfaceColor = "#D0F4DE"
		surfaceBrush = "#D0F4DE"
		surfaceGrad0 = "#FFFFFF"
		surfaceGrad1 = "#D0F4DE"
		surfaceHighlight = "#40000000"
		surfaceText = "#DD000000"
		surfaceIcons = "Dark"
		
		accentColor = "#3C6E71"
		accentBrush = "#3C6E71"
		accentGrad0 = "#3C6E71"
		accentGrad1 = "#3C6E71"
		accentHighlight = "#40FFFFFF"
		accentText = "#DDFFFFFF"
		accentIcons = "Light"

		gradientStrength = 4.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Pastel" = [ordered]@{
		primaryColor = "#F07167"
		primaryBrush = "#F07167"
		primaryGrad0 = "#F07167"
		primaryGrad1 = "#F07167"
		primaryHighlight = "#40000000"
		primaryText = "#DD000000"
		primaryIcons = "Dark"
		
		backgroundColor = "#FED9B7"
		backgroundBrush = "#FED9B7"
		backgroundGrad0 = "#FED9B7"
		backgroundGrad1 = "#FED9B7"
		backgroundHighlight = "#40000000"
		backgroundText = "#DD000000"
		backgroundIcons = "Dark"
		
		surfaceColor = "#FDFCDC"
		surfaceBrush = "#FDFCDC"
		surfaceGrad0 = "#FED9B7"
		surfaceGrad1 = "#FDFCDC"
		surfaceHighlight = "#40000000"
		surfaceText = "#DD000000"
		surfaceIcons = "Dark"
		
		accentColor = "#00AFB9"
		accentBrush = "#00AFB9"
		accentGrad0 = "#00AFB9"
		accentGrad1 = "#00AFB9"
		accentHighlight = "#40000000"
		accentText = "#DD000000"
		accentIcons = "Dark"

		gradientStrength = 2.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Ruby" = [ordered]@{
		primaryColor = "#EF233C"
		primaryBrush = "#EF233C"
		primaryGrad0 = "#EF233C"
		primaryGrad1 = "#EF233C"
		primaryHighlight = "#40FFFFFF"
		primaryText = "#DDFFFFFF"
		primaryIcons = "Light"
		
		backgroundColor = "#2B2D42"
		backgroundBrush = "#2B2D42"
		backgroundGrad0 = "#2B2D42"
		backgroundGrad1 = "#2B2D42"
		backgroundHighlight = "#40FFFFFF"
		backgroundText = "#DDFFFFFF"
		backgroundIcons = "Light"
		
		surfaceColor = "#8D99AE"
		surfaceBrush = "#8D99AE"
		surfaceGrad0 = "#2B2D42"
		surfaceGrad1 = "#8D99AE"
		surfaceHighlight = "#40FFFFFF"
		surfaceText = "#DDFFFFFF"
		surfaceIcons = "Light"
		
		accentColor = "#EDF2F4"
		accentBrush = "#EDF2F4"
		accentGrad0 = "#EDF2F4"
		accentGrad1 = "#EDF2F4"
		accentHighlight = "#40000000"
		accentText = "#DD000000"
		accentIcons = "Dark"

		gradientStrength = 2.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Sunset" = [ordered]@{
		primaryColor = "#3F215F"
		primaryBrush = "#3F215F"
		primaryGrad0 = "#3F215F"
		primaryGrad1 = "#3F215F"
		primaryHighlight = "#40FFFFFF"
		primaryText = "#DDFFFFFF"
		primaryIcons = "Light"
		
		backgroundColor = "#6A0D83"
		backgroundBrush = "#6A0D83"
		backgroundGrad0 = "#6A0D83"
		backgroundGrad1 = "#6A0D83"
		backgroundHighlight = "#40FFFFFF"
		backgroundText = "#DDFFFFFF"
		backgroundIcons = "Light"
		
		surfaceColor = "#EE5D6C"
		surfaceBrush = "#EE5D6C"
		surfaceGrad0 = "#6A0D83"
		surfaceGrad1 = "#EE5D6C"
		surfaceHighlight = "#40FFFFFF"
		surfaceText = "#DDFFFFFF"
		surfaceIcons = "Light"
		
		accentColor = "#EEAF61"
		accentBrush = "#EEAF61"
		accentGrad0 = "#EEAF61"
		accentGrad1 = "#EEAF61"
		accentHighlight = "#40000000"
		accentText = "#DD000000"
		accentIcons = "Dark"

		gradientStrength = 2.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
	
	"Verdant" = [ordered]@{
		primaryColor = "#283618"
		primaryBrush = "#283618"
		primaryGrad0 = "#283618"
		primaryGrad1 = "#283618"
		primaryHighlight = "#40FFFFFF"
		primaryText = "#DDFFFFFF"
		primaryIcons = "Light"
		
		backgroundColor = "#606C38"
		backgroundBrush = "#606C38"
		backgroundGrad0 = "#606C38"
		backgroundGrad1 = "#606C38"
		backgroundHighlight = "#40FFFFFF"
		backgroundText = "#DDFFFFFF"
		backgroundIcons = "Light"
		
		surfaceColor = "#FEFAE0"
		surfaceBrush = "#FEFAE0"
		surfaceGrad0 = "#FEFAE0"
		surfaceGrad1 = "#FEFAE0"
		surfaceHighlight = "#40000000"
		surfaceText = "#DD000000"
		surfaceIcons = "Dark"
		
		accentColor = "#DDA15E"
		accentBrush = "#DDA15E"
		accentGrad0 = "#DDA15E"
		accentGrad1 = "#DDA15E"
		accentHighlight = "#40000000"
		accentText = "#DD000000"
		accentIcons = "Dark"

		gradientStrength = 2.0
		shadowBlur = 20.0
		shadowDepth = 10.0
		cornerStrength = 8.0
	}
}
