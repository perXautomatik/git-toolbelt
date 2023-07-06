$env:GIT_REDIRECT_STDERR = '2>&1'

<#
This code is a PowerShell function that checks the status of git
 repositories in a given directory and its subdirectories. 
 It uses a queue data structure to store the paths of the
  directories and loops through them until the queue is empty. 
  It displays the git status of each directory and skips the 
  ones that are not git repositories. It also shows a progress 
  bar with the percentage of directories processed.#>

function checkPathTree($start) 
{

    begin
    {
        Write-Progress -Activity "Processing files" -Status "Starting" -PercentComplete 0


        $que = New-Object System.Collections.Queue
    
        $start | % { $que.Enqueue($_) }
        $i = 0;
    }
    process {

        do
        {    
            $i++;
            $path = $que.Dequeue()
    
            cd $path;

            $st = (git status).toString() -join ";"


            $object = [PSCustomObject]@{ index = $i ; queCount = $que.count  ; path = $path ; procent = ($i / ($que.count+$i) ) }

            $object | Add-Member -MemberType NoteProperty -Name gitStatus -Value $st



            if($st -like "fatal*")
            {
            try {
                  ($object | Select-Object -Property quecount, path, gitStatus | format-table )
                  }
            catch {}
            }

            if($i -lt 5 -or !($st -like "fatal*"))
            {
                Get-ChildItem -Path "$path\*" -Directory -Exclude "*.git*" | % { $que.Enqueue($_.FullName) }
         
            }
     
            $percentComplete =  ($i / ($que.count+$i) ) * 100
            Write-Progress -Activity "Processing files" -PercentComplete $percentComplete
         
        } while ($que.Count -gt 0)
    }
    end {
        Write-Progress -Activity "Processing files" -Status "Finished" -PercentComplete 100
    }
}

checkPathTree "B:\toGit"