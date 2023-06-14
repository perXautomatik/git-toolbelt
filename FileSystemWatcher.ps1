# Set folder to watch and file filter
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "C:\Program Files (x86)\Steam\steamapps\common\STALKER Shadow of Chernobyl"
#$watcher.Filter = "*.pdf"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Define action to perform when a new file is created
$action = {
    # Get the full path of the new file
    $path = $Event.SourceEventArgs.FullPath

    # Copy the file to the backup folder
    #Copy-Item -Path $path -Destination "D:\Backup" -Force

    # Write a log entry with the date, time and file name
    $logline = "$(Get-Date), Copied, $path"
    $logline
    #Add-content "C:\Documents\log.txt" -value $logline
}

# Register the action to watch for the Created event
Register-ObjectEvent $watcher "Created" -Action $action

# Keep the script running until stopped
while ($true) {sleep 5}