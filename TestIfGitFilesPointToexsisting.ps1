<#
   ========================================================================================================================
   Name         : <Name>.ps1
   Description  : This script ............................
   Created Date : %Date%
   Created By   : %UserName%
   Dependencies : 1) Windows PowerShell 5.1
                  2) .................

   Revision History
   Date       Release  Change By      Description
   %Date% 1.0      %UserName%     Initial Release
   ========================================================================================================================
#>

# Get all the .git files in the current directory and its subdirectories
$gitFiles = Get-ChildItem -Filter ".git" -Recurse

# Loop through each .git file
foreach ($gitFile in $gitFiles) {
  # Read the content of the .git file
  $content = Get-Content $gitFile

  # Extract the "gitdir" path using a regular expression
  $pattern = "gitdir: (.*)"
  if ($content -match $pattern) {
    $gitDir = $Matches[1]
  }
  else {
    # Skip this file if it does not contain a "gitdir" reference
    continue
  }

  # Resolve the "gitdir" path to an absolute path
  $absolutePath = Resolve-Path -Path $gitDir -RelativeTo $gitFile.DirectoryName

  # Check if the "gitdir" path exists
  if (Test-Path $absolutePath) {
    # Output a success message
    Write-Output "$($gitFile.FullName) has a valid gitdir reference to $($absolutePath)"
  }
  else {
    # Output an error message
    Write-Output "$($gitFile.FullName) has an invalid gitdir reference to $($absolutePath)"
  }
}

