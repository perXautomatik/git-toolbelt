# Set the error action preference to stop on any error
$ErrorActionPreference = "Stop"

Import-Module PsIni

function gitRemoveWorktree ($configPath)
{
    $iniContent = Get-IniContent -FilePath $configPath
    $iniContent.core.Remove("worktree") ;
    $iniContent | Out-IniFile -FilePath $configPath -Force
}

# Define a function to get the URL of a submodule
function Get-SubmoduleUrl {
  param(
    [string]$Path # The path of the submodule directory
  )
  # Change the current location to the submodule directory
  Push-Location -Path $Path -ErrorAction Stop
  # Get the URL of the origin remote
  $url = git config remote.origin.url -ErrorAction Stop
  # Write the URL to the host
  Write-Host $url
  # Parse the URL to get the part after the colon
  $parsedUrl = ($url -split ':')[1]
  # Write the parsed URL to the host
  Write-Host $parsedUrl
  # Return to the previous location
  Pop-Location -ErrorAction Stop
}

# Define a function to run git commands and check the exit code
function Invoke-Git {
  param(
    [string]$Command # The git command to run
  )
  # Run the command and capture the output
  $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
  # return the output to the host
  $output
  # Check the exit code and throw an exception if not zero
  if ($LASTEXITCODE -ne 0) {
    throw "Git command failed: git $Command"
  }
}

# Call the function with a submodule path
Get-SubmoduleUrl "B:\ToGit\.git\modules\BucketTemplate"

# Check the status of the submodules
Invoke-Git "submodule status"

# Update the submodules recursively
Invoke-Git "submodule update --init --recursive"

# Sync the submodule URLs with the .gitmodules file
Invoke-Git "submodule sync"

# Remove any broken submodules manually or with a loop
# For example, to remove a submodule named foo:
Invoke-Git "rm --cached foo"
Remove-Item -Path ".git/modules/foo" -Recurse -Force

# Add any new submodules manually or with a loop
# For example, to add a submodule named bar:
Invoke-Git "add bar"
Invoke-Git "submodule update --init --recursive"

# Push the changes to the remote repository
Invoke-Git "push origin master"

