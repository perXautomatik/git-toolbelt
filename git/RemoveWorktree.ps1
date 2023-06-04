Import-Module PsIni

function gitRemoveWorktree ($configPath)
{
    $iniContent = Get-IniContent -FilePath $configPath
    $iniContent.core.Remove("worktree") ;
    $iniContent | Out-IniFile -FilePath $configPath -Force
}