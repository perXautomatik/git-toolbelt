#source: https://www.cyberdrain.com/monitoring-with-powershell-monitoring-disk-speed/

$diskSpdPath = "C:\Windows\Temp\diskspd.exe"
if($diskSpdNotPresent)
{
    $DownloadURL = "https://example.com/diskspd.exe"
    Invoke-WebRequest -Uri $DownloadURL -OutFile $diskSpdPath
}

$ReadTest = & $diskSpdPath  -b128K -d30 -o32 -t1 -W0 -S -w0 -c50M test.dat
$Writetest = & $diskSpdPath -b128K -d30 -o32 -t1 -W0 -S -w100 -Z128K -c50M test.dat
$ReadResults = $readtest[-8] | convertfrom-csv -Delimiter "|" -Header Bytes,IO,Mib,IOPS,File | Select-Object IO,MIB,IOPs
$writeResults = $writetest[-1] | convertfrom-csv -Delimiter "|" -Header Bytes,IO,Mib,IOPS,File | Select-Object IO,MIB,IOPS
