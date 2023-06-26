# This script gets a list of paths from the clipboard and groups them by their basename and parent

# Define a function to get the subparts of a path
function Get-Subpart {
    <#
    .SYNOPSIS
    Gets the subparts of a path.

    .DESCRIPTION
    This function takes a path as a string and returns its parent, grandparent, etc. until the root.

    .PARAMETER Text
    The path to get the subparts from.

    .EXAMPLE
    Get-Subpart "C:\Users\Alice\Documents\Report.docx"

    C:\Users\Alice\Documents
    C:\Users\Alice
    C:\Users
    C:\
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$Text
    )

    while ($Text -ne $null -and $Text -ne "") {
        $Text = (Get-Item -Path $Text) | Split-Path -Parent
        if ($Text -ne $null -and $Text -ne "") {
            Write-Output $Text
        }
    }
}

# Define a function to get a list of paths from the clipboard
function Get-ClipboardPaths {
    <#
    .SYNOPSIS
    Gets a list of paths from the clipboard.

    .DESCRIPTION
    This function reads the text from the clipboard and returns it as an array of paths.

    .EXAMPLE
    Get-ClipboardPaths

    C:\Users\Alice\Documents\Report.docx
    C:\Users\Bob\Pictures\Image.jpg
    C:\Users\Charlie\Music\Song.mp3
    #>
    
    # Get the text from the clipboard
    $text = Get-Clipboard

    # Split the text by newlines and trim any whitespace
    $paths = $text -split "`r`n" | ForEach-Object { $_.Trim() }

    # Return the paths as an array
    return $paths
}

# Define a function to group the paths by their basename and parent
function Group-Paths {
    <#
    .SYNOPSIS
    Groups the paths by their basename and parent.

    .DESCRIPTION
    This function takes an array of paths and returns a collection of groups that have the same basename and parent.

    .PARAMETER Paths
    The array of paths to group.

    .EXAMPLE
    Group-Paths (Get-ClipboardPaths)

     Count Name                      Group                                                                                                                                                                                                                                 
     ----- ----                      -----                                                                                                                                                                                                                                 
         2 Report.docx,C:\Users      {@{parent=C:\Users; basename=Report.docx; subpath=Alice}, @{parent=C:\Users; basename=Report.docx; subpath=Bob}}                                                                                                                     
         1 Image.jpg,C:\Users\Bob... {@{parent=C:\Users\Bob\Pictures; basename=Image.jpg; subpath=Image.jpg}}                                                                                                                                                             
         1 Song.mp3,C:\Users\Charlie {@{parent=C:\Users\Charlie; basename=Song.mp3; subpath=Music}}
    
     #>
     param (
         [Parameter(Mandatory=$true)]
         [string[]]$Paths
     )

     # For each path, get its parent, basename and subpath as properties
     $repeated = $Paths | ForEach-Object {
         $q = (Get-Item -Path $_ | Split-Path -Leaf)
         Get-Subpart $_ | Select-Object @{n="parent"; e={ $_ }}, @{n="basename"; e={ $q }}, @{n="subpath"; e={ (Get-Item -Path $_ | Split-Path -Leaf ) }}
     }

     # Group the paths by their parent and basename properties
     $hashGroups = $repeated | Group-Object -Property basename,parent

     # Return the groups as a collection
     return $hashGroups

}

# Get a list of paths from the clipboard using the function
$paths = Get-ClipboardPaths

# Group the paths by their basename and parent using the function
$groups = Group-Paths -Paths $paths

# Write some information to the console using the groups collection

# Write the count and name of each group
$groups | Select-Object count, name

# Write the groups sorted by name and count in descending order
$groups | Sort-Object -Property name,count -Descending

