Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

. "Z:\Project Shelf\Archive\ps1\Split-TextByRegex.ps1"

. "Z:\Project Shelf\Archive\ps1\keyPairTo-PsCustom.ps1"

$rgx = "submodule";
$workpath = 'B:\ToGit\scoopbucket-presist'
cd $workpath

$p = $workpath+'\.gitmodules'

$TextRanges = Split-TextByRegex -path $p -regx $rgx

$TextRanges | %{ keyPairTo-PsCustom -keyPairStrings $_.values }


# git submodule add -f $urls $paths
