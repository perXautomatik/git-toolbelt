# Define a function that takes a list of paths as input
function Get-ParentFolders ($paths) {
  # Create an empty hashtable to store the parent folders and their counts
  $parentFolders = @{}

  # Loop through each path in the list
  foreach ($path in $paths) {
    # Get the parent folder of the path
    $parent = Split-Path $path -Parent

    # If the parent folder already exists in the hashtable, increment its count
    if ($parentFolders.ContainsKey($parent)) {
      $parentFolders[$parent]++
    }
    # Otherwise, add it to the hashtable with a count of 1
    else {
      $parentFolders[$parent] = 1
    }
  }

  # Sort the hashtable by the count value in descending order
  $sortedParentFolders = $parentFolders.GetEnumerator() | Sort-Object -Property Value -Descending

  # Return the sorted hashtable
  return $sortedParentFolders
}

# Test the function with some sample paths
$paths = Get-Clipboard
Get-ParentFolders $paths