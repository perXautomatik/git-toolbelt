 #load dependensies

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
  # This is the main script that calls the functions
  
<#
.SYNOPSIS
Pushes a subdirectory of a git repository to another repository.

.DESCRIPTION
This function pushes a subdirectory of a git repository to another repository, using the git subtree command. The subdirectory will be filtered out from the original repository and added as a prefix to the destination repository.

.PARAMETER SourceDir
The path of the source directory where the original git repository is located.

.PARAMETER SourceSubdir
The path of the subdirectory within the source directory that will be pushed.

.PARAMETER DestinationDir
The path of the destination directory where the other git repository is located.

.PARAMETER DestinationPrefix
The prefix that will be added to the subdirectory in the destination repository.
#>
function Push-Git-Subtree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SourceDir,

        [Parameter(Mandatory = $true)]
        [string]
        $SourceSubdir,

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationDir,

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationPrefix
    )

    # Change the current location to the source directory
    Set-Location -Path $SourceDir

    # Push all branches to the destination directory
  Push-AllBranches -Remote 'D:\ToGit\AppData'
git push --all 'D:\ToGit\AppData'

    # Change the current location to the destination directory
  Change-Directory -Path 'D:\ToGit\Vortex'
    Set-Location -Path $DestinationDir

    # Filter out the subdirectory from the original repository and add it as a prefix
  Filter-Branch -Subdirectory 'Roaming/Vortex/' -Branch '--all'
git filter-branch -f --subdirectory-filter 'Roaming/Vortex/' -- --all 

    # Pull in any new commits to the subtree from the source directory
  Pull-Subtree -Prefix 'Roaming/Vortex/' -Remote 'C:\Users\chris\AppData\.git' -Branch LargeINcluding 
git subtree pull --prefix 'Roaming/Vortex/' 'C:\Users\chris\AppData\.git' LargeINcluding
}
