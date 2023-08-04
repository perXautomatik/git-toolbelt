$jsonBase = @{}
$list = New-Object System.Collections.ArrayList
$list = "apples","pears","oranges","strawberries"
$basket = @{"Basket"=$list;}
$customer = @{"Name"="John";"Surname"="Smith";"OnSubscription"=$true;}

$jsonBase.Add("Data",$basket)
$jsonBase.Add("Customer",$customer)
$jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\basket.json"