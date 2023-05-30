#source https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-pscustomobject?view=powershell-7.3

#legacy

$defaultDisplaySet = 'Name','Language'
$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
$MyObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

#slicker

$q = [PSCustomObject]@{
        PSTypeName = 'match.range' #give the object a type name
        match="a" ; value="b" ; linenumber = 1 }

    $TypeData = @{
    TypeName = 'match.range' #refere to object by it's type name
    DefaultDisplayPropertySet = 'match','value'}

    $q


# also convinent, asign script propertie to all object of same type name

$typedata = @{
    TypeName = 'match.range' # not PstypeName...
    MemberType = 'ScriptProperty'
    MemberName = 'UpperCaseName'
    Value = {$this.value.toUpper()}
}

Update-TypeData @TypeData

$q.UpperCaseName

function abc(){
    param( [PSTypeName('match.range')]$Data ) # throws validation error if not correct type name
    
        $data.UpperCaseName
    }

abc -Data $q