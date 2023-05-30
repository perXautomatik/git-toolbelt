function Search-GitAllBranches {
    param(
        [Parameter(Mandatory=$true,
        ParameterSetName='SearchString')]
        [string]$match,
 
        [Parameter(Mandatory=$true,
        ParameterSetName='RepoPath')]
        [string]$path
    )
 

cd $path

$mytable = ((git rev-list --all) | 
select -First 10 |
 %{ (git grep $match $_ )})  | %{ $all = $_.Split(':') ; [system.String]::Join(":", $all[2..$all.length]) }

$HashTable=@{}
foreach($r in $mytable)
{
   $HashTable[$r]++
}
$errors = $null

$HashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name 
}