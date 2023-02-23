function consume-LsTree
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTree
        )
        process {
            $blobType = $_.substring(7,4)
            $hashStartPos = 12
            $relativePathStartPos = 53

            if ($blobType -ne 'blob')
                {
                $hashStartPos+=2
                $relativePathStartPos+=2
                } 

            [pscustomobject]@{unkown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     
     } 
}

$codeBlock = {  (git ls-tree -r HEAD  | consume-LsTree  | Select-Object -Property *,@{Name = 'absolute'; Expression = {
               $agressor = [regex]::escape('\')
               $replacement = $agressor+'\d{3}'+$agressor+'\d{3}'
       
       
                    $rp =  $_.relativePath.Trim('"')
                
                    $q = Resolve-Path $rp -ErrorAction SilentlyContinue  ; 
                 
                    if(!($q) -and $rp -match ($replacement ))
                    { 
                       $q = Resolve-Path  (($rp -split($replacement) ) -join('*')) 
                    }

                    return $q     
     } } | Select-Object -Property *,@{Name = 'FileName'; Expression = {$path = $_.absolute;$filename = [System.IO.Path]::GetFileNameWithoutExtension("$path");if(!($filename)) { $filename = [System.IO.Path]::GetFileName("$path") };$filename}},@{Name = 'Parent'; Expression = {Split-Path -Path $_.relativePath}}
) }

Push-Location

cd 'D:\Project Shelf\PowerShellProjectFolder\scripts'

    $repo1 = &$codeblock
  

cd 'D:\Project Shelf\PowerShellProjectFolder'

    $repo2 = &$codeblock

$repo1 | select -First 1



$KeyDelegate = [System.Func[Object,string]] {$args[0].FileName}
$resultDelegate = [System.Func[Object,Object,Object]]{ #outPutDefenition
                    param ($x,$y);
                    
                    New-Object -TypeName PSObject -Property @{
                    Hash = $x.hash;
                    AbsoluteX = $x.absolute;
                    AbsoluteY = $y.absolute
                    }
                }
$resultDelegate = [System.Func[Object,Object,string]] { '{0} x_x {1}' -f $args[0].absolute, $args[1].absolute }


$linqJoinedDataset = [System.Linq.Enumerable]::Join( $repo1, $repo2, #tableReference
        
                                                     $KeyDelegate,$KeyDelegate, #onClause
                
                                                     $resultDelegate
)
$OutputArray = [System.Linq.Enumerable]::ToArray($linqJoinedDataset)

#$OutputArray


$HashDelegate = [system.Func[Object,String]] { $args[0].hash }
$ElementDelegate = [system.Func[Object]] { $args[0] }
$lookup = [system.Linq.Enumerable]::ToLookup($repo1, $HashDelegate,$ElementDelegate)

[Linq.Enumerable]::ToArray($lookup)
# Keys in the Lookup are string lengths per the given delegate


Pop-Location