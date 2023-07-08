# given a sorted list of [Initial]{size, name, path}
# group by size => [gS](count,size){name,path}

$gS = $Initial | Group-Object -Property size

# filter gr in [gs] 
#     if count = 1
#         delete gr
#     else 
#         for each g in gr
#             gr excluding g => [other] 
#              if g.path in [other].path 
#                 deleteDelegate(a,b)
#                 goto ;filterStart

:filterStart
foreach ($gr in $gS) {
    if ($gr.count -eq 1) {
        $gS.Remove($gr)
    }
    else {
        foreach ($g in $gr.Group) {
            $other = $gr.Group | Where-Object {$_.path -ne $g.path}
            if ($other.path -contains $g.path) {
                deleteDelegate($g,$other)
                goto filterStart
            }
        }
    }
}

# group [gS] by name => [gSn](count,name){path}

$gSn = $gS | Group-Object -Property name

# recursive on [root][Index] => [ressult]
#     while index > getParents().length
#         for each entry in [gsn] where count > 1
#             group by getParents()[Index] => [root](count,index++,{parrents}){path}

function recursive ($root, $index) {
    while ($index -gt (getParents).length) {
        foreach ($entry in $gSn | Where-Object {$_.count -gt 1}) {
            $root = $entry | Group-Object -Property {($_.path | Split-Path -Parent)[$index]}
            $index++
            recursive($root, $index)
        }
    }
    return $root
}

$ressult = recursive($root, 0)

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

# [ressult]

# a list of truth statements
# objects who are the same with different parrent whos node at index has same name

#  obja,[parentId],objb,[parentId]
#  obja,[subparentId],objb,[subparentId]
#  objc,[parentId],objb,[parentId]


#  obja @ c:\temp = objb @ c:\etc\osv\temp
#  and
#  obja @ c:\ = objb @ c:\etc\osv\
#     for every subparent they share

 
# ressult can then be consumed 
#     group by size or number
#         => path = path relationship


$ressult | ForEach-Object {
    # a list of truth statements
    $_.Group | ForEach-Object {
        # objects who are the same with different parrent whos node at index has same name
        $_.Group | ForEach-Object {
            # obja,[parentId],objb,[parentId]
            # obja,[subparentId],objb,[subparentId]
            # objc,[parentId],objb,[parentId]
            Write-Output "$($_.name),[$($_.Group.Name)],$($_.path),[$($_.Group.path)]"
        }
    }

    # ressult can then be consumed 
    #     group by size or number
    #         => path = path relationship

    $_.Group | Group-Object -Property size, count | ForEach-Object {
        # => path = path relationship
        Write-Output "$($_.Name) = $($_.Group.path)"
    }
}

# into a que of beond compare session files

$que = New-Object System.Collections.Queue

$ressult | ForEach-Object {
    # create a beond compare session file for each group of paths
    $sessionFile = New-Object System.IO.StreamWriter "$($_.Name).txt"
    foreach ($path in $_.Group.path) {
        $sessionFile.WriteLine($path)
    }
    $sessionFile.Close()
    # add the session file to the que
    $que.Enqueue($sessionFile)
}

# aditionally could name be replaced with hash, and in the final step, we decouple names being != as a list of translations

# replace name with hash
$gS | ForEach-Object {
    $_.name = Get-FileHash $_.path -Algorithm SHA256 | Select-Object -ExpandProperty Hash
}

# decouple names being != as a list of translations
$translations = @{}
$gS | ForEach-Object {
    $translations[$_.name] = $_.path | Split-Path -Leaf
}
