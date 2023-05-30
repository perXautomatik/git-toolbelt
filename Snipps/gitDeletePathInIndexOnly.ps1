$errorus = 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git'
$asFile = ([System.IO.FileInfo]$errorus)
$targetFolder = ($asFile | select Directory).Directory

$name = $targetFolder.Name

#'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\'
$path = $targetFolder.Parent.FullName

#\Export-Inst-Choco\

Push-Location

cd $path

git rm -r  --cached $name 
git commit -m "forgot about $name"

Pop-Location
