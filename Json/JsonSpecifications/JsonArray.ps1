$jsonBase = @{}

$array = @{}

$data = @{"Name"="Matt";"Colour"="Black";}

$array.Add("Person",$data)

$jsonBase.Add("Data",$array)
$jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\write-array.json"