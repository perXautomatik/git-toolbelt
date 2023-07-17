# Set the execution policy to bypass for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Import the required modules
Import-Module "Z:\Project Shelf\Archive\ps1\Split-TextByRegex.ps1"
Import-Module "Z:\Project Shelf\Archive\ps1\keyPairTo-PsCustom.ps1"

# Define a function to split text by a regular expression
function Split-TextByRegex {
    <#
    .SYNOPSIS
    Splits text by a regular expression and returns an array of objects with the start index, end index, and value of each match.

    .DESCRIPTION
    This function takes a path to a text file and a regular expression as parameters, and returns an array of objects with the start index, end index, and value of each match. The function uses the Select-String cmdlet to find the matches, and then creates custom objects with the properties of each match.

    .PARAMETER Path
    The path to the text file to be split.

    .PARAMETER Regx
    The regular expression to use for splitting.

    .EXAMPLE
    Split-TextByRegex -Path ".\test.txt" -Regx "submodule"

    This example splits the text in the test.txt file by the word "submodule" and returns an array of objects with the start index, end index, and value of each match.
    #>

    # Validate the parameters
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Regx
    )

    # Try to read the text from the file
    try {
        $text = Get-Content $Path -Raw
    }
    catch {
        Write-Error "Could not read the file: $_"
        return
    }

    # Try to find the matches using the regular expression
    try {
        $matches = Select-String -InputObject $text -Pattern $Regx -AllMatches | Select-Object -ExpandProperty Matches
    }
    catch {
        Write-Error "Could not find any matches: $_"
        return
    }

    # Create an array to store the results
    $results = @()

    # Loop through each match and create a custom object with its properties
    foreach ($match in $matches) {
        $result = [PSCustomObject]@{
            StartIndex = $match.Index
            EndIndex = $match.Index + $match.Length - 1
            Value = $match.Value
        }
        # Add the result to the array
        $results += $result
    }

    # Return the array of results
    return $results
}

# Define a function to convert key-value pairs to custom objects
function keyPairTo-PsCustom {
    <#
    .SYNOPSIS
    Converts key-value pairs to custom objects with properties corresponding to the keys and values.

    .DESCRIPTION
    This function takes an array of strings containing key-value pairs as a parameter, and returns an array of custom objects with properties corresponding to the keys and values. The function uses the ConvertFrom-StringData cmdlet to parse the key-value pairs, and then creates custom objects with the properties.

    .PARAMETER KeyPairStrings
    The array of strings containing key-value pairs.

    .EXAMPLE
    keyPairTo-PsCustom -KeyPairStrings @("name=John", "age=25")

    This example converts the key-value pairs in the array to custom objects with properties name and age.
    
     #>

     # Validate the parameter
     [CmdletBinding()]
     param (
         [Parameter(Mandatory=$true)]
         [string[]]$KeyPairStrings
     )

     # Create an array to store the results
     $results = @()

     # Loop through each string in the array
     foreach ($string in $KeyPairStrings) {
         # Try to parse the key-value pairs using ConvertFrom-StringData cmdlet
         try {
             $data = ConvertFrom-StringData $string
         }
         catch {
             Write-Error "Could not parse the string: $_"
             continue
         }

         # Create a custom object with properties from the data hashtable
         $result = New-Object -TypeName PSObject -Property $data

         # Add the result to the array
         $results += $result
     }

     # Return the array of results
     return $results
}

# Set the regular expression to use for splitting
$rgx = "submodule"

# Set the working path
$workpath = 'B:\ToGit\Projectfolder\NewWindows\scoopbucket-1'

# Change the current directory to the working path
Set-Location $workpath

# Set the path to the .gitmodules file
$p = Join-Path $workpath ".gitmodules"

# Split the text in the .gitmodules file by the regular expression and store the results in a variable
$TextRanges = Split-TextByRegex -Path $p -Regx $rgx

# Convert the key-value pairs in the text ranges to custom objects and store the results in a variable
$zz = $TextRanges | ForEach-Object {
    try {
        # Trim and join the values in each text range
        $q = $_.value.trim() -join ","
    }
    catch {
        # If trimming fails, just join the values
        $q = $_.value -join ","
    }
    try {
        # Split the string by commas and equal signs and create a hashtable with the path and url keys
        $t = @{
            path = $q.Split(',')[0].Split('=')[1].trim()
            url = $q.Split(',')[1].Split('=')[1].trim()
        }
    }
    catch {
        # If splitting fails, just use the string as it is
        $t = $q
    }
    # Convert the hashtable to a JSON string and then back to a custom object
    $t | ConvertTo-Json | ConvertFrom-Json
}

# Filter out the custom objects that have a path property and loop through them
$zz | Where-Object {($_.path)} | ForEach-Object {
    # Try to add a git submodule using the path and url properties
    try {
        git submodule add -f $_.url $_.path
    }
    catch {
        Write-Error "Could not add git submodule: $_"
    }
}
