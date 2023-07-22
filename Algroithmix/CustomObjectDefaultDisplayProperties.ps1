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