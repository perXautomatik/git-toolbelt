function Split-TextByRegex {
<#
.SYNOPSIS
Splits the text of a file by a regular expression and returns an array of custom objects.

.DESCRIPTION
This function splits the text of a file by a regular expression and returns an array of custom objects. Each object represents a text range that starts with a line that matches the regular expression and ends with the line before the next match or the end of the file. Each object has three properties: match, value and linenumber. The match property is the line that matches the regular expression, the value property is an array of lines that follow the match, and the linenumber property is an array of line numbers that correspond to the value property.

.PARAMETER Path
The path of the file to split.

.PARAMETER Regx
The regular expression to use for splitting.
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
        # Validate that the path parameter is not null or empty and points to an existing file
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
		[ValidateScript({Test-Path $_ -ErrorAction stop})]
		[ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$Path,

        # Validate that the regx parameter is not null or empty and is a valid regular expression
        [Parameter(Mandatory = $true)]
		[string]
		[ValidateScript({[regex]::new($_)})]
		[ValidateNotNullOrEmpty()]$Regx
        
    )

    # Get the content of the text file and append the line number to each line
    try {
    $Input = Get-Content -Path $Path -Raw
    }
    catch {
            Write-Error "Could not read the file: $_"
        return
    }
    # Append the line number to each line as a custom object
    $LineNrAppended = $Input | Select-String -Pattern '.*' | Select-Object LineNumber, Line

    # Get the end of file line number
    $EndOfFile = $Input.Length

    # Find all the lines that match the regular expression and store them as an array of custom objects
    $Delimeters = @($lineNrAppended | Where-Object { $_ -match $Regx })

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

    # Initialize an empty array for the result
    $TextRange = @()

    if($IncNonmatches)
    {
	
    # Loop through each delimiter in the array
    for ($i = 0; $i -lt $Delimeters.length; $i++) {

        # Get the line number of the next delimiter or use the end of file as the upper bound
        $Upper = ( $Delimiters | Select-Object -Index ($i+1) ).LineNumber - 1
        if ($Upper -eq -1) { $Upper = $EndOfFile }

        # Get all the lines between the current delimiter and the upper bound as an array of custom objects
        $Section = ($LineNrAppended | Where-Object { $_.LineNumber -in (( $Delimiters | Select-Object -Index $i ).LineNumber .. $Upper) })

        # Create a custom object with match, value and linenumber properties and add it to the result array
        $TextRange += , [PSCustomObject]@{
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

    # Check if there is already a type data for match.range objects and update it if not
    if (!(Get-TypeData -TypeName 'match.range').defaultDisplayPropertySet) {
        $TypeData = @{
            TypeName = 'match.range' #refere to object by it's type name
            DefaultDisplayPropertySet = 'match','value'
        }
        Update-TypeData @TypeData
    }

    # Return the result array as output
    return  $TextRange
}
