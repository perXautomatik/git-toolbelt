

function GitGrep {
  param ([string]$range, [string]$grepThis)

  git log --pretty=format:"%H" $range --no-merges --grep="$grepThis" | ForEach-Object {
    $Body = git log -1 --pretty=format:"%b" $_ | Select-String "$grepThis"
    if($Body) {
      git log -1 --pretty=format:"%H,%s" $_
      Write-Host $Body
    }
  }
}

function Git-LsTree {
  param ([string]$range, [string]$grepThis)
  
  
$Body =  git ls-tree $range -r
  
     $body | % { 
     $spl = $_ -split ' ',3
     [pscustomobject]@{     
         hash = $range
         q = $spl[0].trim()
         type = $spl[1].trim()
         objectID = $spl[2].Substring(0,40).trim()
         relative = $spl[2].Substring(40).trim()
 
 
      }
    }
}

function Git-FindObject {
  param ([string]$grepThis)
  
 git log -t --find-object=$grepThis | ?{ $zxc = $_ ;$null -ne ('commit' | ? { $zxc -match $_ })  }

 }
 
 cls

git log --pretty=format:"%H" | select -First 1  | %{ Git-LsTree $_ }  | select -First 1 | % { Git-FindObject -grepThis $_.objectId }

