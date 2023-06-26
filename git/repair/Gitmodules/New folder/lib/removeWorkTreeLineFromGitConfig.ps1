<#
.SYNOPSIS
Removes lines that match a pattern from a file.

.DESCRIPTION
Removes lines that match a pattern from a file using Get-Content and Set-Content.

.PARAMETER Path
The path of the file to modify.

.PARAMETER Pattern
The pattern to match and remove.

.EXAMPLE
Remove-Lines -Path "D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git\config" -Pattern "worktree"
#>
function Remove-Lines {
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$Pattern
    )

    # putting get content in parentheses makes it run as a separate thread and doesn't lock the file further down the pipe
    (Get-Content -Path $Path | ? { ! ($_ -match $Pattern) }) | Set-Content -Path $Path
}