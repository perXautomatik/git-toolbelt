Write-Host "[Add Git Submodule from .gitmodules]" -ForegroundColor Green
Write-Host "... Dump git_add_submodule.temp ..." -ForegroundColor DarkGray
git config -f .gitmodules --get-regexp '^submodule\..*\.path$' > git_add_submodule.temp

Get-content git_add_submodule.temp | ForEach-Object {
        try {
            $path_key, $path = $_.split(" ")
            $url_key = "$path_key" -replace "\.path",".url"
            $url= git config -f .gitmodules --get "$url_key"
            Write-Host "$url  -->  $path" -ForegroundColor DarkCyan
            git submodule add $url $path
        } catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
            continue
        }
    }

Write-Host "... Remove git_add_submodule.temp ..." -ForegroundColor DarkGray
Remove-Item git_add_submodule.temp