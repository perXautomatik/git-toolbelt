
<#
.SYNOPSIS
Extracts submodules from a git repository.

.DESCRIPTION
Extracts submodules from a git repository by moving the .git directories from the submodules to the parent repository and updating the configuration.

.PARAMETER Paths
The paths of the submodules to extract. If not specified, all submodules are extracted.

.INPUTS
System.String
You can pipe one or more submodule paths to this function.

.EXAMPLE
Extract-Submodules


.nix
    "!gitextractsubmodules() { set -e && { if [ 0 -lt \"$#\" ]; then printf \"%s\\n\" \"$@\"; else git ls-files --stage | sed -n \"s/^160000 [a-fA-F0-9]\\+ [0-9]\\+\\s*//p\"; fi; } | { local path && while read -r path; do if [ -f \"${path}/.git\" ]; then local git_dir && git_dir=\"$(git -C \"${path}\" rev-parse --absolute-git-dir)\" && if [ -d \"${git_dir}\" ]; then printf \"%s\t%s\n\" \"${git_dir}\" \"${path}/.git\" && mv --no-target-directory --backup=simple -- \"${git_dir}\" \"${path}/.git\" && git --work-tree=\"${path}\" --git-dir=\"${path}/.git\" config --local --path --unset core.worktree && rm -f -- \"${path}/.git~\" && if 1>&- command -v attrib.exe; then MSYS2_ARG_CONV_EXCL=\"*\" attrib.exe \"+H\" \"/D\" \"${path}/.git\"; fi; fi; fi; done; }; } && gitextractsubmodules"

.EXAMPLE
Extract-Submodules "foo" "bar"

.EXAMPLE
Get-SubmodulePaths | Extract-Submodules
#>

Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % {
 $p = $_
 $fullName = $p.FullName 
 try {
    invoke-expression ". $fullName" -ErrorAction Stop
}
catch {
    Write-Output "could not load $p"
}
}
 #load dependensies

<#
.SYNOPSIS
Determines whether all elements of a path exist.

.DESCRIPTION
The Test-Path cmdlet determines whether all elements of the path exist. It returns $true if all elements exist and $false if any are missing. It can also return the item at the specified path if the PassThru switch is used.

.PARAMETER Path
Specifies the path to test. Wildcards are permitted.

.PARAMETER LiteralPath
Specifies a path to test, but unlike Path, the value of LiteralPath is used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks.

.PARAMETER PassThru
Returns an object representing the item at the specified path. By default, this cmdlet does not generate any output.

.INPUTS
System.String
You can pipe a string that contains a path to this cmdlet.

.OUTPUTS
System.Boolean or System.Management.Automation.PathInfo
This cmdlet returns a Boolean value that indicates whether the path exists or an object representing the item at the path if PassThru is used.

.EXAMPLE
Test-Path "C:\Windows"

This command tests whether the C:\Windows directory exists.

.EXAMPLE
Test-Path "C:\Windows\*.exe" -PassThru

This command tests whether there are any files with the .exe extension in the C:\Windows directory and returns them as objects.
#>
function Test-Path {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$LiteralPath,

        [switch]$PassThru
    )

    begin {
        # initialize an empty array to store the paths
        $PathsToTest = @()
    }

    process {
        # add the pipeline input to the array
        if ($Path) {
            $PathsToTest += $Path
        }
        if ($LiteralPath) {
            $PathsToTest += $LiteralPath
        }
    }

    end {
        # loop through each path in the array
        foreach ($P in $PathsToTest) {
            # resolve any wildcards in the path
            $ResolvedPaths = Resolve-Path -Path $P -ErrorAction SilentlyContinue

            # check if any paths were resolved
            if ($ResolvedPaths) {
                # return true or the resolved paths depending on PassThru switch
                if ($PassThru) {
                    $ResolvedPaths | Get-Item
                }
                else {
                    $true
                }
            }
            else {
                # return false or nothing depending on PassThru switch
                if ($PassThru) {
                    # do nothing
                }
                else {
                    $false
                }
            }
        }
    }
}


function Extract-Submodules {
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Paths
    )

    begin {
        # initialize an empty array to store the paths
        $SubmodulePaths = @()
        
        # get the paths of all submodules if not specified, at current path
        if (-not $SubmodulePaths) {
            $SubmodulePaths = Get-SubmodulePaths
        }
        # add the pipeline input to the array
        $SubmodulePaths += $Paths
    }

    process {
       
        # loop through each submodule path
        foreach ($Path in $SubmodulePaths) {
            # check if the path ends with /.git and append it if not
            if (-not $Path.EndsWith("/.git")) {
                $orgPath = $path
                $Path = Test-Path -Path "$Path/.git" -PassThru
                if(!($Path))
                {
                    $path = $orgPath
                }

            }

            # check if the submodule has a .git file
            if (Test-Path -Path $Path -PathType Leaf) {
                # get the absolute path of the .git directory
                $GitDir = Get-GitDir -Path $Path

                # check if the .git directory exists
                if (Test-Path -Path $GitDir -PathType Container) {
                    # display the .git directory and the .git file
                    Write-Host "$GitDir`t$Path"

                    # move the .git directory to the submodule path
                    Move-Item -Path $GitDir -Destination $Path -Backup

                    # unset the core.worktree config for the submodule
                    Unset-CoreWorktree -Path $Path

                    # remove the backup file if any
                    Remove-Item -Path "$Path~" -Force -ErrorAction SilentlyContinue

                    # hide the .git directory on Windows
                    Hide-GitDir -Path $Path
                }
            }
            else {
                # throw an error if the .git file is not present
                throw "Could not find $Path"
            }
        }
    }

    end {

    }
}