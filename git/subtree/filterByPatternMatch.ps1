function gsx () {

# Define the parameters
param (
  [string]$RepoURL,
  [string]$MatchString
)

# Create a temporary folder
$TempFolder = New-TemporaryFile | % { Remove-Item -Path $_.FullName -Force; New-Item -ItemType Directory -Path $_.FullName }
$TempFolder
# Clone the repo into the temporary folder
git clone $RepoURL $TempFolder

# Change the current directory to the repo path
Set-Location $TempFolder

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

return $TempFolder
}

gsx -RepoPath 'C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket' -MatchString 'waifu2x*'

