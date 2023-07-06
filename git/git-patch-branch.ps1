# Get the file name and the branch name from the arguments
$fileName = $args[0]
$branchName = $args[1]

# Check if the arguments are valid
if (!$fileName -or !$branchName) {
    Write-Host "Usage: .\script.ps1 <file name> <branch name>"
    exit
}

# Get the list of commits that modified the file
$commits = git log --pretty=format:"%H" -- $fileName

# Create a new branch with the given name
git checkout -b $branchName

# Loop through the commits and create a patch for each one
foreach ($commit in $commits) {
    # Create a patch file with the commit hash as the name
    $patchFile = "$commit.patch"
    git format-patch -1 $commit --stdout > $patchFile

    # Apply the patch to the new branch
    git apply $patchFile

    # Add the file to the staging area
    git add $fileName

    # Commit with the commit hash as the message
    git commit -m $commit

    # Delete the patch file
    Remove-Item $patchFile
}

# Show the log of the new branch
git log --oneline --graph --decorate --all
