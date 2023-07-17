# Define the list of paths to .git files
$paths = @(Get-Clipboard)

# Define an empty array to store the output
$output = @()

# Define a progress counter
$progress = 0

# For each path, go to the parent folder, check git status, and return status or error
foreach ($path in $paths) {
    # Get the parent folder of the .git file
    $parentFolder = Split-Path $path -Parent

    # Change the current location to the parent folder
    Set-Location $parentFolder

    # Try to check the git status and capture the output or error
    try {
        # Wrap the git call with invoke-expression and 2>&1 to redirect stderr to stdout
        $status = Invoke-Expression "git status 2>&1"
        $errorX = $null
    }
    catch {
        $status = $null
        $errorX = $_.Exception.Message
    }

    # Create a custom object with the path and the status or error
    $object = [PSCustomObject]@{
        Path = $path
        Status = if ($status) { $status } else { $errorX }
    }

    # Add the object to the output array
    $output += $object

    # Increment the progress counter
    $progress++

    # Write a progress bar with the current percentage and path
    Write-Progress -Activity "Checking git status" -Status "$path" -PercentComplete ($progress / $paths.Count * 100)
}

# Group the output by status and then list the paths of each group
$output | ForEach-Object {
     # If status is an object, convert it to string 

# Get the first two words of status
$words = $_.Status.ToString().Split()
$firstTwoWords = $words[0..1] -join " "

# Add a new property to store the first two words of status
$_ | Add-Member -MemberType NoteProperty -Name FirstTwoWords -Value $firstTwoWords

} | Group-Object -Property FirstTwoWords | ForEach-Object { 
    # Write a separator line 
Write-Host (“-” * 80)

# Write the group name (first two words of status)
Write-Host $_.Name

# Write the paths of the group members
$_.Group | Select-Object -ExpandProperty Path | Write-Host

}
