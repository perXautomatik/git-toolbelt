cd 'D:\Project Shelf\PowerShellProjectFolder\scripts'



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


function Git-TranslateRelative
{
    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$relativePath

        )
        begin {
               
            $agressor = [regex]::escape('\')

            $replacement = $agressor+'\d{3}'+$agressor+'\d{3}'
        }
        process {
                $rp =  $_.relativePath.Trim('"')
                
                $q = Resolve-Path -Verbose $rp -ErrorAction SilentlyContinue  ; 
                 
                if(!($q) -and $rp -match ($replacement ))
                { 
                   $q = Resolve-Path  (($rp -split($replacement) ) -join('*')) 
                }

                return $q     
            }                                         
}


#git ls-tree -r HEAD  | consume-LsTree | Git-TranslateRelative



$u = (git ls-tree -r HEAD  | consume-LsTree )  #| Add-Member -type ScriptProperty -name TranslatePath -value { Git-TranslateRelative -relativePath $this.relativePath -inPath $pwd } -PassThru )
$u | Select-Object -Property *,@{Name = 'TranslatePath'; Expression = {
           $agressor = [regex]::escape('\')
           $replacement = $agressor+'\d{3}'+$agressor+'\d{3}'
       
       
                $rp =  $_.relativePath.Trim('"')
                
                $q = Resolve-Path $rp -ErrorAction SilentlyContinue  ; 
                 
                if(!($q) -and $rp -match ($replacement ))
                { 
                   $q = Resolve-Path  (($rp -split($replacement) ) -join('*')) 
                }

                return $q     
 } }

