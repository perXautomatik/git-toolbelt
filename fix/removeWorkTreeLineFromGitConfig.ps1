$path = 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git\config'

# putting get content in paranteses makes it run as a separate thread and doesn't lock the file further down the pipe
(Get-Content -Path $path | ? { ! ($_ -match 'worktree') }) | Set-Content -Path $path