<# .SYNOPSIS
Splits a text file into multiple sections based on a regular expression.
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
function Split-TextByRegex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Regx
    )
    # Get the content of the text file and append the line number to each line
    $Input = Get-Content -Path $Path
    $LineNrAppended = $Input | Select-String -Pattern '.*' | Select-Object LineNumber, Line

    # Get the end of file line number
    $EndOfFile = $Input.Length

    # Find the delimiters that match the regular expression
    $Delimiters = @($LineNrAppended | Where-Object { $_ -match $Regx })

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

    # Define a default display property set for the custom object type if it doesn't exist already
    if (-not (Get-TypeData -TypeName 'match.range').DefaultDisplayPropertySet) {
        Update-TypeData -TypeName 'match.range' -DefaultDisplayPropertySet 'match', 'value'
    }

    # Return the custom object array
    return  $TextRange
}
