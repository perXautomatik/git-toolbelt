$jsonBase = @{}
$list = New-Object System.Collections.ArrayList
$list.Add("Foo")
$list.Add("Bar")
$jsonBase.Add("Data",$list)
$jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\write-list.json"