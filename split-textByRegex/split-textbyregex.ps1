function Split-TextByRegex {
<# .SYNOPSIS
Splits a text file into multiple sections based on a regular expression.

    .DESCRIPTION
    This function takes a path to a text file and a regular expression as parameters, and returns an array of objects with the start index, end index, and value of each match. The function uses the Select-String cmdlet to find the matches, and then creates custom objects with the properties of each match.

.PARAMETER Path
The path to the text file to split.
.PARAMETER Regx
The regular expression that matches the delimiters of each section.
.OUTPUTS
A custom object of type 'match.range' that contains the match, value and linenumber properties for each section.
.EXAMPLE
PS C:\> Split-TextByRegex -Path "C:\temp\test.txt" -Regx "^\[.*\]$"
match   value
-----   -----
[one]   {a, b, c}
[two]   {d, e, f}
[three] {g, h, i}
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_ -ErrorAction stop})] 
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string][ValidateNotNullOrEmpty()]$Regx
        
    )
    # Get the content of the text file and append the line number to each line
    try {
    $Input = Get-Content -Path $Path -Raw
    }
    catch {
            Write-Error "Could not read the file: $_"
        return
    }
    $LineNrAppended = $Input | Select-String -Pattern '.*' | Select-Object LineNumber, Line

    # Get the end of file line number
    $EndOfFile = $Input.Length

    # Find the delimiters that match the regular expression
    $Delimiters = @($LineNrAppended | Where-Object { $_ -match $Regx })

    # Try to split the content by the regular expression
    try {
        $Matchez = [regex]::Matches($Input, $Regx)
        $NonMatches = [regex]::Split($Input, $Regx)        
        $single = Select-String -InputObject $Content -Pattern $Regx -AllMatches | Select-Object -ExpandProperty Matches
    }
    catch {
        Write-Error "Could not split the content by $Regx"
        return
    }

        # Create an array to store the results
    $Results = @()

    if($IncNonmatches)
    {
	
    # Loop through the delimiters and create a custom object for each section
    $TextRange = for ($i = 0; $i -lt $Delimiters.length; $i++) {
        # Get the upper bound of the section by finding the next delimiter or the end of file
        $Upper = ( $Delimiters | Select-Object -Index ($i+1) ).LineNumber - 1
        if ($Upper -eq -1) { $Upper = $EndOfFile }

        # Get the lines that belong to the section
        $Section = ($LineNrAppended | Where-Object { $_.LineNumber -in (( $Delimiters | Select-Object -Index $i ).LineNumber .. $Upper) })

        # Create a custom object with the match, value and linenumber properties
        [PSCustomObject]@{
            PSTypeName = 'match.range' # Give the object a type name
            match = $Section.Line[0] # The first line is the match
            value = @($Section.Line | Select-Object -Skip 1) # The rest are the values
            linenumber = $Section.LineNumber # The line numbers of the section
        }
    }
    else {    
            # Loop through each match and create a custom object with its properties
        foreach ($match in $single) {
            $result = [PSCustomObject]@{
                StartIndex = $match.Index
                EndIndex = $match.Index + $match.Length - 1
                Value = $match.Value
            }
            # Add the result to the array
            $results += $result
        }
    }

    # Define a default display property set for the custom object type if it doesn't exist already
    if (-not (Get-TypeData -TypeName 'match.range').DefaultDisplayPropertySet) {
        Update-TypeData -TypeName 'match.range' -DefaultDisplayPropertySet 'match', 'value'
    }

    # Return the custom object array
    return  $TextRange
}
