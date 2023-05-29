$env:GIT_REDIRECT_STDERR = '2>&1'


function addProperty($object,$name,$function)
{

    $object = [PSCustomObject]@{
            path = "Value1"
        }

    $object | Add-Member -MemberType NoteProperty -Name Property2 -Value "Value2"
}


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