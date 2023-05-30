
function TokenizeCode($c)
{

$errors = $null

[system.management.automation.psparser]::Tokenize($c,[ref]$errors) 

}

function Remove-AliasFromCommand ($b) {


Get-Alias |

 Select-Object name, definition |

 Foreach-object -begin {$a = @{} } -process { $a.add($_.name,$_.definition)} -end {}


TokenizeCode $b  | ?{ $_.type -eq “command” }  | %{
 if($a.($_.Content)) 
 { $b = $b -replace $_.Content, $a.($_.Content) } }
 
 $b  
#; 
}

function TokenizeHistory 
{
#Remove-AliasFromCommand -b "gps | fl *"
$count = @{}

$fileLines = get-content 'C:\Users\crbk01\appdata\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt'
$line = '';


$fileLines |
  %{
    $line = $_
    $i = 0;
    $tokenz = @($line | %{TokenizeCode $_ } )

    $tokenz | 
    %{
         $content = $_.content;
          $type = $_.type ;  
          $start = '';
          $onlyContent = @()
          $innerINdex = 0 
          $currentPos = $i++;

         if ($type -eq “command” )
         {            
            
            $subRangeFromHere = $tokenz[$currentPos..$tokenz.Count]                  


            $nextCommandPos = $subRangeFromHere | %{ $innerINdex++; $_ } | %{ if( $_.type -eq “command”) { $innerIndex } } | select -first 1 
            if ( $nextCommandPos -gt $currentPos )
            {
            $tokenz[$currentPos..$nextCommandPos+1] | % {$onlyContent += $_.content}        

            $content = $onlyContent -join '¤'
            }



         }
         #else  {  }
 
         $count[$content]++
 
    }
 }

$count.GetEnumerator() | Sort value -Descending

 }


 function TypesOfTokens 
 {

 $countZ = @{}

$fileLinesq = get-content 'C:\Users\crbk01\appdata\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt'



$fileLinesq |
  %{
    $lineq = $_
    $i = 0;
    $tokenza = @($lineq | %{TokenizeCode $_ } )
    
    $tokenza | %{
     $typeQ = $_.type
     $contentQ = $_.content
     $inner = @{}

     if($countZ.item($typeQ))
     {
      $countZ.item($typeQ)[$contentQ]++     
     }
     else
     {
     $inner[$contentQ]++     
     $countZ.Add($typeQ,$inner)
     }
     
     

     #$content = $_.content; $inner = @{} ; $inner.add($type,$content) ; $count[$inner]++ 
     }
    
    }

$countZ.GetEnumerator() | Sort value -Descending

}


function TokenizeHistory2
{
#Remove-AliasFromCommand -b "gps | fl *"
$count = @{}

$fileLines = get-content 'C:\Users\crbk01\appdata\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt'
$line = '';


$fileLines |
  %{
    $lineT = $_
    $i = 0;
    $tokenz = @($lineT | %{TokenizeCode $_ } )

    $tokenz | 
    %{
         $content = $_.content;
          $type = $_.type ;  
          $start = '';
          $onlyContent = @()
          $innerINdex = 0 
          $currentPos = $i++;

         if ($type -eq “command” )
         {            
            
            $subRangeFromHere = $tokenz[$currentPos..$tokenz.Count]                  
            $start = $_.startColumn -1
            $nextCommandPos = $subRangeFromHere | %{ $innerINdex++; $_ } | %{ if( $_.type -eq “command”) { $_.endColumn } } | select -first 1 
            

            if ( $nextCommandPos -gt $_.endColumn )
            {
            $end = ($nextCommandPos-$start)
                      
            $content = $lineT.substring($start,$end)
            }
            else
            {
            $content = $lineT.substring($start)
            }
         }
         else  { $content = "[$type]$content"  }
 
         $count[$content]++
 
        }
     }

    $count.GetEnumerator() | Sort value -Descending

 }



$fileLines = get-content 'C:\Users\crbk01\appdata\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt'
#$line = ''; fileLines | select -last 2 | %{ $line = $_ ; $i = 0; $tokenz = @($line | %{TokenizeCode $_ } ) ; $tokenz }

TokenizeHistory2 

