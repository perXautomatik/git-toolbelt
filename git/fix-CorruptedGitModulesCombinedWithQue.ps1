begin
{
    Push-Location

    # Validate the arguments
    if (-not (Test-Path -LiteralPath $modules)) { 
      Write-Error "Invalid modules path: $modules"
      exit 1
    }

    if (-not (Test-Path -LiteralPath $folder)) {
      Write-Error "Invalid folder path: $folder"
      exit 1
    }

    # Redirect the standard error output of git commands to the standard output stream
    $env:GIT_REDIRECT_STDERR = '2>&1'

    # Initialize a counter variable
    $i = 0;

    # Define parameters for Write-Progress cmdlet
    $progressParams = @{
        Activity = "Processing files"
        Status = "Starting"
        PercentComplete = 0
    }
}
process {

    # Get all the subdirectories in $folder, excluding any .git files or folders
    $subdirs = Get-ChildItem -LiteralPath $folder -Directory -Recurse -Filter "*"

    # Loop through each subdirectory
    foreach ($subdir in $subdirs) {
      
      # Increment the counter
      $i++;

      # Change the current directory to the subdirectory
      Set-Location $subdir.FullName

      # Run git status and capture the output
      $output = git status

      # Check if the output is fatal
      if($output -like "fatal*")
      {
          # Print a message indicating fatal status
          Write-Output "fatal status for $subdir"

          # Get the .git file or folder in that subdirectory
          $gitFile = Get-ChildItem -LiteralPath "$subdir\*" -Force | Where-Object { $_.Name -eq ".git" }

          # Check if it is a file or a folder
          if( $gitFile -is [System.IO.FileInfo] )
          {
              # Define parameters for Move-Item cmdlet
              $moveParams = @{
                  Path = Join-Path -Path $modules -ChildPath $gitFile.Directory.Name
                  Destination = $gitFile
                  Force = $true
                  PassThru = $true
              }

              # Move the module folder to replace the .git file and return the moved item
              $movedItem = Move-Item @moveParams

              # Print a message indicating successful move
              Write-Output "moved $($movedItem.Name) to $($movedItem.DirectoryName)"
          }
          elseif( $gitFile -is [System.IO.DirectoryInfo] )
          {
              # Get the path to the git config file
              $configFile = Join-Path -Path $gitFile -ChildPath "\config"
    
              # Check if it exists
              if (-not (Test-Path -LiteralPath $configFile)) {
                Write-Error "Invalid folder path: $gitFile"  
              }
              else
              {
                  # Read the config file content as a single string
                  $configContent = Get-Content -LiteralPath $configFile -Raw

                  # Remove any line that contains worktree and store the new content in a variable
                  $newConfigContent = $configContent -Replace "(?m)^.*worktree.*$\r?\n?"

                  # Check if there are any lines to remove
                  if ($configContent -ne $newConfigContent)
                  {
                      # Write the new config file content
                      $newConfigContent | Set-Content -LiteralPath $configFile -Force

                      # Print a message indicating successful removal
                      Write-Output "removed worktree from $configFile"
                  }
              }
          }
          else
          {
              # Print an error message if it is not a file or a folder
              Write-Error "not a .git file or folder: $gitFile"
          }
      }

      # Calculate the percentage of directories processed
      $percentComplete =  ($i / ($subdirs.count+$i) ) * 100

      # Update the progress bar
      $progressParams.PercentComplete = $percentComplete
      Write-Progress @progressParams
     
    } 
}
end {
    # Restore the original location
    Pop-Location

    # Complete the progress bar
    $progressParams.Status = "Finished"
    Write-Progress @progressParams
}
