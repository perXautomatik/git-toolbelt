# Define a function to remove a submodule
function Remove-Submodule {
  param(
    [string]$SubmoduleName, # The name of the submodule
    [string]$SubmodulePath, # The path of the submodule
    [string]$SubmoduleUrl   # The remote URL of the submodule
  )

  # Try to remove the submodule and catch any errors
  try {
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

# Define a function to create a worktree from a branch
function Create-Worktree {
  param(
    [string]$BranchName, # The name of the branch
    [string]$WorktreePath # The path of the worktree
  )

  # Try to create a worktree and catch any errors
  try {
    # Create a new worktree from the branch
    git worktree add $WorktreePath $BranchName

    # Write a success message
    Write-Host "Successfully created $WorktreePath worktree from $BranchName branch"
  }
  catch {
    # Write an error message and exit
    Write-Error "Failed to create $WorktreePath worktree from $BranchName branch: $_"
    exit 1
  }
}

# Call the functions with some example parameters
Remove-Submodule -SubmoduleName "Foo" -SubmodulePath "submodules/Foo" -SubmoduleUrl "https://example.com/foo.git"
Create-Worktree -BranchName "Foo" -WorktreePath "../Foo"
