# Define a function to remove a submodule
function Remove-Submodule {
  param(
    [string]$SubmodulePath, # The path of the submodule
    [string]$SubmoduleName, # The name of the submodule (optional)
    [string]$SubmoduleUrl,  # The remote URL of the submodule (optional)
    [switch]$Force,         # A flag to force the removal even if the submodule is not properly pushed
    [switch]$AttemptToSync  # A flag to attempt to sync the submodule with its remote before removing it
  )

  # Try to remove the submodule and catch any errors
  try {
    # If the submodule name is not given, try to get it from different sources
    if (!$SubmoduleName) {
      # Try to get the name from the .gitmodules file using git config
      $SubmoduleName = git config --file .gitmodules --get-regexp path | Where-Object {$_ -match $SubmodulePath} | ForEach-Object {$_ -split " "} | Select-Object -Last 1

      # If the name is still not found, try to get it from the .git/config file using git config
      if (!$SubmoduleName) {
        $SubmoduleName = git config --get-regexp url | Where-Object {$_ -match $SubmoduleUrl} | ForEach-Object {$_ -split " "} | Select-Object -Last 1
      }

      # If the name is still not found, try to get it from the last part of the submodule path
      if (!$SubmoduleName) {
        $SubmoduleName = Split-Path $SubmodulePath -Leaf
      }
    }

    # If the submodule URL is not given, try to get it from different sources
    if (!$SubmoduleUrl) {
      # Change directory to the submodule path
      Push-Location $SubmodulePath

      # Try to get the URL of the currently checked out branch if it has a tracked remote branch
      $SubmoduleUrl = git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>$null | ForEach-Object {git remote get-url $_.Split("/")[0]}

      # If the URL is still not found, try to get the URL of any registered remote that has a branch with the same name as currently checked out in submodule
      if (!$SubmoduleUrl) {
        $CurrentBranch = git rev-parse --abbrev-ref HEAD
        $RemoteName = git branch -r --contains $CurrentBranch | Select-Object -First 1 | ForEach-Object {$_ -split "/"} | Select-Object -First 1
        if ($RemoteName) {
          $SubmoduleUrl = git remote get-url $RemoteName
        }
      }

      # If the URL is still not found, try to get the URL of any remote, preferring origin if present
      if (!$SubmoduleUrl) {
        $RemoteName = git remote | Where-Object {$_ -eq "origin"} | Select-Object -First 1
        if (!$RemoteName) {
          $RemoteName = git remote | Select-Object -First 1
        }
        if ($RemoteName) {
          $SubmoduleUrl = git remote get-url $RemoteName
        }
      }

      # If the URL is still not found, try to get it from the .gitmodules file using git config
      if (!$SubmoduleUrl) {
        Pop-Location # Go back to the main repository directory
        $SubmoduleUrl = git config --file .gitmodules --get-regexp url | Where-Object {$_ -match $SubmoduleName} | ForEach-Object {$_ -split " "} | Select-Object -Last 1
      }

      # If the URL is still not found, try to get it from the .git/config file using git config
      if (!$SubmoduleUrl) {
        Pop-Location # Go back to the main repository directory
        $SubmoduleUrl = git config --get-regexp url | Where-Object {$_ -match $SubmoduleName} | ForEach-Object {$_ -split " "} | Select-Object -Last 1
      }

      # If the URL is still not found, use the submodule path as a fallback
      if (!$SubmoduleUrl) {
        Pop-Location # Go back to the main repository directory
        $SubmoduleUrl = $SubmodulePath
      }
    }

    # Register where the submodule stores its config file before removing it
    Push-Location $SubmodulePath # Change directory to the submodule path
    $ConfigFile = git rev-parse --git-path config # Get the config file path using git rev-parse[^1^][1]
    
    # Check if the submodule is properly pushed to its remote
    $LocalCommit = git rev-parse HEAD # Get the local commit hash
    $RemoteCommit = git rev-parse @{u} # Get the remote commit hash
    if ($LocalCommit -ne $RemoteCommit) {
      # If the commits are different, the submodule is not properly pushed
      if ($Force) {
        # If the force flag is given, ignore the difference and warn the user
        Write-Warning "The submodule $SubmoduleName is not properly pushed to its remote. Proceeding with removal anyway."
      }
      elseif ($AttemptToSync) {
        # If the attempt to sync flag is given, try to sync the submodule with its remote
        Write-Host "The submodule $SubmoduleName is not properly pushed to its remote. Attempting to sync it."
        $CurrentBranch = git rev-parse --abbrev-ref HEAD # Get the current branch name
        $RemoteBranch = git rev-parse --abbrev-ref --symbolic-full-name @{u} # Get the remote branch name
        if ($CurrentBranch -eq $RemoteBranch) {
          # If the current branch and the remote branch are the same, use git pull to sync
          git pull --rebase # Use rebase option to avoid merge commits
        }
        else {
          # If the current branch and the remote branch are different, use git merge to sync
          git merge $RemoteBranch # Merge the remote branch into the current branch
        }
        # Check again if the submodule is properly pushed to its remote
        $LocalCommit = git rev-parse HEAD # Get the new local commit hash
        $RemoteCommit = git rev-parse @{u} # Get the new remote commit hash
        if ($LocalCommit -ne $RemoteCommit) {
          # If the commits are still different, the sync failed
          Write-Error "Failed to sync the submodule $SubmoduleName with its remote. Aborting removal."
          exit 1
        }
      }
      else {
        # If neither flag is given, abort the removal and inform the user
        Write-Error "The submodule $SubmoduleName is not properly pushed to its remote. Aborting removal. Use -Force or -AttemptToSync flags to override this behavior."
        exit 1
      }
    }

    Pop-Location # Go back to the main repository directory

    # Deinit the submodule
    git submodule deinit $SubmodulePath -f

    # Remove the submodule and its folder using Remove-Item cmdlet[^2^][2]
    Remove-Item -Path "$($ConfigFile)/../.." -Recurse -Force

    # Commit the changes
    git commit -m "Remove $SubmoduleName submodule"

    # Add the remote URL
    git remote add $SubmoduleName $SubmoduleUrl

    # Fetch the history
    git fetch $SubmoduleName

    # Create a new branch based on the submodule history
    git branch $SubmoduleName "$($SubmoduleName)/master"

    # Write a success message
    Write-Host "Successfully removed $SubmoduleName submodule"
  }
  catch {
    # Write an error message and exit
    Write-Error "Failed to remove $SubmoduleName submodule: $_"
    exit 1
  }
}
