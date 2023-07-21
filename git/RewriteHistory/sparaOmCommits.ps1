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
# A powershell function that cleans branches using git-filter-repo
function Clean-Branch-GitFilterRepo {
  # Get the arguments
  param (
    [string]$branch,
    [string]$pattern,
    [string]$replacement
  )

  # Check if the arguments are valid
  if (-not $branch -or -not $pattern -or -not $replacement) {
    Write-Error "Please provide a branch, a pattern and a replacement as arguments"
    return
  }

  # Use git-filter-repo to clean the branch
  git filter-repo --refs $branch --blob-callback "
    blob.data = blob.data.replace(b'$pattern', b'$replacement')
  "
}

# A powershell function that cleans branches using BFG Repo-Cleaner
function Clean-Branch-BFG {
  # Get the arguments
  param (
    [string]$branch,
    [string]$pattern,
    [string]$replacement
  )

  # Check if the arguments are valid
  if (-not $branch -or -not $pattern -or -not $replacement) {
    Write-Error "Please provide a branch, a pattern and a replacement as arguments"
    return
  }

  # Create a temporary file to store the replacements
  $tempfile = New-TemporaryFile
  echo "$pattern==$replacement" > $tempfile

  # Use BFG to clean the branch
  bfg --replace-text $tempfile --no-blob-protection --private my-repo.git

  # Clean up the temporary file
  Remove-Item -Force $tempfile
}
