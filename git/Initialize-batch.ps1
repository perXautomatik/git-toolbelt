<#
.SYNOPSIS
This script initializes a git repository in each data subfolder of the PortableApps folder and adds and commits all the files in it.
#>

function Initialize-GitRepos {
    # Change the current location to the PortableApps folder
    Set-Location -Path "D:\portapps\2. file Organization\PortableApps"

    # Loop through each item in the PortableApps folder
    foreach ($a in Get-ChildItem) {
        # Create the data subfolder path by joining the item name and 'data'
        $q = Join-Path -Path $a -ChildPath 'data'
        # Check if the data subfolder exists
        if (Test-Path -Path $q) {
            # Change the current location to the data subfolder
            Set-Location -Path $q
            # Initialize a git repository
            git init
            # Add all the files to the staging area
            git add .
            # Commit the files with a message 'initial'
            git commit -m 'initial'
        }
    }
}
