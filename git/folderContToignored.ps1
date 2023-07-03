<#
.SYNOPSIS
Add the names of the non-excluded folders in a root folder to a .gitignore file.

.DESCRIPTION
This script takes two parameters: the path to the root folder and an array of excluded folder names. It then uses the Get-ChildItem cmdlet to get the list of folders in the root folder and filters out the ones that are in the excluded array. It then writes the names of the remaining folders to a .gitignore file in the current directory.

.PARAMETER Root
The path to the root folder to get the folder names from.

.PARAMETER Excluded
An array of excluded folder names that should not be added to the .gitignore file.

.EXAMPLE
PS C:\> AddToIgnored -Root "C:\Users\user\Documents\Project" -Excluded "bin", "obj", "test"

This example adds the names of the non-excluded folders in the "C:\Users\user\Documents\Project" folder to a .gitignore file in the current directory.
#>

function AddToIgnored {
    [CmdletBinding()]
    param (
    
        [Parameter(Mandatory=$true,
                    HelpMessage="root dir to")] 
        [string]$Root,
    
        [Parameter(Mandatory=$false,
                    HelpMessage="excluded dirs")] 
        [string[]]$Excluded
    )

    # Get the list of folders in the root folder and filter out the ones that are in the excluded array
    $folders = Get-ChildItem -Path $Root -Directory | Where-Object { $_.Name -notin $Excluded }

    # Write the names of the remaining folders to a .gitignore file in the current directory
    $folders.Name | Out-File -FilePath .gitignore
}
