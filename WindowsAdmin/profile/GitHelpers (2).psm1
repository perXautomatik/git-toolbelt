
if ( $(Test-CommandExists 'git') ) {
    Set-Alias g    git -Option AllScope
    function git-root { $gitrootdir = (git rev-parse --show-toplevel) ; if ( $gitrootdir ) { Set-Location $gitrootdir } }

    if ( $IsWindows ) {
        function git-sh {
            if ( $args.Count -eq 0 ) { . $(Join-Path -Path $(Split-Path -Path $(Get-Command git).Source) -ChildPath "..\bin\sh") -l
            } else { . $(Join-Path -Path $(Split-Path -Path $(Get-Command git).Source) -ChildPath "..\bin\sh") $args }
        }

        function git-bash {
            if ( $args.Count -eq 0 ) {
                . $(Join-Path -Path $(Split-Path -Path $(Get-Command git).Source) -ChildPath "..\bin\bash") -l
            } else {
                . $(Join-Path -Path $(Split-Path -Path $(Get-Command git).Source) -ChildPath "..\bin\bash") $args
            }
        }

        function git-vim { . $(Join-Path -Path $(Split-Path -Path $(Get-Command git).Source) -ChildPath "..\bin\bash") -l -c `'vim $args`' }

        if ( -Not (Test-CommandExists 'sh') ){ Set-Alias sh   git-sh -Option AllScope }

        if ( -Not (Test-CommandExists 'bash') ){ Set-Alias bash   git-bash -Option AllScope }

        if ( -Not (Test-CommandExists 'vi') ){ Set-Alias vi   git-vim -Option AllScope }

        if ( -Not (Test-CommandExists 'vim') ){ Set-Alias vim   git-vim -Option AllScope }
    }


set-alias GitAdEPathAsSNB    invoke-GitSubmoduleAdd                 -Option AllScope
    set-alias -Name:"gitSilently" -Value:"invoke-GitLazySilently" -Description:"" -Option:"AllScope"
    set-alias -Name:"gitSingleRemote" -Value:"invoke-gitFetchOrig" -Description:"" -Option:"AllScope"
    set-alias -Name:"gitsplit" -Value:"subtree-split-rm-commit" -Description:"" -Option:"AllScope"
set-alias GitUp              invoke-GitLazy                         -Option AllScope
    set-alias -Name:"remote" -Value:"invoke-gitRemote" -Description:"" -Option:"AllScope"
}