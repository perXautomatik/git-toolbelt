function gsx () {

    # Define the parameters
    param (
      [string]$RepoPath,
      [string]$MatchString
    )

    # Change the current directory to the repo path
    Set-Location $RepoPath

    # Get all the files in the repo that match the pattern
    $Files = Get-ChildItem -Recurse -Filter "*$MatchString*"

    # Loop through each file
    foreach ($File in $Files) {
      # Get the relative path of the file
      $FilePath = $File.FullName.Replace($RepoPath, "")

      # Check if filter-repo is available
      if (Get-Command git-filter-repo -ErrorAction SilentlyContinue) {
        # Use filter-repo to get only the history relevant to the file
        git filter-repo --path "$FilePath" --force
      }
      else {
        # Use filter-branch to get only the history relevant to the file
        git filter-branch --tree-filter "git ls-files -z | grep -zv '$FilePath' | xargs -0 rm" --prune-empty --force
      }
    }
}

gsx -RepoPath 'C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket' -MatchString 'waifu2x*'