#cls #Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser #. '\\100.84.7.151\NetBackup\Project Shelf\ToGit\PowerShellProjectFolder\scripts\TodoProjects\Tokenization.ps1'
function Search-GitAllBranches {
    param(
        [Parameter(Mandatory=$true,
        ParameterSetName='SearchString')]
        [string]$match,
 
        [Parameter(Mandatory=$true,
        ParameterSetName='RepoPath')]
        [string]$path
    )
 

$repoPath = 'D:\Users\crbk01\AppData\Roaming\JetBrains\Datagrip\consolex\db\' ; cd $repoPath
cd $path

$fileName = 'harAnsökan (3).sql'
#

$mytable = ((git rev-list --all) | 
select -First 10 |
 %{ (git grep $match $_ )})  | %{ $all = $_.Split(':') ; [system.String]::Join(":", $all[2..$all.length]) }

$searchString = "utanOnÃ¶digaHandlingar"
$regexSearchstring = [Regex]::Escape($searchString)
$Date = "2020-03-02"

#git log --all --before $date -G $searchString 
#git grep $searchString 

#git log --all --oneline --source -- $fileName

# git branch --contains <commit> - to figure out which branch contains the specific sha1

# If you get Argument list too long, you can use git rev-list --all | xargs git grep 'abc':
$out = @{}

#$mytable = (git rev-list --all) # get all commits in the whole repo
#$mytable | Measure-Object

#git log -G $regexSearchstring

$mytable = (git log --all --before="$Date" --pretty=format:"%H")

$mytable | Measure-Object
#$mytable | ? { $true -eq (git grep --ignore-case --word-regexp --fixed-strings --count -o $seachString -- $_)  } | Measure-Object

$mytable | ? { $true -eq (git log -G $regexSearchstring -- $_)  } | Measure-Object

#$mytable | % { git log -p --grep-reflog=$regexSearchstring  $_ } | Measure-Object

# Pipe the events to the ForEach-Object cmdlet.
$mytable | ForEach-Object -Begin {
    # In the Begin block, use Clear-Host to clear the screen.
    Clear-Host
    # Set the $i counter variable to zero.
    $i = 0
    # Set the $out variable to a empty string.
} -Process {
    # In the Process script block search the message property of each incoming object for "bios".    
    $res =  (git grep --ignore-case --word-regexp --fixed-strings -o $seachString -- $_)
    if($res)
    {
        # Append the matching message to the out variable.        
        
        $res 
    }
    # Increment the $i counter variable which is used to create the progress bar.
    $i = $i+1
    # Determine the completion percentage
    $Completed = ($i/$myTable.count*100)
    # Use Write-Progress to output a progress bar.
    # The Activity and Status parameters create the first and second lines of the progress bar
    # heading, respectively.
    Write-Progress -Activity "Searching Events" -Status "Progress:" -PercentComplete $Completed
} -End {
    # Display the matching messages using the out variable.
    #$out
}

#$out 



     #Out-Host -Paging ;   does not work in ise
        




$HashTable=@{}
foreach($r in $mytable)
{
   $HashTable[$r]++
}
$errors = $null

$HashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name 
#  | select value, name, @{Expression = TokenizeCode $_ ; Name = "token"}
}