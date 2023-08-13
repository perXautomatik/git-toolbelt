# Define the parameters for the script
param (
    [string]$RepoPath, # The path to the git repo
    [string]$FileName  # The filename to filter the commits
)

# Change the current directory to the repo path
Set-Location $RepoPath

# Get all the commits that touch the filename in all branches
$Commits = git log --all --pretty=format:"%H %an %ad %s" --name-status -- $FileName

# Split the commits by newline and filter out the ones that delete the file
$Commits = $Commits -split "`n" | Where-Object {$_ -notmatch "^D\t"}

# Sort the commits by date in ascending order
$Commits = $Commits | Sort-Object {datetime[2..4] -join " "}

# Initialize an empty array to store the unique commits
$UniqueCommits = @()

# Loop through the commits and check for duplicates
foreach ($Commit in $Commits) {
    # Get the commit hash, author, date, message and status from the string
    $Hash, $Author, $Date, $Message, $Status = $Commit -split " ", 5

    # Get the file content after applying the commit
    $Content = git show $Hash:$FileName

    # Check if there is any existing commit with the same content in the unique array
    $Duplicate = $UniqueCommits | Where-Object {git show $_.Hash:$FileName -eq $Content}

    # If there is no duplicate, add the commit to the unique array
    if (-not $Duplicate) {
        $UniqueCommits += [PSCustomObject]@{
            Hash = $Hash
            Author = $Author
            Date = $Date
            Message = $Message
            Status = $Status
        }
    }
    # If there is a duplicate, compare the author and message length and keep the one with higher priority
    else {
        # Get the index of the duplicate commit in the unique array
        $Index = [array]::IndexOf($UniqueCommits, $Duplicate)

        # Count the number of occurrences of each author in the unique array
        $AuthorCount = $UniqueCommits | Group-Object Author | Select-Object Name, Count

        # Get the number of occurrences of the current author and the duplicate author
        $CurrentAuthorCount = ($AuthorCount | Where-Object {$_.Name -eq $Author}).Count
        $DuplicateAuthorCount = ($AuthorCount | Where-Object {$_.Name -eq $Duplicate.Author}).Count

        # Compare the author counts and message lengths and update the unique array accordingly
        if ($CurrentAuthorCount -gt $DuplicateAuthorCount -or ($CurrentAuthorCount -eq $DuplicateAuthorCount -and $Message.Length -gt $Duplicate.Message.Length)) {
            $UniqueCommits[$Index] = [PSCustomObject]@{
                Hash = $Hash
                Author = $Author
                Date = $Date
                Message = $Message
                Status = $Status
            }
        }
    }
}

# Create a new branch with a random name
$BranchName = "branch-" + (Get-Random)
git checkout -b $BranchName

# Loop through the unique commits and cherry-pick them with theirs strategy and path option, ignoring empty commits
foreach ($Commit in $UniqueCommits) {
    git cherry-pick --strategy-option=theirs --path "$FileName" --allow-empty-message --keep-redundant-commits --no-commit "$Commit.Hash"
}
