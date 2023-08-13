# Define a function to remove a submodule
function Remove-Submodule {
  param(
    [string]$SubmodulePath, # The path of the submodule
    [string]$SubmoduleUrl,  # The remote URL of the submodule
    [string]$SubmoduleName  # The name of the submodule (optional)
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

    # Deinit the submodule
    git submodule deinit $SubmodulePath -f

    # Remove the submodule
    git rm $SubmodulePath -f

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
