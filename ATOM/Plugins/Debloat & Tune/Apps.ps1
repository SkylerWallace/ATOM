$apps = [ordered]@{
    'Amazon' = @{
        PackageName = "Amazon.com.Amazon"
        PublisherId = "343d40qqvtj1t"
        Important = $true
    }
    'Amazon Alexa' = @{
        PackageName = "57540AMZNMobileLLC.AmazonAlexa"
        PublisherId = "22t9g3sebte08"
    }
    'Amazon Prime Video' = @{
        PackageName = "AmazonVideo.PrimeVideo"
        PublisherId = "pwbj9vvecjh7j"
    }
    'Booking.com' = @{
        PackageName = "PricelinePartnerNetwork.Booking.comUSABigsavingson"
        PublisherId = "mgae2k3ys4ra0"
    }
    'Candy Crush Friends' = @{
        PackageName = "king.com.CandyCrushFriends"
        PublisherId = "kgqvnymyfvs32"
    }
    'Candy Crush Saga' = @{
        PackageName = "king.com.CandyCrushSaga"
        PublisherId = "kgqvnymyfvs32"
    }
    'Clipchamp' = @{
        PackageName = "Clipchamp.Clipchamp"
        PublisherId = "yxz26nhyzhsrt"
    }
    'Dropbox for S-Mode' = @{
        PackageName = "C27EB4BA.Dropbox"
        PublisherId = "xbfy0k16fey96"
    }
    'Dropbox Promotion' = @{
        PackageName = "C27EB4BA.DropboxOEM"
        PublisherId = "xbfy0k16fey96"
    }
    'DisneyPlus' = @{
        PackageName = "Disney.37853FC22B2CE"
        PublisherId = "6rarf9sa4v8jt"
    }
    'Dolby Access' = @{
        PackageName = "DolbyLaboratories.DolbyAccess"
        PublisherId = "rz1tebttyb220"
    }
    'ESPN' = @{
        PackageName = "22364Disney.ESPNBetaPWA"
        PublisherId = "6rarf9sa4v8jt"
    }
    'Facebook' = @{
        PackageName = "FACEBOOK.FACEBOOK"
        PublisherId = "8xx8rvfyw5nnt"
    }
    'Family' = @{
        PackageName = "MicrosoftCorporationII.MicrosoftFamily"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Feedback Hub' = @{
        PackageName = "Microsoft.WindowsFeedbackHub"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Hulu' = @{
        PackageName = "HULULLC.HULUPLUS"
        PublisherId = "fphbd361v8tya"
    }
    'Instagram' = @{
        PackageName = "Facebook.InstagramBeta"
        PublisherId = "8xx8rvfyw5nnt"
    }
    'Messenger' = @{
        PackageName = "FACEBOOK.317180B0BB486"
        PublisherId = "8xx8rvfyw5nnt"
    }
    'Microsoft Journal' = @{
        PackageName = "Microsoft.MicrosoftJournal"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Microsoft News' = @{
        PackageName = "Microsoft.BingNews"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Microsoft Sudoku' = @{
        PackageName = "Microsoft.MicrosoftSudoku"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Microsoft Teams' = @{
        PackageName = "MicrosoftTeams"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Microsoft Weather' = @{
        PackageName = "Microsoft.BingWeather"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Microsoft To Do' = @{
        PackageName = "Microsoft.Todos"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Microsoft Whiteboard' = @{
        PackageName = "Microsoft.Whiteboard"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Minecraft Education Edition' = @{
        PackageName = "Microsoft.MinecraftEducationEdition"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Mixed Reality PortalNetflix' = @{
        PackageName = "Microsoft.MixedReality.Portal"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Netflix' = @{
        PackageName = "4DF9E0F8.Netflix"
        PublisherId = "mcm4njqhnhss8"
    }
    'People' = @{
        PackageName = "Microsoft.People"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Phone Link' = @{
        PackageName = "Microsoft.YourPhone"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Realtek Audio Console' = @{
        PackageName = "RealtekSemiconductorCorp.RealtekAudioControl"
        PublisherId = "dt26b99r8h8gj"
        Important = $true
    }
    'Skype' = @{
        PackageName = "Microsoft.SkypeApp"
        PublisherId = "kzf8qxf38zg5c"
    }
    'Spotify' = @{
        PackageName = "SpotifyAB.SpotifyMusic"
        PublisherId = "zpdnekdrzrea0"
    }
    'Sticky Notes' = @{
        PackageName = "Microsoft.MicrosoftStickyNotes"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Tiktok' = @{
        PackageName = "BytedancePte.Ltd.TikTok"
        PublisherId = "6yccndn6064se"
    }
    'Tips' = @{
        PackageName = "Microsoft.Getstarted"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Twitter' = @{
        PackageName = "9E2F88E3.TWITTER"
        PublisherId = "wgeqdkkx372wm"
    }
    'WhatsApp' = @{
        PackageName = "5319275A.WhatsAppDesktop"
        PublisherId = "cv1g1gvanyjgm"
    }
    'Windows Maps' = @{
        PackageName = "Microsoft.WindowsMaps"
        PublisherId = "8wekyb3d8bbwe"
    }
    'Xbox' = @{
        PackageName = "Microsoft.GamingApp"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Xbox Console Companion' = @{
        PackageName = "Microsoft.XboxApp"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Xbox Game Bar' = @{
        PackageName = "Microsoft.XboxGamingOverlay"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Xbox Game Bar Plugin' = @{
        PackageName = "Microsoft.XboxGameOverlay"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Xbox Identity Provider' = @{
        PackageName = "Microsoft.XboxIdentityProvider"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Xbox Game Speech Window' = @{
        PackageName = "Microsoft.XboxSpeechToTextOverlay"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
    'Xbox Live' = @{
        PackageName = "Microsoft.Xbox.TCUI"
        PublisherId = "8wekyb3d8bbwe"
        Important = $true
    }
# Acer OEM MS Store Apps
# ASUS OEM MS Store Apps
    'Armoury Crate' = @{
        PackageName = "B9ECED6F.ArmouryCrate"
        PublisherId = "qmba6cd70vzyy"
        Important = $true
    }
    'Aura Creator' = @{
        PackageName = "B9ECED6F.AURACreator"
        PublisherId = "qmba6cd70vzyy"
        Important = $true
    }
    'MyASUS' = @{
        PackageName = "B9ECED6F.ASUSPCAssistant"
        PublisherId = "qmba6cd70vzyy"
        Important = $true
    }
# Dell OEM MS Store Apps
    'Dell Cinema Color' = @{
        PackageName = "PortraitDisplays.DellCinemaColor"
        PublisherId = "2dgmkzkw4h30c"
        Important = $true
    }
    'Dell Customer Connect' = @{
        PackageName = "DellInc.DellCustomerConnect"
        PublisherId = "htrsf667h5kn2"
    }
    'Dell Digital Delivery' = @{
        PackageName = "DellInc.DellDigitalDelivery"
        PublisherId = "htrsf667h5kn2"
    }
    'Dell SupportAssist' = @{
        PackageName = "DellInc.DellSupportAssistforPCs"
        PublisherId = "htrsf667h5kn2"
        Important = $true
    }
    'Killer Control Center' = @{
        PackageName = "RivetNetworks.KillerControlCenter"
        PublisherId = "rh07ty8m5nkag"
    }
    'My Dell' = @{
        PackageName = "DellInc.MyDell"
        PublisherId = "htrsf667h5kn2"
    }
    'SmartByte' = @{
        PackageName = "RivetNetworks.SmartByte"
        PublisherId = "rh07ty8m5nkag"
    }
    'Waves MaxxAudio' = @{
        PackageName = "WavesAudio.MaxxAudioProforDell2022"
        PublisherId = "fh4rh281wavaa"
        Important = $true
    }
# HP OEM MS Store Apps
    'Bang & Olufsen Audio Control' = @{
        PackageName = "AD2F1837.BangOlufsenAudioControl"
        PublisherId = "v10z8vjag6ke6"
        Important = $true
    }
    'Energy Star' = @{
        PackageName = "AD2F1837.HPInc.EnergyStar"
        PublisherId = "v10z8vjag6ke6"
    }
    'HP Audio Center' = @{
        PackageName = "AD2F1837.HPAudioCenter"
        PublisherId = "v10z8vjag6ke6"
    }
    'HP Command Center' = @{
        PackageName = "AD2F1837.HPThermalControl"
        PublisherId = "v10z8vjag6ke6"
        Important = $true
    }
    'HP Enhanced Lighting' = @{
        PackageName = "AD2F1837.HPEnhance"
        PublisherId = "v10z8vjag6ke6"
    }
    'HP JumpStart' = @{
        PackageName = "AD2F1837.HPJumpStarts"
        PublisherId = "v10z8vjag6ke6"
    }
    'HP Pen Control Plus' = @{
        PackageName = "AD2F1837.HPPenControlPlus"
        PublisherId = "v10z8vjag6ke6"
        Important = $true
    }
    'HP Privacy Settings' = @{
        PackageName = "AD2F1837.HPPrivacySettings"
        PublisherId = "v10z8vjag6ke6"
    }
    'HP QuickDrop' = @{
        PackageName = "AD2F1837.HPQuickDrop"
        PublisherId = "v10z8vjag6ke6"
    }
    'HP Smart' = @{
        PackageName = "AD2F1837.HPInc.EnergyStar"
        PublisherId = "v10z8vjag6ke6"
        Important = $true
    }
    'HP System Event Utility' = @{
        PackageName = "AD2F1837.HPSystemEventUtility"
        PublisherId = "v10z8vjag6ke6"
        Important = $true
    }
    'MyHP' = @{
        PackageName = "AD2F1837.myHP"
        PublisherId = "v10z8vjag6ke6"
    }
    'Omen Gaming Hub' = @{
        PackageName = "AD2F1837.OMENCommandCenter"
        PublisherId = "v10z8vjag6ke6"
        Important = $true
    }
    'Random Salad Games Solitaire' = @{
        PackageName = "26720RandomSaladGamesLLC.3899848563C1F"
        PublisherId = "kx24dqmazqk8j"
    }
    'Random Salad Games Solitaire |Alt|' = @{
        PackageName = "26720RandomSaladGamesLLC.SimpleSolitaire"
        PublisherId = "kx24dqmazqk8j"
    }
# Lenovo OEM MS Store Apps
    'Lenovo Hotkeys' = @{
        PackageName = "E0469640.LenovoUtility"
        PublisherId = "5grkq8ppsgwt4"
        Important = $true
    }
    'Lenovo Pen' = @{
        PackageName = "WacomTechnologyCorp.157535B83C264"
        PublisherId = "ss941bf8mfs8a"
        Important = $true
    }
    'Lenovo Smart Appearance' = @{
        PackageName = "E0469640.SmartAppearance"
        PublisherId = "5grkq8ppsgwt4"
        Important = $true
    }
    'Lenovo Voice' = @{
        PackageName = "E046963F.LenovoVoiceWorldWide"
        PublisherId = "k1h2ywk1493x8"
    }
    'Mirkat' = @{
        PackageName = "Mirkat.Mirkat"
        PublisherId = "hm0vq9nycmfde"
    }
# MSI OEM MS Store Apps
# Razer OEM MS Store Apps
# Samsung OEM MS Store Apps
}
