 cd 'C:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\consoles\db\8b7c273a-baa2-4933-a5d5-4862e23c0af2'
 
  $y = Get-ChildItem 

 $x = (join-path -childpath (split-path -path (git rev-parse --show-toplevel) -noQualifier) -path 'C:')

 cd $x

$y | %{Resolve-Path -relative $_.fullname }