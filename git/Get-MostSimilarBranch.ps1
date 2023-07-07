# query: can you write me a powershell script which accepts a object "commit,sha,branch,or path" and returns the tree contained of the branch that is the most similar to provided object, any tree included in all history of the repo
# Define a function that accepts an object and returns the most similar branch
function Get-MostSimilarBranch {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Object
    )

    # Get the current repository
    $repo = git rev-parse --show-toplevel

    # Check the type of the object
    switch ($Object) {
        # If it is a commit, get its SHA
        {$_ -is [LibGit2Sharp.Commit]} {
            $sha = $Object.Sha
            break
        }
        # If it is a SHA, use it as is
        {$_ -match '^[0-9a-f]{40}$'} {
            $sha = $_
            break
        }
        # If it is a branch, get its tip SHA
        {$_ -match '^refs/heads/'} {
            $sha = git rev-parse $_
            break
        }
        # If it is a path, get the SHA of the latest commit that modified it
        {Test-Path -Path $_} {
            $sha = git log -1 --format=%H -- $_
            break
        }
        # Otherwise, throw an error
        default {
            throw "Invalid object: $Object"
        }
    }

    # Get all the branches in the repository
    $branches = git branch --all

    # Initialize a hashtable to store the similarity scores for each branch
    $scores = @{}

    # For each branch, calculate the similarity score with the object SHA
    foreach ($branch in $branches) {
        # Get the tip SHA of the branch
        $branch_sha = git rev-parse $branch

        # Get the common ancestor of the object SHA and the branch SHA
        $merge_base = git merge-base $sha $branch_sha

        # Get the number of commits between the object SHA and the common ancestor
        $ahead = git rev-list --count $merge_base..$sha

        # Get the number of commits between the branch SHA and the common ancestor
        $behind = git rev-list --count $merge_base..$branch_sha

        # Calculate the similarity score as 1 / (1 + ahead + behind)
        $score = 1 / (1 + $ahead + $behind)

        # Store the score in the hashtable with the branch name as the key
        $scores[$branch] = $score
    }

    # Sort the hashtable by value in descending order and get the first key, which is the most similar branch
    $most_similar_branch = ($scores.GetEnumerator() | Sort-Object Value -Descending)[0].Key

    # Return the most similar branch
    return $most_similar_branch
}

# Define a function that accepts an object and returns the tree contained of the most similar branch
function Get-TreeOfMostSimilarBranch {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Object
    )

    # Get the most similar branch using the previous function
    $most_similar_branch = Get-MostSimilarBranch -Object $Object

    # Get the tree contained of the most similar branch using git ls-tree command
    $tree = git ls-tree -r --name-only $most_similar_branch

    # Return the tree as an array of strings
    return @($tree)
}

# Example usage: get the tree of the most similar branch to a given commit object
$commit = git log -1 | ConvertFrom-GitLog | Select-Object -First 1

$tree = Get-TreeOfMostSimilarBranch -Object $commit

Write-Output "The tree of the most similar branch to commit $($commit.Sha) is:"

$tree | ForEach-Object {
    Write-Output $_
}
