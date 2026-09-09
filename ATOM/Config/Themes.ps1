# Gradient settings may be overridden by any individual theme.
# gradientStyle accepts Radial, Linear, or None.
$themeGradientDefaults = [ordered]@{
    gradientStyle = "Radial"
    gradientInterpolation = "ScRgb"
    linearGradientStart = "0,0"
    linearGradientEnd = "1,1"
    panelGradientCenter = "0.16,0.10"
    panelGradientOrigin = "0.02,0.02"
    panelGradientRadiusX = $null
    panelGradientRadiusY = 1.1
    panelGradientMidpoint = 0.55
    listGradientCenter = "0.5,0"
    listGradientOrigin = "0.5,-0.2"
    listGradientRadiusX = 0.9
    listGradientRadiusY = $null
    listGradientMidpoint = 0.5
}

$themeShadowDefaults = [ordered]@{
    shadowColor = "#000000"
    shadowOpacity = 0.2
    shadowDirection = 315.0
}

$themes = [ordered]@{
    "Atomic" = [ordered]@{
        primaryColor = "#E37222"
        primaryBrush = "#E37222"
        primaryGrad0 = "#E37222"
        primaryGrad1 = "#F59B2B"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#272728"
        backgroundBrush = "#272728"
        backgroundGrad0 = "#272728"
        backgroundGrad1 = "#272728"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#49494A"
        surfaceBrush = "#49494A"
        surfaceGrad0 = "#2F2F30"
        surfaceGrad1 = "#49494A"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#C3C4C4"
        accentBrush = "#C3C4C4"
        accentGrad0 = "#C3C4C4"
        accentGrad1 = "#C3C4C4"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 1.5
        gradientStyle = "Radial"
        gradientInterpolation = "SRgb"
        panelGradientCenter = "0.12,0.08"
        panelGradientOrigin = "0.04,0.02"
        panelGradientRadiusX = 1.5
        panelGradientRadiusY = 1.5
        panelGradientMidpoint = 1
        listGradientCenter = "0.5,0"
        listGradientOrigin = "0.5,-0.05"
        listGradientRadiusX = 1.5
        listGradientRadiusY = 1.5
        listGradientMidpoint = 0.75

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Beach" = [ordered]@{
        primaryColor = "#007C91"
        primaryBrush = "#007C91"
        primaryGrad0 = "#006D77"
        primaryGrad1 = "#087A82"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#F2D6A2"
        backgroundBrush = "#F2D6A2"
        backgroundGrad0 = "#F7E4BD"
        backgroundGrad1 = "#E7C47F"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#D8F3ED"
        surfaceBrush = "#D8F3ED"
        surfaceGrad0 = "#EAFBF7"
        surfaceGrad1 = "#BFE8E0"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#FF7F50"
        accentBrush = "#FF7F50"
        accentGrad0 = "#FF7F50"
        accentGrad1 = "#F4A261"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Celadon" = [ordered]@{
        primaryColor = "#3F6F67"
        primaryBrush = "#3F6F67"
        primaryGrad0 = "#315851"
        primaryGrad1 = "#4B7E74"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#F4F1E8"
        backgroundBrush = "#F4F1E8"
        backgroundGrad0 = "#FCFAF5"
        backgroundGrad1 = "#E7E2D4"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#B8D8C8"
        surfaceBrush = "#B8D8C8"
        surfaceGrad0 = "#D3E8DE"
        surfaceGrad1 = "#9FC8B5"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#A6404E"
        accentBrush = "#A6404E"
        accentGrad0 = "#84323E"
        accentGrad1 = "#B94F5C"
        accentHighlight = "#40FFFFFF"
        accentText = "#DDFFFFFF"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Cyber" = [ordered]@{
        primaryColor = "#F3E600"
        primaryBrush = "#F3E600"
        primaryGrad0 = "#DFD000"
        primaryGrad1 = "#FFF455"
        primaryHighlight = "#24000000"
        primaryText = "#FF141820"

        backgroundColor = "#090F18"
        backgroundBrush = "#090F18"
        backgroundGrad0 = "#060A11"
        backgroundGrad1 = "#111D2C"
        backgroundHighlight = "#30FFFFFF"
        backgroundText = "#FFFFFFFF"

        surfaceColor = "#172838"
        surfaceBrush = "#172838"
        surfaceGrad0 = "#101E2C"
        surfaceGrad1 = "#22384A"
        surfaceHighlight = "#30FFFFFF"
        surfaceText = "#FFFFFFFF"

        accentColor = "#48E5F0"
        accentBrush = "#48E5F0"
        accentGrad0 = "#22CAD8"
        accentGrad1 = "#78F2F7"
        accentHighlight = "#24000000"
        accentText = "#FF141820"

        gradientStrength = 1.5
        gradientStyle = "Radial"

        shadowColor = "#22D9E8"
        shadowOpacity = 0.55
        shadowBlur = 18.0
        shadowDepth = 0.0
        shadowDirection = 0.0

        cornerStrength = 4.0
    }

    "Daybreak" = [ordered]@{
        primaryColor = "#282342"
        primaryBrush = "#282342"
        primaryGrad0 = "#1D1932"
        primaryGrad1 = "#3B315B"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#B82E43"
        backgroundBrush = "#B82E43"
        backgroundGrad0 = "#8F2234"
        backgroundGrad1 = "#C83A4D"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#F06A3C"
        surfaceBrush = "#F06A3C"
        surfaceGrad0 = "#E9502E"
        surfaceGrad1 = "#FF8A4C"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#FFD166"
        accentBrush = "#FFD166"
        accentGrad0 = "#F7B733"
        accentGrad1 = "#FFE08A"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Espresso" = [ordered]@{
        primaryColor = "#D7B58A"
        primaryBrush = "#D7B58A"
        primaryGrad0 = "#C59A69"
        primaryGrad1 = "#E5CBA8"
        primaryHighlight = "#24000000"
        primaryText = "#FF141820"

        backgroundColor = "#211813"
        backgroundBrush = "#211813"
        backgroundGrad0 = "#17110D"
        backgroundGrad1 = "#30221A"
        backgroundHighlight = "#30FFFFFF"
        backgroundText = "#FFFFFFFF"

        surfaceColor = "#443127"
        surfaceBrush = "#443127"
        surfaceGrad0 = "#34241D"
        surfaceGrad1 = "#543D30"
        surfaceHighlight = "#30FFFFFF"
        surfaceText = "#FFFFFFFF"

        accentColor = "#BBD0A3"
        accentBrush = "#BBD0A3"
        accentGrad0 = "#A7BE8C"
        accentGrad1 = "#D0DFC0"
        accentHighlight = "#24000000"
        accentText = "#FF141820"

        gradientStrength = 1.5
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Graphite" = [ordered]@{
        primaryColor = "#2A2A2A"
        primaryBrush = "#2A2A2A"
        primaryGrad0 = "#161616"
        primaryGrad1 = "#3A3A3A"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"
        controlBrush = "#D0D0D0"
        controlText = "#DD000000"

        backgroundColor = "#101010"
        backgroundBrush = "#101010"
        backgroundGrad0 = "#080808"
        backgroundGrad1 = "#181818"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#2D2D2D"
        surfaceBrush = "#2D2D2D"
        surfaceGrad0 = "#202020"
        surfaceGrad1 = "#3A3A3A"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#D0D0D0"
        accentBrush = "#D0D0D0"
        accentGrad0 = "#B8B8B8"
        accentGrad1 = "#E2E2E2"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 4.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Lagoon" = [ordered]@{
        primaryColor = "#58D4BE"
        primaryBrush = "#58D4BE"
        primaryGrad0 = "#36BBA7"
        primaryGrad1 = "#84E6D1"
        primaryHighlight = "#24000000"
        primaryText = "#FF141820"

        backgroundColor = "#08272C"
        backgroundBrush = "#08272C"
        backgroundGrad0 = "#051C21"
        backgroundGrad1 = "#10373E"
        backgroundHighlight = "#30FFFFFF"
        backgroundText = "#FFFFFFFF"

        surfaceColor = "#16464E"
        surfaceBrush = "#16464E"
        surfaceGrad0 = "#103740"
        surfaceGrad1 = "#215861"
        surfaceHighlight = "#30FFFFFF"
        surfaceText = "#FFFFFFFF"

        accentColor = "#F1C590"
        accentBrush = "#F1C590"
        accentGrad0 = "#DFAD72"
        accentGrad1 = "#F8DDBA"
        accentHighlight = "#24000000"
        accentText = "#FF141820"

        gradientStrength = 1.5
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Marigold" = [ordered]@{
        primaryColor = "#8A5A00"
        primaryBrush = "#8A5A00"
        primaryGrad0 = "#704700"
        primaryGrad1 = "#9A6700"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#FFF8E1"
        backgroundBrush = "#FFF8E1"
        backgroundGrad0 = "#FFFDF5"
        backgroundGrad1 = "#F5E6B3"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#FFE7A3"
        surfaceBrush = "#FFE7A3"
        surfaceGrad0 = "#FFF2C7"
        surfaceGrad1 = "#EAC66D"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#A63D12"
        accentBrush = "#A63D12"
        accentGrad0 = "#8F3210"
        accentGrad1 = "#B74718"
        accentHighlight = "#40FFFFFF"
        accentText = "#DDFFFFFF"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Midnight" = [ordered]@{
        primaryColor = "#5865F2"
        primaryBrush = "#5865F2"
        primaryGrad0 = "#5865F2"
        primaryGrad1 = "#7C83FF"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#0D1117"
        backgroundBrush = "#0D1117"
        backgroundGrad0 = "#090C10"
        backgroundGrad1 = "#161B22"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#161B22"
        surfaceBrush = "#161B22"
        surfaceGrad0 = "#0D1117"
        surfaceGrad1 = "#21262D"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#58A6FF"
        accentBrush = "#58A6FF"
        accentGrad0 = "#58A6FF"
        accentGrad1 = "#58A6FF"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 1.5
        gradientStyle = "Radial"

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
        controlBrush = "#607D8B"
        controlText = "#DDFFFFFF"

        backgroundColor = "#FFFFFF"
        backgroundBrush = "#FFFFFF"
        backgroundGrad0 = "#FFFFFF"
        backgroundGrad1 = "#FFFFFF"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#B0BEC5"
        surfaceBrush = "#B0BEC5"
        surfaceGrad0 = "#FFFFFF"
        surfaceGrad1 = "#B0BEC5"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#607D8B"
        accentBrush = "#607D8B"
        accentGrad0 = "#607D8B"
        accentGrad1 = "#607D8B"
        accentHighlight = "#40FFFFFF"
        accentText = "#DDFFFFFF"

        gradientStrength = 4.0
        gradientStyle = "Radial"
        panelGradientCenter = "0.5,0.1"
        panelGradientOrigin = "0.5,0.0"
        panelGradientRadiusX = 3
        panelGradientRadiusY = 2.5
        panelGradientMidpoint = 0.95
        listGradientCenter = "0.5,0.1"
        listGradientOrigin = "0.5,0.0"
        listGradientRadiusX = 3
        listGradientRadiusY = 2.5
        listGradientMidpoint = 0.95

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Mystic" = [ordered]@{
        primaryColor = "#6B3A75"
        primaryBrush = "#6B3A75"
        primaryGrad0 = "#4E2858"
        primaryGrad1 = "#75417F"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"
        controlBrush = "#4FBFA5"
        controlText = "#DD000000"

        backgroundColor = "#17111C"
        backgroundBrush = "#17111C"
        backgroundGrad0 = "#0E0A12"
        backgroundGrad1 = "#24172B"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#35203F"
        surfaceBrush = "#35203F"
        surfaceGrad0 = "#281832"
        surfaceGrad1 = "#4B2A56"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#4FBFA5"
        accentBrush = "#4FBFA5"
        accentGrad0 = "#3AA58F"
        accentGrad1 = "#6ED0B9"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 1.5
        gradientStyle = "Radial"

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

        backgroundColor = "#E4F5F9"
        backgroundBrush = "#E4F5F9"
        backgroundGrad0 = "#E4F5F9"
        backgroundGrad1 = "#E4F5F9"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#D0F4DE"
        surfaceBrush = "#D0F4DE"
        surfaceGrad0 = "#FFFFFF"
        surfaceGrad1 = "#D0F4DE"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#3C6E71"
        accentBrush = "#3C6E71"
        accentGrad0 = "#3C6E71"
        accentGrad1 = "#3C6E71"
        accentHighlight = "#40FFFFFF"
        accentText = "#DDFFFFFF"

        gradientStrength = 4.0
        gradientStyle = "Radial"
        panelGradientCenter = "0.5,0.1"
        panelGradientOrigin = "0.5,0.0"
        panelGradientRadiusX = 2
        panelGradientRadiusY = 1.5
        panelGradientMidpoint = 1
        listGradientCenter = "0.5,0.1"
        listGradientOrigin = "0.5,0.0"
        listGradientRadiusX = 2
        listGradientRadiusY = 1.5
        listGradientMidpoint = 1

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Neon" = [ordered]@{
        primaryColor = "#F000FF"
        primaryBrush = "#F000FF"
        primaryGrad0 = "#E500F5"
        primaryGrad1 = "#FF3DF2"
        primaryHighlight = "#40000000"
        primaryText = "#DD000000"

        backgroundColor = "#08090B"
        backgroundBrush = "#08090B"
        backgroundGrad0 = "#030405"
        backgroundGrad1 = "#111318"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#1B1E22"
        surfaceBrush = "#1B1E22"
        surfaceGrad0 = "#101216"
        surfaceGrad1 = "#272B31"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#A8FF00"
        accentBrush = "#A8FF00"
        accentGrad0 = "#7FD900"
        accentGrad1 = "#C6FF3D"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 1.0
        gradientStyle = "Radial"

        shadowColor = "#F000FF"
        shadowOpacity = 0.6
        shadowBlur = 18.0
        shadowDepth = 0.0
        shadowDirection = 0.0

        cornerStrength = 8.0
    }

    "Nightfall" = [ordered]@{
        primaryColor = "#47405F"
        primaryBrush = "#47405F"
        primaryGrad0 = "#332D49"
        primaryGrad1 = "#544C70"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"
        controlBrush = "#D6A84F"
        controlText = "#DD000000"

        backgroundColor = "#090B12"
        backgroundBrush = "#090B12"
        backgroundGrad0 = "#05060B"
        backgroundGrad1 = "#131621"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#242838"
        surfaceBrush = "#242838"
        surfaceGrad0 = "#191C29"
        surfaceGrad1 = "#30364A"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#D6A84F"
        accentBrush = "#D6A84F"
        accentGrad0 = "#B88B36"
        accentGrad1 = "#E5C06C"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 1.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Nord" = [ordered]@{
        primaryColor = "#4C6A92"
        primaryBrush = "#4C6A92"
        primaryGrad0 = "#4C6A92"
        primaryGrad1 = "#5E81AC"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#2E3440"
        backgroundBrush = "#2E3440"
        backgroundGrad0 = "#242933"
        backgroundGrad1 = "#2E3440"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#3B4252"
        surfaceBrush = "#3B4252"
        surfaceGrad0 = "#2E3440"
        surfaceGrad1 = "#434C5E"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#88C0D0"
        accentBrush = "#88C0D0"
        accentGrad0 = "#88C0D0"
        accentGrad1 = "#8FBCBB"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 1.5
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Olive" = [ordered]@{
        primaryColor = "#C3C77A"
        primaryBrush = "#C3C77A"
        primaryGrad0 = "#ADB263"
        primaryGrad1 = "#D9DC98"
        primaryHighlight = "#24000000"
        primaryText = "#FF141820"

        backgroundColor = "#1D2113"
        backgroundBrush = "#1D2113"
        backgroundGrad0 = "#13170C"
        backgroundGrad1 = "#2B311C"
        backgroundHighlight = "#30FFFFFF"
        backgroundText = "#FFFFFFFF"

        surfaceColor = "#3B4328"
        surfaceBrush = "#3B4328"
        surfaceGrad0 = "#2B331D"
        surfaceGrad1 = "#4B5434"
        surfaceHighlight = "#30FFFFFF"
        surfaceText = "#FFFFFFFF"

        accentColor = "#EDCAA0"
        accentBrush = "#EDCAA0"
        accentGrad0 = "#DDB886"
        accentGrad1 = "#F5DFC3"
        accentHighlight = "#24000000"
        accentText = "#FF141820"

        gradientStrength = 1.5
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Pastel" = [ordered]@{
        primaryColor = "#776A8B"
        primaryBrush = "#776A8B"
        primaryGrad0 = "#695D7C"
        primaryGrad1 = "#786A84"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#F4F0EC"
        backgroundBrush = "#F4F0EC"
        backgroundGrad0 = "#FAF8F5"
        backgroundGrad1 = "#E8E0D8"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#DCD5E3"
        surfaceBrush = "#DCD5E3"
        surfaceGrad0 = "#EEE9F1"
        surfaceGrad1 = "#CDC3D6"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#8A9A7B"
        accentBrush = "#8A9A7B"
        accentGrad0 = "#8A9A7B"
        accentGrad1 = "#A7B49D"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Retro" = [ordered]@{
        primaryColor = "#B23A2B"
        primaryBrush = "#B23A2B"
        primaryGrad0 = "#8F2D24"
        primaryGrad1 = "#B9472C"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#F1E0C5"
        backgroundBrush = "#F1E0C5"
        backgroundGrad0 = "#FBF3E4"
        backgroundGrad1 = "#DFC79F"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#376996"
        surfaceBrush = "#376996"
        surfaceGrad0 = "#2D557A"
        surfaceGrad1 = "#467394"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#D66A2C"
        accentBrush = "#D66A2C"
        accentGrad0 = "#D0642C"
        accentGrad1 = "#E88745"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Ruby" = [ordered]@{
        primaryColor = "#A4133C"
        primaryBrush = "#A4133C"
        primaryGrad0 = "#800F2F"
        primaryGrad1 = "#C9184A"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#160A0E"
        backgroundBrush = "#160A0E"
        backgroundGrad0 = "#0B0507"
        backgroundGrad1 = "#241016"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#4A1826"
        surfaceBrush = "#4A1826"
        surfaceGrad0 = "#32101A"
        surfaceGrad1 = "#651F32"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#E7C6A5"
        accentBrush = "#E7C6A5"
        accentGrad0 = "#D9B08C"
        accentGrad1 = "#F3D8BD"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Sakura" = [ordered]@{
        primaryColor = "#AD1457"
        primaryBrush = "#AD1457"
        primaryGrad0 = "#AD1457"
        primaryGrad1 = "#C2185B"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#FFF7FA"
        backgroundBrush = "#FFF7FA"
        backgroundGrad0 = "#FFF7FA"
        backgroundGrad1 = "#FCE4EC"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#F8BBD0"
        surfaceBrush = "#F8BBD0"
        surfaceGrad0 = "#FCE4EC"
        surfaceGrad1 = "#F8BBD0"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#6A1B9A"
        accentBrush = "#6A1B9A"
        accentGrad0 = "#6A1B9A"
        accentGrad1 = "#8E24AA"
        accentHighlight = "#40FFFFFF"
        accentText = "#DDFFFFFF"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Sunset" = [ordered]@{
        primaryColor = "#3D1E5A"
        primaryBrush = "#3D1E5A"
        primaryGrad0 = "#321747"
        primaryGrad1 = "#5A2A72"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"
        controlBrush = "#F4A261"
        controlText = "#DD000000"

        backgroundColor = "#25163F"
        backgroundBrush = "#25163F"
        backgroundGrad0 = "#1E1433"
        backgroundGrad1 = "#43235F"
        backgroundHighlight = "#40FFFFFF"
        backgroundText = "#DDFFFFFF"

        surfaceColor = "#6D3A73"
        surfaceBrush = "#6D3A73"
        surfaceGrad0 = "#A14C78"
        surfaceGrad1 = "#4F2A68"
        surfaceHighlight = "#40FFFFFF"
        surfaceText = "#DDFFFFFF"

        accentColor = "#F4A261"
        accentBrush = "#F4A261"
        accentGrad0 = "#F4A261"
        accentGrad1 = "#F6BD7A"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 4.0
        gradientStyle = "Radial"
        panelGradientCenter = "0.5,0.9"
        panelGradientOrigin = "0.5,1.1"
        panelGradientRadiusX = 3
        panelGradientRadiusY = 1.5
        panelGradientMidpoint = 0.25
        listGradientCenter = "0.5,0.9"
        listGradientOrigin = "0.5,1.1"
        listGradientRadiusX = 3
        listGradientRadiusY = 1.5
        listGradientMidpoint = 0.25

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Terracotta" = [ordered]@{
        primaryColor = "#9C4429"
        primaryBrush = "#9C4429"
        primaryGrad0 = "#7F3522"
        primaryGrad1 = "#A94F35"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#F4E4D4"
        backgroundBrush = "#F4E4D4"
        backgroundGrad0 = "#FBF3EA"
        backgroundGrad1 = "#E5C7AF"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#D8B4A0"
        surfaceBrush = "#D8B4A0"
        surfaceGrad0 = "#E8D0C1"
        surfaceGrad1 = "#C9987E"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#556B2F"
        accentBrush = "#556B2F"
        accentGrad0 = "#465A27"
        accentGrad1 = "#667A3A"
        accentHighlight = "#40FFFFFF"
        accentText = "#DDFFFFFF"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Verdant" = [ordered]@{
        primaryColor = "#2F5D50"
        primaryBrush = "#2F5D50"
        primaryGrad0 = "#23483D"
        primaryGrad1 = "#3A6B5B"
        primaryHighlight = "#40FFFFFF"
        primaryText = "#DDFFFFFF"

        backgroundColor = "#DCE8D5"
        backgroundBrush = "#DCE8D5"
        backgroundGrad0 = "#E8F0E3"
        backgroundGrad1 = "#CFDFC8"
        backgroundHighlight = "#40000000"
        backgroundText = "#DD000000"

        surfaceColor = "#BFD8B8"
        surfaceBrush = "#BFD8B8"
        surfaceGrad0 = "#D7E8D1"
        surfaceGrad1 = "#A9C9A2"
        surfaceHighlight = "#40000000"
        surfaceText = "#DD000000"

        accentColor = "#5F8F63"
        accentBrush = "#5F8F63"
        accentGrad0 = "#5F8F63"
        accentGrad1 = "#7EAA71"
        accentHighlight = "#40000000"
        accentText = "#DD000000"

        gradientStrength = 2.0
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }

    "Wisteria" = [ordered]@{
        primaryColor = "#594581"
        primaryBrush = "#594581"
        primaryGrad0 = "#453268"
        primaryGrad1 = "#68538F"
        primaryHighlight = "#30FFFFFF"
        primaryText = "#FFFFFFFF"

        backgroundColor = "#F1ECFA"
        backgroundBrush = "#F1ECFA"
        backgroundGrad0 = "#FAF7FF"
        backgroundGrad1 = "#E4DCF1"
        backgroundHighlight = "#24000000"
        backgroundText = "#FF141820"

        surfaceColor = "#D6C9E9"
        surfaceBrush = "#D6C9E9"
        surfaceGrad0 = "#E8DFF4"
        surfaceGrad1 = "#C6B5DE"
        surfaceHighlight = "#24000000"
        surfaceText = "#FF141820"

        accentColor = "#365D7D"
        accentBrush = "#365D7D"
        accentGrad0 = "#294962"
        accentGrad1 = "#426C8D"
        accentHighlight = "#30FFFFFF"
        accentText = "#FFFFFFFF"

        gradientStrength = 1.5
        gradientStyle = "Radial"

        shadowBlur = 20.0
        shadowDepth = 10.0

        cornerStrength = 8.0
    }
}
