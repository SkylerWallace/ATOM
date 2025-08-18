﻿$tooltip = "Disables all user-facing settings in Settings > Privacy & Security"

Write-Host "Disabling Telemetry"

# All registry values for disabling Privacy & Security settings
$settings = [ordered]@{
# General privacy options
    'Personalized ads' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        name = "Enabled"
        type = "DWord"
        value = 0
    }
    'Language-relevant content' = @{
        path = "HKCU:\Control Panel\International\User Profile"
        name = "HttpAcceptLanguageOptOut"
        type = "DWord"
        value = 1
    }
    'Start & seach app-tracking' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        name = "Start_TrackProgs"
        type = "DWord"
        value = 0
    }
    'Suggested content' = [ordered]@{
        'Settings-suggested content 1' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-338387Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 2' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-338388Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 3' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-338389Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 4' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-338393Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 5' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-353694Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 6' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-353696Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 7' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SubscribedContent-353698Enabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 8' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "ContentDeliveryAllowed"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 9' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "OemPreInstalledAppsEnabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 10' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "PreInstalledAppsEnabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 11' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "PreInstalledAppsEverEnabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 12' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SilentInstalledAppsEnabled"
            type = "DWord"
            value = 0
        }
        'Settings-suggested content 13' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            name = "SystemPaneSuggestionsEnabled"
            type = "DWord"
            value = 0
        }
    }
    'Settings notifications' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications"
        name = "EnableAccountNotifications"
        type = "DWord"
        value = 0
    }
# Online speech recognition
    'Online speech recognition' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
        name = "HasAccepted"
        type = "DWord"
        value = 0
    }
# Inking & typing personalization
    'Inking & typing' = [ordered]@{
        'Inking & typing 1' = @{
            path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
            name = "RestrictImplicitInkCollection"
            type = "DWord"
            value = 1
        }
        'Inking & typing 2' = @{
            path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
            name = "RestrictImplicitTextCollection"
            type = "DWord"
            value = 1
        }
        'Inking & typing 3' = @{
            path = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
            name = "HarvestContacts"
            type = "DWord"
            value = 0
        }
        'Inking & typing 4' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
            name = "AcceptedPrivacyPolicy"
            type = "DWord"
            value = 0
        }
    }
# Diagnostics & feedback
    'Diagnostic telemetry' = [ordered]@{
        'Diagnostic telemetry 1' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack"
            name = "ShowedToastAtLevel"
            type = "DWord"
            value = 1
        }
        'Diagnostic telemetry 2' = @{
            path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
            name = "AllowTelemetry"
            type = "DWord"
            value = 1
        }
        'Diagnostic telemetry 3' = @{
            path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
            name = "MaxTelemetryAllowed"
            type = "DWord"
            value = 1
        }
    }
    'Inking and typing telemetry' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Input\TIPC"
        name = "Enabled"
        type = "DWord"
        value = 0
    }
    'Tailored experiences' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
            name = "TailoredExperiencesWithDiagnosticDataEnabled"
            type = "DWord"
            value = 0
    }
    'Diagnostic data viewer' = @{
        path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey"
        name = "EnableEventTranscript"
        type = "DWord"
        value = 0
    }
    'Feedback frequency' = [ordered]@{
        'Feedback frequency 1' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
            name = "NumberOfSIUFInPeriod"
            type = "DWord"
            value = 0
        }
        'Feedback frequency 2' = @{
            path = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
            name = "PeriodInNanoSeconds"
            type = "DWord"
            value = 0
        }
    }
# Activity history
    'Activity history' = [ordered]@{
        'Activity history 1' = @{
            path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            name = "EnableActivityFeed"
            type = "DWord"
            value = 0
        }
        'Activity history 2' = @{
            path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            name = "PublishUserActivities"
            type = "DWord"
            value = 0
        }
        'Activity history 3' = @{
            path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            name = "UploadUserActivities"
            type = "DWord"
            value = 0
        }
    }
# Search permissions
    'Safesearch' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"
        name = "SafeSearchMode"
        type = "DWord"
        value = 0
    }
    'Cloud search (Microsoft)' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"
        name = "IsMSACloudSearchEnabled"
        type = "DWord"
        value = 0
    }
    'Cloud search (Work/School)' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"
        name = "IsAADCloudSearchEnabled"
        type = "DWord"
        value = 0
    }
    'Search history' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"
        name = "IsDeviceSearchHistoryEnabled"
        type = "DWord"
        value = 0
    }
    'Search highlights' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings"
        name = "IsDynamicSearchBoxEnabled"
        type = "DWord"
        value = 0
    }
    # Start menu settings (Settings > Personalization > Start)
    'Start menu ads' = @{
        path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        name = "Start_IrisRecommendations"
        type = "DWord"
        value = 0
    }
}

# Import function
'Set-ThingProperty' | ForEach-Object {
    . "$functionsPath\$_.ps1"
}

$settings.GetEnumerator() | ForEach-Object {
    $value = $_.Value
    if ($value -is [System.Collections.Specialized.OrderedDictionary]) {
        $value.GetEnumerator() | ForEach-Object { 
            $settingParams = $_.Value
            Set-ThingProperty @settingParams
        }
    } else {
        $settingParams = $value
        Set-ThingProperty @settingParams
    }

    Write-Host "- $($_.Name) > Disabled"
}

Write-Host ""