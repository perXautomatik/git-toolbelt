
####################################################################################
####################################################################################

#Open website
$webSite = Invoke-WebRequest -Uri https://www.one-tab.com/page/L_ZxBFaBSeWyO5eh9icKBA

#Find table in the website
$tableHeader = $webSite.AllElements | Where-Object {$_.tagname -eq 'div'}
$tableData = $webSite.AllElements | Where-Object {$_.tagname -eq 'a'}

#$tableHeader
#Table header and data
$thead = $tableHeader.innerText #[0..(($tableHeader.innerText.count/2) - 1)]
$tdata = $tableData.href

#$tableHeader | % {echo 'ZzZ';$_;echo 'xXx';$_.innerText[0..(($_.innerText.count/2) - 1)]echo 'QqQ';$_.innerText}

#Break table data into smaller chuck of data.
$dataResult = New-Object System.Collections.ArrayList
for ($i = 0; $i -le $tdata.count; $i+= ($thead.count - 1))
{
    if ($tdata.count -eq $i)
    {
        break
    }        
    $group = $i + ($thead.count - 1)
    [void]$dataResult.Add($tdata[$i..$group])
    $i++
}

#Html data into powershell table format
$finalResult = @()
foreach ($data in $dataResult)
{
    $newObject = New-Object psobject
    for ($i = 0; $i -le ($thead.count - 1); $i++) {
        if($thead[$i])
        {
            $newObject | Add-Member -Name $thead[$i] -MemberType NoteProperty -value $data[$i] -ErrorAction SilentlyContinue
        }
    }
    $finalResult += $newObject
}
$finalResult | select name,value # ft -AutoSize


