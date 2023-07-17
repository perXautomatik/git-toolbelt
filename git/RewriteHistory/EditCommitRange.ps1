<#
.SYNOPSIS
Select and modify commits from a git repository based on a range of criteria.

.DESCRIPTION
This script takes four parameters: the path to the git repository, the start date, the end date, and the author name. It then changes the current directory to the git repository and uses the git log command to select the commits that match the criteria. It then displays the selected commits in a grid view and allows the user to modify their properties, such as message, author, date, etc. It then uses the git filter-branch command to reapply the modified commits back to the repository, changing its history.

.PARAMETER GitRepoPath
The path to the git repository to select and modify commits from.

.PARAMETER StartDate
The start date of the range of commits to select. The default value is "1970-01-01".

.PARAMETER EndDate
The end date of the range of commits to select. The default value is "2099-12-31".

.PARAMETER AuthorName
The author name of the commits to select. The default value is "*".

.EXAMPLE
PS C:\> Select-Modify-Commits -GitRepoPath "C:\Users\user\Documents\my-repo" -StartDate "2021-01-01" -EndDate "2021-12-31" -AuthorName "user"

This example selects and modifies the commits from the "C:\Users\user\Documents\my-repo" repository that were made by "user" between "2021-01-01" and "2021-12-31".
#>

function Select-Modify-Commits {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$GitRepoPath,
        [Parameter(Mandatory=$false)]
        [string]$StartDate = "1970-01-01",
        [Parameter(Mandatory=$false)]
        [string]$EndDate = "2099-12-31",
        [Parameter(Mandatory=$false)]
        [string]$AuthorName = "*"
    )

    # Change the current directory to the git repository
    cd $GitRepoPath

    # Use the git log command to select the commits that match the criteria
    $commits = git log --pretty=format:"%H|%an|%ae|%ad|%s" --after=$StartDate --before=$EndDate --author=$AuthorName

    # Convert the output of the git log command to custom objects with properties
    $commitObjects = $commits | ForEach-Object {
        $parts = $_ -split "\|"
        [PSCustomObject]@{
            Hash = $parts[0]
            AuthorName = $parts[1]
            AuthorEmail = $parts[2]
            AuthorDate = $parts[3]
            Message = $parts[4]
        }
    }

    # Display the selected commits in a grid view and allow the user to modify their properties
    $modifiedCommits = $commitObjects | Out-GridView -Title "Select and modify commits" -PassThru

    # Loop through each modified commit
    foreach ($commit in $modifiedCommits) {

        # Use the git filter-branch command to reapply the modified commit back to the repository, changing its history
        git filter-branch -f --env-filter @'
if [ "$GIT_COMMIT" = "$($commit.Hash)" ]
then
    export GIT_AUTHOR_NAME="$($commit.AuthorName)"
    export GIT_AUTHOR_EMAIL="$($commit.AuthorEmail)"
    export GIT_AUTHOR_DATE="$($commit.AuthorDate)"
    export GIT_COMMITTER_NAME="$($commit.AuthorName)"
    export GIT_COMMITTER_EMAIL="$($commit.AuthorEmail)"
    export GIT_COMMITTER_DATE="$($commit.AuthorDate)"
fi
'@
        # Use the git commit --amend command to change the message of the modified commit
        git commit --amend -m "$($commit.Message)"
    }
}
