#loadDependensies

Set-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
. .\Forks\0cc040af9e7d768f13c998cde8dc414d\temporary-directory.ps1
. .\Forks\7ca47b54d66abde42192471c53bbadcd\checking-for-null.ps1
. .\Forks\fa4261bf1ff6e47734c2af4ec8c1f6a5\set-Encoding.ps1


function GitCommitEach{

    param
    (
    
    [Parameter(ValueFromPipeline=$true)]
    $params
    )
   try{  
    if ($params.count -gt 0) {
    
        $folderPath = New-TemporaryDirectory
        Set-Location $folderpath
        
        git init

        #$params | %{
        For ($i=0; $i -lt $params.length; $i++){
        $file = $params[$i]
        #$file = $_
        $tempName = "dest.txt"
        
        $destFileName = Join-Path -Path $folderPath -ChildPath $tempName
    
            If( Test-Path -Path $file )
            {
            
                Copy-Item $file -Destination $destFileName -Force 
                $fileMeta = (Get-ChildItem $file)      
                git add $tempName

                $message = $fileMeta.Name + " "                 
                $message = $message + $fileMeta.CreationTime  + " "
                $message = $message + $fileMeta.LastWriteTime  + " "
                $message = $message + $fileMeta.Parent + " " 
                git commit -m $message 
                try{
                $hash = ""
                $hash =  (Get-FileHash $file).hash
                $hash = "$hash"      
                
                git tag -a $hash -m $i
                }
                catch
                {
                 $hash
                    $hash.GetType().Name
                }
                
            }
            else {
                "error" 
                $file
            }
        }
            
    }
        else {
            
            $params.count
            $params.length
            $params.GetType().Name

            "emptyParams"
        
            $params[0];
        "<>"
            $params[1]
        "<>"
            $params
        }

        }
        catch
        {
            $e 
            $file
        }

        finally {        ii $folderPath}

    


    
}

SetEncoding("UTF8")

$csv = get-content -path "D:\Project Shelf\PowerShellProjectFolder\git\GeneralSourceCompare\fileList.txt" #-raw

GitCommitEach($csv)


