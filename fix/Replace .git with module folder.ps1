$errorus = 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git'
$toReplaceWith = 'D:\Project Shelf\.git\modules\PowerShellProjectFolder\modules\scripts\modules\windowsAdmin\modules\Export-Inst-Choco' #can be done with everything and menu

#([System.IO.FileInfo]$errorus) | get-member
$asFile = ([System.IO.FileInfo]$errorus)

$targetFolder = ($asFile | select Directory).Directory
$target = $targetFolder | Join-Path -ChildPath 'x.git'
$asFile.MoveTo($target)

$asFile = ([System.IO.FileInfo]$toReplaceWith)
$target = $targetFolder | Join-Path -ChildPath '.git'
$asFile.MoveTo($target)
