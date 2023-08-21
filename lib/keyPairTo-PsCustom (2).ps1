# array with key pairs d
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
    $Delim = '='
    )
    
    #todo : error on $delim not found
    #todo : error on $keyPairStrings.length = 0
    #todo : make pipable
    #todo : return null on error



     "{"+(($keyPairStrings | % { '"{0}":"{1}"' -f @(($_ -split $delim) | %{ $_.trim()} ) })-join ', ' )+"}" | ConvertFrom-Json
}