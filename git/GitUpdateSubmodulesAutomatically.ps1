# Set the error action preference to stop on any error
$ErrorActionPreference = "Stop"

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