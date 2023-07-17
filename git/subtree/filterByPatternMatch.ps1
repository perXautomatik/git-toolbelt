function gsx () {

# Define the parameters
param (
  [string]$RepoURL,
  [string]$MatchString
)

# Create a temporary folder
$TempFolder = New-TemporaryFile | % { Remove-Item -Path $_.FullName -Force; 

try {
New-Item -ItemType Directory -Path $_.FullName -ErrorAction Stop
}
catch
{
    rm -Path $_.FullName;
    New-Item -ItemType Directory -Path $_.FullName 
}
}

# Change the current directory to the repo path
Set-Location $TempFolder -PassThru


# Clone the repo into the temporary folder
invoke-expression "git clone --local $RepoURL $TempFolder" 

git status

# Check if filter-repo is available
  if (Get-Command git-filter-repo -ErrorAction SilentlyContinue) {
    # Use filter-repo to get only the history relevant to the file
    git filter-repo --path-glob "*$MatchString*" --force
  }
  else {
  # Get all the files in the repo that match the pattern
$Files = Get-ChildItem -Recurse -Filter "*$MatchString*"

# Loop through each file
foreach ($File in $Files) {
  # Get the relative path of the file
  $FilePath = $File.FullName.Replace($RepoPath, "")

    # Use filter-branch to get only the history relevant to the file
    git filter-branch --tree-filter "git ls-files -z | grep -zv '$FilePath' | xargs -0 rm" --prune-empty --force
  
    }
}

}

gsx -RepoURL 'C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\' -MatchString 'bucket/waifu2x'

