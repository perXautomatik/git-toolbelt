# source https://stackoverflow.com/a/73343519
<#

#Usage example:

$JSON = Get-Content "C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" -Raw | ConvertFrom-Json

# Unroll the JSON
$flatJSON = $JSON | Expand-Json   

# Filter by path - this outputs an array
$filteredJSON = $flatJSON | Where-Object Path -like 'data.b<*>.bData.bAbc<0>.bAbcZ'

# Convert data back to JSON string
$filteredJSON.Value | ConvertTo-Json

#>



Function Expand-Json {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] $InputObject,
        [Parameter()] [string] $Path,
        [Parameter()] [string] $PathSeparator = '.',
        [Parameter()] [string] $IndexFormat = '[{0}]'
    )
    
    process {       
        if( $InputObject -is [Collections.IList] ) {
            # Iterate over array elements
            $i = 0
            foreach( $item in $InputObject ) {

                # Full path of current array item
                $itemPath = $Path + ($IndexFormat -f $i++)

                propOrRecurse $item $itemPath $InputObject
            }
        }
        elseif( $InputObject -is [PSCustomObject] ) {
            # Iterate over properties

                foreach( $prop in $InputObject.PSObject.Properties ) {

           
                    # Full path of the current property
                    $propertyPath = if( $Path ) { $Path, $prop.Name -join $PathSeparator } else { $prop.Name }
                    propOrRecurse $prop.value $propertyPath $InputObject
                }
        }
    }
}

function propOrRecurse($propxValue,$propertyPathx,$InputObjectx)
{
    if( $propxValue -is [PSCustomObject] -or $propxValue -is [Collections.IList] ) {
        # Recurse into child container
        Expand-Json -InputObject $propxValue -Path $propertyPathx -PathSeparator $PathSeparator -IndexFormat $IndexFormat
    } else # Output current property with path
    {
        $parm = @{
        propertyPathxx = $propertyPath 
        propxxValue = $propValue
        inp = $inputObjectx  
        filter = {$_.type -eq "folder"} 
        }
        PropertyByPredicate $parm
    }
}


function PropertyByPredicate {
Param(
[String]$propertyPathxx,
[String]$propxxValue,
[String]$inp,
 [scriptblock]$filter = {$true})
 
    #retrieve the data
 
    #filter the data
    $inp | where-object $filter | % { [PSCustomObject]@{ Path = $propertyPathxx; Value = $propxxValue }
 
    #process the data
            }
}
 

cls
#Usage example:

$inputPath = "C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\_side_profiles\a_Theater\Bookmarks"
$JSON = Get-Content $inputPath -Raw | ConvertFrom-Json

# Unroll the JSON
$flatJSON = $JSON | Expand-Json   

add-type -Path "C:\Program Files\PackageManagement\NuGet\Packages\chilkat-x64.9.5.0.93\lib\net47\ChilkatDotNet47.dll"

#build your json from paths

$json = New-Object Chilkat.JsonObject

$flatJSON | % { $json.UpdateString($_.path,$_.value) }

$JSON.ToString()