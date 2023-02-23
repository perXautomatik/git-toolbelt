#Git copy diff to move
cls
$root = 'U:\Project Shelf\PowerShell-Scripts'
cd $root
$zx = (Get-Clipboard ).split('()')

$destinationExists = Test-Path $remote


$localRelative = $zx[0].Trim()
$local = (Join-Path -Path $root -ChildPath $localRelative)
$local

$remoteRelative = $zx[1].Substring(5).Trim()
$remote = Join-Path -Path $root -ChildPath $remoteRelative
$remote

$localLinux = $local.Replace('\','/') 
$remoteLinux = $remote.Replace('\','/')



$inIndexLocal = (git ls-files --error-unmatch $localRelative) 
$inIndexRemote = (git ls-files --error-unmatch $remoteRelative)

if ($inIndexLocal)
{ echo "local is in index $indexLocal"}
else
 {
    if(Test-Path ($local))
        {git add $localRelative --force ; git commendHEAD }
 }


if ($inIndexRemote)
{
 echo "Remote is in index $inIndexRemote"
 }
 else
{
    if(Test-Path ($remote))
         {git add $remoteRelative --force ; git commendHEAD }
}



if($destinationExists)
{    git rm $localRelative  }
else
{
    git mv $localRelative $remoteRelative
}

