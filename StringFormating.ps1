#soure:https://stackoverflow.com/questions/48270462/creating-a-custom-powershell-object-from-csv-input

$availableValues = Import-Csv $csvfile | Select-Object @{n='value';e={
    'id={0},name={1},surname={2},age={3}' -f $_.id, $_.name, $_.surname, $_.age
}}, @{n='displayName';e={$_.name}}, description