# Define the two files to compare
$file1 = "file1.txt"
$file2 = "file2.txt"

# Get the git diff output for the files
$diff = git diff --no-index $file1 $file2

# Write the diff output to the console
Write-Host $diff

# Initialize the counters for the lines
$similar = 0
$changed = 0
$missing1 = 0 # Missing lines in file1
$missing2 = 0 # Missing lines in file2

# Loop through the diff output and count the lines
foreach ($line in $diff) {
    # Ignore the header lines that start with "diff", "index", "---" or "+++"
    if ($line -notmatch "^diff|^index|^-{3}|\+{3}") {
        # If the line starts with a space, it is a similar line
        if ($line -match "^ ") {
            $similar++
        }
        # If the line starts with a minus, it is a missing line in file2
        elseif ($line -match "^-") {
            $missing2++
        }
        # If the line starts with a plus, it is a missing line in file1 or a changed line in file2
        elseif ($line -match "^\+") {
            # Check if the next line is also a plus, which means it is a changed line
            if ($diff[$diff.IndexOf($line) + 1] -match "^\+") {
                $changed++
            }
            else {
                $missing1++
            }
        }
    }
}

# Write the summary of the lines to the console
Write-Host "Similar lines: $similar"
Write-Host "Changed lines: $changed"
Write-Host "Missing lines in file1: $missing1"
Write-Host "Missing lines in file2: $missing2"
