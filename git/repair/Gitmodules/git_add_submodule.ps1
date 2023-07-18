#Get-Content .\.gitmodules | ? { $_ -match 'url' } | % { ($_ -split "=")[1].trim() } 
function prevImplementaton () {
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
}

function git-GetSubmodulePathsUrls
{    [CmdletBinding()]
        Param(       
            [Parameter(Mandatory=$true)]
            [ValidateScript({Test-Path -Path "$_\.gitmodules"})]            
            [string]
            $RepoPath
        )
        try {    
            (git config -f .gitmodules --get-regexp '^submodule\..*\.path$')  | 
            % {
                $path_key, $path = $_.split(" ")
                $prop = [ordered]@{ 
                    Path = $path
                    Url = git config -f .gitmodules --get ("$path_key" -replace "\.path",".url")
                    NonRelative = Join-Path $RepoPath $path
                }
                return New-Object –TypeName PSObject -Property $prop
            }        
        }
        catch{
            Throw "$($_.Exception.Message)"
        }
}


Function Git-InitializeSubmodules {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
       Param(
        # File to Create
        [Parameter(Mandatory=$true)]
        [string]
        $RepoPath
    )
    begin{    
    	Write-Verbose "[Add Git Submodule from .gitmodules]"    
    }
    process{
    
        git-GetSubmodulePathsUrls $RepoPath | %{   $url = $_.url
            $path = $_.path
            
            if( New-Item -ItemType dir -Name $path -WhatIf -ErrorAction SilentlyContinue)
            {
                if($PSCmdlet.ShouldProcess($path,"clone $url -->")){                                                   
                 
                }
                else
                {
                   git submodule add $url $path
                }
            }
            else
            {
                if($PSCmdlet.ShouldProcess($path,"folder already exsists, will trye to clone $url --> "))
                {   
                    
                }
                else
                {
                  git submodule add $url $path
                }
            }
        }
    }
}

Git-InitializeSubmodules -repoPath 'G:\ToGit\projectFolderBare\scoopbucket-presist'
