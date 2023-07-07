# Define a function to run git commands and check the exit code
function Invoke-Git {
  param(
    [string]$Command # The git command to run
  )
  $env:GIT_REDIRECT_STDERR = "2>&1"
  # Run the command and capture the output
  $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
  # return the output to the host
  $output
  # Check the exit code and print a verbose message if not zero
  if ($LASTEXITCODE -ne 0) {
    Write-Verbose "Git command failed: git $Command"
  }
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
  # Check the exit code and print a verbose message if not zero
  if ($LASTEXITCODE -ne 0) {
    Write-Verbose "Git command failed: git $Command"
  }
}

# Define a function that takes a list of paths as input
function Get-NonTrackedPaths {
  param (
    [Parameter(Mandatory=$true)]
    [string[]]$Paths
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

    # Check if the path is a valid directory
    if (Test-Path -Path $Path -PathType Container) {

      # Check if the path contains a .git folder
      if (Test-Path -Path "$Path\.git") {

        # Assume the path is not tracked by any other path
        $IsTracked = $false

        # Loop through the remaining paths in the queue with a progress bar
        $j = 0
        foreach ($OtherPath in $PathQueue) {

          # Update the progress bar for the inner loop
          $j++
          Write-Progress -Activity "Checking other paths" -Status "Processing other path $j of $($PathQueue.Count)" -PercentComplete ($j / $PathQueue.Count * 100) -Id 1

          # Check if the other path is a valid directory
          if (Test-Path -Path $OtherPath -PathType Container) {

            # Check if the other path contains a .git folder
            if (Test-Path -Path "$OtherPath\.git") {

              # Change the current location to the other path
              Push-Location -Path $OtherPath

              # Invoke git status command using the Invoke-Git function and capture the output
              try {
                $GitStatus = Invoke-Git -Command "status --porcelain --untracked-files=no"
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

              # Restore the original location
              Pop-Location

              # Check if the output contains the current path as a normal part of repository or as a submodule
              if ($GitStatus -match [regex]::Escape($Path)) {

                # Set the flag to indicate the current path is tracked by the other path
                $IsTracked = $true

                # Add a tracking status property to the output object of the current path
                Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name TrackingStatus -Value "Tracked by $($OtherPath)"

                # Break the inner loop
                break

              }

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
        Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name ErrorMessage -Value "No .git folder found"
      }

    }
    else {
      # Add an error message property to the output object of the current path
      Add-Member -InputObject $OutputObject -MemberType NoteProperty -Name ErrorMessage -Value "Invalid directory"
    }

    # Add the output object to the output objects array
    $OutputObjects += $OutputObject

  }

  # Return the output objects array as a table
  return $OutputObjects | Format-Table -AutoSize

}

# Example usage: pass a list of paths as input and get the non-tracked paths as output

$Paths = Get-Clipboard | % { $_ | Split-Path -Parent }

$NonTrackedPaths = Get-NonTrackedPaths -Paths @($Paths)

$NonTrackedPaths
