cd (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
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
        cd $folderpath
        
        git init

        #$params | %{
        For ($i=0; $i -lt $params.length; $i++){
        $file = $params[$i]
        #$file = $_
    
            If( Test-Path -Path $file )
            {
            
                Copy-Item $file -Destination $folderPath -Force
                $fileMeta = (Get-ChildItem $file)      
                git add $fileMeta.Name

                $message = $fileMeta.FullName + " " 
                $message = $message + $fileMeta.CreationTime  + " "
                $message = $message + $fileMeta.LastWriteTime
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

$csv = get-content -path "D:\Project Shelf\PowerShellProjectFolder\Todo\GeneralSourceCompare\fileList.txt" #-raw
#$csv = import-csv "D:\Project Shelf\PowerShellProjectFolder\Todo\GeneralSourceCompare\fileList.txt"
#$csv | %{ Test-Path -Path  $_ } 
GitCommitEach($csv)

#$csv | %{If( Test-Path -Path $_ ){$_}} 

