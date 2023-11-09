# BrowserNotifications.ps1 checks Chromium-based browsers installed on the computer (currently Chrome & Edge)
# for sites that have notifications enabled.  If a browser has a site with notifications enabled that isn't
# whitelisted, the user will be prompted to launch the browser to manually check for site notifications.

# This array whitelists sites.
# These are needed for the script to decide to prompt the user to launch the browser.
$whitelistSites = @(
	("www.calendar.google.com"),
	("www.facebook.com"),
	("www.mail.google.com"),
	("www.outlook.live.com"),
	("www.meet.google.com"),
	("www.netflix.com"),
	("www.youtube.com"),
	("www.zoom.us")
)

# Sets variables for Chrome and then runs Check-Notifications function
$browserPath = "C:\Program Files*\Google\Chrome"
$userDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$preferencesPath = "$userDataPath\*\Preferences"

if ((Test-Path $browserPath) -And (Test-Path $preferencesPath)) {
$browserName = "Chrome"
$browserNotificationsPath = "chrome://settings/content/notifications"

Check-Notifications
}

# Sets variables for Edge and then runs Check-Notifications function
$browserPath = "C:\Program Files*\Microsoft\Edge"
$userDataPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
$preferencesPath = "$userDataPath\*\Preferences"

if ((Test-Path $browserPath) -And (Test-Path $preferencesPath)) {
$browserName = "MSEdge"
$browserNotificationsPath = "edge://settings/content/notifications"

Check-Notifications
}