cls
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser


. '\\100.84.7.151\NetBackup\Project Shelf\ToGit\PowerShellProjectFolder\scripts\TodoProjects\Tokenization.ps1'



cd 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell'

$mytable = ((git rev-list --all) | 
select -First 10 |
 %{ (git grep "echo" $_ )})  | %{ $all = $_.Split(':') ; [system.String]::Join(":", $all[2..$all.length]) }


$HashTable=@{}
foreach($r in $mytable)
{
   $HashTable[$r]++
}
$errors = $null

$HashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name  | select value, name, @{Expression = TokenizeCode $_ ; Name = "token"}

