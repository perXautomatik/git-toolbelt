
# Synopsis: A script to get the submodules recursively for a given repo path or a list of repo paths
# Parameter: RepoPaths - The path or paths to the repos
param (
  [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
  [string[]]$RepoPaths # The path or paths to the repos
)

# A function to validate a path argument
function Validate-Path {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter(Mandatory=$true)]
    [string]$Name
  )
  if (-not (Test-Path $Path)) {
    Write-Error "Invalid $Name path: $Path"
    exit 1
  }
}

# A function to run git commands and check the exit code
function Invoke-Git {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Command # The git command to run
  )
  # Run the command and capture the output
  $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
  # return the output to the host
  $output
  # Check the exit code and throw an exception if not zero
  if ($LASTEXITCODE -ne 0) {
    throw "Git command failed: git $Command"
  }
}

# A function to get the submodules recursively for a given repo path
function Get-SubmodulesRecursive {
  param(
    [Parameter(Mandatory=$true)]
    [string]$RepoPath # The path to the repo
  )

  begin {
    # Validate the repo path
    Validate-Path -Path $RepoPath -Name "repo"

    # Change the current directory to the repo path
    Set-Location $RepoPath

    # Initialize an empty array for the result
    $result = @()
  }

  process {
    # Run git submodule foreach and capture the output as an array of lines
    $list = @(Invoke-Git "submodule foreach --recursive 'git rev-parse --git-dir'")

    # Loop through the list and skip the last line (which is "Entering '...'")
    foreach ($i in 0.. ($list.count-2)) { 
      # Check if the index is even, which means it is a relative path line
      if ($i % 2 -eq 0) 
      {
        # Create a custom object with the base, relative and gitDir properties and add it to the result array
        $result += , [PSCustomObject]@{
          base = $RepoPath
          relative = $list[$i]
          gitDir = $list[$i+1]
        }
      }
    }
    
  }

  end {
    # Return the result array
    $result 
  }
}

# Call the main function for each repo path in the pipeline
foreach ($RepoPath in $RepoPaths) {
  Get-SubmodulesRecursive -RepoPath $RepoPath
}
