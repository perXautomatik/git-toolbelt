# This function creates a queue of directories to process
function createQueue($start) {
    $que = New-Object System.Collections.Queue
    $start | % { $que.Enqueue($_) }
    return $que
}

# This function changes the current directory to a given path and returns the git status as a string
function getGitStatus($path) {
    cd $path
    $st = (git status).toString() -join ";"
    return $st
}

# This function creates a custom object with the index, queue count, path, percentage and git status of a directory
function createObject($i, $que, $path, $st) {
    $object = [PSCustomObject]@{ index = $i ; queCount = $que.count  ; path = $path ; procent = ($i / ($que.count+$i) ) }
    $object | Add-Member -MemberType NoteProperty -Name gitStatus -Value $st
    return $object
}

# This function displays the custom object if the git status is fatal (meaning not a git repository)
function displayObject($object) {
    if($object.gitStatus -like "fatal*")
    {
        try {
            ($object | Select-Object -Property quecount, path, gitStatus | format-table )
        }
        catch {}
    }
}

# This function adds the subdirectories of a given path to the queue if the git status is not fatal and the index is less than 5
function addSubdirectories($i, $que, $path, $st) {
    if($i -lt 5 -or !($st -like "fatal*"))
    {
        Get-ChildItem -Path "$path\*" -Directory -Exclude "*.git*" | % { $que.Enqueue($_.FullName) }
    }
}

# This function updates the progress bar with the percentage of directories processed
function updateProgress($i, $que) {
    $percentComplete =  ($i / ($que.count+$i) ) * 100
    Write-Progress -Activity "Processing files" -PercentComplete $percentComplete
}

# This function checks the status of git repositories in a given directory and its subdirectories using the above functions
function checkPathTree($start) 
{
    begin
    {
        Write-Progress -Activity "Processing files" -Status "Starting" -PercentComplete 0

        # Create a queue of directories to process
        $que = createQueue($start)
        $i = 0;
    }
    process {

        do
        {    
            $i++;
            # Dequeue a path from the queue
            $path = $que.Dequeue()
    
            # Get the git status of the path
            $st = getGitStatus($path)

            # Create a custom object with the relevant information
            $object = createObject($i, $que, $path, $st)

            # Display the object if the git status is fatal
            displayObject($object)

            # Add the subdirectories of the path to the queue if the git status is not fatal and the index is less than 5
            addSubdirectories($i, $que, $path, $st)
     
            # Update the progress bar with the percentage of directories processed
            updateProgress($i, $que)
         
        } while ($que.Count -gt 0)
    }
    end {
        Write-Progress -Activity "Processing files" -Status "Finished" -PercentComplete 100
    }
}
