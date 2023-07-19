#must be a functional repo
function gsx () {

# Define the parameters
param (
  [string]$RepoURL,
  [string]$MatchString
)
    # A function to run git commands and check the exit code
    function Invoke-Git {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Command # The git command to run
        )
        # Run the command and capture the output
        $output = Invoke-Expression -Command "git $Command 2>&1" -ErrorAction Stop 
        # return the output to the host
        $output
        # Check the exit code and throw an exception if not zero
       if ($LASTEXITCODE -ne 0) {
            trow "Git command failed: git $Command"
        }
    }

# Create a temporary folder
$TempFolder = New-TemporaryFile | %{ Remove-Item -Path $_.FullName -Force; $path = $_ -replace "\..*$";New-Item -ItemType Directory -Path ($path) -ErrorAction Stop }

# Change the current directory to the repo path
Set-Location $TempFolder -PassThru

 $regex = "/[^/:]+(?=(\.git)?($|:))/"
 $newFolder = $RepoURL -replace $regex , ''

# Clone the repo into the temporary folder

try {
invoke-git "clone --local $RepoURL $newFolder" 
Set-Location $newFolder -PassThru
}
catch
{ 
    Write-Error "--local failed"
try{
 invoke-git "clone --no-hardlinks $RepoURL"

 Set-Location $newFolder -PassThru
 }
 catch
 {
    Write-Error "--no-hardlinks failed"

    invoke-git "init"
    invoke-git "fetch $RepoURL"
 }
}



invoke-git "status"



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

Write-Host $TempFolder

}

gsx -RepoURL 'B:\PF\.git\modules\PowerShell' -MatchString 'git'

