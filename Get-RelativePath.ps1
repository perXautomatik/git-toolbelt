<#
.SYNOPSIS
This script gets the relative paths of the files in a folder with respect to the root of a git repository.
# Example usage
Get-RelativePaths -folderPath 'C:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\consoles\db\8b7c273a-baa2-4933-a5d5-4862e23c0af2' -gitRepoPath (git rev-parse --show-toplevel)

#>

function Get-RelativePaths {
    # Get the folder path and the git repository path as parameters
    param (
        [Parameter(Mandatory=$true)]
        [string]$folderPath,
        [Parameter(Mandatory=$true)]
        [string]$gitRepoPath
    )

    # Change the current location to the folder path
    Set-Location -Path $folderPath

    # Get the child items of the folder
    $y = Get-ChildItem

    # Get the root path of the git repository without the drive letter
    $x = Join-Path -Path 'C:' -ChildPath (Split-Path -Path $gitRepoPath -NoQualifier)

    # Change the current location to the root path of the git repository
    Set-Location -Path $x

    # Loop through each child item and get its relative path
    $y | ForEach-Object {
        Resolve-Path -Relative $_.FullName
    }
}

