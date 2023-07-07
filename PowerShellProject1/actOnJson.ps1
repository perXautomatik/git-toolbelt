$jsonx = "C:\Users\chris\OneDrive\Desktop\cluster-windows.json"

$json = [ordered]@{}


(Get-Content $jsonx -Raw | ConvertFrom-Json).PSObject.Properties |
    ForEach-Object { $json[$_.Name] = $_.Value }



$json.SyncRoot


