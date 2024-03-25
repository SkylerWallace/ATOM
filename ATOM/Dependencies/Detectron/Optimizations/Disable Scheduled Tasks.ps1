$tooltip = "Disable unnecessary startups from common programs"

#Write-OutputBox "Disable Scheduled Tasks"

# Create a list of tasks to disable with their paths
$tasks = @(
    "AdobeAAMUpdater-1.0-HP",
    "AppleSoftwareUpdate",
    "BlueStacksHelper_nxt",
    "CCleanerCrashReporting",
    "Consolidator",
    "UsbCeip",
    "Microsoft-Windows-DiskDiagnosticDataCollector",
    "Office ClickToRun Service Monitor",
    "XblGameSaveTask"
)

# Tasks with multiple entries
$tasksLike = @(
    "NvTmRep_CrashReport_*"
)

# Disable the tasks
foreach ($task in $tasks) {
    $taskObj = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
    if ($taskObj -ne $null){
        if ($taskObj.State -ne "Disabled")
        {
            Disable-ScheduledTask -TaskName $task -TaskPath $taskObj.TaskPath
            Write-OutputBox "- $task has been disabled."
        }
        else
        {
            Write-OutputBox "- $task is already disabled."
        }
    }
    else
    {
        Write-OutputBox "- $task not detected."
    }
}

# Disable tasks with multiple entries
foreach ($task in $tasksLike) {
    $taskObjs = Get-ScheduledTask | Where-Object { $_ -like $task}
    if ($taskObjs -ne $null){
        foreach ($taskObj in $taskObjs){
            $name = $taskObj.TaskName
            if ($taskObj.State -ne "Disabled")
            {
                Disable-ScheduledTask -TaskName $name -TaskPath $taskObj.TaskPath
                Write-OutputBox "- $name has been disabled."
            }
            else
            {
                Write-OutputBox "- $name is already disabled."
            }
        }
    }
    else
    {
        Write-OutputBox "- $task not detected."
    }
}

Write-OutputBox ""