# Get the file name from the user input
$fileName = Read-Host "Enter the file name"

# Check if the current working folder is a git repository
if (Test-Path .git) {
    # Find all the references of the file name in the repository history by blob
    $references = git log --raw --abbrev=40 --pretty=format:"%H" -- $fileName | Select-String -Pattern "^[0-9a-f]{40}$|^[ACDMRTUXB]"

    # Initialize an empty array to store the blob sequences
    $sequences = @()

    # Initialize an empty string to store the current blob sequence
    $sequence = ""

    # Loop through each reference
    foreach ($reference in $references) {
        # If the reference is a commit hash, start a new blob sequence
        if ($reference -match "^[0-9a-f]{40}$") {
            # If the current blob sequence is not empty, add it to the array
            if ($sequence -ne "") {
                $sequences += $sequence.TrimEnd("-")
            }
            # Reset the current blob sequence
            $sequence = ""
        }
        # If the reference is a change status, append the old and new blob hashes to the current blob sequence
        if ($reference -match "^[ACDMRTUXB]") {
            # Split the reference by whitespace and get the third and fourth elements, which are the old and new blob hashes
            $hashes = $reference -split "\s+" | Select-Object -Index 2,3
            # Append the hashes to the current blob sequence, separated by "-"
            $sequence += "$hashes[0]-$hashes[1]-"
        }
    }
    # If the current blob sequence is not empty, add it to the array
    if ($sequence -ne "") {
        $sequences += $sequence.TrimEnd("-")
    }

    # Present each blob sequence touching the file name as SHA-1 hashes separated by "-"
    Write-Host "The following are the blob sequences touching the file name $fileName:"
    foreach ($sequence in $sequences) {
        Write-Host $sequence
    }
}
else {
    # If the current working folder is not a git repository, show an error message
    Write-Error "The current working folder is not a git repository"
}
