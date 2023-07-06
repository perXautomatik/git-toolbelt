<#
.SYNOPSIS
Updates the submodules of a git repository.

.DESCRIPTION
This function updates the submodules of a git repository, using the PsIni module and the git commands. The function removes any broken submodules, adds any new submodules, syncs the submodule URLs with the .gitmodules file, and pushes the changes to the remote repository.

.PARAMETER RepositoryPath
The path of the git repository where the submodules are located.

.PARAMETER SubmoduleNames
An array of submodule names that will be updated. If not specified, all submodules will be updated.
#>
function Update-Git-Submodules {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string]
      $RepositoryPath,

      [Parameter(Mandatory = $false)]
      [string[]]
      $SubmoduleNames
  )

# Set the error action preference to stop on any error
  # Import the PsIni module

  # Define a function to remove the worktree from a config file
  function Remove-Worktree {
      param(
          [string]$ConfigPath # The path of the config file
      )
      # Get the content of the config file as an ini object
      $iniContent = Get-IniContent -FilePath $ConfigPath
      # Remove the worktree property from the core section
      $iniContent.core.Remove("worktree")
      # Write the ini object back to the config file
      $iniContent | Out-IniFile -FilePath $ConfigPath -Force
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
      # Return the parsed URL as output
      return $parsedUrl
  }

  # Define a function to run git commands and check the exit code
  function Invoke-Git {
      param(
          [string]$Command # The git command to run
      )
      # Run the command and capture the output
      $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
      # Write the output to the host
      Write-Host $output
      # Check the exit code and throw an exception if not zero
      if ($LASTEXITCODE -ne 0) {
          throw "Git command failed: git $Command"
      }
  }

# Call the function with a submodule path
Get-SubmoduleUrl "B:\ToGit\.git\modules\BucketTemplate"

# Check the status of the submodules
Invoke-Git "submodule status"

  # Change the current location to the repository path
  Set-Location -Path $RepositoryPath

  # Get all submodules from the .gitmodules file as an array of objects
  $submodules = Get-IniContent -Path ".gitmodules" | Select-Object -Property submodule

  # If submodule names are specified, filter out only those submodules from the array
  if ($SubmoduleNames) {
      $submodules = $submodules | Where-Object { $_.submodule.Name -in $SubmoduleNames }
  }

  # Loop through each submodule in the array and update it
  foreach ($submodule in $submodules) {
      
  # Get submodule name and path from ini object properties
  
  $submoduleName = $submodule.submodule.Name
  
  $submodulePath = Join-Path -Path (Split-Path -Path ".gitmodules") -ChildPath ($submodule.submodule.path)
  
  # Check if submodule directory exists
  
  if (Test-Path -Path $submodulePath) {
    
    # Change current location to submodule directory
    
    Push-Location -Path $submodulePath
    
    # Get submodule URL from git config
    
    $submoduleUrl = Get-GitRemoteUrl
    
    # Check if submodule URL is empty or local path
    
    if ([string]::IsNullOrEmpty($submoduleUrl) -or (Test-Path -Path $submoduleUrl)) {
      
      # Set submodule URL to remote origin URL
      
      Set-GitRemoteUrl -Url (Get-SubmoduleUrl -Path $submodulePath)
      
    }
    
    # Return to previous location
    
    Pop-Location
    
# Update the submodules recursively
    
Invoke-Git "submodule update --init --recursive"
    
  }
  
  else {
    
    # Add submodule from remote URL
    
    Invoke-Git "submodule add $(Get-SubmoduleUrl -Path $submodulePath) $submodulePath"
    
  }
  
}
# Sync the submodule URLs with the .gitmodules file

# Remove any broken submodules manually or with a loop
# For example, to remove a submodule named foo:
Invoke-Git "rm --cached foo"
Remove-Item -Path ".git/modules/foo" -Recurse -Force

# Add any new submodules manually or with a loop
# For example, to add a submodule named bar:
Invoke-Git "add bar"
Invoke-Git "submodule update --init --recursive"
# Push the changes to the remote repository
}
