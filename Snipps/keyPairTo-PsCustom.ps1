<# .SYNOPSIS
Converts a string array of key-value pairs into a PowerShell custom object.
.PARAMETER KeyPairStrings
An array of strings that contain key-value pairs separated by a delimiter.
.PARAMETER Delim
The delimiter that separates the key and value in each string. The default is '='.
.EXAMPLE
PS C:\> "name=John","age=25" | keyPairTo-PsCustom
name age
---- ---
John 25
.EXAMPLE
PS C:\> keyPairTo-PsCustom -KeyPairStrings "color:blue","size:large" -Delim ':'
color size
----- ----
blue  large
#>
function keyPairTo-PsCustom {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$KeyPairStrings,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Delim = '='
    )
    begin {
        # Check if the delimiter exists in the input array
        if (-not ($KeyPairStrings -match $Delim)) {
            Write-Error "Delimiter '$Delim' not found in the input array."
            return $null
        }
    }
    process {
        # Convert each string into a JSON object and merge them into one object
        $JsonObject = $KeyPairStrings | ForEach-Object {
            try {
                # Split the string by the delimiter and trim the whitespace
                $Key, $Value = $_ -split $Delim | ForEach-Object { $_.Trim() }
                # Create a JSON object with the key and value
                ConvertTo-Json -InputObject @{ $Key = $Value } -Compress
            }
            catch {
                # Handle any errors during the conversion
                Write-Error "Failed to convert '$_' to a JSON object: $($_.Exception.Message)"
                return $null
            }
        } | Join-String -Separator ',' -Prefix '{' -Suffix '}'
        # Convert the JSON object into a PowerShell custom object and output it
        try {
            ConvertFrom-Json -InputObject $JsonObject
        }
        catch {
            # Handle any errors during the conversion
            Write-Error "Failed to convert '$JsonObject' to a PowerShell custom object: $($_.Exception.Message)"
            return $null
        }
    }
}
