function SubmodulesRecursive {
  param(
    [string]$repoPath
  )

    # Define a function to run git commands and check the exit code
    function Invoke-Git {
      param(
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

    cd $repoPath

    $list = @(invoke-git "submodule foreach --recursive 'git rev-parse --git-dir'")   #‘git status'
    $result = @() # empty array for result
    foreach ($i in 0.. ($list.count-2)) { 
      if ($i % 2 -eq 0) 
      {
        $result += , [PSCustomObject]@{
          base = $repoPath
          relative = $list[$i]
          gitDir = $list[$i+1]
        }
      }
    }
    $result # display result
}



SubmodulesRecursive 'B:\PF\scoopbucket-presist\AppData'

SubmodulesRecursive  'B:\PF\chris\AppData'
