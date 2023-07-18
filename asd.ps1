<#
.SYNOPSIS
A function to run a search and move files based on their extensions.

.DESCRIPTION
This function uses Search-Everything and trid to search for files that are not gz, webp or gif in the current directory or its subdirectories, excluding .git folders. It then moves the files to a destination drive based on their extensions.

.PARAMETER DestinationDrive
The drive letter where the files will be moved to. Default is L:.

.PARAMETER OtherFolder
The name of the folder where the files will be moved to if the condition is not met. Default is Other.

.EXAMPLE
runx -DestinationDrive M: -OtherFolder Unknown

This will search for files that are not gz, webp or gif in the current directory or its subdirectories, excluding .git folders, and move them to M: drive based on their extensions.
#>
function runx {
    [CmdletBinding()]
    param(
      [ValidatePattern("^[A-Z]:$")]
      [string]$DestinationDrive = "L:",
      [string]$OtherFolder = "Other"
    )
  
    try {
      # Search for files that are not gz, webp or gif, excluding .git folders
      $v = Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" -Global
  
      if ($v) {
        # Initialize a progress bar
        $progress = @{
          Activity = "Moving files based on extensions"
          Status   = "Processing file"
          PercentComplete = 0
        }
  
        # Loop through the files
        foreach ($file in $v) {
          # Update the progress bar
          $progress.PercentComplete = ($v.IndexOf($file) / $v.Count) * 100
          Write-Progress @progress
  
          # Get the file extension using trid
          $q = trid $file -ce
  
          if ($q[-1] -ne " 0 file(s) renamed.") {
            $g = ($q -match 'Collecting data from file: ')
            $pos = [array]::IndexOf($q, $g)
            $filename = ($q[$pos] -split 'file: ')[1]
            $regex = "[()]"
            $ext = (($q[$pos + 1] -split $regex)[1] -split '/')[0]
            $file = ($filename + $ext)
  
            # Check if the file exists
            if (Test-Path $file) {
              # Get the file path without the drive letter
              $filePath = $file.Substring(2)
  
              # Construct the destination path by replacing the drive letter
              $destinationPath = $DestinationDrive + $filePath
  
              # Create the destination directory if it does not exist
              $destinationDir = Split-Path -Path $destinationPath -Parent
              if (-not (Test-Path -Path $destinationDir)) {
                New-Item -Path $destinationDir -ItemType Directory
              }
  
              # Move the file to the destination path
              Move-Item -Path $file -Destination $destinationPath
            }
          }
          else {
              # Get the drive letter and the file name of the original file
              $driveLetter = Split-Path -Path $file -Qualifier
              $fileName = Split-Path -Path $file -Leaf
  
              # Construct the destination path by appending the other folder name
              $destinationPath = Join-Path -Path "$driveLetter\$OtherFolder" -ChildPath $fileName
  
              # Create the other folder if it does not exist
              if (-not (Test-Path -Path "$driveLetter\$OtherFolder")) {
                New-Item -Path "$driveLetter\$OtherFolder" -ItemType Directory
              }
  
              # Move the file to the destination path
              Move-Item -Path $file -Destination $destinationPath
  
              Write-Output "Moved file to other folder: $destinationPath"
            }
        }
  
        # Complete the progress bar
        $progress.PercentComplete = 100
        Write-Progress @progress
  
      }
      else {
        Write-Output "No results"
      }
    }
    catch {
      Write-Error $_.Exception.Message
    }
  }
  