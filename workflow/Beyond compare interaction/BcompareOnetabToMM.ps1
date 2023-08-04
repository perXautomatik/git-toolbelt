$url = 'https://www.one-tab.com/page/L_ZxBFaBSeWyO5eh9icKBA'

$tempEmpty = New-TemporaryFile #should stay empty

$htmlCasting = [System.IO.Path]::ChangeExtension((New-TemporaryFile).fullname ,".html")
$htmlCasting

$outputPath =  New-TemporaryFile #retain till session ends

cmd /C "C:\Program Files\Beyond Compare 4\BComp.exe" $url $tempEmpty.FullName


$tempEmpty, $htmlCasting, $outputPath | % { Remove-Item $_.FullName -Force }

 
 



#cmd /C "C:\Program Files\Beyond Compare 4\BComp.com" /automerge /mergeoutput=$outputPath.fullname $url $tempEmpty.FullName

Get-Content $outputPath.FullName


cmd /C "C:\Program Files\Beyond Compare 4\BComp.exe"  /qc /iu /K  $url "file2.c" 