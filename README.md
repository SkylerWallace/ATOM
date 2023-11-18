# ATOM (A Tool Of Mine)
![](ATOM/Dependencies/Icons/ATOM%20Logo%20(Light).png)

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

## Additional PE Functionality
If ATOM.zip is extracted to a flash drive with a Windows PE installation on it, you will have additional functionality.

In the ATOM title bar, you will have an additional button:
- If in an online OS, the button will boot the computer directly to Windows PE
- If in Windows PE (including Windows RE), the button will launch MountOS.ps1
  - MountOS allows you to mount registry hives from offline Windows installations, also supports unlocking encrypted drives

**IMPORTANT:** If your Windows PE installation does not have PowerShell installed onto it and also have PowerShell added to path, you will need to install PowerShell Core via the ATOM Store if you want to launch ATOM in Windows PE.

Since Windows RE is a PE environment, you can launch ATOM in Windows RE provided you downloaded PowerShell Core using the ATOM Store plugin. Launch Command Prompt in Windows RE and navigate to your ATOM installation. Launch ATOM in Command Prompt by starting ATOM.bat.
> start ATOM.bat

Select the Command Prompt window that ATOM.bat creates and press 'Enter' twice to launch ATOM.

## Adding Plugin Categories
To add a Plugin Category, do the following:
- Navigate to ATOM directory.
- Create a new folder named "Plugins - CategoryName" where CategoryName is your desired Category name.
- If ATOM has already been launched, you can reload Plugins and Plugin Categories by clicking the Refresh ↻ icon.

## Adding Plugins
To add a Plugin, do the following:
- Navigate to ATOM directory.
- Open the Plugin folder you would like to add your plugin to. (EX: "Plugins - Data Services")
- Place your PowerShell script, batch script, or executable in the folder.
- If ATOM has already been launched, you can reload Plugins and Plugin Categories by clicking the Refresh ↻ icon.

To add a custom icon for your plugin, do the following:
- Create, extract, or download PNG file to be used as your icon (128x128 or native resolution recommended)
- Navigate to "ATOM\Dependencies\Icons\Plugins"
- Place PNG file in directory (PNG file must have same name as the plugin, EX: if plugin is "Plugin.ps1", PNG icon must be "Plugin.png")

If you do not add a custom icon, a default icon from "ATOM\Dependencies\Icons\Default" will be used instead.

## Configuring Plugins to Silently Launch
ATOM has the ability to launch PowerShell and Batch Plugins without displaying the command line window.

For PowerShell script (.ps1), the first line of your script should be:
> \# Launch: Silent

For Batch script (.bat), the first line of your script should be:
> REM Launch: Silent
