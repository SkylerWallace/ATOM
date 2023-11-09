# ATOM (A Tool Of Mine)
![](ATOM/Dependencies/Icons/ATOM%20Logo.png)

## What is ATOM?
ATOM is a launcher for PowerShell scripts, batch scripts, and executables. Although ATOM comes with many plugins preloaded, its modular nature invites people to create and add their own scripts.
ATOM is coded in PowerShell and uses WPF for its UI.

## Who is ATOM for?
ATOM is intended for computer repair technicians but can also be used by anybody who wishes to repair or modify their Windows installation.

## How to Deploy ATOM
**Direct download to latest ATOM:**

https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM.zip

ATOM.zip can be extracted anywhere but it's recommended to be extracted to the root of a flash drive. If the flash drive has a Windows PE installation on it, ATOM will have additional features.

Launch ATOM by double-clicking the ATOM.bat file.

**IMPORTANT:** ATOM.bat and the ATOM folder must remain in the same directory for ATOM.bat to launch ATOM.

Once ATOM is launched, you can launch a Plugin by **double-clicking** the Plugin.

Many of ATOM's plugins are downloaded on-the-fly and will be cached in the Temp directory (C:\Users\UserName\AppData\Local\Temp).
The ATOM Store plugin can be used to download a portable version for use in offline environments.

## Adding Plugin Categories
To add a Plugin Category, do the following:
- Navigate to ATOM directory.
- Create a new folder named "Plugins - CategoryName" where CategoryName is your desired Category name.
- If ATOM has already been launched, you can reload Plugins and Plugin Categories by clicking the Refresh icon.

## Adding Plugins
To add a Plugin, do the following:
- Navigate to ATOM directory.
- Open the Plugin folder you would like to add your plugin to. (EX: "Plugins - Data Services")
- Place your PowerShell script, batch script, or executable in the folder.
- If ATOM has already been launched, you can reload Plugins and Plugin Categories by clicking the Refresh icon.
