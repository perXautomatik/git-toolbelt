<#can you help me rewrite this pseudocode into powershell script;
in a git repository,
    undo last commit,
        for each json file changed or added in commit (not renamed, atleast not 100% identical rename), 
            commit as separate commit
                with message and content from the json file
    recommit any files not recommited, as the last commits date, author, message
 #>   
    
# Get the last commit object
$lastCommit = git log -1 --pretty=format:"%H"

# Get the last commit's date, author and message
$lastCommitDate = git log -1 --pretty=format:"%ad" $lastCommit
$lastCommitAuthor = git log -1 --pretty=format:"%an <%ae>" $lastCommit
$lastCommitMessage = git log -1 --pretty=format:"%s" $lastCommit



# Undo the last commit and keep the changes
git reset --soft HEAD~1

# Get the list of json files changed or added in the last commit
$jsonFiles = git diff --name-only --diff-filter=AM $lastCommit | Where-Object { $_.EndsWith(".json") }

# For each json file, commit it separately with the message and content from the file
foreach ($jsonFile in $jsonFiles) {
    # Read the json file content
    $jsonContent = Get-Content $jsonFile -Raw

    # Parse the json content as an object
    $jsonObject = ConvertFrom-Json $jsonContent

    # Get the message from the json object
    $message = $jsonObject.message

    # Add the json file to the staging area
    git add $jsonFile

    # Commit the json file with the message
    git commit -m $message
}

# Add any remaining files to the staging area
git add .

# Recommit any files not recommited, as the last commit's date, author, message
# Commit with the last commit's date, author and message
git commit --date="$lastCommitDate" --author="$lastCommitAuthor" -m "$lastCommitMessage"
