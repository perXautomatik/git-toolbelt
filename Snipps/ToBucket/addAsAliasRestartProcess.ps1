# Get the path of your profile file
$profilePath = $profile.CurrentUserAllHosts

# Append the function and the alias definitions to your profile file
Add-Content -Path $profilePath -Value "function Restart-ProcessByName {`n  param(`n    [string]`$Name # The name of the process to restart`n  )`n  # Stop the process by name`n  Stop-Process -Name `$Name -Force -ErrorAction Stop`n  # Start the process by name`n  Start-Process -Name `$Name -ErrorAction Stop`n}"
Add-Content -Path $profilePath -Value "New-Alias -Name restart -Value Restart-ProcessByName"