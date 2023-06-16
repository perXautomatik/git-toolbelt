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

  # Create an empty hashtable to store the subpaths and their parent folders
  $subpaths = @{}

  # Loop through each parent folder in the hashtable
  foreach ($parentFolder in $parentFolders.Keys) {
    # Get the subpath of the parent folder by removing the drive letter and colon
    $subpath = $parentFolder -replace "^[A-Z]:"

    # If the subpath already exists in the hashtable, add the parent folder and its count to its value
    if ($subpaths.ContainsKey($subpath)) {
      $subpaths[$subpath] += @{"$parentFolder" = $parentFolders[$parentFolder]}
    }
    # Otherwise, create a new entry in the hashtable with the subpath as the key and the parent folder and its count as the value
    else {
      $subpaths[$subpath] = @{"$parentFolder" = $parentFolders[$parentFolder]}
    }
  }

  # Sort the subpaths hashtable by the sum of the counts of their parent folders in descending order
  $sortedSubpaths = $subpaths.GetEnumerator() | Sort-Object -Property {($_.Value.Values | Measure-Object -Sum).Sum} -Descending

  # Create an empty array to store the output objects
  $output = @()

  # Loop through each sorted subpath in the hashtable
  foreach ($sortedSubpath in $sortedSubpaths) {
    # Create a custom object with three properties: Subpath, ParentFolders, and TotalCount
    $object = [PSCustomObject]@{
      Subpath = $sortedSubpath.Key
      TotalCount = ($sortedSubpath.Value.Values | Measure-Object -Sum).Sum
      ParentFolders = $sortedSubpath.Value.Keys -join ", "      
    }

    # Add the object to the output array
    $output += $object
  }

  # Return the output array
  return $output
}

# Test the function with some sample paths
$paths = Get-Clipboard
Get-ParentFolders $paths
