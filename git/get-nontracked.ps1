# Define a function that takes a list of paths as input and returns an array of objects with their error message or tracking status
<#
.SYNOPSIS
Takes a list of paths as input and returns an array of objects with their error message or tracking status.

.DESCRIPTION
This function takes a list of paths as input and checks if they are valid git repositories.
It also checks if they are tracked by any other path in the list as a normal part of repository or as a submodule using the Test-GitTracking function.
It returns an array of objects with the path, error message (if any) and tracking status (if any) as properties.

.PARAMETER Paths
The list of paths to check.

.EXAMPLE
Get-NonTrackedPaths -Paths @("C:\path1", "C:\path2", "C:\path3", "C:\path4")

This example takes a list of four paths and returns an array of objects with their error message or tracking status.
#>
function Get-NonTrackedPaths {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Paths # The list of paths to check
  )

  # Initialize an empty array to store the non-tracked paths
  $NonTrackedPaths = @()

  # Initialize a queue to store the paths to be checked
  $PathQueue = New-Object System.Collections.Queue

  # Sort the paths alphabetically and enqueue them
  foreach ($Path in $Paths | Sort-Object) {
    $PathQueue.Enqueue($Path)
  }

  # Initialize an empty array to store the output objects
  $OutputObjects = @()

  # Loop through the queue until it is empty
  while ($PathQueue.Count -gt 0) {

    # Dequeue the first path from the queue
    $Path = $PathQueue.Dequeue()

    # Create an output object with the path as a property
    $OutputObject = New-Object PSObject -Property @{Path = $Path}

    # Check if the path is a valid git repository using the Test-GitRepository function
    if (Test-GitRepository -Path $Path) {

      # Assume the path is not tracked by any other path
      $IsTracked = $false

      # Filter the remaining paths in the queue to only include those that are relative to the current path or vice versa
      $FilteredPaths = @($PathQueue | Where-Object {($_.StartsWith($Path) -or $Path.StartsWith($_))})

      # Loop through the filtered paths with a progress bar
      $j = 0
      foreach ($OtherPath in $FilteredPaths) {

        # Update the progress bar for the inner loop
        $j++
        Write-Progress -Activity "Checking other paths" -Status "Processing other path $j of $($FilteredPaths.Count)" -PercentComplete ($j / $FilteredPaths.Count * 100) -Id 1

        # Check if the other path is a valid git repository using the Test-GitRepository function
        if (Test-GitRepository -Path $OtherPath) {

          # Check if the current path is tracked by the other path using the Test-GitTracking function
          try {
            if (Test-GitTracking -Path $Path -OtherPath $OtherPath) {

              # Set the flag to indicate the current path is tracked by the other path
              $IsTracked = $true

              # Add a tracking status property to the output object of the current path
              Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name TrackingStatus -Value "Tracked by $($OtherPath)"

              # Break the inner loop
              break

            }
          }
          catch {
            # Print the error as a verbose message and continue
            Write-Verbose $_.Exception.Message

            # Remove the error prone repo from the queue
            $PathQueue = New-Object System.Collections.Queue ($PathQueue | Where-Object {$_ -ne $OtherPath})

            # Add an error message property to the output object of the other path
            foreach ($OutputObject in $OutputObjects) {
              if ($OutputObject.Path -eq $OtherPath) {
                Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name ErrorMessage -Value $_.Exception.Message
              }
            }

            continue

          }

        }

      }

      # If the flag is still false, add the current path to the non-tracked paths array and set its tracking status as untracked
      if (-not $IsTracked) {
        $NonTrackedPaths += $Path

        Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name TrackingStatus -Value "Untracked"
      }

    }
    else {
      # Add an error message property to the output object of the current path
      Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name ErrorMessage -Value "Invalid git repository"
    }

    # Add the output object to the output objects array
    $OutputObjects += $OutputObject

  }
  $OutputObjects
}

# Define a function to run git commands and check the exit code
<#
.SYNOPSIS
Runs a git command and checks the exit code.

.DESCRIPTION
This function runs a git command using Invoke-Expression and captures the output.
It returns the output to the host and prints a verbose message if the exit code is not zero.

.PARAMETER Command
The git command to run.

.EXAMPLE
Invoke-Git -Command "status --porcelain --untracked-files=no"

This example runs the git status command with some options and returns the output.
#>
function Invoke-Git {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Command # The git command to run
  )
  # Run the command and capture the output
  $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
  # return the output to the host
  $output
  # Check the exit code and print a verbose message if not zero
  if ($LASTEXITCODE -ne 0) {
    Write-Verbose "Git command failed: git $Command"
  }
}

# Define a function to check if a path is a valid git repository
<#
.SYNOPSIS
Checks if a path is a valid git repository.

.DESCRIPTION
This function checks if a path is a valid directory and contains a .git folder.
It returns $true if both conditions are met, otherwise it returns $false.

.PARAMETER Path
The path to check.

.EXAMPLE
Test-GitRepository -Path "C:\path1"

This example checks if C:\path1 is a valid git repository and returns $true or $false.
#>
function Test-GitRepository {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path # The path to check
  )
  # Check if the path is a valid directory and contains a .git folder
  if (Test-Path -Path $Path -PathType Container -ErrorAction SilentlyContinue) {
    if (Test-Path -Path "$Path\.git" -ErrorAction SilentlyContinue) {
      return $true
    }
  }
  return $false
}

# Define a function to check if a path is tracked by another path as a normal part of repository or as a submodule
<#
.SYNOPSIS
Checks if a path is tracked by another path as a normal part of repository or as a submodule.

.DESCRIPTION
This function changes the current location to another path and invokes the git status command using the Invoke-Git function.
It checks if the output contains the path as a normal part of repository or as a submodule using regular expression matching.
It returns $true if the path is tracked, otherwise it returns $false.
It also restores the original location after checking.

.PARAMETER Path
The path to check.

.PARAMETER OtherPath
The other path to compare with.

.EXAMPLE
Test-GitTracking -Path "C:\path1" -OtherPath "C:\path2"

This example checks if C:\path1 is tracked by C:\path2 as a normal part of repository or as a submodule and returns $true or $false.
#>
function Test-GitTracking {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path, # The path to check

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$OtherPath # The other path to compare with
  )
  # Change the current location to the other path
  Push-Location -Path $OtherPath

  # Invoke git status command using the Invoke-Git function and capture the output
  try {
    $GitStatus = Invoke-Git -Command "status --porcelain --untracked-files=no"
  }
  catch {
    # Print the error as a verbose message and rethrow it
    Write-Verbose $_.Exception.Message
    throw $_.Exception.Message
  }

  # Restore the original location
  Pop-Location

  # Check if the output contains the path as a normal part of repository or as a submodule using regular expression matching
  if ($GitStatus -match [regex]::Escape($Path)) {
    return $true
  }
  
  return $false
  
}

  # Return the output
# Example usage: pass a list of paths as input and get the non-tracked paths as output

$Paths = Get-Clipboard | % { $_ | Split-Path -Parent }

$NonTrackedPaths = Get-NonTrackedPaths -Paths @($Paths)

$NonTrackedPaths | format-table
