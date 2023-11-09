<#
	Metro apps array
	(0, 1, 2)
	Element 0 = app name
	Element 1 = user data path
	Element 2 = debloat mode threshold (Safe, Balanced, Aggressive)
#>
$apps = @(
# General MS Store Apps
#	@("Amazon", "Amazon.com.Amazon_343d40qqvtj1t", "1"),
	@("Amazon Alexa", "57540AMZNMobileLLC.AmazonAlexa_22t9g3sebte08\LocalState\Alexa", "1"),
	@("Amazon Prime Video", "AmazonVideo.PrimeVideo_pwbj9vvecjh7j\LocalCache\Roaming", "1"),
	@("Booking.com", "PricelinePartnerNetwork.Booking.comUSABigsavingson_mgae2k3ys4ra0\DUMMYDIR", "1"),
	@("Candy Crush Friends", "king.com.CandyCrushFriends_kgqvnymyfvs32\LocalState\Documents", "1"),
	@("Candy Crush Saga", "king.com.CandyCrushSaga_kgqvnymyfvs32\LocalState\Documents", "1"),
	@("Clipchamp", "Clipchamp.Clipchamp_yxz26nhyzhsrt\LocalState\EBWebView", "1"),
	@("Dropbox for S-Mode", "C27EB4BA.Dropbox_xbfy0k16fey96\SystemAppData\Helium", "1")
	@("Dropbox Promotion", "C27EB4BA.DropboxOEM_xbfy0k16fey96\SystemAppData\Helium", "1"),
	@("DisneyPlus", "Disney.37853FC22B2CE_6rarf9sa4v8jt\LocalState\Sentry", "1"),
	@("Dolby Access", "DolbyLaboratories.DolbyAccess_rz1tebttyb220\LocalState\Microsoft", "1"),
	@("ESPN", "22364Disney.ESPN*\PLACEHOLDER", "1"),
	@("Facebook", "FACEBOOK.FACEBOOK_8xx8rvfyw5nnt\PLACEHOLDER", "1"),
	@("Family", "MicrosoftCorporationII.MicrosoftFamily_8wekyb3d8bbwe\LocalState\EBWebView\BrowserMetrics-spare.pma", "1"),
	@("Feedback Hub", "Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe\DUMMYDIR1", "1"),
	@("Hulu", "HULULLC.HULUPLUS_fphbd361v8tya\PLACEHOLDER", "1"),
	@("Instagram", "Facebook.Instagram*\PLACEHOLDER", "1"),
	@("Messenger", "FACEBOOK.317180B0BB486_8xx8rvfyw5nnt\AC\Messenger\TamStorage", "1"),
	@("Microsoft Journal", "Microsoft.MicrosoftJournal_8wekyb3d8bbwe\DUMMYDIR", "1"),
	@("Microsoft News", "Microsoft.BingNews_8wekyb3d8bbwe\LocalState\EBWebView", "1"),
	@("Microsoft Sudoku", "Microsoft.MicrosoftSudoku_8wekyb3d8bbwe\LocalState\VungleSDK", "1"),
#	@("Microsoft Teams", "MicrosoftTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\EBWebView", "1"),
	@("Microsoft Weather", "Microsoft.BingWeather_8wekyb3d8bbwe\LocalState\Cache", "3"),
	@("Microsoft To Do", "Microsoft.Todos_8wekyb3d8bbwe\DUMMYDIR", "1"),
	@("Microsoft Whiteboard", "Microsoft.Whiteboard_8wekyb3d8bbwe\DUMMYDIR", "1"),
	@("Minecraft Education Edition", "Microsoft.MinecraftEducationEdition_8wekyb3d8bbwe\LocalState\games", "1"),
	@("Mixed Reality Portal", "Microsoft.MixedReality.Portal_8wekyb3d8bbwe\DUMMYDIR", "1"),
	@("Netflix", "4DF9E0F8.Netflix_mcm4njqhnhss8\PLACEHOLDER", "1"),
	@("People", "Microsoft.People_8wekyb3d8bbwe\LocalState\SRPData.xml", "1"),
	@("Phone Link", "Microsoft.YourPhone_8wekyb3d8bbwe\SystemAppData\Helium", "3"),
	@("Realtek Audio Console", "RealtekSemiconductorCorp.RealtekAudioControl_dt26b99r8h8gj\DUMMYDIR", "2"),
	@("Skype", "Microsoft.SkypeApp_kzf8qxf38zg5c\LocalCache\Roaming\Microsoft\Skype for Store", "1"),
	@("Spotify", "SpotifyAB.SpotifyMusic_zpdnekdrzrea0\LocalCache\Roaming", "1"),
	@("Sticky Notes", "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\profile", "3"),
	@("Tiktok", "BytedancePte.Ltd.TikTok_6yccndn6064se\PLACEHOLDER", "1"),
	@("Tips", "Microsoft.Getstarted_8wekyb3d8bbwe\DUMMYDIR", "1"),
	@("Twitter", "9E2F88E3.TWITTER_wgeqdkkx372wm\PLACEHOLDER", "1"),
	@("Whatsapp", "5319275A.WhatsAppDesktop_cv1g1gvanyjgm\PLACEHOLDER", "1"),
	@("Windows Maps", "Microsoft.WindowsMaps_8wekyb3d8bbwe\LocalState\Collections", "2"),
#	@("Xbox", "Microsoft.GamingApp_8wekyb3d8bbwe", "1"),
	@("Xbox Console Companion", "Microsoft.XboxApp_8wekyb3d8bbwe\LocalState\SmartGlass", "1"),
	@("Xbox Game Bar", "Microsoft.XboxGamingOverlay_8wekyb3d8bbwe\LocalState\DiagOutputDir", "3"),
#	@("Xbox Game Bar Plugin", "Microsoft.XboxGameOverlay_8wekyb3d8bbwe", "3"),
#	@("Xbox Identity Provider", "Microsoft.XboxIdentityProvider_8wekyb3d8bbwe", "3"),
#	@("Xbox Game Speech Window", "Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe", "3"),
#	@("Xbox Live", "Microsoft.Xbox.TCUI_8wekyb3d8bbwe", "1"),
# Acer OEM MS Store Apps
# ASUS OEM MS Store Apps
#	@("Armoury Crate", "B9ECED6F.ArmouryCrate_qmba6cd70vzyy", "2"),
#	@("Aura Creator", "B9ECED6F.AURACreator_qmba6cd70vzyy", "2"),
	@("MyASUS", "B9ECED6F.ASUSPCAssistant_qmba6cd70vzyy", "3"),
# Dell OEM MS Store Apps
#	@("Dell Cinema Color", "PortraitDisplays.DellCinemaColor_2dgmkzkw4h30c", "3"),
	@("Dell Customer Connect", "DellInc.DellCustomerConnect_htrsf667h5kn2\DUMMYDIR", "1"),
	@("Dell Digital Delivery", "DellInc.DellDigitalDelivery_htrsf667h5kn2\DUMMYDIR", "1"),
#	@("Dell SupportAssist", "DellInc.DellSupportAssistforPCs_htrsf667h5kn2", "3"),
	@("Killer Control Center", "RivetNetworks.KillerControlCenter_rh07ty8m5nkag\SystemAppData\Helium", "1"),
	@("My Dell", "DellInc.MyDell_htrsf667h5kn2\DUMMYDIR", "1"),
	@("SmartByte", "RivetNetworks.SmartByte_rh07ty8m5nkag\DUMMYDIR", "1"),
#	@("Waves MaxxAudio", "WavesAudio.MaxxAudioProforDell2022_fh4rh281wavaa", "3"),
# HP OEM MS Store Apps
#	@("Bang & Olufsen Audio Control", "AD2F1837.BangOlufsenAudioControl_v10z8vjag6ke6", "3"),
	@("Energy Star", "AD2F1837.HPInc.EnergyStar_v10z8vjag6ke6\DUMMYDIR", "1"),
	@("HP Audio Center", "AD2F1837.HPAudioCenter_v10z8vjag6ke6", "2"),
#	@("HP Command Center", "AD2F1837.HPThermalControl_v10z8vjag6ke6", "3"),
#	@("HP Enhanced Lighting", " AD2F1837.HPEnhance_v10z8vjag6ke6", "3"),
	@("HP JumpStart", "AD2F1837.HPJumpStarts_v10z8vjag6ke6\DUMMYDIR", "1"),
#	@("HP Pen Control Plus", "AD2F1837.HPPenControlPlus_v10z8vjag6ke6", "3"),
	@("HP Privacy Settings", "AD2F1837.HPPrivacySettings_v10z8vjag6ke6\DUMMYDIR", "1"),
	@("HP QuickDrop", "AD2F1837.HPQuickDrop_v10z8vjag6ke6\DUMMYDIR", "1"),
#	@("HP Smart", "AD2F1837.HPInc.EnergyStar_v10z8vjag6ke6\DUMMYDIR", "2"),
#	@("HP System Event Utility", "AD2F1837.HPSystemEventUtility_v10z8vjag6ke6", "3"),
	@("MyHP", "AD2F1837.myHP_v10z8vjag6ke6\DUMMYDIR", "1"),
#	@("Omen Gaming Hub", "AD2F1837.OMENCommandCenter_v10z8vjag6ke6", "3"),
	@("Random Salad Games Solitaire", "26720RandomSaladGamesLLC.3899848563C1F_kx24dqmazqk8j\LocalCache\cdState.txt", "1"),
	@("Random Salad Games Solitaire |Alt|", "26720RandomSaladGamesLLC.SimpleSolitaire_kx24dqmazqk8j\LocalCache\cdState.txt", "1"),
# Lenovo OEM MS Store Apps
#	@("Lenovo Hotkeys", "E0469640.LenovoUtility_5grkq8ppsgwt4\DUMMYDIR", "2"),
#	@("Lenovo Pen", "WacomTechnologyCorp.157535B83C264_ss941bf8mfs8a\DUMMYDIR", "2"),
#	@("Lenovo Smart Appearance, "E0469640.SmartAppearance_5grkq8ppsgwt4\DUMMYDIR", "1"),
	@("Lenovo Voice", "E046963F.LenovoVoiceWorldWide_k1h2ywk1493x8\DUMMYDIR", "1"),
	@("Mirkat", "Mirkat.Mirkat_hm0vq9nycmfde\SystemAppData\Helium\User.dat", "1")
# MSI OEM MS Store Apps
# Razer OEM MS Store Apps
# Samsung OEM MS Store Apps,
)