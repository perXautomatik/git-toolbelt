function Split-TextByRegex 
{
    param(
    $path,$regx
    )

    $input = Get-Content $path
    
    $lineNrAppended = $input | select-string '.*' | select LineNumber,Line

    $endOfFile = $input.Length

    
    $Delimeters = @($lineNrAppended | ?{ $_ -match $regx }) 

    $TextRange = for ($i = 0; $i -lt $Delimeters.length; $i++) {
    
        $upper = ( $Delimeters | Select-Object -Index ($i+1) ).LineNumber-1

        if($upper -eq -1 ) {$upper = $endOfFile }

        $q = ($lineNrAppended | ? { $_.lineNumber -in (( $Delimeters | Select-Object -Index $i ).LineNumber .. $upper) })
        
        [PSCustomObject]@{
        PSTypeName = 'match.range' #give the object a type name
        match=$q.line[0] ; value=@($q.line | select -Skip 1) ; linenumber = $q.lineNumber }
    }



    if(!((Get-TypeData -TypeName 'match.range').defaultDisplayPropertySet)) # basicly ignores errors if instance contaians previous runs, due to Update-typedata being picky
    {
        $TypeData = @{
            TypeName = 'match.range' #refere to object by it's type name
            DefaultDisplayPropertySet = 'match','value'
        }
        Update-TypeData @TypeData
    }

  return  $TextRange
}