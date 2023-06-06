
cd 'B:\PF\scoopbucket-presist\' ; git submodule foreach 'git status'

cd 'B:\PF\chris\' ; git submodule foreach 'git status'

# following method does not work if any submodule returns error

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
          relative = ($list[$i] -split "'")[1]
          gitDir = $list[$i+1]
        }
      }
    }
    $result # display result
}

$people1 = SubmodulesRecursive 'B:\PF\scoopbucket-presist\' | select @{name='GitDirSP'; expression={$_.gitdir} },relative, @{name='baseSP'; expression={$_.base} }

$people2 = SubmodulesRecursive  'B:\PF\chris\'

$people1
$people2




$keySelector = [Func [object,object]] { param($x) $x.relative }

# Use LINQ to join the two arrays by their Name property and select a new object with all properties.
$joined = [System.Linq.Enumerable]::Join(
  $people1,
  $people2,
  $keySelector, # outer key selector
  $keySelector, # inner key selector
  [Func [object,object,object]] { param($x,$y) # result selector
    # Create a new object with all properties from both objects.
    $props = @{}
    foreach ($prop in ($x.psobject.Properties+$y.psobject.Properties)) { $props[$prop.Name] = $prop.Value }
    [pscustomobject] $props
  }
)


$joined

# Output the result.
$joined | % {
    cd $_.baseSP
    cd $_.relative
    $q = Join-Path $_.base $_.relative

    
    git config --get core.worktree
    
    #git config --local --replace-all core.worktree $q
     
}

#$List2 = invoke-git "submodule foreach --recursive" #‘git status'

#Compare-Object -ReferenceObject $List1 -DifferenceObject $List2 -PassThru


# git --git-dir /home/gituser/website1.git --work-tree /var/www/website1 status
# GIT_DIR=/home/gituser/website1.git GIT_WORK_TREE=/var/www/website1 git status
