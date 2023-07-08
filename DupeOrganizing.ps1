# Synopsis: This function gets the list of files in a given path and groups them by size and name
# Parameters: 
#   -Path: The path to search for files. Required, string, must exist
# Output: A list of objects with properties: count, size, name, path
function Get-FileGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$Path
    )
    try {
        # get the list of files in the path
        $files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction Stop
        # group them by size and name
        $groups = $files | Group-Object -Property size, name
        # return the groups
        return $groups
    }
    catch {
        # handle any errors
        Write-Error $_.Exception.Message
    }
}
 
# deleteDelegate(a,b)
# {
#     a type requiring obj a, obj b, delgate x <= deciding which to delete

#     throw error if a & b still excists    
# }

function deleteDelegate ($a, $b) {
    param (
        [Parameter(Mandatory=$true)]
        [object]$a,
        [Parameter(Mandatory=$true)]
        [object]$b,
        [Parameter(Mandatory=$true)]
        [scriptblock]$x # delegate to decide which to delete
    )
    if (Test-Path $a.path -and Test-Path $b.path) {
        throw "Both objects still exist"
    }
    else {
        Invoke-Command -ScriptBlock $x -ArgumentList @($a,$b)
    }
}
 
# Synopsis: This function filters out the groups that have only one file or have duplicate paths
# Parameters: 
#   -Groups: The list of groups to filter. Required, array of objects with properties: count, size, name, path
# Output: A filtered list of groups with properties: count, size, name, path
function Filter-FileGroups {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_.count -gt 0})]
        [object[]]$Groups
    )
    try {
        # loop through the groups
        foreach ($group in $Groups) {
            # if the group has only one file, skip it
            if ($group.count -eq 1) {
                continue
            }
            # else, check for duplicate paths
            else {
                # loop through each file in the group
                foreach ($file in $group.Group) {
                    # get the other files in the group that are not the current file
                    $other = $group.Group | Where-Object {$_.path -ne $file.path}
                    # if the current file's path is in the other files' paths, skip it
                    if ($other.path -contains $file.path) {
                        continue
                    }
                    # else, return the file as part of the filtered group
                    else {
                        return $file
                    }
                }
            }
        }
    }
    catch {
        # handle any errors
        Write-Error $_.Exception.Message
    }
}

# Synopsis: This function groups the filtered groups by their parent paths at a given index level
# Parameters: 
#   -Groups: The list of filtered groups to group by parent paths. Required, array of objects with properties: count, size, name, path
#   -Index: The index level of the parent paths to group by. Required, integer, must be positive
# Output: A list of objects with properties: count, index, parents, path
function Group-ByParentPaths {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_.count -gt 0})]
        [object[]]$Groups,
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -ge 0})]
        [int]$Index
    )
    try {
        # loop through the groups
        foreach ($group in $Groups) {
            # get the parent paths of each file in the group at the given index level
            $parents = $group.Group | ForEach-Object {($_.path | Split-Path -Parent)[$Index]}
            # group the files by their parent paths and return them as objects with properties: count, index, parents, path
            $group | Group-Object -Property {$parents} | ForEach-Object {
                [PSCustomObject]@{
                    count = $_.count;
                    index = $Index;
                    parents = $_.Name;
                    path = $_.Group.path;
                }
            }
        }
    }
    catch {
        # handle any errors
        Write-Error $_.Exception.Message
    }
}

# Synopsis: This function recursively calls Group-ByParentPaths until the index level exceeds the length of the parent paths array
# Parameters: 
#   -Groups: The list of filtered groups to group by parent paths recursively. Required, array of objects with properties: count, size, name, path
# Output: A list of objects with properties: count, index, parents, path
function Recursive-GroupByParentPaths {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_.count -gt 0})]
        [object[]]$Groups
    )
    try {
        # initialize the index level to zero
        $index = 0
        # get the length of the parent paths array
        $length = ($Groups[0].path | Split-Path -Parent).length
        # while the index level is less than the length of the parent paths array
        while ($index -lt $length) {
            # call Group-ByParentPaths with the current index level and assign the result to a variable
            $result = Group-ByParentPaths -Groups $Groups -Index $index
            # increment the index level by one
            $index++
            # return the result
            return $result
        }
    }
    catch {
        # handle any errors
        Write-Error $_.Exception.Message
    }
}

# Synopsis: This function replaces the name property of each group with a hash value and creates a hashtable of name-path translations
# Parameters: 
#   -Groups: The list of groups to replace name with hash. Required, array of objects with properties: count, size, name, path
# Output: A hashtable of name-path translations
function Replace-NameWithHash {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_.count -gt 0})]
        [object[]]$Groups
    )
    try {
        # create a new hashtable object
        $translations = @{}
        # loop through the groups
        foreach ($group in $Groups) {
            # replace the name property with a hash value using SHA256 algorithm
            $group.name = Get-FileHash $group.path -Algorithm SHA256 | Select-Object -ExpandProperty Hash
            # add an entry to the hashtable with the hash as the key and the file name as the value
            $translations[$group.name] = $group.path | Split-Path -Leaf
        }
        # return the hashtable
        return $translations
    }
    catch {
        # handle any errors
        Write-Error $_.Exception.Message
    }
}

# Synopsis: This function creates a queue of Beyond Compare session files for each group of paths
# Parameters: 
#   -Groups: The list of groups to create session files for. Required, array of objects with properties: count, index, parents, path
# Output: A queue of session files
function Create-SessionFiles {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_.count -gt 0})]
        [object[]]$Groups
    )
    try {
        # create a new queue object
        $queue = New-Object System.Collections.Queue
        # loop through the groups
        foreach ($group in $Groups) {
            # create a session file for each group with the name as the group's parents property
            $sessionFile = New-Object System.IO.StreamWriter "$($group.parents).txt"
            # write each path in the group to the session file
            foreach ($path in $group.path) {
                $sessionFile.WriteLine($path)
            }
            # close the session file
            $sessionFile.Close()
            # add the session file to the queue
            $queue.Enqueue($sessionFile)
        }
        # return the queue
        return $queue
    }
    catch {
        # handle any errors
        Write-Error $_.Exception.Message
    }
}

# Main script

# get the path from user input or use current location as default
$path = Read-Host "Enter a path to search for files" -ErrorAction SilentlyContinue

if (-not $path) {
    $path = Get-Location | Select-Object -ExpandProperty Path 
}

# get the list of files and group them by size and name
$groups = Get-FileGroups -Path $path

# filter out the groups that have only one file or have duplicate paths
$filteredGroups = Filter-FileGroups -Groups $groups

# group the filtered groups by their parent paths recursively 
$recursiveGroups = Recursive-GroupByParentPaths -Groups $filteredGroups

# create a queue of Beyond Compare session files for each group of paths 
$sessionFiles = Create-SessionFiles -Groups $recursiveGroups

# replace the name property of each group with a hash value and create a hashtable of name-path translations 
$hashTranslations = Replace-NameWithHash -Groups $groups

