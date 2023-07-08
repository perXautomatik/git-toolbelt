$jsonBase = @{}
$list = New-Object System.Collections.ArrayList

$list.Add(@{"Name"="John";"Surname"="Smith";"OnSubscription"=$true;})
$list.Add(@{"Name"="Daniel";"Surname"="Cray";"OnSubscription"=$false;})
$list.Add(@{"Name"="James";"Surname"="Reed";"OnSubscription"=$true;})
$list.Add(@{"Name"="Jack";"Surname"="York";"OnSubscription"=$false;})

$customers = @{"Customers"=$list;}

$jsonBase.Add("Data",$customers)
$jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\customers.json"