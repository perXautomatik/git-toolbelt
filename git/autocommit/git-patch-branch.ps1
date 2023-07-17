# Define a function that gets the list of commits that modified a file
function Get-Commits {
    param (
        # The file name to search for
        [Parameter(Mandatory=$true)]
        [string]$FileName,

        # The optional branch name to search in
        [Parameter(Mandatory=$false)]
        [string]$BranchName
    )

    # Validate the file name
    if (!(Test-Path $FileName)) {
        Write-Error "File $FileName does not exist"
        return
    }

    # If there is a branch name, add it to the git log command
    if ($BranchName) {
        $BranchName = "$BranchName --"
    }

    # Call git log and return the commit hashes as an array
    return git log --pretty=format:"%H" --all $BranchName $FileName
}

# Define a function that creates a new branch with a given name
function New-Branch {
    param (
        # The branch name to create
        [Parameter(Mandatory=$true)]
        [string]$BranchName
    )

    # Validate the branch name
    if (git branch --list $BranchName) {
        Write-Error "Branch $BranchName already exists"
        return
    }

    # Call git checkout with the -b option
    git checkout -b $BranchName
}

# Define a function that creates a patch file for a given commit and returns the patch file name and the original commit message
function New-Patch {
    param (
        # The commit hash to create a patch for
        [Parameter(Mandatory=$true)]
        [string]$CommitHash
    )

    # Validate the commit hash
    if (!(git cat-file -e $CommitHash)) {
        Write-Error "Commit $CommitHash does not exist"
        return
    }

    # Create a patch file with the commit hash as the name
    $PatchFile = "$CommitHash.patch"
    git format-patch -1 $CommitHash --stdout > $PatchFile

    # Get the original commit message using git show with the --pretty option
    $CommitMessage = git show -s --pretty=%B $CommitHash

    # Return the patch file name and the original commit message as an object
    return [PSCustomObject]@{
        PatchFile = $PatchFile
        CommitMessage = $CommitMessage
    }
}

# Define a function that applies a patch file to the current branch
function Apply-Patch {
    param (
        # The patch file name to apply
        [Parameter(Mandatory=$true)]
        [string]$PatchFile
    )

    # Validate the patch file name
    if (!(Test-Path $PatchFile)) {
        Write-Error "Patch file $PatchFile does not exist"
        return
    }

    # Call git apply with the patch file name
    git apply $PatchFile

    # Return the status code of the git command
    return $?
}

# Define a function that adds a file to the staging area
function Add-File {
    param (
        # The file name to add
        [Parameter(Mandatory=$true)]
        [string]$FileName
    )

    # Validate the file name
    if (!(Test-Path $FileName)) {
        Write-Error "File $FileName does not exist"
        return
    }

    # Call git add with the file name
    git add $FileName

    # Return the status code of the git command
    return $?
}

# Define a function that commits with a given message and an optional prefix 
function Commit-Message {
     param (
         # The message to commit with 
         [Parameter(Mandatory=$true)]
         [string]$Message,

         # The optional prefix to add before the message 
         [Parameter(Mandatory=$false)]
         [string]$Prefix = ""
        
     )

     # If there is a prefix, add a space after it 
     if ($Prefix) {
         $Prefix += " "
     }

     # Call git commit with the prefix and the message as an argument 
     git commit -m "$Prefix$Message"

     # Return the status code of the git command 
     return $? 
}

# Get the file name and the branch name from the arguments 
$FileName = $args[0] 
$BranchName = $args[1]

# Check if the arguments are valid 
if (!$FileName) { 
     Write-Host "Usage: .\script.ps1 <file name> [<branch name>]" 
     exit 
}

# Get the list of commits that modified the file using the Get-Commits function 
$Commits = Get-Commits -FileName $FileName -BranchName $BranchName

# Create a new branch with the given name using the New-Branch function 
New-Branch -BranchName $BranchName

# Loop through the commits and create and apply a patch for each one using the New-Patch and Apply-Patch functions  
foreach ($Commit in $Commits) {
    
     # Create a patch file with the commit hash as the name and get the original commit message using the New-Patch function  
     $Patch = New-Patch -CommitHash $Commit

     # Apply the patch to the new branch using the Apply-Patch function  
     if (Apply-Patch -PatchFile $Patch.PatchFile) {

         # Add the file to the staging area using the Add-File function  
         if (Add-File -FileName $FileName) {

             # Commit with the commit hash and the original commit message as the message using the Commit-Message function  
             Commit-Message -Message $Patch.CommitMessage -Prefix $Commit

             # Delete the patch file  
             Remove-Item $Patch.PatchFile
         }
     }
}

# Show the log of the new branch 
git log --oneline --graph --decorate --all
